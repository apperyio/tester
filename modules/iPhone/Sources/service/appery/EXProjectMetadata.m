//
//  EXProjectMetadata.m
//  Appery
//
//  Created by Sergey Seroshtan on 07/31/12.
//  Copyright 2012 Exadel Inc. All rights reserved.
//

#import "EXProjectMetadata.h"

static NSString *const kProjectId = @"id";
static NSString *const kProjectCreationDate = @"creationDate";
static NSString *const kProjectModifiedDate = @"modifiedDate";
static NSString *const kProjectCreator = @"creator";
static NSString *const kProjectDisabled = @"disabled";
static NSString *const kProjectGuid = @"guid";
static NSString *const kProjectName = @"name";
static NSString *const kProjectOpenWith = @"openWith";
static NSString *const kProjectPushNotification = @"pushNotification";
static NSString *const kProjectSharedWithSupport = @"sharedWithSupport";
static NSString *const kProjectSharedWithSupportBy = @"sharedWithSupportBy";
static NSString *const kProjectType = @"type";

#pragma mark - Private interface declaration

@interface EXProjectMetadata ()

/**
 * Format date specifiied in milliseconds (from 1970 year) to convinient string representation.
 */
- (NSString *) formatDateFromMiliseconds: (NSNumber *) milliseconds;

/**
 * @return - YES if specified value is nil or it's string representation is equal to "null"
 *         - NO - otherwise
 */
- (BOOL) isEmptyValue: (id) value;

/**
 * @returns - 'value' if it is not empty (@see isEmptyValue: method) or nil otherwise
 */
- (id) getCorrectValue: (id) value;

@end

@implementation EXProjectMetadata

#pragma mark - Initialization

- (id) initWithMetadata: (NSDictionary *) metadata
{
    if (self = [super init]) {
        self._id =  [self getCorrectValue:[metadata objectForKey: kProjectId]];
        self.creationDate =  [self getCorrectValue:[metadata objectForKey: kProjectCreationDate]];
        if (self.creationDate == nil) {
            self.creationDate = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceReferenceDate]];
        }
        self.modifiedDate =  [self getCorrectValue:[metadata objectForKey: kProjectModifiedDate]];
        if (self.modifiedDate == nil) {
            self.modifiedDate = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceReferenceDate]];
        }
        self.creator = [self getCorrectValue:[metadata objectForKey: kProjectCreator]];
        self.disabled = [self getCorrectValue:[metadata objectForKey: kProjectDisabled]];
        self.guid = [self getCorrectValue:[metadata objectForKey: kProjectGuid]];
        self.name = [self getCorrectValue:[metadata objectForKey: kProjectName]];
        self.openWith = [self getCorrectValue:[metadata objectForKey: kProjectOpenWith]];
        self.pushNotification = [self getCorrectValue:[metadata objectForKey: kProjectPushNotification]];
        self.sharedWithSupport = [self getCorrectValue:[metadata objectForKey: kProjectSharedWithSupport]];
        self.sharedWithSupportBy = [self getCorrectValue:[metadata objectForKey: kProjectSharedWithSupportBy]];
        self.type = [self getCorrectValue:[metadata objectForKey: kProjectType]];
    }
    
    return self;
}

#pragma mark - Getters

- (NSString *) formattedModifiedDate
{
    return [self formatDateFromMiliseconds: self.modifiedDate];
}

#pragma mark - Override

- (NSString *) description
{
    return [NSString stringWithFormat: @"guid = %@, name = %@", self.guid, self.name];
}

#pragma mark - Private interface implementation

- (NSString *) formatDateFromMiliseconds:(NSNumber *) milliseconds
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[milliseconds doubleValue] * 0.001];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd kk:mm:ss"];
    
    return [dateFormatter stringFromDate: date];
}

- (BOOL) isEmptyValue: (id)value
{
    return (value == nil) || value == [NSNull null];
}
                    
- (id) getCorrectValue: (id) value
{
    return [self isEmptyValue: value] ? nil : value;
}
    
@end
