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

#pragma mark - NSCoding protocol implementation

- (id) initWithCoder: (NSCoder *)decoder
{
    if (self = [super init]) {
        self.userName = [decoder decodeObjectForKey: kUserName];
        self.shouldRememberMe = [decoder decodeBoolForKey: kShouldRememberMe];
        self.sortMethodType = [decoder decodeIntForKey:kSortMethod];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)encoder
{
    [encoder encodeObject: self.userName forKey: kUserName];
    [encoder encodeBool: self.shouldRememberMe forKey: kShouldRememberMe];
    [encoder encodeInteger:self.sortMethodType forKey:kSortMethod];
}

@end
