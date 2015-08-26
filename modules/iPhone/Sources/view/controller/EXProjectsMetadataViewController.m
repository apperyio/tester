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

#pragma mark - UI string constants

static const NSString * kArrowUpSymbol = @"\u2191";
static const NSString * kArrowDownSymbol = @"\u2193";

#pragma mark - Private interface declaration

@interface EXProjectsMetadataViewController ()

@property (nonatomic, strong, readwrite) EXApperyService *apperyService;

/// @name UI properties
@property (nonatomic, weak) IBOutlet UITableView *rootTableView;

@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *sortByDateButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *sortByNameButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *folderButton;
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

@property (nonatomic, strong) NSArray* folders;

/**
 * @returns reusable custom UITableViewCell object.
 */
- (EXProjectMetadataCell *) getCustomTableViewCell;

/// @name UI actions
- (IBAction)logoutButtonPressed:(id)sender;
- (IBAction)sortByDateButtonPressed:(id)sender;
- (IBAction)sortByNameButtonPressed:(id)sender;
- (IBAction)selectFolderButtonPressed:(id)sender;

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

@end

#pragma mark - Public interface implementation

@implementation EXProjectsMetadataViewController

@synthesize apperyService = _apperyService;
@synthesize delegate = _delegate;

@synthesize rootTableView = _rootTableView;
@synthesize navigationBar = _navigationBar;
@synthesize toolBar = _toolBar;
@synthesize sortByDateButton = _sortByDateButton;
@synthesize sortByNameButton = _sortByNameButton;
@synthesize folderButton = _folderButton;
@synthesize refreshControl = _refreshControl;

@synthesize projectsMetadata = _projectsMetadata;
@synthesize filteredProjectsMetadata = _filteredProjectsMetadata;
@synthesize projectsObservers = _projectsObservers;
@synthesize selectFolderController = _selectFolderController;
@synthesize currentFolder = _currentFolder;
@synthesize currentProjectsSortingMethod = _currentProjectsSortingMethod;
@synthesize isObservingRegistered = _isObservingRegistered;
@synthesize folders = _folders;

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
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil service:nil projectsMetadata:nil];
}

- (void)viewDidLoad {
    [self registerRotationObserving];
    [super viewDidLoad];
    
    [self configureToolbar];
    if (self.projectsMetadata.count == 0) {
        [self loadProjectsMetadataCompletion:^(BOOL succeeded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.rootTableView.userInteractionEnabled = YES;
                [self.refreshControl endRefreshing];
                [self sortProjectsByCurrentSortingMethod];
            });
        }];
    }
    else {
        [self sortProjectsByCurrentSortingMethod];
    }
    
    self.title = NSLocalizedString(@"Apps", @"EXProjectsViewController title");
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading apps"];
    [refreshControl addTarget:self action: @selector(reloadProjects) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.rootTableView addSubview:self.refreshControl];
    
    UIBarButtonItem *bbLogout = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logout"] style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonPressed:)];
    self.navigationItem.leftBarButtonItem = bbLogout;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
    [self unregisterRotationObserving];
    [super didReceiveMemoryWarning];
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

- (IBAction)logoutButtonPressed:(id)sender {
    _currentProjectsSortingMethod = EXSortingMethodType_DateDescending;
    [self logoutFromService];
}

- (IBAction)sortByDateButtonPressed:(id)sender {
    [self reverseSortProjectsByDate];
}

- (IBAction)sortByNameButtonPressed:(id)sender {
    [self reverseSortProjectsByName];
}

- (IBAction)selectFolderButtonPressed:(id)sender {
    self.selectFolderController.selection = self.currentFolder;
    [self.selectFolderController updateUI];
    
    __weak EXProjectsMetadataViewController *weakSelf = self;
    
    self.selectFolderController.completion = ^(BOOL success, id selection) {
        EXProjectsMetadataViewController *strongSelf = weakSelf;
        if (success) {
            NSString *(^getFolderButtonTitle)(void) = ^{
                if ([selection length] > 7) {
                    NSRange stringRange = {0, MIN([selection length], 7)};
                    stringRange = [selection rangeOfComposedCharacterSequencesForRange:stringRange];
                    NSString *shortString = [selection substringWithRange:stringRange];
                    return [shortString stringByAppendingString:@"..."];
                }
                return (NSString *)selection;
            };
            
            strongSelf.folderButton.title = getFolderButtonTitle();
            strongSelf.currentFolder = selection;
            [strongSelf filterProjectsWithOwner:selection];
        }
        
        strongSelf.navigationBar.userInteractionEnabled = YES;
        strongSelf.rootTableView.userInteractionEnabled = YES;
        strongSelf.toolBar.userInteractionEnabled = YES;
        [strongSelf hideSelectFolderView];
    };
    
    self.navigationBar.userInteractionEnabled = NO;
    self.rootTableView.userInteractionEnabled = NO;
    self.toolBar.userInteractionEnabled = NO;
    
    [self showSelectFolderView];
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
    
    EXProjectMetadata *projectMetadata = [self.filteredProjectsMetadata objectAtIndex:indexPath.row];
    EXProjectMetadataCell *cell = [self getCustomTableViewCell];
    cell.projectNameLabel.text = projectMetadata.name;
    cell.authorLabel.text = projectMetadata.creator;
    cell.modificationDateLabel.text = projectMetadata.formattedModifiedDate;
    
    switch ([projectMetadata.type intValue]) {
        case 1:
            [cell.projectTypeIcon setImage:[UIImage imageNamed: @"icon_jqm"]];
            break;
        
        case 7:
            [cell.projectTypeIcon setImage:[UIImage imageNamed: @"icon_bootsrap"]];
            break;
        
        case 8:
            [cell.projectTypeIcon setImage:[UIImage imageNamed: @"icon_ionic"]];
            break;
        
        default:
            break;
    }
    
	return cell;
}

#pragma mark - UITableViewDelegete protocol implementation

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    EXProjectMetadataCell *cell = [self getCustomTableViewCell];
    
    return cell.bounds.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(indexPath.row < self.filteredProjectsMetadata.count , @"No data for the specified indexPath");
    
    EXProjectMetadata *projectMetadata = [self.filteredProjectsMetadata objectAtIndex: indexPath.row];
    id<EXProjectControllerActionDelegate> del = self.delegate;
    if (del != nil) {
        [del masterControllerDidLoadMetadata:projectMetadata];
    }
    else {
        EXProjectViewController *pvc = [[EXProjectViewController alloc] initWithService:self.apperyService projectMetadata:projectMetadata];
        pvc.wwwFolderName = @"www";
        pvc.startPage = @"index.html";
        self.delegate = pvc;
        
        [pvc updateContent];
        [self.navigationController pushViewController:pvc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

#pragma mark - Private

#pragma mark - Configuration helpers

- (void)setSortButtonsDefaultNames {
    self.sortByDateButton.title = NSLocalizedString(@"Date", @"Apps list | Toolbar | Date button");
    self.sortByNameButton.title = NSLocalizedString(@"Name", @"Apps list | Toolbar | Name button");
}

- (void)configureToolbar {
    [self setSortButtonsDefaultNames];
}

- (void)initializeProjectsMetadata:(NSArray *)projectsMetadata {
    NSArray *enabledProjectsMetadata = [self getEnabledProjectsMetadata:projectsMetadata];
    self.projectsMetadata = enabledProjectsMetadata;
    [self.filteredProjectsMetadata removeAllObjects];
    [self.filteredProjectsMetadata addObjectsFromArray:enabledProjectsMetadata];
    [self redefineAvailableFolders];
    [self configureSelectFolderViewController];
    [self sortProjectsByCurrentSortingMethod];
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
                [self.navigationController popToRootViewControllerAnimated:YES];
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

- (EXProjectMetadataCell *)getCustomTableViewCell {
    static NSString *cellIdentifier = @"ProjectMetadataCellIdentifier";
    EXProjectMetadataCell *cell = (EXProjectMetadataCell *)[self.rootTableView dequeueReusableCellWithIdentifier: cellIdentifier];
    
	if(cell == nil) {
		cell = [[EXProjectMetadataCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
	}
    
    return cell;
}

- (void)showSelectFolderView {
    UIView *viewToShow = self.selectFolderController.view;
    
    __block CGRect frame = viewToShow.frame;
    frame.origin.x = 0;
    frame.origin.y = self.view.frame.size.height;
    frame.size.width = self.view.bounds.size.width;
    viewToShow.frame = frame;
    
    if (![self.view.subviews containsObject:viewToShow]) {
        [self.view insertSubview:viewToShow belowSubview:self.toolBar];
    }
    
    [UIView animateWithDuration:0.4f animations:^{
        frame.origin.y = self.view.bounds.size.height - frame.size.height - self.toolBar.bounds.size.height;
        viewToShow.frame = frame;
    }];
}

- (void)hideSelectFolderView {
    UIView *viewToHide = self.selectFolderController.view;
    
    [UIView animateWithDuration:0.4f animations:^{
        CGRect frame = viewToHide.frame;
        frame.origin.y = self.view.frame.size.height;
        viewToHide.frame = frame;
    } completion:^(BOOL finished) {
        [viewToHide removeFromSuperview];
    }];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    if (![self.view.subviews containsObject:self.selectFolderController.view]) {
        return;
    }
    
    UIView *viewToLayout = self.selectFolderController.view;
    
    [UIView animateWithDuration:0.4f animations:^{
        CGRect frame = viewToLayout.frame;
        frame.origin.y = self.view.bounds.size.height - frame.size.height - self.toolBar.bounds.size.height;
        viewToLayout.frame = frame;
    }];
}

- (void)redefineAvailableFolders {
    NSArray *availableFolders = [self.projectsMetadata valueForKeyPath:@"@distinctUnionOfObjects.creator"];
    NSString *allFolderName = NSLocalizedString(@"All", @"Apps list | Toolbar | Folder button possible value");
    self.folders = [[NSArray arrayWithObject:allFolderName] arrayByAddingObjectsFromArray:availableFolders];
    self.folderButton.title = allFolderName;
    self.currentFolder = allFolderName;
}

- (void)configureSelectFolderViewController {
    self.selectFolderController.data = self.folders;
    [self.selectFolderController updateUI];
    self.selectFolderController.completion = nil;
}

- (void)filterProjectsWithOwner:(id)owner {
    [self.filteredProjectsMetadata removeAllObjects];
    
    if ([self.folders indexOfObject:owner] == 0) {
        [self.filteredProjectsMetadata addObjectsFromArray:self.projectsMetadata];
    }
    else {
        NSPredicate *filterByOwnerPredicate = [NSPredicate predicateWithFormat:@"creator like[cd] %@", owner];
        [self.filteredProjectsMetadata addObjectsFromArray:[self.projectsMetadata filteredArrayUsingPredicate:filterByOwnerPredicate]];
    }
    
    [self sortProjectsByCurrentSortingMethod];
}

#pragma mark - KVO

- (void)registerRotationObserving {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.isObservingRegistered = YES;
}

- (void)unregisterRotationObserving {
    if (self.isObservingRegistered) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
        self.isObservingRegistered = NO;
    }
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

- (void)reverseSortProjectsByDate {
    static BOOL ascending = NO;
    
    switch (self.currentProjectsSortingMethod) {
        case EXSortingMethodType_DateAscending:
            ascending = NO;
            break;
        case EXSortingMethodType_DateDescending:
            ascending = YES;
            break;
        default:
            break;
    }
    
    [self sortProjectsByDateAscending:ascending];
}

- (void)sortProjectsByDateAscending:(BOOL)ascending {
    // Sorting
    [self.filteredProjectsMetadata sortUsingComparator: ^NSComparisonResult(id obj1, id obj2) {
        EXProjectMetadata *first = (EXProjectMetadata *)obj1;
        EXProjectMetadata *second = (EXProjectMetadata *)obj2;
        
        return ((ascending) ? [first.modifiedDate compare: second.modifiedDate] : [second.modifiedDate compare: first.modifiedDate]);
    }];
    
    // UI changes
    [self setSortButtonsDefaultNames];
    
    self.sortByDateButton.title = [self.sortByDateButton.title stringByAppendingFormat:@" %@", ascending ? kArrowUpSymbol : kArrowDownSymbol];
    
    self.currentProjectsSortingMethod = ascending ? EXSortingMethodType_DateAscending : EXSortingMethodType_DateDescending;
    
    [self.rootTableView reloadData];
}

- (void)reverseSortProjectsByName {
    static BOOL ascending = NO;
    
    switch (self.currentProjectsSortingMethod) {
        case EXSortingMethodType_NameAscending:
            ascending = NO;
            break;
        case EXSortingMethodType_NameDescending:
            ascending = YES;
            break;
        default:
            break;
    }
    
    [self sortProjectsByNameAscending:ascending];
}

- (void)sortProjectsByNameAscending:(BOOL)ascending {
    // Sorting
    [self.filteredProjectsMetadata sortUsingComparator: ^NSComparisonResult(id obj1, id obj2) {
        EXProjectMetadata *first = (EXProjectMetadata *)obj1;
        EXProjectMetadata *second = (EXProjectMetadata *)obj2;
        
        if (ascending) {
            return [first.name localizedCaseInsensitiveCompare: second.name];
        }
        else {
            return [second.name localizedCaseInsensitiveCompare: first.name];
        }
    }];
    
    // UI changes
    [self setSortButtonsDefaultNames];
    
    self.sortByNameButton.title = [self.sortByNameButton.title stringByAppendingFormat:@" %@", ascending ? kArrowUpSymbol : kArrowDownSymbol];
    
    self.currentProjectsSortingMethod = ascending ? EXSortingMethodType_NameAscending : EXSortingMethodType_NameDescending;
    
    [self.rootTableView reloadData];
}

- (void)sortProjectsByCurrentSortingMethod {
    switch (self.currentProjectsSortingMethod) {
        case EXSortingMethodType_DateAscending:
            [self sortProjectsByDateAscending:YES];
            break;
        case EXSortingMethodType_DateDescending:
            [self sortProjectsByDateAscending:NO];
            break;
        case EXSortingMethodType_NameAscending:
            [self sortProjectsByNameAscending:YES];
            break;
        case EXSortingMethodType_NameDescending:
            [self sortProjectsByNameAscending:NO];
            break;
        default:
            [self reverseSortProjectsByDate];
            break;
    }
}

@end
