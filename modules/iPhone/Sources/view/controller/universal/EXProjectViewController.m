//
//  EXProjectViewController~iPad.m
//  Appery
//
//  Created by Sergey Seroshtan on 22.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXProjectViewController.h"

#import "MainCommandQueue.h"
#import "MBProgressHUD.h"
#import "IIViewDeckController.h"
#import "EXProjectsMetadataViewController.h"

#pragma mark - UI constants
static const CGFloat kLeftViewWidth = 270;
static const CGFloat kCenterViewLedge = 50;

static const CGFloat kStatusBarHeight = 20;
static const CGFloat kNavigationBarHeight = 44;


@interface EXProjectViewController () <EXProjectsObserver>

@property (nonatomic, retain) EXProjectMetadata *_projectMetadata;
@property (nonatomic, retain) UINavigationController *projectNavigationController;

@end

@implementation EXProjectViewController

#pragma mark - Lifecycle
- (id) initWithProjectMetadata: (EXProjectMetadata *)projectMetadata {
    self = [super init];
    if (self) {
        _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
        self.title = projectMetadata == nil ? [self defaultTitle] : projectMetadata.name;
        self._projectMetadata = projectMetadata;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.projectsMetadataViewController addProjectsObserver: self];
    [self attachSlideViewController];
}

- (void) viewDidDisappear: (BOOL)animated {
    [super viewDidDisappear: animated];

    [self.projectsMetadataViewController removeProjectsObserver: self];
    [self detachSlideViewController];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:)
            name:UIDeviceOrientationDidChangeNotification object:nil];
        
    [self configureNavigationBar];
}

- (void) dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public interface implementation
- (void) loadProjectsMetadata {
    [self.projectsMetadataViewController loadProjectsMetadataCompletion:^(BOOL succeeded) {
        if ([self.title isEqualToString:[self defaultTitle]]) {
            [self.viewDeckController openLeftViewAnimated:YES];
        }
    }];
}

- (NSString *)defaultWebResourceFolder {
    return [[NSBundle mainBundle] pathForResource:@"www" ofType:@""];
}

#pragma mark - EXProjectsObserver protocol implementation
- (void) projectMetadataWasSelected: (EXProjectMetadata *)projectMetadata {
    [self loadProjectForMetadata: projectMetadata];
}

- (void) logoutCompleted {
    [self.viewDeckController closeLeftViewAnimated:NO];
    self.viewDeckController.leftController = nil;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - iOS 5 rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - iOS 6 rotation
- (BOOL) shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
    
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Private interface implementation
- (NSString *)defaultTitle {
    return NSLocalizedString(@"Select project", @"Project view controller | Default title");
}

- (void) configureNavigationBar {
    
    UIBarButtonItem *projectsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"]
            style: UIBarButtonItemStylePlain target: self action: @selector(showProjectsViewController)];

    UIBarButtonItem *reloadProjectButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reload"]
           style: UIBarButtonItemStylePlain target:self action:@selector(reloadProject)];

    self.navigationItem.leftBarButtonItem = projectsButton;
    self.navigationItem.rightBarButtonItem = reloadProjectButton;
}

- (void) showProjectsViewController {
    [self.viewDeckController toggleLeftViewAnimated:YES];
}

- (void) reloadProject {
    if (self._projectMetadata) {
        [self loadProjectForMetadata: self._projectMetadata];
    } else {
        NSString *infoTitle = NSLocalizedString(@"Info", @"Title for Info alert");
        NSString *infoCancelButtonTitle = NSLocalizedString(@"Ok", @"Info alert cancel button");
        NSString *infoMessage = 
                NSLocalizedString(@"No one project was loaded. Please select some project from Projects menu.",
                                  @"Info message if was attemt to reload project if it was not loaded");
        UIAlertView *infoAlert = [[UIAlertView alloc] initWithTitle: infoTitle message: infoMessage
                delegate: nil cancelButtonTitle: infoCancelButtonTitle otherButtonTitles: nil];
        [infoAlert show];
    }
}

- (void) loadProjectForMetadata: (EXProjectMetadata *)projectMetadata {
    NSAssert(projectMetadata != nil, @"projectMetadata is not defined");
    [self.viewDeckController closeLeftViewAnimated:YES];
    
    UIView *rootView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo: rootView animated: YES];
    progressHud.labelText = NSLocalizedString(@"Loading project", @"Loading project progress hud title");

    NSAssert(self.apperyService != nil, @"apperyService property is not defined");
    [self.apperyService loadProjectForMetadata: projectMetadata
        succeed:^(NSString *projectLocation, NSString *startPageName) {
            [progressHud hide: NO];
            EXProjectViewController *projectViewController = [[EXProjectViewController alloc]
                    initWithProjectMetadata: projectMetadata];
            projectViewController.apperyService = self.apperyService;
            projectViewController.projectsMetadataViewController = self.projectsMetadataViewController;
            projectViewController.wwwFolderName = projectLocation;
            projectViewController.startPage = startPageName;
            
            NSMutableArray *controllers = [NSMutableArray arrayWithArray: self.navigationController.viewControllers];
            [controllers removeLastObject];
            [controllers addObject: projectViewController];
            
            [self.navigationController setViewControllers: controllers animated: NO];
            
        } failed:^(NSError *error) {
            [progressHud hide: NO];
            NSString *errorTitle = NSLocalizedString(@"Failed", @"Title for Failed alert");
            NSString *errorCancelButtonTitle = NSLocalizedString(@"Ok", @"Failed alert cancel button");
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle: errorTitle
                    message: [error localizedDescription] delegate: nil
                    cancelButtonTitle: errorCancelButtonTitle otherButtonTitles: nil];
            [errorAlert show];
            NSLog(@"Project loading failed due to: %@", [error localizedDescription]);
        }
     ];
}

- (void) didRotate:(NSNotification *)notification {
    self.viewDeckController.leftSize = [self calculateLeftViewSize];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        // ETST-14908 fix
        CGSize screen = [[UIScreen mainScreen] bounds].size;
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIDeviceOrientationIsPortrait(orientation)) {
            self.view.frame = CGRectMake(0, 0, screen.width, screen.height - kStatusBarHeight - kNavigationBarHeight);
        } else {
            self.view.frame = CGRectMake(0, 0, screen.height, screen.width - kStatusBarHeight - kNavigationBarHeight);
        }
    }
}

- (CGFloat)calculateLeftViewSize {
    CGFloat centerViewLedge = self.view.bounds.size.width > kLeftViewWidth ? 0 : kCenterViewLedge;
    return self.view.bounds.size.width - kLeftViewWidth + centerViewLedge;
}

- (void)attachSlideViewController {
    self.viewDeckController.leftController = self.projectsMetadataViewController;
    self.viewDeckController.leftSize = [self calculateLeftViewSize];
    if ([self.wwwFolderName isEqualToString:[self defaultWebResourceFolder]]) {
        [self.viewDeckController openLeftViewAnimated:YES];
    }
}

- (void)detachSlideViewController {
    [self.viewDeckController closeLeftView];
    self.viewDeckController.leftController = nil;
}

@end
