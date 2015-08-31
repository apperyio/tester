//
//  EXProjectViewController.m
//  Appery
//
//  Created by Sergey Seroshtan on 22.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXProjectViewController.h"

#import "MBProgressHUD.h"
#import "EXUserSettingsStorage.h"
#import "EXCredentialsManager.h"

#import "EXProjectsMetadataViewController.h"
#import "NSObject+Utils.h"

#import "EXMainWindowAppDelegate.h"
#import "RootViewControllerManager.h"

#pragma mark - UI constants

static NSString *const kDefaultWebResourceFolder = @"www";

@interface EXProjectViewController ()

@property (nonatomic, retain) EXProjectMetadata *projectMetadata;
@property (nonatomic, copy) NSString *appCode;
@property (nonatomic, assign) BOOL isShare;


@end

@implementation EXProjectViewController

@synthesize apperyService = _apperyService;
@synthesize projectMetadata = _projectMetadata;
@synthesize appCode = _appCode;
@synthesize isShare = _isShare;

#pragma mark - Lifecycle

- (instancetype)initWithService:(EXApperyService *)service projectMetadata:(EXProjectMetadata *)projectMetadata {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _apperyService = service;
    _projectMetadata = projectMetadata;
    _isShare = NO;
    return self;
}

- (instancetype)initWithService:(EXApperyService *)service projectCode:(NSString *)projectCode {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _apperyService = service;
    _appCode = projectCode;
    _isShare = YES;
    return self;
}

#pragma mark - View management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *title = nil;
    if (self.projectMetadata != nil) {
        title = self.projectMetadata.name;
    }
    else if (self.appCode.length > 0) {
        title = self.appCode;
    }
    self.title = (title.length == 0) ? [self defaultTitle] : title;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self configureNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#warning Need to show sidebar somehow.
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    
//    [[RootViewControllerManager sharedInstance] showSidebarController:nil animated:YES completionBlock:nil];
//}

#pragma mark - Public interface implementation

- (void) updateContent {
    [self reloadProject];
}

#pragma mark - Private interface implementation

- (NSString *)defaultTitle {
    return NSLocalizedString(@"App Preview", @"App view controller | Default title");
}

- (void) configureNavigationBar {
    UIBarButtonItem *projectsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(showProjectsViewController)];
    UIBarButtonItem *reloadProjectButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reload"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(reloadProject)];

    self.navigationItem.leftBarButtonItem = projectsButton;
    self.navigationItem.rightBarButtonItem = reloadProjectButton;
}

- (void) back {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showProjectsViewController {
    RootViewControllerManager *manager = [RootViewControllerManager sharedInstance];
    UIViewController *sideController = [manager topSidebarController];
    if (sideController != nil) {
        [manager toggleSidebarControllerAnimated:YES completionBlock:nil];
    }
    else {
        if ([self.navigationController.viewControllers count] <= 1) {
            [self masterControllerDidLogout];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)reloadProject {
    if (self.isShare && self.appCode.length > 0) {
        [self loadProjectForAppCode:self.appCode];
        return;
    }
    
    if (self.projectMetadata != nil) {
        [self loadProjectForMetadata:self.projectMetadata];
        return;
    }

    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", nil)
                                message:NSLocalizedString(@"Please select an app from the app list", nil)
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                      otherButtonTitles:nil] show];
}

- (void)loadProjectForAppCode:(NSString *)appCode {
    if (appCode.length == 0) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Application code is not given.", @"Application code is not given.")
                                    message:NSLocalizedString(@"There is no application code to load the project.", @"There is no application code to load the project.")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                          otherButtonTitles:nil] show];
        return;
    }
    
    if ([[RootViewControllerManager sharedInstance] isSidebarShown]) {
        [[RootViewControllerManager sharedInstance] hideSidebarControllerAnimated:YES completionBlock:nil];
    }
    
    UIView *rootView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo: rootView animated: YES];
    progressHud.labelText = NSLocalizedString(@"Loading app", @"Loading app progress hud title");
    
    __weak EXApperyService *weakService = self.apperyService;
    [self.apperyService loadProjectForAppCode:appCode
                                      succeed:^(NSString *projectLocation, NSString *startPageName) {
                                          DLog(@"The project for code: '%@' has been loaded.", appCode);
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              EXApperyService *strongService = weakService;
                                              [progressHud hide:NO];
                                              EXProjectViewController *pvc = [[EXProjectViewController alloc] initWithService:strongService projectCode:appCode];
                                              pvc.wwwFolderName = projectLocation;
                                              pvc.startPage = startPageName;
                                              
                                              RootViewControllerManager *manager = [RootViewControllerManager sharedInstance];
                                              EXProjectsMetadataViewController *pmvc = [[manager topSidebarController] as:[EXProjectsMetadataViewController class]];
                                              pmvc.delegate = pvc;
                                              
                                              NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                                              [viewControllers removeLastObject];
                                              [viewControllers addObject:pvc];
                                              
                                              [self.navigationController setViewControllers:viewControllers animated:NO];
                                          });
                                        } failed:^(NSError *error) {
                                            DLog(@"The project for code: '%@' has NOT been loaded. Error: %@.", appCode, [error localizedDescription]);
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [progressHud hide:NO];
                                                [[[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                                            message:error.localizedRecoverySuggestion
                                                                           delegate:nil
                                                                  cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                                                  otherButtonTitles:nil] show];
                                            });
                                        }
     ];
}

- (void)loadProjectForMetadata:(EXProjectMetadata *)projectMetadata {
    if (projectMetadata == nil) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Project's metadata is not given.", @"Project's metadata is not given.")
                                    message:NSLocalizedString(@"There is no project's metadata to load the project.", @"There is no project's metadata to load the project.")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                          otherButtonTitles:nil] show];
        return;
    }
    
    if ([[RootViewControllerManager sharedInstance] isSidebarShown]) {
        [[RootViewControllerManager sharedInstance] hideSidebarControllerAnimated:YES completionBlock:nil];
    }
    
    UIView *rootView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo: rootView animated: YES];
    progressHud.labelText = NSLocalizedString(@"Loading app", @"Loading app progress hud title");
    
    __weak EXApperyService *weakService = self.apperyService;
    void(^reloadProject)(void) = ^{
        [self.apperyService loadProjectForMetadata:projectMetadata
            succeed:^(NSString *projectLocation, NSString *startPageName) {
                DLog(@"The project with name '%@' has been loaded.", projectMetadata.name);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressHud hide: NO];
                    EXApperyService *strongService = weakService;
                    EXProjectViewController *pvc = [[EXProjectViewController alloc] initWithService:strongService projectMetadata:projectMetadata];
                    pvc.wwwFolderName = projectLocation;
                    pvc.startPage = startPageName;
                    
                    RootViewControllerManager *manager = [RootViewControllerManager sharedInstance];
                    EXProjectsMetadataViewController *pmvc = [[manager topSidebarController] as:[EXProjectsMetadataViewController class]];
                    pmvc.delegate = pvc;
                    
                    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                    [viewControllers removeLastObject];
                    [viewControllers addObject:pvc];
                    
                    [self.navigationController setViewControllers:viewControllers animated:NO];
                });
            } failed:^(NSError *error) {
                DLog(@"The project with name: '%@' has NOT been loaded. Error: %@.", projectMetadata.name, error.localizedDescription);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressHud hide: NO];
                    
                    [[[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                message:error.localizedRecoverySuggestion
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                      otherButtonTitles:nil] show];
                });
            }
         ];
    };
    
    if (self.apperyService.isLoggedOut) {
        EXUserSettingsStorage *usStorage = [EXUserSettingsStorage sharedUserSettingsStorage];
        EXUserSettings *lastUserSettings = [usStorage retreiveLastStoredSettings];
        NSString *password = [EXCredentialsManager retreivePasswordForUser: lastUserSettings.userName];
        
        [self.apperyService loginWithUsername:lastUserSettings.userName password:password succeed:^(NSArray *projectsMetadata) {
            reloadProject();
        } failed:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [progressHud hide: NO];
                EXApperyService *strongService = weakService;
                [strongService quickLogout];
                [self masterControllerDidLogout];
            });
        }];
    }
    else {
        reloadProject();
    }
}


#pragma mark - EXProjectControllerActionDelegate

- (void)masterControllerDidLogout {
    [[EXMainWindowAppDelegate appDelegate] navigateToStartPage];
}

- (void)masterControllerDidLoadMetadata:(EXProjectMetadata *)metadata {
    [self loadProjectForMetadata:metadata];
}

- (void)masterControllerDidAcquireAppCode:(NSString *)appCode {
    [self loadProjectForAppCode:appCode];
}

@end
