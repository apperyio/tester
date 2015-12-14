//
//  EXProjectViewController.h
//  Appery
//
//  Created by Sergey Seroshtan on 22.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXApperyService.h"

#import <Cordova/CDVViewController.h>

#import "EXProjectsMetadataViewController.h"
#import "EXProjectControllerActionDelegate.h"

/**
 * Provides container for cordova projects.
 *     Inheritance is used to configure navigation controller bar appearance and behaviour.
 */
@interface EXProjectViewController : CDVViewController <CDVScreenOrientationDelegate, EXProjectControllerActionDelegate>

/**
 * Reference to the appery.io web service.
 * @required
 */
@property (nonatomic, strong, readonly) EXApperyService *apperyService;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 * Initialize with view controller and configures it with loaded project correspond to the specified project metadata.
 */
- (instancetype)initWithService:(EXApperyService *)service projectMetadata:(EXProjectMetadata *)projectMetadata NS_DESIGNATED_INITIALIZER;

/**
 * Initialize with view controller and configures it with loaded project correspond to the specified project app code.
 */
- (instancetype)initWithService:(EXApperyService *)service projectCode:(NSString *)projectCode NS_DESIGNATED_INITIALIZER;

- (void)updateContent;

@end
