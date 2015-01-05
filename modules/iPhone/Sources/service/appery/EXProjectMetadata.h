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

@property (nonatomic, retain) NSNumber *creationDate;       // Project creation Date
@property (nonatomic, retain) NSString *creator;            // Project creator
@property (nonatomic, retain) NSNumber *disabled;           // Project disabled
@property (nonatomic, retain) NSString *guid;               // Project guid
@property (nonatomic, retain) NSString *name;               // Project name
@property (nonatomic, retain) NSString *openWith;           // Project open with
@property (nonatomic, retain) NSNumber *pushNotification;   // Push Notification
@property (nonatomic, retain) NSString *sharedWithSupport;  // Project shared with support
@property (nonatomic, retain) NSString *sharedWithSupportBy;// Project shared with support by ...
@property (nonatomic, retain) NSNumber *type;               // Project type

@property (nonatomic, readonly) NSString *formattedCreationDate;   // Formatted creation date

/**
 * Initialize this object with values specified in properties dictionary.
 * @param metadata - dictionary with project's metadata received from the appery.io service.
 */
- (id) initWithMetadata: (NSDictionary *) metadata;

@end
