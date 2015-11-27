//
//  EXCredentialsManager.h
//  Appery
//
//  Created by Sergey Seroshtan on 21.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This class provides credentials management such as storing passwords, certificates, keys, and identities.
 *     As the permanent storage keychain is used.
 */
@interface EXCredentialsManager : NSObject

/**
 * Adds password for the specified user.
 *     If password has already exist for the specified user new value will be set. 
 *
 * @param password - user's password
 * @param userName - user's name
 *
 * @return YES - if adding was successfull, NO - otherwise
 */
+ (BOOL)addPassword:(NSString *)password forUser:(NSString *)userName;

/**
 * Removes password for the specified user.
 *
 * @param userName - user's name
 *
 * @return YES - if removing was successfull, NO - otherwise
 */
+ (BOOL)removePasswordForUser:(NSString *)userName;

/**
 * Retreives password for the specified user.
 *
 * @param userName - user's name
 *
 * @return password if it exist for the specified user, nil - otherwise
 */
+ (NSString *)retreivePasswordForUser:(NSString *)userName;

@end
