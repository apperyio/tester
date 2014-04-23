//
//  EXLoginViewController.m
//  Appery
//
//  Created by Sergey Seroshtan on 30.07.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXLoginViewController.h"

#import "MBProgressHUD.h"

#import "EXProjectsMetadataViewController~iPhone.h"
#import "EXProjectViewController.h"

#import "EXApperyServiceException.h"

#pragma mark - Private interface declaration

@interface EXLoginViewController ()

@property (nonatomic, retain) EXProjectViewController *projectViewController;

/**
 * Hides keyboard if it visible
 */
- (void) hideKeyboard;

@end

@implementation EXLoginViewController

#pragma mark - Life cycle

- (id) initWithNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Login", @"EXLoginViewController title");
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self configureUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureCredentialFields];
}

#pragma mark - iOS 5 rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

#pragma mark - iOS 6 rotation

- (BOOL) shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - EXViewControllerProvider protocol implementation

- (UIViewController *) nextViewController
{
    return self.projectViewController;
}

#pragma mark - Private interface implementation

- (void) hideKeyboard
{
    [self.userName resignFirstResponder];
    [self.userPassword resignFirstResponder];
}

- (void) saveUserSettings
{
    if (self.shouldRememberMe.on) {
        // save user settings
        EXUserSettings *userSettings = [[EXUserSettings alloc] init];
        userSettings.userName = self.userName.text;
        userSettings.shouldRememberMe = self.shouldRememberMe.on;
        userSettings.shouldRememberPassword = self.shouldRememberPassword.on;
        
        [self.userSettingsStorage storeSettings: userSettings];
        
        // save user credentials
        if (self.shouldRememberPassword.on) {
            if ([self.credentialsManager addPassword: self.userPassword.text forUser: self.userName.text] == NO) {
                // not critical
                NSLog(@"Can not add password: %@ for user: %@", self.userPassword.text, self.userName.text);
            }
        } else {
            if ([self.credentialsManager removePasswordForUser: self.userName.text] == NO) {
                // not critical
                NSLog(@"Can not remove password: %@ for user: %@", self.userPassword.text, self.userName.text);
            }
        }
    } else {
        // remove user settings if it was stored
        [self.userSettingsStorage removeSettingsForUser: self.userName.text];
    }
}

- (void) navigateToNextViewController
{
    UIViewController *nextViewController = [self nextViewController];
    
    if ([self.navigationController.viewControllers containsObject: nextViewController]) {
        [self.navigationController popToViewController: nextViewController animated: YES];
    } else {
        [self.navigationController pushViewController:nextViewController animated: YES];
    }
}

- (void) updateProjectsMetadataForNextViewController
{
    id nextViewController = [self nextViewController];
    
    if ([nextViewController respondsToSelector: @selector(loadProjectsMetadata)]) {
        [nextViewController loadProjectsMetadata];
    }
}

#pragma mark - UI action handlers

- (IBAction) login: (id)sender
{
    NSAssert(self.apperyService != nil, @"apperyService property is not specified");

    [self hideKeyboard];
  
    UIView *rootView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo: rootView animated: YES];
    progressHud.labelText = NSLocalizedString(@"Login", @"Login progress hud title");
   
    NSAssert(self.apperyService != nil, @"apperyService property is not defined");
    
    [self.apperyService loginWithUsername: self.userName.text password: self.userPassword.text succeed: ^{
            [progressHud hide: YES];
            [self saveUserSettings];
            [self navigateToNextViewController];
            [self updateProjectsMetadataForNextViewController];
        }
        failed:^(NSError *error) {
            [progressHud hide: YES];
            UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle: @"Login failed"
                                                                 message: error.domain
                                                                delegate: nil cancelButtonTitle: @"Ok"
                                                       otherButtonTitles: nil];
            [loginAlert show];
        }];
}

- (IBAction) onShouldRememberMeValueChanged: (id)sender
{
    self.shouldRememberPassword.enabled = self.shouldRememberMe.on;
    self.shouldRememberPassword.on = self.shouldRememberMe.on ? self.shouldRememberPassword.on : NO;
}

#pragma mark - UITextFieldDelefate protocol implementation

- (BOOL) textFieldShouldReturn: (UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Private

#pragma mark - Configuration helpers

- (void)configureUI
{
    [self configureCredentialFields];
    [self configureLoginButton];

    self.projectViewController = [[EXProjectViewController alloc] initWithProjectMetadata: nil];
    self.projectViewController.apperyService = self.apperyService;
    self.projectViewController.wwwFolderName = @"www";
    self.projectViewController.startPage = @"index.html";
    
    EXProjectsMetadataViewController *projectsMetadataViewController = [[EXProjectsMetadataViewController alloc]
            initWithNibName:NSStringFromClass([EXProjectsMetadataViewController class]) bundle:nil];
    projectsMetadataViewController.apperyService = self.apperyService;
    self.projectViewController.projectsMetadataViewController = projectsMetadataViewController;
    
    //For ios 7 and later
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
    }
}

- (void)configureLoginButton
{
    UIColor *topColorNormal = [UIColor colorWithRed:0.f green:152/255.f blue:249/255.f alpha:1.f];
    UIColor *bottomColorNormal = [UIColor colorWithRed:9/255.f green:117/255.f blue:226/255.f alpha:1.f];
    self.loginButton.normalGradientColors =
            [NSArray arrayWithObjects:(id)[bottomColorNormal CGColor], (id)[topColorNormal CGColor], nil];
    self.loginButton.normalGradientLocations =
            [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:1.0f], nil];

    UIColor *topColorHighlight = [UIColor colorWithRed:0.f green:130/255.f blue:249/255.f alpha:1.f];
    UIColor *bottomColorHighlight = [UIColor colorWithRed:9/255.f green:95/255.f blue:226/255.f alpha:1.f];
    self.loginButton.highlightGradientColors =
            [NSArray arrayWithObjects:(id)[bottomColorHighlight CGColor], (id)[topColorHighlight CGColor], nil];
    self.loginButton.highlightGradientLocations =
            [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:1.0f], nil];
    
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

- (void)configureCredentialFields
{
    self.userName.text = @"";
    self.userPassword.text = @"";

    EXUserSettings *lastUserSettings = [self.userSettingsStorage retreiveLastStoredSettings];

    if (lastUserSettings) {
        self.shouldRememberMe.on = lastUserSettings.shouldRememberMe;
        self.shouldRememberPassword.enabled = lastUserSettings.shouldRememberMe;
        self.shouldRememberPassword.on = lastUserSettings.shouldRememberPassword;
        if (lastUserSettings.shouldRememberMe) {
            self.userName.text = lastUserSettings.userName;
            if (lastUserSettings.shouldRememberPassword) {
                self.userPassword.text = [self.credentialsManager retreivePasswordForUser: lastUserSettings.userName];
            }
        }
    }
}

@end
