//
//  EXMainWindowAppDelegate.m
//  Appery
//
//  Created by Sergey Seroshtan on 30.07.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXMainWindowAppDelegate.h"

#import "EXApperyService.h"
#import "EXUserSettingsStorage.h"
#import "EXSignInViewController.h"
#import "EXProjectViewController.h"
#import "EXProjectsMetadataViewController.h"
#import "RootViewControllerManager.h"
#import "SSKeychain.h"
#import "MBProgressHUD.h"
#import "UIColor+hexColor.h"

#pragma mark - Private interface declaration

@interface EXMainWindowAppDelegate ()

@property (nonatomic, strong) EXApperyService *apperyService;

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString;
- (void)createAndConfigureApperyService;
- (BOOL)updateBaseUrl;
- (void)hideAllHuds;
- (void)cancelApperyServiceActivity;

@end

@implementation EXMainWindowAppDelegate

#pragma mark - Public methods

+ (EXMainWindowAppDelegate *)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

+ (UIWindow *)mainWindow
{
    return [[self appDelegate] window];
}

- (void)navigateToSignInViewController
{
    RootViewControllerManager *manager = [RootViewControllerManager sharedInstance];
    
    if (manager.isSidebarShown) {
        __weak RootViewControllerManager *weakManager = manager;
        [manager setSidebarEnabled:NO animated:NO completionBlock:^{
            RootViewControllerManager *blockManager = weakManager;
            [blockManager setSidebarViewController:nil];
        }];
    }
    
    EXSignInViewController *signIn = [[EXSignInViewController alloc] initWithNibName:nil bundle:nil service:self.apperyService];
    [[RootViewControllerManager sharedInstance] pushRootViewController:signIn animated:NO completionBlock:nil];
}

- (void)navigateToProjectsViewController
{
    RootViewControllerManager *manager = [RootViewControllerManager sharedInstance];
    EXProjectsMetadataViewController *pmvc = [[EXProjectsMetadataViewController alloc] initWithNibName:nil bundle:nil service:self.apperyService projectsMetadata:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        EXProjectViewController *pvc = [[EXProjectViewController alloc] initWithService:self.apperyService projectMetadata:nil];
        pvc.wwwFolderName = @"www";
        pvc.startPage = @"index.html";
        pmvc.delegate = pvc;
        
        [manager setSidebarViewController:pmvc];
        [manager setSidebarEnabled:YES];
        __weak RootViewControllerManager *weakManager = manager;
        [manager pushRootViewController:pvc animated:YES completionBlock:^{
            RootViewControllerManager *strongManager = weakManager;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [strongManager showSidebarController:nil animated:YES completionBlock:nil];
            });
        }];
    }
    
    [manager pushRootViewController:pmvc animated:NO completionBlock:nil];
}

#pragma mark - UIApplicationDelegate protocol - Monitoring Application State Changes

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSError  *error = nil;
    NSArray  *directoriesInDomain = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsFolderPath = [directoriesInDomain objectAtIndex: 0];
    NSString *projectsLocation    = [NSString pathWithComponents:@[documentsFolderPath, @"projects"]];
    
    // Create projects location directory if it's needed
    if (![[NSFileManager defaultManager] fileExistsAtPath:projectsLocation]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:projectsLocation withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    [self addSkipBackupAttributeToItemAtPath:projectsLocation];
    [self createAndConfigureApperyService];
    
    EXUserSettingsStorage *usStorage = [EXUserSettingsStorage sharedUserSettingsStorage];
    EXUserSettings *lastUserSettings = [usStorage retreiveLastStoredSettings];
    if (lastUserSettings != nil) {
        NSString *password = [SSKeychain passwordForService:APPERI_SERVICE account:lastUserSettings.userName];
        if (password != nil) {
            [self navigateToProjectsViewController];
        } else {
            [self navigateToSignInViewController];
        }
    } else {
        [self navigateToSignInViewController];
    }
    
    [self.window makeKeyAndVisible];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorFromHEXString:@"#F6F6F6"]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorFromHEXString:@"#4D4D4D"]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:20.], NSForegroundColorAttributeName:[UIColor colorFromHEXString:@"#4D4D4D"] }];
    
    return YES;
}

#pragma mark - UIApplicationDelegate protocol - Responding to System Notifications

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self hideAllHuds];
    [self cancelApperyServiceActivity];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // When user turn off auto login or change base url we must go to SignIn page
    if ([self updateBaseUrl] || ![self autoLogin]) {
        [self navigateToSignInViewController];
    }
}

#pragma mark - Private interface implementation

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString
{
    NSURL *URL = [NSURL fileURLWithPath:filePathString];
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]], @"The project folder does not exist");
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:@YES
                                  forKey:NSURLIsExcludedFromBackupKey error:&error];
    if(!success) {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    
    // For test
    id flag = nil;
    [URL getResourceValue:&flag
                   forKey:NSURLIsExcludedFromBackupKey error:&error];
    NSLog(@"NSURLIsExcludedFromBackupKey flag value is %@", flag);
    
    return success;
}

- (void)createAndConfigureApperyService
{
    NSAssert(self.apperyService == nil, @"self.apperyService is already initialized");
    
    self.apperyService = [[EXApperyService alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *baseUrl = [defaults stringForKey:@"baseURL"];
    self.apperyService.baseUrl = baseUrl;
    NSLog(@"Appery service base URL: %@", baseUrl);
}

- (BOOL)autoLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *autoLogin = [defaults stringForKey:@"autoLogin"];
    NSLog(@"Auto login is turn %@", autoLogin ? @"on" : @"off");
    
    return YES;
}

- (BOOL)updateBaseUrl
{
    NSString *oldBaseUrl = self.apperyService.baseUrl;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.apperyService.baseUrl = [defaults valueForKey:@"baseURL"];
    
    return ![self.apperyService.baseUrl isEqualToString:oldBaseUrl];
}

- (void)hideAllHuds
{
    [MBProgressHUD hideAllHUDsForView:self.window.rootViewController.view animated:NO];
}

- (void)cancelApperyServiceActivity
{
    [self.apperyService cancelAllOperation];
    
    if (self.apperyService.isLoggedIn) {
        [self.apperyService quickLogout];
    }
}

@end
