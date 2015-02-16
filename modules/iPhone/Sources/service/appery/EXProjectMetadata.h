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

@property (nonatomic, strong) NSNumber *_id;                // Project id
@property (nonatomic, strong) NSNumber *creationDate;       // Project creation Date
@property (nonatomic, strong) NSNumber *modifiedDate;       // Project modified Date
@property (nonatomic, strong) NSString *creator;            // Project creator
@property (nonatomic, strong) NSNumber *disabled;           // Project disabled
@property (nonatomic, strong) NSString *guid;               // Project guid
@property (nonatomic, strong) NSString *name;               // Project name
@property (nonatomic, strong) NSString *openWith;           // Project open with
@property (nonatomic, strong) NSNumber *pushNotification;   // Push Notification
@property (nonatomic, strong) NSString *sharedWithSupport;  // Project shared with support
@property (nonatomic, strong) NSString *sharedWithSupportBy;// Project shared with support by ...
@property (nonatomic, strong) NSNumber *type;               // Project type

@property (nonatomic, readonly) NSString *formattedModifiedDate;   // Formatted modified date

/**
 * Initialize this object with values specified in properties dictionary.
 * @param metadata - dictionary with project's metadata received from the appery.io service.
 */
- (id) initWithMetadata: (NSDictionary *) metadata;

@end
