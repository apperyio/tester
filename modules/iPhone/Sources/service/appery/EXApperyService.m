//
//  EXApperyService.m
//  Appery
//
//  Created by Sergey Seroshtan on 30.07.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXApperyService.h"

#import "EXApperyServiceOperationLoadProjectsMetadata.h"
#import "EXApperyServiceOperationLoadProject.h"
#import "EXProjectMetadata.h"
#import <Cordova/CDVJSON.h>
#import "NSString+URLUtility.h"

#pragma mark - Service configure constants

static NSString * const BASE_URL_STRING = @"appery.io";
static NSString * const LOGIN_PATH_URL_STRING = @"/idp/doLogin";
static NSString * const PROJECTS_PATH_URL_STRING = @"/app/rest/projects";
static NSString * const PROJECT_PATH_URL_STRING = @"/app/project/%@/export/sources/web_resources/";
static NSString * const LOGOUT_PATH_URL_STRING = @"/app/logout?GLO=true";

#pragma mark - Private interface declaration

@interface EXApperyService ()

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userPassword;

/**
 * Contains current executing operation reference. Used be cancelCurrentOperation method.
 */
@property (nonatomic, strong) EXApperyServiceOperation *currentOperation;

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

@synthesize userName = _userName;
@synthesize userPassword = _userPassword;

#pragma mark - Lifecycle

- (id) init
{
    if (self = [super init]) {
    
    }
    
    return self;
}

- (void) dealloc
{
    self.userName = nil;
    self.userPassword = nil;
}

#pragma mark - Getters/Setters

- (NSString *) baseUrl
{
    return _baseUrl == nil ? BASE_URL_STRING : _baseUrl;
}

- (void) setBaseUrl: (NSString *)baseUrl
{
    _baseUrl = nil;

    if (baseUrl != nil) {
        _baseUrl = [baseUrl removeTrailingSlashes];
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
    return self.userName;
}

#pragma mark - Public interface implementation

- (void)loginWithUsername: (NSString *)userName password: (NSString *)password
                  succeed: (void (^)(NSArray *))succeed
                   failed: (void (^)(NSError *))failed
{
    NSAssert(succeed != nil, @"succeed callback block is not specified");
    NSAssert(failed != nil, @"failed callback block is not specified");
    
    self.currentOperation = [[EXApperyServiceOperationLoadProjectsMetadata alloc] initWithCompletionHendler: ^(EXApperyServiceOperation *operation) {
        if (operation.isSuccessfull) {
            [self changeLoggedStatusTo: YES];
            [self rememberUserName: userName password: password];
            
            succeed(((EXApperyServiceOperationLoadProjectsMetadata *)operation).projectsMetadata);
        } else {
            failed(operation.error);
        }
        
        self.currentOperation = nil;
    }];
    
    NSString *loginString = [[@"https://idp." stringByAppendingString: self.baseUrl] URLByAddingResourceComponent: LOGIN_PATH_URL_STRING];
    NSString *target = [[@"https://" stringByAppendingString: self.baseUrl] URLByAddingResourceComponent: PROJECTS_PATH_URL_STRING];
    NSString *ePassword = [password encodedUrlString];
    NSString *requestUrlStr = [NSString stringWithFormat:@"%@?cn=%@&pwd=%@&TARGET=%@", loginString, userName, ePassword, target];
    NSURL *loginUrl = [NSURL URLWithString:requestUrlStr];
    NSMutableURLRequest *loginRequest = [NSMutableURLRequest requestWithURL:loginUrl
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:60.0];
    self.currentOperation.request = loginRequest;
    
    [self.currentOperation start];
}

- (void) quickLogout
{
    [self removeLocalAuthentication];
    [self changeLoggedStatusTo: NO];
}

- (void) cancelCurrentOperation
{
    [_currentOperation cancel];
}

- (void) logoutSucceed: (void (^)(void))succeed failed: (void (^)(NSError *))failed
{
    NSAssert(succeed != nil, @"succeed callback block is not specified");
    NSAssert(failed != nil, @"failed callback block is not specified");
    
    EXApperyServiceOperation *logoutOperation = [[EXApperyServiceOperation alloc] initWithCompletionHendler: ^(EXApperyServiceOperation *operation) {
            if (operation.isSuccessfull) {
                succeed();
            } else {
                failed(operation.error);
            }
            operation = nil;
            _currentOperation = nil;
        }];
    
    _currentOperation = logoutOperation;
    
    NSURL *logoutUrl = [NSURL URLWithString:[[@"https://" stringByAppendingString: self.baseUrl] URLByAddingResourceComponent: LOGOUT_PATH_URL_STRING]];
    NSMutableURLRequest *logoutRequest = [NSMutableURLRequest requestWithURL:logoutUrl
                                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                             timeoutInterval:60.0];
    logoutOperation.request = logoutRequest;
    [logoutOperation start];
    
    [self quickLogout];
}

- (void) loadProjectsMetadata: (void (^)(NSArray *))succeed failed: (void (^)(NSError *))failed
{
    NSAssert(succeed != nil, @"succeed callback block is not specified");
    NSAssert(failed != nil, @"failed callback block is not specified");
    
    self.currentOperation = [[EXApperyServiceOperationLoadProjectsMetadata alloc] initWithCompletionHendler: ^(EXApperyServiceOperation *operation) {
        if (operation.isSuccessfull) {
            succeed(((EXApperyServiceOperationLoadProjectsMetadata *)operation).projectsMetadata);
        } else {
            failed(operation.error);
        }
        
        self.currentOperation = nil;
    }];
    
    NSURL *loadProjectsUrl = [NSURL URLWithString:[[@"https://" stringByAppendingString: self.baseUrl] URLByAddingResourceComponent: PROJECTS_PATH_URL_STRING]];
    NSMutableURLRequest *loadProjectsRequest = [NSMutableURLRequest requestWithURL:loadProjectsUrl
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:60.0];
    self.currentOperation.request = loadProjectsRequest;
    
    [self.currentOperation start];
}

- (void) loadProjectForMetadata: (EXProjectMetadata *) projectMetadata
                        succeed: (void (^)(NSString *projectLocation, NSString *startPageName)) succeed
                         failed: (void (^)(NSError *error)) failed
{
    NSAssert(projectMetadata != nil, @"projectMetadata is undefined");
    NSAssert(succeed != nil, @"succeed callback block is not specified");
    NSAssert(failed != nil, @"failed callback block is not specified");
    
    EXApperyServiceOperationLoadProject *loadProjectOperation = [[EXApperyServiceOperationLoadProject alloc] initWithCompletionHendler: ^(EXApperyServiceOperation *operation) {
        EXApperyServiceOperationLoadProject *loadProjectOperation = (EXApperyServiceOperationLoadProject *)operation;
        
        if (operation.isSuccessfull) {
            succeed(loadProjectOperation.projectLocation, loadProjectOperation.projectStartPageName);
        } else {
            failed (operation.error);
        }
        
        self.currentOperation = nil;
    }];
    
    NSURL *loadProjectUrl = [NSURL URLWithString:[[@"https://" stringByAppendingString: self.baseUrl] URLByAddingResourceComponent: [NSString stringWithFormat:PROJECT_PATH_URL_STRING, projectMetadata.guid]]];
    NSMutableURLRequest *loadProjectRequest = [NSMutableURLRequest requestWithURL:loadProjectUrl
                                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                   timeoutInterval:60.0];
    loadProjectOperation.projectMetadata = projectMetadata;
    self.currentOperation = loadProjectOperation;
    self.currentOperation.request = loadProjectRequest;
    
    [self.currentOperation start];
}

#pragma mark - Private interface implementation

- (void) changeLoggedStatusTo: (BOOL)status
{
    _isLoggedIn = status;
}

- (void) rememberUserName: (NSString *)userName password: (NSString *)password
{
    NSAssert(userName != nil, @"userName is not specified");
    NSAssert(password != nil, @"password is not specified");
    
    self.userName = userName;
    self.userPassword = password;
}

- (void) removeLocalAuthentication
{
    self.userName = nil;
    self.userPassword = nil;
    
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
        if ([cookie.name isEqualToString: @"JSESSIONID"] || [cookie.name isEqualToString: @"APPSSO"]) {
            [authenticationCookies addObject: cookie];
        }
    }
    
    return authenticationCookies;
}

@end
