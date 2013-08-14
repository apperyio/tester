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
static NSString *const kShouldRememberPassword = @"shouldRememberPassword";

@implementation EXUserSettings

#pragma mark - Public Properties sinthesize

@synthesize userName;
@synthesize shouldRememberMe;
@synthesize shouldRememberPassword;

#pragma mark - NSCoding protocol implementation

- (id) initWithCoder: (NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.userName = [decoder decodeObjectForKey: kUserName];
        self.shouldRememberMe = [decoder decodeBoolForKey: kShouldRememberMe];
        self.shouldRememberPassword = [decoder decodeBoolForKey: kShouldRememberPassword];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)encoder {
    [encoder encodeObject: self.userName forKey: kUserName];
    [encoder encodeBool: self.shouldRememberMe forKey: kShouldRememberMe];
    [encoder encodeBool: self.shouldRememberPassword forKey: kShouldRememberPassword];
}

#pragma mark - Life cycle

- (void) dealloc {
    self.userName = nil;
    [super dealloc];
}

@end
