//
//  EXProjectMetadata.h
//  Appery
//
//  Created by Sergey Seroshtan on 07/31/12.
//  Copyright 2012 Exadel Inc. All rights reserved.
//
//  This class provides meta information about project located on the appery.io service.
//

#import <Foundation/Foundation.h>

@interface EXProjectMetadata : NSObject 

@property (nonatomic, retain) NSNumber *identifier;     // Project id
@property (nonatomic, retain) NSString *name;           // Project name
@property (nonatomic, retain) NSString *owner;          // Project owner
@property (nonatomic, retain) NSNumber *featured;       // Project featured
@property (nonatomic, retain) NSString *modifier;       // User name of the last modifier/owner
@property (nonatomic, retain) NSString *link;           // Link to Project
@property (nonatomic, retain) NSString *description;    // Project description
@property (nonatomic, retain) NSString *htmlBundle;     // Link to the project bundle
@property (nonatomic, retain) NSString *showcaseLink;   // Link to the project showcase
@property (nonatomic, retain) NSNumber *isDisabled;     // Project is disabled
@property (nonatomic, retain) NSNumber *modifyDate;     // Project last modification date
@property (nonatomic, retain) NSNumber *creationDate;   // Project creation date
@property (nonatomic, retain) NSNumber *submissionDate; // Project submission date

@property (nonatomic, readonly) NSString *formattedModifyDate;     // Formatted date of the last modifying
@property (nonatomic, readonly) NSString *formattedCreationDate;   // Formatted creation date
@property (nonatomic, readonly) NSString *formattedSubmissionDate; // Formatted submission date

/**
 * Initialize this object with values specified in properties dictionary.
 * @param metadata - dictionary with project's metadata received from the appery.io service.
 */
- (id) initWithMetadata: (NSDictionary *) metadata;

@end
