//
//  EXUserSettingsStorage.m
//  Appery
//
//  Created by Sergey Seroshtan on 09.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXUserSettingsStorage.h"

static NSString *const kLastUser = @"lastUser";

@implementation EXUserSettingsStorage

+ (instancetype) sharedUserSettingsStorage
{
    static dispatch_once_t pred;
    static id shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[super alloc] initUniqueUserSettingsStorage];
    });
    
    return shared;
}

- (instancetype) initUniqueUserSettingsStorage
{
    return [super init];
}

#pragma mark - Private service methods

- (NSString *)pathForStorageFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex: 0];
    
    return [documentDirectory stringByAppendingPathComponent: @"users_settings.plist"];
}

- (NSMutableDictionary *)retreiveAllSettingsPrivate
{
    if ([[NSFileManager defaultManager] fileExistsAtPath: [self pathForStorageFile]]) {
        NSData *rawSettings = [NSData dataWithContentsOfFile: [self pathForStorageFile]];
        return [NSMutableDictionary dictionaryWithDictionary: [NSKeyedUnarchiver unarchiveObjectWithData: rawSettings]];
    } else {
        return [NSMutableDictionary dictionary];
    }
}

- (BOOL)storeAllSettingsPrivate:(NSDictionary *)allSettings
{
    NSAssert(allSettings != nil, @"allSettings is not defined");
    
    NSData *serializedData = [NSKeyedArchiver archivedDataWithRootObject: allSettings];
    
    return [serializedData writeToFile: [self pathForStorageFile] atomically: YES];
}

#pragma mark - Public interface implementation

- (void)storeSettings:(EXUserSettings *)settings
{
    NSAssert(settings != nil, @"settings is not defined");
    
    NSMutableDictionary *allSettings = [self retreiveAllSettingsPrivate];
    
    [allSettings setValue: settings forKey: settings.userName];
    [allSettings setValue: settings forKey: kLastUser];

    if ([self storeAllSettingsPrivate: allSettings] == NO) {
        NSLog(@"Settings for user: %@ was not stored.", settings.userName);
    }
}

- (void)removeSettingsForUser:(NSString *)userName
{
    NSAssert(userName != nil, @"userName is undefined");

    NSMutableDictionary *allSettings = [self retreiveAllSettingsPrivate];
    [allSettings removeObjectForKey: userName];
    
    EXUserSettings *lastUserSettings = [allSettings objectForKey: kLastUser];
    
    if (lastUserSettings != nil && [lastUserSettings.userName isEqualToString: userName]) {
        // removed user was last stored, so lastUser shoud removed
        [allSettings removeObjectForKey: kLastUser];
    }
    
    [self storeAllSettingsPrivate: allSettings];
}

- (EXUserSettings *)retreiveLastStoredSettings
{
    return [[self retreiveAllSettingsPrivate] valueForKey: kLastUser];
}

- (NSDictionary *)retreiveAllSettings
{
    NSMutableDictionary *allSettings = [self retreiveAllSettingsPrivate];
    [allSettings removeObjectForKey: kLastUser];
    
    return allSettings;
}
 
@end
