//
//  EXLoginViewController.m
//  Appery
//
//  Created by Sergey Seroshtan on 30.07.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXLoginViewController.h"
#import "MBProgressHUD.h"
#import "NSStringMask.h"

#pragma mark - Private interface declaration

@interface EXLoginViewController ()

@property (nonatomic, strong) NSStringMask *mask;

/**
 * Hides keyboard if it visible
 */
- (void) hideKeyboard;

@end

@implementation EXLoginViewController

#pragma mark - Life cycle

- (id) initWithNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        self.title = NSLocalizedString(@"Login", @"EXLoginViewController title");
        self.mask = [[NSStringMask alloc] initWithPattern:@"(\\d{3})-(\\d{3})-(\\d{3})" placeholder:@"_"];
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

#pragma mark - UI action handlers

- (IBAction) login: (id)sender
{
    NSAssert(self.apperyService != nil, @"apperyService property is not specified");

    [self hideKeyboard];
  
    UIView *rootView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo: rootView animated: YES];
    progressHud.labelText = NSLocalizedString(@"Login", @"Login progress hud title");
    
    [self.apperyService quickLogout];
    
    [self.apperyService loginWithUsername: self.userName.text password: self.userPassword.text succeed: ^(NSArray *projectsMetadata) {
        [progressHud hide: YES];
    
        [self saveUserSettings];
        [self navigateToNextViewController];
        [self updateProjectsMetadata:projectsMetadata];
    
        NSLog(@"User %@ login to %@", self.userName.text, self.apperyService.baseUrl);
    }
    failed:^(NSError *error) {
        [progressHud hide: YES];
        
        [[[UIAlertView alloc] initWithTitle: error.localizedDescription
                                    message: error.localizedRecoverySuggestion
                                   delegate: nil
                          cancelButtonTitle: NSLocalizedString(@"Ok", nil)
                          otherButtonTitles: nil] show];
        
        NSLog(@"User %@ can't login to %@", self.userName.text, self.apperyService.baseUrl);
    }];
}

- (IBAction)toShare:(id)sender
{
    UIAlertView *shareAlert = [[UIAlertView alloc] initWithTitle:@"Enter an app code"
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"Enter", nil];
    
    shareAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *textfield = [shareAlert textFieldAtIndex:0];
    textfield.backgroundColor = [UIColor clearColor];
    textfield.placeholder = @"App code";
    textfield.tag = 43834;
    textfield.keyboardType = UIKeyboardTypeNumberPad;
    textfield.returnKeyType = UIReturnKeyDone;
    textfield.delegate = self;
    [shareAlert show];
}

#pragma mark - Public interface implementation

- (void) updateProjectsMetadata:(NSArray *)projectsMetadata
{
    EXProjectViewController *nextViewController = (EXProjectViewController *)[self nextViewController];
    
    if ([nextViewController.projectsMetadataViewController respondsToSelector: @selector(initializeProjectsMetadata:)]) {
        [nextViewController.projectsMetadataViewController initializeProjectsMetadata:projectsMetadata];
    }
}

#pragma mark - EXViewControllerProvider protocol implementation

- (UIViewController *) nextViewController
{
    return self.projectViewController;
}

#pragma mark - UITextFieldDelefate protocol implementation

- (BOOL) textFieldShouldReturn: (UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag != 43834) {
        return YES;
    }
    
    NSRange newRange = NSMakeRange(0, 0);
    NSString *mutableString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *clean = [self.mask validCharactersForString:mutableString];
    mutableString = [self.mask format:mutableString];
    
    if (clean.length > 0)
    {
        newRange = [mutableString rangeOfString:[clean substringFromIndex:clean.length - 1] options:NSBackwardsSearch];
        if (newRange.location == NSNotFound)
        {
            newRange.location = mutableString.length;
        }
        else
        {
            newRange.location += newRange.length;
        }
        
        newRange.length = 0;
    }
    
    textField.text = mutableString;
    [textField setValue:[NSValue valueWithRange:newRange] forKey:@"selectionRange"];
    
    return NO;
}

#pragma mark - UIAlertViewDelegate protocol implementation

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    }
    
    UIView *rootView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:rootView animated:YES];
    progressHud.labelText = NSLocalizedString(@"Loading app", @"Loading app progress hud title");
    
    NSString *appCode = [[alertView textFieldAtIndex:0] text];
    
    [self.apperyService   loadProjectForAppCode:appCode
                                        succeed:^(NSString *projectLocation, NSString *startPageName) {
                                           [progressHud hide: NO];
                                           
                                           EXProjectViewController *projectViewController = [[EXProjectViewController alloc] initWithProjectCode:appCode];
                                           projectViewController.apperyService = self.apperyService;
                                           projectViewController.wwwFolderName = projectLocation;
                                           projectViewController.startPage = startPageName;
                                           
                                           [self.navigationController pushViewController:projectViewController animated:YES];
                                           
                                           NSLog(@"App %@ was load", appCode);
                                        } failed:^(NSError *error) {
                                           [progressHud hide: NO];
                                           
                                           [[[UIAlertView alloc] initWithTitle: error.localizedDescription
                                                                       message: error.localizedRecoverySuggestion
                                                                      delegate: nil
                                                             cancelButtonTitle: NSLocalizedString(@"Ok", nil)
                                                             otherButtonTitles: nil] show];
                                           
                                           NSLog(@"App loading failed due to: %@", error.localizedDescription);
                                        }
     ];
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    return YES;
}

#pragma mark - Private

#pragma mark - Private interface implementation

- (void) hideKeyboard
{
    [self.userName resignFirstResponder];
    [self.userPassword resignFirstResponder];
}

- (void) saveUserSettings
{
    EXUserSettingsStorage *usStorage = [EXUserSettingsStorage sharedUserSettingsStorage];
    
    if (self.shouldRememberMe.on) {
        // save user settings
        EXUserSettings *userSettings = [[EXUserSettings alloc] init];
        
        userSettings.userName = self.userName.text;
        userSettings.shouldRememberMe = self.shouldRememberMe.on;
        userSettings.sortMethodType = [[usStorage retreiveLastStoredSettings] sortMethodType];
        
        [usStorage storeSettings: userSettings];
        
        // save user credentials
        if ([EXCredentialsManager addPassword: self.userPassword.text forUser: self.userName.text] == NO) {
            // not critical
            NSLog(@"Can not add password for user: %@", self.userName.text);
        }
        
    } else {
        // remove user settings if it was stored
        [usStorage removeSettingsForUser: self.userName.text];
        
        if ([EXCredentialsManager removePasswordForUser: self.userName.text] == NO) {
            // not critical
            NSLog(@"Can not remove password for user: %@", self.userName.text);
        }
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

#pragma mark - Configuration helpers

- (void)configureUI
{
    [self configureCredentialFields];
    [self configureLoginButton];
    
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
    
    EXUserSettingsStorage *usStorage = [EXUserSettingsStorage sharedUserSettingsStorage];
    EXUserSettings *lastUserSettings = [usStorage retreiveLastStoredSettings];

    if (lastUserSettings) {
        self.shouldRememberMe.on = lastUserSettings.shouldRememberMe;
        self.userName.text = lastUserSettings.userName;
    }
}

@end
