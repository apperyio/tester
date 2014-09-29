//
//  EXUserSettings.h
//  Appery
//
//  Created by Sergey Seroshtan on 03.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This class provides access to user settings which define this application's behaviour.
 */
@interface EXUserSettings : NSObject <NSCoding>

/**
 * @name Properties
 */

/**
 * Defines user name
 */
@property (nonatomic, retain) NSString *userName;

/**
 * Defines if application should to remember current user
 *   to make possible to restore his settings after application launching or not.
 */
@property (nonatomic, assign) BOOL shouldRememberMe;

@end
