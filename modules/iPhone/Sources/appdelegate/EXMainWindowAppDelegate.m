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
- (BOOL)autoLogin;
- (BOOL)updateBaseUrl;
- (void)registerDefaultsFromSettingsBundle;

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
    [manager pushRootViewController:signIn animated:NO completionBlock:nil];
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
    else {
        [manager pushRootViewController:pmvc animated:NO completionBlock:nil];
    }
}

#pragma mark - UIApplicationDelegate protocol - Monitoring Application State Changes

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *baseURL = [standardUserDefaults objectForKey:@"baseURL"];
    if (!baseURL) {
        [self registerDefaultsFromSettingsBundle];
    }
    
    NSError  *error = nil;
    NSArray  *directoriesInDomain = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsFolderPath = [directoriesInDomain objectAtIndex:0];
    NSString *projectsLocation    = [NSString pathWithComponents:@[documentsFolderPath, @"projects"]];
    
    // Create projects location directory if it's needed
    if (![[NSFileManager defaultManager] fileExistsAtPath:projectsLocation]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:projectsLocation withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    [self addSkipBackupAttributeToItemAtPath:projectsLocation];
    [self createAndConfigureApperyService];
    
    // Auto login
    EXUserSettingsStorage *usStorage = [EXUserSettingsStorage sharedUserSettingsStorage];
    EXUserSettings *lastUserSettings = [usStorage retreiveLastStoredSettings];
    NSString *userName = lastUserSettings.userName;
    NSString *password = [SSKeychain passwordForService:APPERI_SERVICE account:userName];
    if ([self autoLogin] && userName && password) {
        [self navigateToProjectsViewController];
    } else
    {
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
    [MBProgressHUD hideAllHUDsForView:self.window.rootViewController.view animated:NO];
    [self.apperyService cancelAllOperation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // When user change base url we must go to SignIn page
    if ([self updateBaseUrl]) {
        [self navigateToSignInViewController];
        return;
    }
    
    // Auto login
    EXUserSettingsStorage *usStorage = [EXUserSettingsStorage sharedUserSettingsStorage];
    EXUserSettings *lastUserSettings = [usStorage retreiveLastStoredSettings];
    NSString *userName = lastUserSettings.userName;
    NSString *password = [SSKeychain passwordForService:APPERI_SERVICE account:userName];
    if ([self autoLogin] && userName && password) {
        [EXMainWindowAppDelegate mainWindow].userInteractionEnabled = NO;
        [self.apperyService loginWithUsername:userName password:password succeed:^(NSArray *projectsMetadata) {
            NSLog(@"Auto login was success");
            dispatch_async(dispatch_get_main_queue(), ^{
                [EXMainWindowAppDelegate mainWindow].userInteractionEnabled = YES;
            });
        } failed:^(NSError *error) {
            NSLog(@"Auto login faile with error: %@", [error localizedDescription]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [EXMainWindowAppDelegate mainWindow].userInteractionEnabled = YES;
            });
        }];
    }
    else {
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
    
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"baseURL"];
    self.apperyService = [[EXApperyService alloc] init];
    self.apperyService.baseUrl = baseUrl;
    
    NSLog(@"Appery service base URL: %@", baseUrl);
}

- (BOOL)autoLogin
{
    BOOL autoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"autoLogin"];
    NSLog(@"Auto login is turn %@", autoLogin ? @"on" : @"off");
    
    return autoLogin;
}

- (BOOL)updateBaseUrl
{
    NSString *oldBaseUrl = self.apperyService.baseUrl;
    self.apperyService.baseUrl = [[NSUserDefaults standardUserDefaults] valueForKey:@"baseURL"];
    
    return ![self.apperyService.baseUrl isEqualToString:oldBaseUrl];
}

#pragma mark - NSUserDefaults

- (void)registerDefaultsFromSettingsBundle
{
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for (NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if (key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}

@end
