//
//  EXApperyServiceOperationLoadProjectsMetadata.h
//  Appery
//
//  Created by Sergey Seroshtan on 10.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXApperyServiceOperation.h"

/**
 * Perform appery.io load projects metadata.
 */
@interface EXApperyServiceOperationLoadProjectsMetadata : EXApperyServiceOperation

/**
 * Provides access to the loaded projects metadata.
 *
 * @return array of EXProjectMetadata objects
 */
@property (nonatomic, readonly) NSArray *projectsMetadata;

@end
