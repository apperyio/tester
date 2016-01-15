//
//  EXApperyService.h
//  Appery
//
//  Created by Sergey Seroshtan on 30.07.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EXProjectMetadata.h"

/**
 * Provides interface to communicate with appery.io service.
 */
@interface EXApperyService : NSObject

/**
 * Configures service to the specified base address.
 */
@property (nonatomic, strong) NSString *baseUrl;

/**
 * @name Service methods
 */

/**
 * Login specified user to the service.
 *
 * @param userName - user name (e-mail)
 * @param password - user password
 * @param succeed  - block of code invoked when operation is successfull 
 * @param failed   - block of code invoked when operation is failed, error parameter describes details
 */
- (void)loginWithUsername:(NSString *)userName password:(NSString *)password
                  succeed:(void (^)(NSArray *projectsMetadata))succeed
                   failed:(void (^)(NSError *error))failed;

/**
 * Logout current user from the service and make quick logout (@see quickLogout).
 *
 * @param succeed - block of code invoked when operation is successfull 
 * @param failed  - block of code invoked when opeartion is failed, error parameter describes details
 *                  if logout:failed: opeartion is failed
 */
- (void)logoutSucceed:(void(^)(void))succeed failed:(void(^)(NSError *error))failed;

/**
 * Interrupt all appery.io service operation.
 */
- (void)cancelAllOperation;

/**
 * Load projects from the service.
 *
 * @param succeed - block of code invoked when operation is successfull,
 *                  projectsMetadata parameter contains array of EXProjectMetadata objects
 * @param failed  - block of code invoked when oeration is failed, error parameter describes details
 */
- (void)loadProjectsMetadata:(void (^)(NSArray *projectsMetadata))succeed failed:(void (^)(NSError *error))failed;

/**
 * Load project correspond to specified poject metadata and store it to the specified folder.
 *
 * @param projectMetadata       - project metadata
 * @param succeed - block of code invoked when operation is successfull, where projectLocation parameter contains full
 *                  path to the uzipped project location and startPageName parameter contains root html page name
 * @param failed  - block of code invoked when operation is failed, error parameter describes details
 */
- (void)loadProjectForMetadata:(EXProjectMetadata *)projectMetadata
                       succeed:(void (^)(NSString *projectLocation, NSString *startPageName))succeed
                        failed:(void (^)(NSError *error)) failed;

/**
 * Load project correspond to specified poject code and store it to the specified folder.
 *
 * @param appCode - project code
 * @param succeed - block of code invoked when operation is successfull, where projectLocation parameter contains full
 *                  path to the uzipped project location and startPageName parameter contains root html page name
 * @param failed  - block of code invoked when operation is failed, error parameter describes details
 */
- (void)loadProjectForAppCode:(NSString *)appCode
                      succeed:(void (^)(NSString *projectLocation, NSString *startPageName))succeed
                       failed:(void (^)(NSError *error))failed;

@end
