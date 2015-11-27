//
//  EXProjectsViewController.h
//  Appery
//
//  Created by Sergey Seroshtan on 30.07.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//
//  Displays information about projects provided by appery.io service (@see EXApperyService class).
//      It also provides ability to load them in the embedded PhoneGap container.
//

#import <UIKit/UIKit.h>

#import "EXBaseViewController.h"
#import "EXApperyService.h"
#import "EXProjectMetadata.h"
#import "EXProjectControllerActionDelegate.h"

/// @name Additional types
typedef void(^EXProjectsMetadataViewControllerCompletionBlock)(BOOL succeeded);

@interface EXProjectsMetadataViewController : EXBaseViewController

/**
 * Reference to the appery.io web service.
 * EXProjectsViewController uses this property to access to appery.io service for:
 *  - load projects metadata
 *  - logout from service
 *  - load project
 *  - etc
 * So this property should be defined for correct work.
 */
@property (nonatomic, strong, readonly) EXApperyService *apperyService;

@property (nonatomic, weak) id<EXProjectControllerActionDelegate> delegate;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil service:(EXApperyService *)service projectsMetadata:(NSArray *)metadata NS_DESIGNATED_INITIALIZER;

@end
