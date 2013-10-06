//
//  EXProjectViewController~iPad.h
//  Appery
//
//  Created by Sergey Seroshtan on 22.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXApperyService.h"

#import <Cordova/CDVViewController.h>

#import "EXProjectsMetadataViewController.h"

/**
 * Provides container for cordova projects.
 *     Inheritance is used to configure navigation controller bar appearance and behaviour.
 */
@interface EXProjectViewController : CDVViewController <CDVScreenOrientationDelegate>

/**
 * Initialize with view controller and configures it with loaded project correspond to the specified project metadata.
 *
 * @param projectMetadata - project metadata for loading project, if nil empty view will be shown
 */
- (id) initWithProjectMetadata: (EXProjectMetadata *)projectMetadata;

/**
 * Reference to the appery.io web service.
 * @required
 */
@property (nonatomic, retain) EXApperyService *apperyService;

/**
 * Reference to EXProjectsMetadataViewController object is used to display it in popover.
 */
@property (nonatomic, retain) EXProjectsMetadataViewController *projectsMetadataViewController;

/**
 * Updates projects metadata.
 */
- (void) loadProjectsMetadata;
@end
