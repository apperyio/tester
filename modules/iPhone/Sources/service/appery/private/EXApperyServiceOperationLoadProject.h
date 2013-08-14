//
//  EXApperyServiceOperationLoadProject.h
//  Appery
//
//  Created by Sergey Seroshtan on 20.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXApperyServiceOperation.h"

#import "EXProjectMetadata.h"

/**
 * Perofrms loading and extracting project bundle from appery.io service
 *    and provides information about it location, start page name, etc. 
 */
@interface EXApperyServiceOperationLoadProject : EXApperyServiceOperation

/** @name Configuring operation properties */

/**
 * Configures operation to load project with the specified project metadata.
 */
@property (nonatomic, retain) EXProjectMetadata *projectMetadata;

/** @name Info access properties */
 
/**
 * @return loaded project's folder full path.
 */
@property (nonatomic, readonly, retain) NSString *projectLocation;

/**
 * @return loaded project's start page name (root html file name).
 */
@property (nonatomic, readonly, retain) NSString *projectStartPageName;

@end
