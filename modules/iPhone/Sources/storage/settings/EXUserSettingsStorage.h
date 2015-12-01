//
//  EXUserSettingsStorage.h
//  Appery
//
//  Created by Sergey Seroshtan on 09.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EXUserSettings.h"

/**
 * Provides interface to manage with users settings in permanent store.
 */
@interface EXUserSettingsStorage : NSObject

+ (instancetype)sharedUserSettingsStorage;

+ (instancetype) alloc NS_UNAVAILABLE;
- (instancetype) init  NS_UNAVAILABLE;
- (instancetype) copy  NS_UNAVAILABLE;
+ (instancetype) new   NS_UNAVAILABLE;
- (instancetype) allocWithZone:(NSZone *)zone NS_UNAVAILABLE;
- (instancetype) copyWithZone:(NSZone *)zone  NS_UNAVAILABLE;

/**
 * Stores specified user settings.
 */
- (void)storeSettings:(EXUserSettings *)settings;

/**
 * Removes user settings for the specified user.
 */
- (void)removeSettingsForUser:(NSString *)userName;

/**
 * Retreives last stored user settings.
 *
 * @return last stored user settings
 */
- (EXUserSettings *)retreiveLastStoredSettings;

/**
 * Retreives all stored users settings.
 *
 * @return dictionary where keys is user name and value is correspond user settings (EXUserSettings object) */
- (NSDictionary *)retreiveAllSettings;

@end
