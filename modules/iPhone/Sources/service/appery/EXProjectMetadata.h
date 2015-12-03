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

@property (nonatomic, strong, readonly) NSNumber *_id;                // Project id
@property (nonatomic, strong, readonly) NSNumber *creationDate;       // Project creation Date
@property (nonatomic, strong, readonly) NSNumber *modifiedDate;       // Project modified Date
@property (nonatomic, strong, readonly) NSString *creator;            // Project creator
@property (nonatomic, strong, readonly) NSNumber *disabled;           // Project disabled
@property (nonatomic, strong, readonly) NSString *guid;               // Project guid
@property (nonatomic, strong, readonly) NSString *name;               // Project name
@property (nonatomic, strong, readonly) NSString *openWith;           // Project open with
@property (nonatomic, strong, readonly) NSNumber *pushNotification;   // Push Notification
@property (nonatomic, strong, readonly) NSString *sharedWithSupport;  // Project shared with support
@property (nonatomic, strong, readonly) NSString *sharedWithSupportBy;// Project shared with support by ...
@property (nonatomic, strong, readonly) NSNumber *type;               // Project type

@property (nonatomic, readonly) NSString *formattedModifiedDate;      // Formatted modified date

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;

/**
 * Initialize this object with values specified in properties dictionary.
 * @param metadata - dictionary with project's metadata received from the appery.io service.
 */
- (instancetype)initWithMetadata:(NSDictionary *)metadata NS_DESIGNATED_INITIALIZER;

@end
