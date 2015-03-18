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

#pragma mark - Additional types

typedef enum {
    EXProjectsMetadataSortingMethodType_None = 0,
    EXProjectsMetadataSortingMethodType_DateAscending,
    EXProjectsMetadataSortingMethodType_DateDescending,
    EXProjectsMetadataSortingMethodType_NameAscending,
    EXProjectsMetadataSortingMethodType_NameDescending,
} EXProjectsMetadataSortingMethodType;

#pragma mark - UI string constants

static const NSString * kArrowUpSymbol = @"\u2191";
static const NSString * kArrowDownSymbol = @"\u2193";

#pragma mark - Private interface declaration

@interface EXProjectsMetadataViewController ()

/// Handles all projects metadata.
@property (nonatomic, retain) NSArray *projectsMetadata;


/// Handles filtered projects metadata.
@property (nonatomic, retain) NSMutableArray *filteredProjectsMetadata;


/// Contains projects observers list.
@property (nonatomic, retain) NSMutableArray *projectsObservers;

/// Handles view controller for folder selection.
@property (nonatomic, retain) EXSelectViewController *selectFolderController;

/// Current selected folder name.
@property (nonatomic, retain) NSString *currentFolder;

/// Current selected sorting method for projects metadata.
@property (nonatomic, assign) EXProjectsMetadataSortingMethodType currentProjectsSortingMethod;

/// Defines wheter KVO is registered.
@property (nonatomic, assign) BOOL isObservingRegistered;

/**
 * @returns reusable custom UITableViewCell object.
 */
- (EXProjectMetadataCell *) getCustomTableViewCell;

@property (retain,nonatomic) NSArray* folders;

@end

#pragma mark - Public interface implementation

@implementation EXProjectsMetadataViewController

#pragma mark - Life cycle

- (id) initWithNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.projectsObservers = [[NSMutableArray alloc] init];
        self.filteredProjectsMetadata = [[NSMutableArray alloc] init];
        self.selectFolderController = [[EXSelectViewController alloc] initWithTitle:@"Folders"];
    }
    return self;
}

- (void)viewDidLoad
{
    [self configureNavigationBar];
    [self configureToolbar];
    [self registerRotationObserving];
    
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    [self unregisterRotationObserving];
}

#pragma mark - UI actions

- (void)reloadProjects
{
    self.currentProjectsSortingMethod = EXProjectsMetadataSortingMethodType_None;
    
    void(^reloadProjectsInfo)(void) = ^{
        [self loadProjectsMetadataCompletion:^(BOOL succeeded) {
            self.rootTableView.userInteractionEnabled = YES;
            [self.refreshControl endRefreshing];
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
            self.rootTableView.userInteractionEnabled = YES;
            
            [self.apperyService quickLogout];
            [self fireProjectsObserversLogoutCompleted];
        }];
    } else {
        reloadProjectsInfo();
    }
}

- (IBAction)logoutButtonPressed:(id)sender
{
    self.currentProjectsSortingMethod = EXProjectsMetadataSortingMethodType_None;
    [self logoutFromService];
}

- (IBAction)sortByDateButtonPressed:(id)sender
{
    [self reverseSortProjectsByDate];
}

- (IBAction)sortByNameButtonPressed:(id)sender
{
    [self reverseSortProjectsByName];
}

- (IBAction)selectFolderButtonPressed:(id)sender
{
    self.selectFolderController.selection = self.currentFolder;
    [self.selectFolderController updateUI];
    
    __unsafe_unretained EXProjectsMetadataViewController *weekSelf = self;
    
    self.selectFolderController.completion = ^(BOOL success, id selection) {
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
            
            weekSelf.folderButton.title = getFolderButtonTitle();
            weekSelf.currentFolder = selection;
            [weekSelf filterProjectsWithOwner:selection];
        }
        
        weekSelf.navigationBar.userInteractionEnabled = YES;
        weekSelf.rootTableView.userInteractionEnabled = YES;
        weekSelf.toolBar.userInteractionEnabled = YES;
        [weekSelf hideSelectFolderView];
    };
    
    self.navigationBar.userInteractionEnabled = NO;
    self.rootTableView.userInteractionEnabled = NO;
    self.toolBar.userInteractionEnabled = NO;
    
    [self showSelectFolderView];
}

#pragma mark - Public interface implementation

- (void) addProjectsObserver: (id<EXProjectsObserver>)observer
{
    NSAssert(observer != nil, @"added observer is not defined");

    if (![self.projectsObservers containsObject: observer]) {
        [self.projectsObservers addObject: observer];
    }
}

- (void) removeProjectsObserver: (id<EXProjectsObserver>)observer
{
    NSAssert(observer != nil, @"removed observer is not defined");
    
    [self.projectsObservers removeObject: observer];
}

- (void) initializeProjectsMetadata:(NSArray *) projectsMetadata
{
    NSArray *enabledProjectsMetadata = [self getEnabledProjectsMetadata:projectsMetadata];
    self.projectsMetadata = enabledProjectsMetadata;
    [self.filteredProjectsMetadata removeAllObjects];
    [self.filteredProjectsMetadata addObjectsFromArray:enabledProjectsMetadata];
    [self redefineAvailableFolders];
    [self configureSelectFolderViewController];
    [self reverseSortProjectsByDate];
}

- (void) loadProjectsMetadataCompletion:(EXProjectsMetadataViewControllerCompletionBlock)completion
{
    NSAssert(self.apperyService != nil, @"apperyService property is not defined");
    
    [self.apperyService loadProjectsMetadata: ^(NSArray *projectsMetadata) {
        [self initializeProjectsMetadata:projectsMetadata];

        if (completion) {
            completion(YES);
        }
    } failed:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle: error.localizedDescription
                                 message: error.localizedRecoverySuggestion
                                delegate: nil
                       cancelButtonTitle: NSLocalizedString(@"Ok", nil)
                       otherButtonTitles: nil] show];

        NSLog(@"Projects loading failed due to: %@", error.localizedDescription);

        if (completion) {
            completion(NO);
        }
    }];
}

- (void) logoutFromService
{
    UIView *rootView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo: rootView animated: YES];
    progressHud.labelText = NSLocalizedString(@"Logout", @"Logout progress hud title");
    
    void(^finalize)(void)  = ^{
        [progressHud hide: YES];
        [self fireProjectsObserversLogoutCompleted];
    };
    
    [self.apperyService logoutSucceed: ^{
        finalize();
    } failed:^(NSError *error) {
        NSLog(@"Error was occured during remote logout operation. Details: %@", [error localizedDescription]);
        finalize();
    }];
}

#pragma mark - UITableViewDataSource protocol implementation

- (NSInteger) numberOfSectionsInTableView: (UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
    return self.filteredProjectsMetadata != nil ? self.filteredProjectsMetadata.count : 0;
}

- (UITableViewCell *) tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    NSAssert(self.filteredProjectsMetadata != nil, @"No data to feed EXProjectsViewController");
    NSAssert(indexPath.row < self.filteredProjectsMetadata.count , @"No data for the specified indexPath");
    
    EXProjectMetadata *projectMetadata = [self.filteredProjectsMetadata objectAtIndex: indexPath.row];
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

- (CGFloat) tableView: (UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath
{
    EXProjectMetadataCell *cell = [self getCustomTableViewCell];
    
    return cell.bounds.size.height;
}

- (void) tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    NSAssert(indexPath.row < self.filteredProjectsMetadata.count , @"No data for the specified indexPath");
    
    EXProjectMetadata *projectMetadata = [self.filteredProjectsMetadata objectAtIndex: indexPath.row];
    [self fireProjectsObserversMetadataWasSelected: projectMetadata];
    
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

#pragma mark - Private

#pragma mark - Configuration helpers

- (void)configureNavigationBar
{
    self.title = NSLocalizedString(@"Projects", @"EXProjectsViewController title");
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading projects"];
    [refreshControl addTarget:self action: @selector(reloadProjects) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.rootTableView addSubview:self.refreshControl];
    
    //For ios 7 and later
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        CGRect barFrame = self.navigationBar.frame;
        barFrame.size = CGSizeMake(barFrame.size.width, 64);
        self.navigationBar.frame = barFrame;
    }
}

- (void)setSortButtonsDefaultNames
{
    self.sortByDateButton.title = NSLocalizedString(@"Date", @"Projects list | Toolbar | Date button");
    self.sortByNameButton.title = NSLocalizedString(@"Name", @"Projects list | Toolbar | Name button");
}

- (void)configureToolbar
{
    [self setSortButtonsDefaultNames];
}

#pragma mark - UI helpers

- (EXProjectMetadataCell *) getCustomTableViewCell
{
    static NSString *cellIdentifier = @"ProjectMetadataCellIdentifier";
    EXProjectMetadataCell *cell = (EXProjectMetadataCell *)[self.rootTableView dequeueReusableCellWithIdentifier: cellIdentifier];
    
	if(cell == nil) {
		cell = [[EXProjectMetadataCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
	}
    
    return cell;
}

- (void)showSelectFolderView
{
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

- (void)hideSelectFolderView
{
    UIView *viewToHide = self.selectFolderController.view;
    
    [UIView animateWithDuration:0.4f animations:^{
        CGRect frame = viewToHide.frame;
        frame.origin.y = self.view.frame.size.height;
        viewToHide.frame = frame;
    } completion:^(BOOL finished) {
        [viewToHide removeFromSuperview];
    }];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
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

- (void)redefineAvailableFolders
{
    NSArray *availableFolders = [self.projectsMetadata valueForKeyPath:@"@distinctUnionOfObjects.creator"];
    NSString *allFolderName = NSLocalizedString(@"All", @"Projects list | Toolbar | Folder button possible value");
    self.folders = [[NSArray arrayWithObject:allFolderName] arrayByAddingObjectsFromArray:availableFolders];
    self.folderButton.title = allFolderName;
    self.currentFolder = allFolderName;
}

- (void)configureSelectFolderViewController
{
    self.selectFolderController.data = self.folders;
    [self.selectFolderController updateUI];
    self.selectFolderController.completion = nil;
}

- (void)filterProjectsWithOwner:(id)owner
{
    [self.filteredProjectsMetadata removeAllObjects];
    
    if ([self.folders indexOfObject:owner] == 0) {
        [self.filteredProjectsMetadata addObjectsFromArray:self.projectsMetadata];
    } else {
        NSPredicate *filterByOwnerPredicate = [NSPredicate predicateWithFormat:@"creator like[cd] %@", owner];
        [self.filteredProjectsMetadata addObjectsFromArray:[self.projectsMetadata filteredArrayUsingPredicate:filterByOwnerPredicate]];
    }
    
    [self sortProjectsByCurrentSortingMethod];
}

#pragma mark - KVO

- (void)registerRotationObserving
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.isObservingRegistered = YES;
}

- (void)unregisterRotationObserving
{
    if (self.isObservingRegistered) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
        self.isObservingRegistered = NO;
    }
}

#pragma mark - Observers notification

- (void) fireProjectsObserversMetadataWasSelected: (EXProjectMetadata *) projectMetadata
{
    for (id<EXProjectsObserver> observer in self.projectsObservers) {
        if ([observer respondsToSelector: @selector(projectMetadataWasSelected:)]) {
            [observer projectMetadataWasSelected: projectMetadata];
        }
    }
}

- (void) fireProjectsObserversLogoutCompleted
{
    for (id<EXProjectsObserver> observer in self.projectsObservers) {
        if ([observer respondsToSelector: @selector(logoutCompleted)]) {
            [observer logoutCompleted];
        }
    }
}


#pragma mark - Projects sorting / filtering

- (NSArray *)getEnabledProjectsMetadata:(NSArray *)projectsMetadata
{
    NSPredicate *enabledProjectsPredicate = [NSPredicate predicateWithFormat:@"disabled == %@", @0];
    return [projectsMetadata filteredArrayUsingPredicate:enabledProjectsPredicate];
}

- (void)reverseSortProjectsByDate
{
    static BOOL ascending = NO;
    
    switch (self.currentProjectsSortingMethod) {
        case EXProjectsMetadataSortingMethodType_DateAscending:
            ascending = NO;
            break;
        case EXProjectsMetadataSortingMethodType_DateDescending:
            ascending = YES;
            break;
        default:
            break;
    }
    
    [self sortProjectsByDateAscending:ascending];
}

- (void)sortProjectsByDateAscending:(BOOL)ascending
{
    // Sorting
    [self.filteredProjectsMetadata sortUsingComparator: ^NSComparisonResult(id obj1, id obj2) {
        EXProjectMetadata *first = (EXProjectMetadata *)obj1;
        EXProjectMetadata *second = (EXProjectMetadata *)obj2;
        
        if (ascending) {
            return [first.modifiedDate compare: second.modifiedDate];
        } else {
            return [second.modifiedDate compare: first.modifiedDate];
        }
    }];
    
    // UI changes
    [self setSortButtonsDefaultNames];
    
    self.sortByDateButton.title = [self.sortByDateButton.title stringByAppendingFormat:@" %@",
            ascending ? kArrowUpSymbol : kArrowDownSymbol];
    
    self.currentProjectsSortingMethod = ascending ?
            EXProjectsMetadataSortingMethodType_DateAscending :
            EXProjectsMetadataSortingMethodType_DateDescending;
    
    [self.rootTableView reloadData];
}

- (void)reverseSortProjectsByName
{
    static BOOL ascending = NO;
    switch (self.currentProjectsSortingMethod) {
        case EXProjectsMetadataSortingMethodType_NameAscending:
            ascending = NO;
            break;
        case EXProjectsMetadataSortingMethodType_NameDescending:
            ascending = YES;
            break;
        default:
            break;
    }
    
    [self sortProjectsByNameAscending:ascending];
}

- (void)sortProjectsByNameAscending:(BOOL)ascending
{
    // Sorting
    [self.filteredProjectsMetadata sortUsingComparator: ^NSComparisonResult(id obj1, id obj2) {
        EXProjectMetadata *first = (EXProjectMetadata *)obj1;
        EXProjectMetadata *second = (EXProjectMetadata *)obj2;
        
        if (ascending) {
            return [first.name localizedCaseInsensitiveCompare: second.name];
        } else {
            return [second.name localizedCaseInsensitiveCompare: first.name];
        }
    }];
    
    // UI changes
    [self setSortButtonsDefaultNames];
    
    self.sortByNameButton.title = [self.sortByNameButton.title stringByAppendingFormat:@" %@",
            ascending ? kArrowUpSymbol : kArrowDownSymbol];
    self.currentProjectsSortingMethod = ascending ?
            EXProjectsMetadataSortingMethodType_NameAscending :
            EXProjectsMetadataSortingMethodType_NameDescending;
    
    [self.rootTableView reloadData];
}

- (void)sortProjectsByCurrentSortingMethod
{
    switch (self.currentProjectsSortingMethod) {
        case EXProjectsMetadataSortingMethodType_DateAscending:
            [self sortProjectsByDateAscending:YES];
            break;
        case EXProjectsMetadataSortingMethodType_DateDescending:
            [self sortProjectsByDateAscending:NO];
            break;
        case EXProjectsMetadataSortingMethodType_NameAscending:
            [self sortProjectsByNameAscending:YES];
            break;
        case EXProjectsMetadataSortingMethodType_NameDescending:
            [self sortProjectsByNameAscending:NO];
            break;
        default:
            [self reverseSortProjectsByDate];
            break;
    }
}

@end
