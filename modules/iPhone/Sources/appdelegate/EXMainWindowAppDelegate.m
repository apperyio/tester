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
@interface EXMainWindowAppDelegate () {
    EXApperyService *_apperyService;
    EXUserSettingsStorage *_userSettingsStorage;
    EXCredentialsManager *_credentialsManager;
    UINavigationController *_rootNavigationController;
}
@end

@implementation EXMainWindowAppDelegate

#pragma mark - Public properties synthesize
@synthesize window = _window;

#pragma mark - UIApplicationDelegate protocol
#pragma mark - UIApplicationDelegate protocol - Monitoring Application State Changes

- (BOOL) application: (UIApplication *)application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions {
    [self createApperyService];
    [self configureApperyService];
    [self createAndConfigureUserSettingsStorage];
    [self createCredentialsManager];
    
    EXLoginViewController *loginViewController = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ?
            [[EXLoginViewController_iPad alloc] initWithNibName: @"EXLoginViewController~iPad" bundle: nil] :
            [[EXLoginViewController alloc] initWithNibName: @"EXLoginViewController" bundle: nil];
    
    loginViewController.apperyService = _apperyService;
    loginViewController.userSettingsStorage = _userSettingsStorage;
    loginViewController.credentialsManager = _credentialsManager;
    
    _rootNavigationController = [[UINavigationController alloc] initWithRootViewController: loginViewController];
    IIViewDeckController *viewDeckController =
            [[IIViewDeckController alloc] initWithCenterViewController: _rootNavigationController];
    viewDeckController.navigationControllerBehavior = IIViewDeckNavigationControllerContained;
    viewDeckController.elastic = NO;
    viewDeckController.sizeMode = IIViewDeckLedgeSizeMode;
    
    self.window.rootViewController = [viewDeckController autorelease];
    [self.window makeKeyAndVisible];
    
    [loginViewController release];
    
    return YES;
}

#pragma mark - UIApplicationDelegate protocol - Responding to System Notifications
- (void) applicationDidReceiveMemoryWarning: (UIApplication *)application {
    
}

- (void) applicationDidEnterBackground: (UIApplication *)application {
    [self hideAllHuds];
    [self cancelApperyServiceActivity];
    [self navigateToStartPage];
}

- (void) applicationWillEnterForeground: (UIApplication *)application {
    [self configureApperyService];
}

#pragma mark - Private interface implementation
- (void) createApperyService {
    NSAssert(_apperyService == nil, @"_apperyService is already initialized");
    _apperyService = [[[EXApperyService alloc] init] autorelease];
}

- (void) configureApperyService {
    _apperyService.baseUrl = [[NSUserDefaults standardUserDefaults] valueForKey: @"baseURL"];
    DLog(@"Appery service base URL: %@", _apperyService.baseUrl);
}

- (void) createAndConfigureUserSettingsStorage {
    NSAssert(_userSettingsStorage == nil, @"_userSettingsStorage is already initialized");
    _userSettingsStorage = [[[EXUserSettingsStorage alloc] init] autorelease];
}

- (void) createCredentialsManager {
    NSAssert(_credentialsManager == nil, @"_credentialsManager is already initialized");
    _credentialsManager = [[EXCredentialsManager alloc] init];
}

- (void) hideAllHuds {
    [MBProgressHUD hideAllHUDsForView: self.window.rootViewController.view animated: NO];
}

- (void) navigateToStartPage {
    [_rootNavigationController popToRootViewControllerAnimated: NO];
    IIViewDeckController *rootDeckViewController = (IIViewDeckController *)self.window.rootViewController;
    [rootDeckViewController closeLeftView];
    rootDeckViewController.leftController = nil;
    [rootDeckViewController closeRightView];
    rootDeckViewController.rightController = nil;
}

- (void) cancelApperyServiceActivity {
    [_apperyService cancelCurrentOperation];
    if (_apperyService.isLoggedIn) {
        [_apperyService quickLogout];
    }
}

@end
