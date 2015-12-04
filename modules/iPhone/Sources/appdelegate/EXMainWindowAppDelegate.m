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
#import "RootViewControllerManager.h"
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
- (void)navigateToStartPage;

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

- (void)navigateToStartPage
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
    
    [self navigateToStartPage];
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
    [self updateBaseUrl];
    [self navigateToStartPage];
}

#pragma mark - Private interface implementation

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString
{
    NSURL* URL = [NSURL fileURLWithPath:filePathString];
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]], @"The project folder does not exist");
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:@YES
                                  forKey:NSURLIsExcludedFromBackupKey error:&error];
    if(!success) {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    
    //for test
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
    self.apperyService.baseUrl = [[NSUserDefaults standardUserDefaults] valueForKey:@"baseURL"];
    
    NSLog(@"Appery service base URL: %@", self.apperyService.baseUrl);
}

- (BOOL)updateBaseUrl
{
    NSString *oldBaseUrl = self.apperyService.baseUrl;
    self.apperyService.baseUrl = [[NSUserDefaults standardUserDefaults] valueForKey:@"baseURL"];
    
    return ![self.apperyService.baseUrl isEqualToString:oldBaseUrl];
}

- (void)hideAllHuds
{
    [MBProgressHUD hideAllHUDsForView: self.window.rootViewController.view animated:NO];
}

- (void)cancelApperyServiceActivity
{
    [self.apperyService cancelAllOperation];
    
    if (self.apperyService.isLoggedIn) {
        [self.apperyService quickLogout];
    }
}

@end
