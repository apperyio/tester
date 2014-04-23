//
//  EXMainWindowAppDelegate.m
//  Appery
//
//  Created by Sergey Seroshtan on 30.07.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXMainWindowAppDelegate.h"

#import "EXLoginViewController.h"
#import "EXLoginViewController~ipad.h"

#import "EXApperyService.h"
#import "EXUserSettingsStorage.h"

#import "MBProgressHUD.h"

#import "IIViewDeckController.h"

/**
 * Fix for Cordova library version 1.9.0 and higher.
 */
NSString * const NSURLIsExcludedFromBackupKey = @"NSURLIsExcludedFromBackupKey";

#pragma mark - Private interface declaration

@interface EXMainWindowAppDelegate ()

@property (nonatomic, strong) EXApperyService *apperyService;
@property (nonatomic, strong) EXUserSettingsStorage *userSettingsStorage;
@property (nonatomic, strong) EXCredentialsManager *credentialsManager;
@property (nonatomic, strong) UINavigationController *rootNavigationController;

@end

@implementation EXMainWindowAppDelegate

#pragma mark - UIApplicationDelegate protocol - Monitoring Application State Changes

- (BOOL) application: (UIApplication *)application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
    [self createApperyService];
    [self configureApperyService];
    [self createAndConfigureUserSettingsStorage];
    [self createCredentialsManager];
    
    EXLoginViewController *loginViewController = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ?
            [[EXLoginViewController_iPad alloc] initWithNibName: @"EXLoginViewController~iPad" bundle: nil] :
            [[EXLoginViewController alloc] initWithNibName: @"EXLoginViewController" bundle: nil];
    
    loginViewController.apperyService = self.apperyService;
    loginViewController.userSettingsStorage = self.userSettingsStorage;
    loginViewController.credentialsManager = self.credentialsManager;
    
    self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController: loginViewController];
    IIViewDeckController *viewDeckController = [[IIViewDeckController alloc] initWithCenterViewController: self.rootNavigationController];
    viewDeckController.navigationControllerBehavior = IIViewDeckNavigationControllerContained;
    viewDeckController.elastic = NO;
    viewDeckController.sizeMode = IIViewDeckLedgeSizeMode;
    
    self.window.rootViewController = viewDeckController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - UIApplicationDelegate protocol - Responding to System Notifications

- (void) applicationDidReceiveMemoryWarning: (UIApplication *)application
{
    
}

- (void) applicationDidEnterBackground: (UIApplication *)application
{
    [self hideAllHuds];
    [self cancelApperyServiceActivity];
    [self navigateToStartPage];
}

- (void) applicationWillEnterForeground: (UIApplication *)application
{
    [self configureApperyService];
}

#pragma mark - Private interface implementation

- (void) createApperyService
{
    NSAssert(self.apperyService == nil, @"self.apperyService is already initialized");
    self.apperyService = [[EXApperyService alloc] init];
}

- (void) configureApperyService
{
    self.apperyService.baseUrl = [[NSUserDefaults standardUserDefaults] valueForKey: @"baseURL"];
    NSLog(@"Appery service base URL: %@", self.apperyService.baseUrl);
}

- (void) createAndConfigureUserSettingsStorage
{
    NSAssert(self.userSettingsStorage == nil, @"self.userSettingsStorage is already initialized");
    self.userSettingsStorage = [[EXUserSettingsStorage alloc] init];
}

- (void) createCredentialsManager
{
    NSAssert(self.credentialsManager == nil, @"self.credentialsManager is already initialized");
    self.credentialsManager = [[EXCredentialsManager alloc] init];
}

- (void) hideAllHuds
{
    [MBProgressHUD hideAllHUDsForView: self.window.rootViewController.view animated: NO];
}

- (void) navigateToStartPage
{
    [self.rootNavigationController popToRootViewControllerAnimated: NO];

    IIViewDeckController *rootDeckViewController = (IIViewDeckController *)self.window.rootViewController;
    [rootDeckViewController closeLeftView];
    rootDeckViewController.leftController = nil;
    [rootDeckViewController closeRightView];
    rootDeckViewController.rightController = nil;
}

- (void) cancelApperyServiceActivity
{
    [self.apperyService cancelCurrentOperation];

    if (self.apperyService.isLoggedIn) {
        [self.apperyService quickLogout];
    }
}

@end
