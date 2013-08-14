//
//  EXLoginViewController.h
//  Appery
//
//  Created by Sergey Seroshtan on 30.07.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EXViewControllerProvider.h"
#import "EXApperyService.h"
#import "EXUserSettingsStorage.h"
#import "EXCredentialsManager.h"
#import "GradientButton.h"

@interface EXLoginViewController : UIViewController <UITextFieldDelegate, EXViewControllerProvider>

@property (retain, nonatomic) IBOutlet UITextField *userName;
@property (retain, nonatomic) IBOutlet UITextField *userPassword;
@property (retain, nonatomic) IBOutlet UISwitch *shouldRememberMe;
@property (retain, nonatomic) IBOutlet UISwitch *shouldRememberPassword;
@property (retain, nonatomic) IBOutlet GradientButton *loginButton;

/**
 * Reference to the appery.io web service.
 * @required
 */
@property (nonatomic, retain) EXApperyService *apperyService;

/**
 * Contains reference to user settings storage.
 * @required
 */
@property (nonatomic, retain) EXUserSettingsStorage *userSettingsStorage;

/**
 * Contains reference to user credentials manager.
 * @required
 */
@property (nonatomic, retain) EXCredentialsManager *credentialsManager;

/**
 * Provides login action, when user taps to correspond button.
 */
- (IBAction) login:(id)sender;

/**
 * Handler for shouldRememberMe switch change event.
 */
- (IBAction) onShouldRememberMeValueChanged: (id)sender;

@end
