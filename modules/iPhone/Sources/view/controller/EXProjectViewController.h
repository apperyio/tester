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

/**
 * Initialize with view controller and configures it with loaded project correspond to the specified project metadata.
 *
 * @param projectMetadata - project metadata for loading project, if nil empty view will be shown
 */
- (instancetype)initWithService:(EXApperyService *)service projectMetadata:(EXProjectMetadata *)projectMetadata;
- (instancetype)initWithService:(EXApperyService *)service projectCode:(NSString *)projectCode;

- (void)updateContent;

@end
