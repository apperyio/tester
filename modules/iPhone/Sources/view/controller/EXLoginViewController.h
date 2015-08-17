//
//  EXLoginViewController.h
//  Appery
//
//  Created by Sergey Seroshtan on 30.07.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EXViewControllerProvider.h"
#import "EXProjectViewController.h"
#import "EXApperyService.h"
#import "EXUserSettingsStorage.h"
#import "EXCredentialsManager.h"
#import "GradientButton.h"

@interface EXLoginViewController : UIViewController <UITextFieldDelegate, EXViewControllerProvider>

@property (retain, nonatomic) IBOutlet UITextField *userName;
@property (retain, nonatomic) IBOutlet UITextField *userPassword;
@property (retain, nonatomic) IBOutlet UISwitch *shouldRememberMe;
@property (retain, nonatomic) IBOutlet GradientButton *loginButton;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;

@property (nonatomic, retain) EXProjectViewController *projectViewController;

/**
 * Reference to the appery.io web service.
 * @required
 */
@property (nonatomic, retain) EXApperyService *apperyService;

/**
 * Provides login action, when user taps to correspond button.
 */
- (IBAction) login:(id)sender;

/**
 * Go to enter shared app code
 */
- (IBAction) toShare:(id)sender;

/**
 *
 */
- (void) updateProjectsMetadata:(NSArray *)projectsMetadata;

@end
