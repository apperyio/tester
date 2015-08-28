//
//  EXUserSettings.m
//  Appery
//
//  Created by Sergey Seroshtan on 03.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXUserSettings.h"

#pragma mark - User defaults keys

/**
 * Keys for archiving properties.
 */
static NSString *const kUserName = @"userName";
static NSString *const kShouldRememberMe = @"shouldRememberMe";
static NSString *const kSortMethod = @"sortMethod";

@implementation EXUserSettings

@synthesize userName = _userName;
@synthesize shouldRememberMe = _shouldRememberMe;
@synthesize sortMethodType = _sortMethodType;

#pragma mark - NSCoding protocol implementation

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _userName = [decoder decodeObjectForKey:kUserName];
    _shouldRememberMe = [decoder decodeBoolForKey:kShouldRememberMe];
    _sortMethodType = [decoder decodeIntegerForKey:kSortMethod];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.userName forKey:kUserName];
    [encoder encodeBool:self.shouldRememberMe forKey:kShouldRememberMe];
    [encoder encodeInteger:self.sortMethodType forKey:kSortMethod];
}

@end
