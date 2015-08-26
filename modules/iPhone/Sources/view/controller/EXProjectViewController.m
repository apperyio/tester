//
//  EXProjectViewController.m
//  Appery
//
//  Created by Sergey Seroshtan on 22.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXProjectViewController.h"

#import "MBProgressHUD.h"
#import "IIViewDeckController.h"

#import "EXUserSettingsStorage.h"
#import "EXCredentialsManager.h"

#import "EXProjectsMetadataViewController.h"
#import "NSObject+Utils.h"

#pragma mark - UI constants

static const CGFloat kLeftViewWidth = 270;
static const CGFloat kCenterViewLedge = 50;

static const CGFloat kStatusBarHeight = 20;
static const CGFloat kNavigationBarHeight = 44;

static NSString *const kDefaultWebResourceFolder = @"www";

@interface EXProjectViewController ()

@property (nonatomic, retain) EXProjectMetadata *projectMetadata;
@property (nonatomic, copy) NSString *appCode;
@property (nonatomic, assign) BOOL isShare;


@end

@implementation EXProjectViewController

@synthesize apperyService = _apperyService;
@synthesize slideController = _slideController;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self attachSlideViewController];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [self detachSlideViewController];
}

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
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
    [self configureNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Public interface implementation

- (void) updateContent {
    [self reloadProject];
}

#pragma mark - Private interface implementation

- (NSString *)defaultTitle {
    return NSLocalizedString(@"Select app", @"App view controller | Default title");
}

- (void) configureNavigationBar {
    UIBarButtonItem *projectsButton = nil;
    
    if (self.appCode.length > 0) {
        projectsButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(back)];
    }
    else {
        projectsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(showProjectsViewController)];
    }
    
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
    if (self.slideController != nil) {
        [self.viewDeckController toggleLeftViewAnimated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
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
                                              pvc.slideController = self.slideController;
                                              if (self.slideController != nil) {
                                                  UINavigationController *nc = [self.slideController as:[UINavigationController class]];
                                                  if (nc.viewControllers.count > 0) {
                                                      EXProjectsMetadataViewController *pmvc = [nc.viewControllers[0] as:[EXProjectsMetadataViewController class]];
                                                      pmvc.delegate = pvc;
                                                  }
                                              }

                                              
                                              NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                                              [controllers removeLastObject];
                                              [controllers addObject:pvc];
                                              
                                              [self.navigationController setViewControllers: controllers animated: NO];
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
    
    if (self.slideController != nil) {
        [self.viewDeckController closeLeftViewAnimated:YES];
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
                    pvc.slideController = self.slideController;
                    if (self.slideController != nil) {
                        UINavigationController *nc = [self.slideController as:[UINavigationController class]];
                        if (nc.viewControllers.count > 0) {
                            EXProjectsMetadataViewController *pmvc = [nc.viewControllers[0] as:[EXProjectsMetadataViewController class]];
                            pmvc.delegate = pvc;
                        }
                    }
                
                    NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                    [controllers removeLastObject];
                    [controllers addObject:pvc];
                    
                    [self.navigationController setViewControllers:controllers animated:NO];
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

- (void)didRotate:(NSNotification *)notification {
    self.viewDeckController.leftSize = [self calculateLeftViewSize];

    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        // ETST-14908 fix
        CGSize screen = [[UIScreen mainScreen] bounds].size;
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIDeviceOrientationIsPortrait(orientation)) {
            self.view.frame = CGRectMake(0, 0, screen.width, screen.height - kStatusBarHeight - kNavigationBarHeight);
        }
        else {
            self.view.frame = CGRectMake(0, 0, screen.height, screen.width - kStatusBarHeight - kNavigationBarHeight);
        }
    }
}

- (CGFloat)calculateLeftViewSize {
    CGFloat centerViewLedge = self.view.bounds.size.width > kLeftViewWidth ? 0 : kCenterViewLedge;
    return self.view.bounds.size.width - kLeftViewWidth + centerViewLedge;
}

- (void)attachSlideViewController {
    if (self.slideController != nil) {
        self.viewDeckController.leftController = self.slideController;
        self.viewDeckController.leftSize = [self calculateLeftViewSize];
        
        if ([self.wwwFolderName isEqualToString:kDefaultWebResourceFolder]) {
            [self.viewDeckController openLeftViewAnimated:YES];
        }
    }
}

- (void)detachSlideViewController {
    [self.viewDeckController closeLeftView];
    self.viewDeckController.leftController = nil;
}

#pragma mark - EXProjectControllerActionDelegate

- (void)masterControllerDidLogout {
    [self.viewDeckController closeLeftViewAnimated:NO];
    self.viewDeckController.leftController = nil;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)masterControllerDidLoadMetadata:(EXProjectMetadata *)metadata {
    [self loadProjectForMetadata:metadata];
}

@end
