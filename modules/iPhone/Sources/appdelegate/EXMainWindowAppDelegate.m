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
#import "MBProgressHUD.h"
#import "IIViewDeckController.h"

#import "EXSignInViewController.h"

#pragma mark - Private interface declaration

@interface EXMainWindowAppDelegate ()

@property (nonatomic, strong) EXApperyService *apperyService;
@property (nonatomic, strong) EXSignInViewController *loginViewController;
@property (nonatomic, strong) IIViewDeckController *viewDeckController;

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *) filePathString;
- (void)createAndConfigureApperyService;
- (BOOL)updateBaseUrl;
- (void)hideAllHuds;
- (void)cancelApperyServiceActivity;
- (void)navigateToStartPage;

@end

@implementation EXMainWindowAppDelegate

#pragma mark - UIApplicationDelegate protocol - Monitoring Application State Changes

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSError  *error = nil;
    NSArray  *directoriesInDomain = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsFolderPath = [directoriesInDomain objectAtIndex: 0];
    NSString *projectsLocation    = [NSString pathWithComponents:@[documentsFolderPath, @"projects"]];
    
    // Create projects location directory if it's needed
    if (![[NSFileManager defaultManager] fileExistsAtPath:projectsLocation])
        [[NSFileManager defaultManager] createDirectoryAtPath:projectsLocation withIntermediateDirectories:NO attributes:nil error:&error];
    
    [self addSkipBackupAttributeToItemAtPath:projectsLocation];
    [self createAndConfigureApperyService];
    
    self.loginViewController = [[EXSignInViewController alloc] initWithNibName:nil bundle:nil service:self.apperyService];
    
    UINavigationController *rootNavigationController = [[UINavigationController alloc] initWithRootViewController: self.loginViewController];
    self.viewDeckController = [[IIViewDeckController alloc] initWithCenterViewController:rootNavigationController];
    self.viewDeckController.navigationControllerBehavior = IIViewDeckNavigationControllerContained;
    self.viewDeckController.elastic = NO;
    self.viewDeckController.sizeMode = IIViewDeckLedgeSizeMode;
    
    self.window.rootViewController = self.viewDeckController;
    
    [self.window makeKeyAndVisible];
    
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
    [self navigateToStartPage];
}

#pragma mark - Private interface implementation

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString
{
    NSURL* URL= [NSURL fileURLWithPath: filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool: YES]
                                  forKey:NSURLIsExcludedFromBackupKey error: &error];
    if(!success) {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    
    //for test
    id flag = nil;
    [URL getResourceValue: &flag
                   forKey: NSURLIsExcludedFromBackupKey error: &error];
    NSLog (@"NSURLIsExcludedFromBackupKey flag value is %@", flag);
    
    return success;
}

- (void)createAndConfigureApperyService
{
    NSAssert(self.apperyService == nil, @"self.apperyService is already initialized");
    
    self.apperyService = [[EXApperyService alloc] init];
    self.apperyService.baseUrl = [[NSUserDefaults standardUserDefaults] valueForKey: @"baseURL"];
    
    NSLog(@"Appery service base URL: %@", self.apperyService.baseUrl);
}

- (BOOL)updateBaseUrl
{
    NSString *oldBaseUrl = self.apperyService.baseUrl;
    self.apperyService.baseUrl = [[NSUserDefaults standardUserDefaults] valueForKey: @"baseURL"];
    
    return ![self.apperyService.baseUrl isEqualToString:oldBaseUrl];
}

- (void)hideAllHuds
{
    [MBProgressHUD hideAllHUDsForView: self.window.rootViewController.view animated: NO];
}

- (void)cancelApperyServiceActivity
{
    [self.apperyService cancelCurrentOperation];
    
    if (self.apperyService.isLoggedIn) {
        [self.apperyService quickLogout];
    }
}

- (void)navigateToStartPage
{
    IIViewDeckController *rootDeckViewController = (IIViewDeckController *)self.window.rootViewController;
    [(UINavigationController *)rootDeckViewController.centerController popToRootViewControllerAnimated:NO];
    [rootDeckViewController closeLeftView];
    rootDeckViewController.leftController = nil;
    [rootDeckViewController closeRightView];
    rootDeckViewController.rightController = nil;
}

@end
