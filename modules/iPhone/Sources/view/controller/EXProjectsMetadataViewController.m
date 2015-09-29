//
//  EXProjectsViewController.m
//  Appery
//
//  Created by Sergey Seroshtan on 30.07.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXProjectsMetadataViewController.h"

#import <Cordova/CDVViewController.h>

#import "MBProgressHUD.h"

#import "EXCredentialsManager.h"
#import "EXUserSettingsStorage.h"
#import "EXProjectMetadataCell.h"
#import "EXSelectViewController.h"
#import "EXProjectViewController.h"

#import "EXToolbarItem.h"
#import "EXToolbarItemActionDelegate.h"

#import "EXMainWindowAppDelegate.h"
#import "RootViewControllerManager.h"
#import "NSObject+Utils.h"
#import "EXAppCodeController.h"

#pragma mark - UI string constants

static const NSString * kArrowUpSymbol = @"\u2191";
static const NSString * kArrowDownSymbol = @"\u2193";

#pragma mark - Private interface declaration

@interface EXProjectsMetadataViewController () <EXToolbarItemActionDelegate>

@property (nonatomic, strong, readwrite) EXApperyService *apperyService;

/// @name UI properties
@property (nonatomic, weak) IBOutlet UITableView *rootTableView;

@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

/// Handles all projects metadata.
@property (nonatomic, strong) NSArray *projectsMetadata;

/// Handles filtered projects metadata.
@property (nonatomic, strong) NSMutableArray *filteredProjectsMetadata;

/// Contains projects observers list.
@property (nonatomic, strong) NSMutableArray *projectsObservers;

/// Handles view controller for folder selection.
@property (nonatomic, strong) EXSelectViewController *selectFolderController;

/// Current selected folder name.
@property (nonatomic, strong) NSString *currentFolder;

/// Current selected sorting method for projects metadata.
@property (nonatomic, assign) EXSortingMethodType currentProjectsSortingMethod;

/// Defines wheter KVO is registered.
@property (nonatomic, assign) BOOL isObservingRegistered;

@property (nonatomic, strong) NSArray *folders;

@property (nonatomic, strong) NSArray *toolbarActualItems;

@property (nonatomic, strong) EXAppCodeController *appCodeController;

@property (nonatomic, strong) NSIndexPath *selectedItemPath;

/// @name UI actions
- (void)logoutAction:(id)sender;

- (void)reloadProjects;
/**
 * Initialize Projects Metadata
 */
- (void)initializeProjectsMetadata:(NSArray *)projectsMetadata;

/**
 * Perform logout process.
 */
- (void) logoutFromService;

- (void)loadProjectsMetadataCompletion:(EXProjectsMetadataViewControllerCompletionBlock)completion;

- (void)sortMetadataArray:(NSMutableArray *)metadata withMethod:(EXSortingMethodType)sortMethod;
- (void)setupNameSortMethod;
- (void)setupCreationDateSortMethod;
- (void)setupModificationDateSortMethod;
- (void)setupCreatorUserSortMethod;
- (void)sortByCurrentMethodAndUpdateUI;

@end

#pragma mark - Public interface implementation

@implementation EXProjectsMetadataViewController

@synthesize currentProjectsSortingMethod = _currentProjectsSortingMethod;

#pragma mark - Life cycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil service:(EXApperyService *)service projectsMetadata:(NSArray *)metadata {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self == nil) {
        return nil;
    }
    
    _apperyService = service;
    _projectsObservers = [[NSMutableArray alloc] init];
    _filteredProjectsMetadata = [[NSMutableArray alloc] init];
    _selectFolderController = [[EXSelectViewController alloc] initWithTitle:NSLocalizedString(@"Folders", @"Folders")];
    _currentProjectsSortingMethod = EXSortingMethodType_DateDescending;
    if (metadata.count > 0) {
        [self initializeProjectsMetadata:metadata];
    }
    
    self.preferredContentSize = CGSizeMake(320., 480.);
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil service:nil projectsMetadata:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.rootTableView registerNib:[UINib nibWithNibName:@"EXProjectMetadataCell" bundle:nil] forCellReuseIdentifier:kEXProjectMetadataCell];
    self.rootTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.rootTableView.separatorColor = [UIColor clearColor];
    
    [self configureToolbar];
    if (self.projectsMetadata.count == 0) {
        [self loadProjectsMetadataCompletion:^(BOOL succeeded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.rootTableView.userInteractionEnabled = YES;
                [self.refreshControl endRefreshing];
                [self sortByCurrentMethodAndUpdateUI];
            });
        }];
    }
    else {
        [self sortByCurrentMethodAndUpdateUI];
    }
    
    self.title = NSLocalizedString(@"My apps", @"EXProjectsViewController title");
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading apps"];
    [refreshControl addTarget:self action: @selector(reloadProjects) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.rootTableView addSubview:self.refreshControl];
    
    UIBarButtonItem *bbLogout = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logout"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(logoutAction:)];
    self.navigationItem.leftBarButtonItem = bbLogout;
    
    UIBarButtonItem *bbAppCode = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"App code", @"App code")
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(appCodeAction:)];
    UIFont *bbFont = [UIFont systemFontOfSize:16];
    NSDictionary * attributes = @{NSFontAttributeName:bbFont};
    [bbAppCode setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = bbAppCode;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect viewRect = self.view.frame;
    
    CGRect frm = self.toolBar.frame;
    frm.size.width = viewRect.size.width;
    self.toolBar.frame = frm;
}

#pragma mark - UI actions

- (void)reloadProjects {
    void(^reloadProjectsInfo)(void) = ^{
        [self loadProjectsMetadataCompletion:^(BOOL succeeded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.rootTableView.userInteractionEnabled = YES;
                [self.refreshControl endRefreshing];
            });
        }];
    };
    
    if(self.apperyService.isLoggedOut) {
        self.rootTableView.userInteractionEnabled = NO;
        
        EXUserSettingsStorage *usStorage = [EXUserSettingsStorage sharedUserSettingsStorage];
        EXUserSettings *lastUserSettings = [usStorage retreiveLastStoredSettings];
        NSString *password = [EXCredentialsManager retreivePasswordForUser: lastUserSettings.userName];
        
        [self.apperyService loginWithUsername:lastUserSettings.userName password:password succeed:^(NSArray *projectsMetadata) {
            reloadProjectsInfo();
        } failed:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.rootTableView.userInteractionEnabled = YES;
                
                [self.apperyService quickLogout];
                id<EXProjectControllerActionDelegate> del = self.delegate;
                if (del != nil) {
                    [del masterControllerDidLogout];
                }
                else {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            });
        }];
    }
    else {
        reloadProjectsInfo();
    }
}

- (void)logoutAction:(id)sender {
    #pragma unused(sender)
    _currentProjectsSortingMethod = EXSortingMethodType_DateDescending;
    [self logoutFromService];
}

- (void)appCodeAction:(id)sender {
    #pragma unused(sender)
    self.appCodeController = [[EXAppCodeController alloc] init];
    [self.appCodeController requestCodeWithCompletionHandler:^(NSString *appCode) {
        if (self.selectedItemPath != nil) {
            [self.rootTableView deselectRowAtIndexPath:self.selectedItemPath animated:YES];
            self.selectedItemPath = nil;
        }
        id<EXProjectControllerActionDelegate> del = self.delegate;
        if (del != nil) {
            [del masterControllerDidAcquireAppCode:appCode];
        }
        else {
            EXProjectViewController *pvc = [[EXProjectViewController alloc] initWithService:self.apperyService projectCode:appCode];
            pvc.wwwFolderName = @"www";
            pvc.startPage = @"index.html";
            
            [self.navigationController pushViewController:pvc animated:YES];
            [pvc updateContent];            
        }
        self.appCodeController = nil;
    }];
}

#pragma mark - UITableViewDataSource protocol implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredProjectsMetadata != nil ? self.filteredProjectsMetadata.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(self.filteredProjectsMetadata != nil, @"No data to feed EXProjectsViewController");
    NSAssert(indexPath.row < self.filteredProjectsMetadata.count , @"No data for the specified indexPath");
    
    EXProjectMetadata* projectMetadata = [self.filteredProjectsMetadata objectAtIndex:indexPath.row];
    EXProjectMetadataCell* cell = [tableView dequeueReusableCellWithIdentifier:kEXProjectMetadataCell];
    if (cell == nil) {
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UNEXPECTED_CELL"];
    }
    [cell updateWithMetadata:projectMetadata];
    return cell;
}

#pragma mark - UITableViewDelegete protocol implementation

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [EXProjectMetadataCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(indexPath.row < self.filteredProjectsMetadata.count , @"No data for the specified indexPath");
    
    EXProjectMetadata *projectMetadata = [self.filteredProjectsMetadata objectAtIndex: indexPath.row];
    id<EXProjectControllerActionDelegate> del = self.delegate;
    if (del != nil) {
        self.selectedItemPath = indexPath;
        [del masterControllerDidLoadMetadata:projectMetadata];
    }
    else {
        EXProjectViewController *pvc = [[EXProjectViewController alloc] initWithService:self.apperyService projectMetadata:projectMetadata];
        pvc.wwwFolderName = @"www";
        pvc.startPage = @"index.html";
        
        [pvc updateContent];
        [self.navigationController pushViewController:pvc animated:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Private

#pragma mark - Configuration helpers

- (void)configureToolbar {
    NSMutableArray *actualTBItems = [NSMutableArray array];
    
    EXToolbarItem *name = [[EXToolbarItem alloc] initWithImageName:@"name" activeImageName:@"name_b" title:NSLocalizedString(@"Name", @"Name")];
    name.delegate = self;
    name.tag = [self tagBySortMethod:EXSortingMethodType_NameAscending];
    [actualTBItems addObject:name];
    UIBarButtonItem *bbName = [[UIBarButtonItem alloc] initWithCustomView:name];
    
    UIBarButtonItem *flex1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    EXToolbarItem *date = [[EXToolbarItem alloc] initWithImageName:@"date" activeImageName:@"date_b" title:NSLocalizedString(@"Created", @"Create")];
    date.delegate = self;
    date.tag = [self tagBySortMethod:EXSortingMethodType_DateDescending];
    [actualTBItems addObject:date];
    UIBarButtonItem *bbDate = [[UIBarButtonItem alloc] initWithCustomView:date];
    
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    EXToolbarItem *mod = [[EXToolbarItem alloc] initWithImageName:@"modified" activeImageName:@"modified_b" title:NSLocalizedString(@"Modified", @"Modified")];
    mod.delegate = self;
    mod.tag = [self tagBySortMethod:EXSortingMethodType_ModificationdDescending];
    [actualTBItems addObject:mod];
    UIBarButtonItem *bbMod = [[UIBarButtonItem alloc] initWithCustomView:mod];
    
    UIBarButtonItem *flex3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    EXToolbarItem *user = [[EXToolbarItem alloc] initWithImageName:@"user" activeImageName:@"user_b" title:NSLocalizedString(@"User", @"User")];
    user.delegate = self;
    user.tag = [self tagBySortMethod:EXSortingMethodType_CreatorAscending];
    [actualTBItems addObject:user];
    UIBarButtonItem *bbUser = [[UIBarButtonItem alloc] initWithCustomView:user];
    
    [self.toolBar setItems:@[ bbName, flex1, bbDate, flex2, bbMod, flex3, bbUser ] animated:NO];
    self.toolbarActualItems = actualTBItems;
}

- (void)deactivateToolbarItems {
    for (EXToolbarItem *item in self.toolbarActualItems) {
        [item setStateToActive:NO];
    }
}

- (void)initializeProjectsMetadata:(NSArray *)projectsMetadata {
    NSArray *enabledProjectsMetadata = [self getEnabledProjectsMetadata:projectsMetadata];
    self.projectsMetadata = enabledProjectsMetadata;
    [self.filteredProjectsMetadata removeAllObjects];
    [self.filteredProjectsMetadata addObjectsFromArray:enabledProjectsMetadata];
    [self redefineAvailableFolders];
    [self configureSelectFolderViewController];
    [self sortByCurrentMethodAndUpdateUI];
}

- (void)loadProjectsMetadataCompletion:(EXProjectsMetadataViewControllerCompletionBlock)completion {
    NSAssert(self.apperyService != nil, @"apperyService property is not defined");
    
    [self.apperyService loadProjectsMetadata: ^(NSArray *projectsMetadata) {
        [self initializeProjectsMetadata:projectsMetadata];
        
        if (completion) {
            completion(YES);
        }
    } failed:^(NSError *error) {
        DLog(@"Apps loading failed due to: %@", error.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle: error.localizedDescription
                                        message: error.localizedRecoverySuggestion
                                       delegate: nil
                              cancelButtonTitle: NSLocalizedString(@"Ok", nil)
                              otherButtonTitles: nil] show];
            
        });
        
        if (completion) {
            completion(NO);
        }
    }];
}

- (void)logoutFromService {
    UIView *rootView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo: rootView animated: YES];
    progressHud.labelText = NSLocalizedString(@"Logout", @"Logout progress hud title");
    
    void(^finalize)(void)  = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressHud hide: YES];
            id<EXProjectControllerActionDelegate> del = self.delegate;
            if (del != nil) {
                [del masterControllerDidLogout];
            }
            else {
                [[EXMainWindowAppDelegate appDelegate] navigateToStartPage];
            }
        });
    };
    
    [self.apperyService logoutSucceed: ^{
        finalize();
    } failed:^(NSError *error) {
        DLog(@"Error was occured during remote logout operation. Details: %@", [error localizedDescription]);
        finalize();
    }];
}

#pragma mark - UI helpers

- (void)redefineAvailableFolders {
    NSArray *availableFolders = [self.projectsMetadata valueForKeyPath:@"@distinctUnionOfObjects.creator"];
    NSString *allFolderName = NSLocalizedString(@"All", @"Apps list | Toolbar | Folder button possible value");
    self.folders = [[NSArray arrayWithObject:allFolderName] arrayByAddingObjectsFromArray:availableFolders];
    self.currentFolder = allFolderName;
}

- (void)configureSelectFolderViewController {
    self.selectFolderController.data = self.folders;
    [self.selectFolderController updateUI];
    self.selectFolderController.completion = nil;
}

#pragma mark - Projects sorting / filtering

- (void)setCurrentProjectsSortingMethod:(EXSortingMethodType) type {
    _currentProjectsSortingMethod = type;
    
    EXUserSettingsStorage *usStorage = [EXUserSettingsStorage sharedUserSettingsStorage];
    EXUserSettings *lastUserSettings = [usStorage retreiveLastStoredSettings];
    
    if (lastUserSettings) {
        lastUserSettings.sortMethodType = type;
        [usStorage storeSettings:lastUserSettings];
    }
}

- (EXSortingMethodType)currentProjectsSortingMethod {
    EXUserSettingsStorage *usStorage = [EXUserSettingsStorage sharedUserSettingsStorage];
    EXUserSettings *lastUserSettings = [usStorage retreiveLastStoredSettings];
    
    if (lastUserSettings) {
        _currentProjectsSortingMethod = lastUserSettings.sortMethodType;
    }
    
    return _currentProjectsSortingMethod;
}

- (NSArray *)getEnabledProjectsMetadata:(NSArray *)projectsMetadata {
    NSPredicate *enabledProjectsPredicate = [NSPredicate predicateWithFormat:@"disabled == %@", @0];
    return [projectsMetadata filteredArrayUsingPredicate:enabledProjectsPredicate];
}

- (void)sortMetadataArray:(NSMutableArray *)metadata withMethod:(EXSortingMethodType)sortMethod {
    [metadata sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        EXProjectMetadata *first = [obj1 as:[EXProjectMetadata class]];
        EXProjectMetadata *second = [obj2 as:[EXProjectMetadata class]];
        
        NSComparisonResult order = NSOrderedSame;
        switch (sortMethod) {
            case EXSortingMethodType_NameAscending:
                order = [first.name localizedCaseInsensitiveCompare:second.name];
                break;
            case EXSortingMethodType_NameDescending:
                order = [second.name localizedCaseInsensitiveCompare:first.name];
                break;
            case EXSortingMethodType_DateAscending:
                order = [first.creationDate compare:second.creationDate];
                break;
            case EXSortingMethodType_DateDescending:
                order = [second.creationDate compare:first.creationDate];
                break;
            case EXSortingMethodType_ModificationAscending:
                order = [first.modifiedDate compare:second.modifiedDate];
                break;
            case EXSortingMethodType_ModificationdDescending:
                order = [second.modifiedDate compare:first.modifiedDate];
                break;
            case EXSortingMethodType_CreatorAscending:
                order = [first.creator localizedCaseInsensitiveCompare:second.creator];
                break;
            case EXSortingMethodType_CreatorDescending:
                order = [second.creator localizedCaseInsensitiveCompare:first.creator];
                break;
            default:
                break;
        }
        
        return order;
    }];
}

- (void)setupNameSortMethod {
    switch (self.currentProjectsSortingMethod) {
        case EXSortingMethodType_NameAscending:
            self.currentProjectsSortingMethod = EXSortingMethodType_NameDescending;
            break;
        default:
            self.currentProjectsSortingMethod = EXSortingMethodType_NameAscending;
            break;
    }
}

- (void)setupCreationDateSortMethod {
    switch (self.currentProjectsSortingMethod) {
        case EXSortingMethodType_DateDescending:
            self.currentProjectsSortingMethod = EXSortingMethodType_DateAscending;
            break;
        default:
            self.currentProjectsSortingMethod = EXSortingMethodType_DateDescending;
            break;
    }
}

- (void)setupModificationDateSortMethod {
    switch (self.currentProjectsSortingMethod) {
        case EXSortingMethodType_ModificationdDescending:
            self.currentProjectsSortingMethod = EXSortingMethodType_ModificationAscending;
            break;
        default:
            self.currentProjectsSortingMethod = EXSortingMethodType_ModificationdDescending;
            break;
    }
}

- (void)setupCreatorUserSortMethod {
    switch (self.currentProjectsSortingMethod) {
        case EXSortingMethodType_CreatorAscending:
            self.currentProjectsSortingMethod = EXSortingMethodType_CreatorDescending;
            break;
        default:
            self.currentProjectsSortingMethod = EXSortingMethodType_CreatorAscending;
            break;
    }
}

- (void)sortByCurrentMethodAndUpdateUI {
    MBProgressHUD *localHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [localHud setLabelText:NSLocalizedString(@"Sorting...", @"Sorting...")];
    
    [self deactivateToolbarItems];
    EXToolbarItem *actualItem = [self.toolbarActualItems[[self tagBySortMethod:self.currentProjectsSortingMethod]] as:[EXToolbarItem class]];
    [actualItem setStateToActive:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sortMetadataArray:self.filteredProjectsMetadata withMethod:self.currentProjectsSortingMethod];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rootTableView reloadData];
            [localHud hide:YES];
        });
    });
}

- (NSInteger)tagBySortMethod:(EXSortingMethodType)method {
    NSInteger tag = -1;
    switch (method) {
        case EXSortingMethodType_NameAscending:
        case EXSortingMethodType_NameDescending:
            tag = 0;
            break;
        case EXSortingMethodType_DateAscending:
        case EXSortingMethodType_DateDescending:
            tag = 1;
            break;
        case EXSortingMethodType_ModificationAscending:
        case EXSortingMethodType_ModificationdDescending:
            tag = 2;
            break;
        case EXSortingMethodType_CreatorAscending:
        case EXSortingMethodType_CreatorDescending:
            tag = 3;
            break;
        default:
            break;
    }
    return tag;
}

- (NSInteger)tagByCurrentSortMethod {
    return [self tagBySortMethod:self.currentProjectsSortingMethod];
}

- (void)setCurrentSortMethodByTag:(NSInteger)tag {
    switch (tag) {
        case 0:
            [self setupNameSortMethod];
            break;
        case 1:
            [self setupCreationDateSortMethod];
            break;
        case 2:
            [self setupModificationDateSortMethod];
            break;
        case 3:
            [self setupCreatorUserSortMethod];
            break;
        default:
            break;
    }
}

#pragma mark - EXToolbarItemActionDelegate 

- (void)didActivateToolbarItem:(EXToolbarItem *)item {
    [self setCurrentSortMethodByTag:item.tag];
    [self sortByCurrentMethodAndUpdateUI];
}

@end
