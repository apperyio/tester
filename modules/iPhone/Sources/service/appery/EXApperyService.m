//
//  EXApperyService.m
//  Appery
//
//  Created by Sergey Seroshtan on 30.07.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXApperyService.h"

#import "EXApperyServiceException.h"

#import "EXApperyServiceOperationLoadProjectsMetadata.h"
#import "EXApperyServiceOperationLoadProject.h"

#import "NSString+URLUtility.h"

#pragma mark - Service configure constants

static NSString * const BASE_URL_STRING = @"https://appery.io";
static NSString * const PROJECTS_PATH_URL_STRING = @"/app/rest/user/projects";
static NSString * const LOGIN_PATH_URL_STRING = @"/app/rest/user/login";
static NSString * const LOGOUT_PATH_URL_STRING = @"/app/rest/user/logout";

#pragma mark - Private interface declaration

@interface EXApperyService ()
{
    /**
     * Contains current executing operation reference. Used be cancelCurrentOperation method.
     */
    EXApperyServiceOperation *_currentOperation;
}

@property (nonatomic, retain) NSString *_userName;
@property (nonatomic, retain) NSString *_userPassword;

/**
 * @throw NSException if current service state is logged out.
 */
- (void) throwExceptionIfServiceIsLoggedOut;

/**
 * @throw NSException if current service state is logged in.
 */
- (void) throwExceptionIfServiceIsLoggedIn;

/**
 * Removes local autentication data.
 */
- (void) removeLocalAuthentication;

/**
 * Changes logged status to specified value.
 * 
 * @param status - provide new logged status value.
 */
- (void) changeLoggedStatusTo: (BOOL) status;

/**
 * Remembers specified user's name and user's password to private section;
 */
- (void) rememberUserName: (NSString *) userName password: (NSString *) password;

@end

#pragma mark - Implementation

@implementation EXApperyService

#pragma mark - Public properties synthesize

@synthesize baseUrl = _baseUrl;
@synthesize isLoggedIn = _isLoggedIn;

#pragma mark - Private properties synthesize

@synthesize _userName = __userName;
@synthesize _userPassword = __userPassword;

#pragma mark - Lifecycle

- (id) init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) dealloc
{
    self._userName = nil;
    self._userPassword = nil;
    
    [super dealloc];
}

#pragma mark - Getters/Setters

- (NSString *) baseUrl
{
    return _baseUrl == nil ? BASE_URL_STRING : _baseUrl;
}

- (void) setBaseUrl: (NSString *)baseUrl
{
    [_baseUrl release];
    _baseUrl = nil;

    if (baseUrl != nil) {
        _baseUrl = [[baseUrl removeTrailingSlashes] retain];
    }
}

- (BOOL) isLoggedIn
{
    return _isLoggedIn;
}

- (BOOL) isLoggedOut
{
    return !self.isLoggedIn;
}

- (NSString *)loggedUserName
{
    return self._userName;
}

#pragma mark - Public interface implementation

- (void)loginWithUsername: (NSString *)userName password: (NSString *)password succeed: (void (^)(void))succeed failed: (void (^)(NSError *))failed
{
    NSAssert(succeed != nil, @"succeed callback block is not specified");
    NSAssert(failed != nil, @"failed callback block is not specified");
    
    [self throwExceptionIfServiceIsLoggedIn];
    
    NSString *loginString = [self.baseUrl URLByAddingResourceComponent: LOGIN_PATH_URL_STRING];
    EXApperyServiceOperation *loginOperation = [[EXApperyServiceOperation alloc]
            initWithURL: [NSURL URLWithString: loginString] completion: ^(EXApperyServiceOperation *operation) {
                if (operation.isSuccessfull) {
                    [self changeLoggedStatusTo: YES];
                    [self rememberUserName: userName password: password];
                    succeed();
                } else {
                    failed(operation.error);
                }
                [operation release];
                _currentOperation = nil;
            }];
    
    _currentOperation = loginOperation;
    
    loginOperation.userName = userName;
    loginOperation.userPassword = password;
    [loginOperation start];
}

- (void) quickLogout
{
    [self throwExceptionIfServiceIsLoggedOut];
    [self removeLocalAuthentication];
    [self changeLoggedStatusTo: NO];
}

- (void) cancelCurrentOperation
{
    [_currentOperation cancel];
}

- (void) logoutSucceed: (void (^)(void))succeed failed: (void (^)(NSError *))failed
{
    [self throwExceptionIfServiceIsLoggedOut];

    NSAssert(succeed != nil, @"succeed callback block is not specified");
    NSAssert(failed != nil, @"failed callback block is not specified");

    NSURL *logoutOperationUrl = [NSURL URLWithString:[self.baseUrl URLByAddingResourceComponent: LOGOUT_PATH_URL_STRING]];
    EXApperyServiceOperation *logoutOperation = [[EXApperyServiceOperation alloc] initWithURL: logoutOperationUrl
        completion:^(EXApperyServiceOperation *operation) {
            if (operation.isSuccessfull) {
                succeed();
            } else {
                failed(operation.error);
            }
            [operation release];
            _currentOperation = nil;
        }];

    _currentOperation = logoutOperation;

    logoutOperation.userName = self._userName;
    logoutOperation.userPassword = self._userPassword;
    [logoutOperation start];
    [self quickLogout];
}

- (void) loadProjectsMetadata: (void (^)(NSArray *))succeed failed: (void (^)(NSError *))failed
{
    [self throwExceptionIfServiceIsLoggedOut];

    NSAssert(succeed != nil, @"succeed callback block is not specified");
    NSAssert(failed != nil, @"failed callback block is not specified");
    
    NSURL *loadProjectsUrl = [NSURL URLWithString:[self.baseUrl URLByAddingResourceComponent: PROJECTS_PATH_URL_STRING]];
    EXApperyServiceOperationLoadProjectsMetadata *loadProjectsMetadataOperation =
            [[EXApperyServiceOperationLoadProjectsMetadata alloc] initWithURL:  loadProjectsUrl
            completion:^(EXApperyServiceOperation *operation) {
                if (operation.isSuccessfull) {
                    succeed(((EXApperyServiceOperationLoadProjectsMetadata *)operation).projectsMetadata);
                } else {
                    failed(operation.error);
                }
                [operation release];
                _currentOperation = nil;
            }];
    
    _currentOperation = loadProjectsMetadataOperation;
    
    loadProjectsMetadataOperation.userName = self._userName;
    loadProjectsMetadataOperation.userPassword = self._userPassword;
    [loadProjectsMetadataOperation start];
}

- (void) loadProjectForMetadata: (EXProjectMetadata *) projectMetadata
                        succeed: (void (^)(NSString *projectLocation, NSString *startPageName)) succeed
                         failed: (void (^)(NSError *error)) failed
{
    [self throwExceptionIfServiceIsLoggedOut];
    
    NSAssert(projectMetadata != nil, @"projectMetadata is undefined");
    NSAssert(succeed != nil, @"succeed callback block is not specified");
    NSAssert(failed != nil, @"failed callback block is not specified");
    
    NSURL *loadProjectUrl = [NSURL URLWithString: projectMetadata.htmlBundle];
    
    EXApperyServiceOperationLoadProject *loadProjectOperation =
            [[EXApperyServiceOperationLoadProject alloc] initWithURL: loadProjectUrl
             completion: ^(EXApperyServiceOperation *operation) {
                 EXApperyServiceOperationLoadProject *loadProjectOperation = 
                        (EXApperyServiceOperationLoadProject *)operation;
                 if (operation.isSuccessfull) {
                     succeed(loadProjectOperation.projectLocation, loadProjectOperation.projectStartPageName);
                 } else {
                     failed (operation.error);
                 }
                 [operation release];
                 _currentOperation = nil;
             }];
    
    _currentOperation = loadProjectOperation;
    
    loadProjectOperation.userName = self._userName;
    loadProjectOperation.userPassword = self._userPassword;
    loadProjectOperation.projectMetadata = projectMetadata;
    
    [loadProjectOperation start];
}

#pragma mark - Private interface implementation

- (void) throwExceptionIfServiceIsLoggedOut
{
    if (self.isLoggedOut) {
        @throw [NSException exceptionWithName: @"IllegalStateException"
                                       reason: @"Service is already logged out" userInfo: nil];
    }
}

- (void) throwExceptionIfServiceIsLoggedIn
{
    if (self.isLoggedIn) {
        @throw [NSException exceptionWithName: @"IllegalStateException"
                                       reason: @"Service is already logged in" userInfo: nil];
    }
}

- (void) changeLoggedStatusTo: (BOOL)status
{
    _isLoggedIn = status;
}

- (void) rememberUserName: (NSString *)userName password: (NSString *)password
{
    NSAssert(userName != nil, @"userName is not specified");
    NSAssert(password != nil, @"password is not specified");
    
    self._userName = userName;
    self._userPassword = password;
}

- (void) removeLocalAuthentication
{
    self._userName = nil;
    self._userPassword = nil;
    
    [self removeAutenticationCookies];
}

- (void) removeAutenticationCookies
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in [self findAuthenticationCookies]) {
        [cookieStorage deleteCookie: cookie];
    }
}

- (NSArray *) findAuthenticationCookies
{
    NSMutableArray *authenticationCookies = [[NSMutableArray alloc] init];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
        if ([cookie.name isEqualToString: @"JSESSIONID"] || [cookie.name isEqualToString: @"JSESSIONIDSSO"]) {
            [authenticationCookies addObject: cookie];
        }
    }
    
    return [authenticationCookies autorelease];
}

@end
