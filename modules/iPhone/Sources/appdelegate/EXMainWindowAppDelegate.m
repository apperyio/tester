//
//  EXMainWindowAppDelegate.m
//  Appery
//
//  Created by Sergey Seroshtan on 30.07.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXMainWindowAppDelegate.h"
#import "EXLoginViewController.h"
#import "EXApperyService.h"
#import "EXUserSettingsStorage.h"
#import "MBProgressHUD.h"
#import "IIViewDeckController.h"

#pragma mark - Private interface declaration

@interface EXMainWindowAppDelegate ()

@property (nonatomic, strong) EXApperyService *apperyService;
@property (nonatomic, strong) EXLoginViewController *loginViewController;
@property (nonatomic, strong) IIViewDeckController *viewDeckController;

@end

@implementation EXMainWindowAppDelegate

#pragma mark - UIApplicationDelegate protocol - Monitoring Application State Changes

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self createAndConfigureApperyService];
    
    self.loginViewController = [[EXLoginViewController alloc] initWithNibName:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ?
                                @"EXLoginViewController~iPad" : @"EXLoginViewController" bundle: nil];
    
    self.loginViewController.apperyService = self.apperyService;
    
    self.loginViewController.projectViewController = [[EXProjectViewController alloc] initWithProjectMetadata: nil];
    self.loginViewController.projectViewController.apperyService = self.apperyService;
    self.loginViewController.projectViewController.wwwFolderName = @"www";
    self.loginViewController.projectViewController.startPage = @"index.html";
    
    EXProjectsMetadataViewController *projectsMetadataViewController = [[EXProjectsMetadataViewController alloc]
                                                                        initWithNibName:NSStringFromClass([EXProjectsMetadataViewController class]) bundle:nil];
    projectsMetadataViewController.apperyService = self.apperyService;
    self.loginViewController.projectViewController.projectsMetadataViewController = projectsMetadataViewController;
    
    UINavigationController *rootNavigationController = [[UINavigationController alloc] initWithRootViewController: self.loginViewController];
    
    self.viewDeckController = [[IIViewDeckController alloc] initWithCenterViewController: rootNavigationController];
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
    if ([self shouldLoginToAppery] && ![self updateBaseUrl]) {
        [self loginLastUserToAppery];
    } else {
        [self navigateToStartPage];
    }
}

#pragma mark - Private interface implementation

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

- (BOOL)shouldLoginToAppery
{
    EXUserSettingsStorage *usStorage = [EXUserSettingsStorage sharedUserSettingsStorage];
    EXUserSettings *lastUserSettings = [usStorage retreiveLastStoredSettings];
    
    return lastUserSettings.shouldRememberMe;
}

- (void)loginLastUserToAppery
{
    EXUserSettingsStorage *usStorage = [EXUserSettingsStorage sharedUserSettingsStorage];
    EXUserSettings *lastUserSettings = [usStorage retreiveLastStoredSettings];
    NSString *password = [EXCredentialsManager retreivePasswordForUser: lastUserSettings.userName];
    
    [self.apperyService loginWithUsername: lastUserSettings.userName
                                 password: password
                                  succeed: ^(NSArray *projectsMetadata) {
                                      EXProjectsMetadataViewController *pmvc = ((EXProjectsMetadataViewController *)self.loginViewController.projectViewController.projectsMetadataViewController);
                                      pmvc.rootTableView.userInteractionEnabled = NO;
                                      [self.loginViewController updateProjectsMetadata:projectsMetadata];
                                      pmvc.rootTableView.userInteractionEnabled = YES;
                                      
                                      NSLog(@"User %@ login to %@", lastUserSettings.userName, self.apperyService.baseUrl);
                                  }
                                   failed:^(NSError *error) {
                                       [self navigateToStartPage];
                                       
                                       NSLog(@"User %@ can't login to %@", lastUserSettings.userName, self.apperyService.baseUrl);
                                   }];
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
