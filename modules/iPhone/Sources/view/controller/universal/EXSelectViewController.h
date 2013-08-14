//
//  EXSelectViewController.h
//  Appery
//
//  Created by Sergey Seroshtan on 14.05.13.
//  Copyright (c) 2013Exadel Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^EXSelectViewControllerCompletionBlock)(BOOL success, id selection);

@interface EXSelectViewController : UIViewController

/// @name Configuration properties
@property (nonatomic, retain) NSArray *data;
@property (nonatomic, copy) EXSelectViewControllerCompletionBlock completion;
@property (nonatomic, assign) id selection;

/// @name UI update
/**
 * Update UI due to current [self data] property and [self selection] property.
 */
- (void)updateUI;

/// @name Initialization
- (id)initWithTitle:(NSString *)title;

/// @name UI action
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end
