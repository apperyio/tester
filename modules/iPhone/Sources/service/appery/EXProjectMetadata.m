//
//  EXProjectMetadata.m
//  Appery
//
//  Created by Sergey Seroshtan on 07/31/12.
//  Copyright 2012 Exadel Inc. All rights reserved.
//

#import "EXProjectMetadata.h"

static NSString *const kProjectId = @"id";
static NSString *const kProjectName = @"name";
static NSString *const kProjectFeatured = @"featured";
static NSString *const kProjectModifyDate = @"lastedited";
static NSString *const kProjectCreationDate = @"created";
static NSString *const kProjectSubmissionDate = @"submissionDate";
static NSString *const kProjectModifier = @"lasteditor";
static NSString *const kProjectOwner = @"owner";
static NSString *const kProjectLink = @"link";
static NSString *const kProjectShowcaseLink = @"showcaselink";
static NSString *const kProjectDescription = @"description";
static NSString *const kProjectFolderId = @"owner";
static NSString *const kProjectHtmlBundle = @"htmlBundle";
static NSString *const kProjectIsDisabled = @"isDisabled";

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

- (id) initWithMetadata: (NSDictionary *) metadata {
    self = [super init];
    if (self) {
        self.identifier =  [self getCorrectValue:[metadata objectForKey: kProjectId]];
        self.name = [self getCorrectValue:[metadata objectForKey: kProjectName]];
        self.owner = [self getCorrectValue:[metadata objectForKey: kProjectOwner]];
        self.featured = [self getCorrectValue:[metadata objectForKey: kProjectFeatured]];
        self.modifier = [self getCorrectValue:[metadata objectForKey: kProjectModifier]];
        self.link = [self getCorrectValue:[metadata objectForKey: kProjectLink]];
        self.description = [self getCorrectValue:[metadata objectForKey: kProjectDescription]];
        self.htmlBundle = [self getCorrectValue:[metadata objectForKey: kProjectHtmlBundle]];
        self.showcaseLink = [self getCorrectValue:[metadata objectForKey: kProjectShowcaseLink]];
        self.creationDate = [self getCorrectValue:[metadata objectForKey: kProjectCreationDate]];
        self.modifyDate = [self getCorrectValue:[metadata objectForKey: kProjectModifyDate]];
        self.submissionDate = [self getCorrectValue:[metadata objectForKey: kProjectSubmissionDate]];
        self.isDisabled = [self getCorrectValue:[metadata objectForKey: kProjectIsDisabled]];
    }
    return self;
}

#pragma mark - Memory management

- (void) dealloc  {
    self.identifier = nil;
    self.name = nil;
    self.owner = nil;
    self.featured = nil;
    self.modifier = nil;
    self.link = nil;
    self.description = nil;
    self.htmlBundle = nil;
    self.showcaseLink = nil;
    self.isDisabled = nil;
    self.creationDate = nil;
    self.modifyDate = nil;
    self.submissionDate = nil;
    [super dealloc];
}

#pragma mark - Getters

- (NSString *) formattedCreationDate {
    return [self formatDateFromMiliseconds: self.creationDate];
}

- (NSString *) formattedModifyDate {
    return [self formatDateFromMiliseconds: self.modifyDate];
}

- (NSString *) formattedSubmissionDate {
    return [self formatDateFromMiliseconds: self.submissionDate];
}

#pragma mark Override

- (NSString *) description {
    return [NSString stringWithFormat: @"id = %@, name = %@", self.identifier, self.name];
}


#pragma mark - Private interface implementation

- (NSString *) formatDateFromMiliseconds:(NSNumber *) milliseconds {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[milliseconds doubleValue] * 0.001];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    @try {
        [dateFormatter setDateFormat:@"yyyy-MM-dd kk:mm:ss"];
        return [dateFormatter stringFromDate: date];
    }
    @finally {
        [dateFormatter release];
    }
}

- (BOOL) isEmptyValue: (id)value {
    return (value == nil) || value == [NSNull null];
}
                    
- (id) getCorrectValue: (id) value {
    return [self isEmptyValue: value] ? nil : value;
}
    
@end
