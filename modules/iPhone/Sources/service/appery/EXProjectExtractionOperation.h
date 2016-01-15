//
//  EXProjectExtractionOperation.h
//  Appery
//
//  Created by Sergey Tkachenko on 12/3/15.
//  Copyright (c) 2015 Exadel Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EXProjectMetadata;

@interface EXProjectExtractionOperation : NSOperation

/**
 * Configures operation to load project with the specified project metadata.
 */
@property (nonatomic, strong, readonly) EXProjectMetadata *projectMetadata;

/**
 * @return loaded project's folder full path.
 */
@property (nonatomic, strong, readonly) NSString *projectLocation;

/**
 * @return loaded project's start page name (root html file name).
 */
@property (nonatomic, strong, readonly) NSString *projectStartPageName;

/**
 * @return error if something went wrong
 */
@property (nonatomic, strong, readonly) NSError *error;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithName:(NSString *)name data:(NSData *)projectData NS_DESIGNATED_INITIALIZER;

@end
