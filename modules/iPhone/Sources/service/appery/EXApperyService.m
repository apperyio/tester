//
//  EXApperyService.m
//  Appery
//
//  Created by Sergey Seroshtan on 30.07.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXApperyService.h"

#import "NSObject+Utils.h"
#import "NSString+URLUtility.h"

#import "AFNetworking.h"
#import "EXSAMLResponse.h"
#import "EXSAMLRequestSerializer.h"
#import "EXSAMLResponseSerializer.h"
#import "EXProjectMetadata.h"
#import "EXProjectsMetadataSerializer.h"
#import "EXProjectExtractionOperation.h"
#import <Cordova/CDVJSON.h>

#pragma mark - Service configure constants

static NSString * const BASE_URL_STRING = @"appery.io";
static NSString * const LOGIN_PATH_URL_STRING = @"/idp/doLogin";
static NSString * const PROJECTS_PATH_URL_STRING = @"/app/rest/projects/";
static NSString * const PROJECT_PATH_URL_STRING = @"/app/project/%@/export/sources/web_resources/";
static NSString * const SHARE_PROJECT_PATH_URL_STRING = @"/app/rest/project/shared/%@/export/sources/WEB_RESOURCES";
static NSString * const LOGOUT_PATH_URL_STRING = @"/app/logout?GLO=true";

#pragma mark - Private interface declaration

@interface EXApperyService ()

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userPassword;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

/**
 * @throw NSException if current service state is logged out.
 */
- (void)throwExceptionIfServiceIsLoggedOut;

/**
 * @throw NSException if current service state is logged in.
 */
- (void)throwExceptionIfServiceIsLoggedIn;

/**
 * Removes local autentication data.
 */
- (void)removeLocalAuthentication;

/**
 * Changes logged status to specified value.
 * 
 * @param status - provide new logged status value.
 */
- (void)changeLoggedStatusTo:(BOOL)status;

/**
 * Remembers specified user's name and user's password to private section;
 */
- (void)rememberUserName:(NSString *)userName password:(NSString *)password;

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

- (instancetype)init
{
    if (self = [super init]) {
        _manager = [AFHTTPRequestOperationManager manager];
    }
    
    return self;
}

#pragma mark - Getters/Setters

- (NSString *)baseUrl
{
    return _baseUrl == nil ? BASE_URL_STRING : _baseUrl;
}

- (void)setBaseUrl:(NSString *)baseUrl
{
    _baseUrl = nil;

    if (baseUrl != nil) {
        _baseUrl = [baseUrl removeTrailingSlashes];
    }
}

- (BOOL)isLoggedIn
{
    return _isLoggedIn;
}

- (BOOL)isLoggedOut
{
    return !self.isLoggedIn;
}

- (NSString *)loggedUserName
{
    return self.userName;
}

#pragma mark - Public interface implementation

- (void)loginWithUsername:(NSString *)userName password:(NSString *)password
                  succeed:(void (^)(NSArray *))succeed
                   failed:(void (^)(NSError *))failed
{
    NSAssert(succeed != nil, @"succeed callback block is not specified");
    NSAssert(failed != nil, @"failed callback block is not specified");
    
    [self throwExceptionIfServiceIsLoggedIn];
    
    // Create login request
    NSString *target = [[[@"https://" stringByAppendingString: self.baseUrl] URLByAddingResourceComponent:@"/app/"] encodedUrlString];
    NSString *loginUrlStr = [[@"https://idp." stringByAppendingString: self.baseUrl] URLByAddingResourceComponent:LOGIN_PATH_URL_STRING];
    NSDictionary *parameters = @{@"cn":userName, @"pwd":password, @"target":target};
    NSURLRequest *request = [self.manager.requestSerializer requestWithMethod:@"GET" URLString:loginUrlStr parameters:parameters error:nil];
    
    __weak __typeof(self)weakSelf = self;
    
    // Create login operation
    AFHTTPRequestOperation *loginOperation = [self.manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, EXSAMLResponse *responce) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        NSURLRequest *SAMLRequest = [[EXSAMLRequestSerializer serializer] requestWithMethod:@"POST" URLString:responce.action parameters:responce.value error:nil];
        AFHTTPRequestOperation *SAMLOperation = [strongSelf.manager HTTPRequestOperationWithRequest:SAMLRequest success:^(AFHTTPRequestOperation * _Nonnull operation, id _Nonnull responseObject) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            [strongSelf changeLoggedStatusTo:YES];
            [strongSelf rememberUserName:userName password:password];
            
            NSString *projectsUrlStr = [[@"https://" stringByAppendingString:strongSelf.baseUrl] URLByAddingResourceComponent:PROJECTS_PATH_URL_STRING];
            NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:projectsUrlStr parameters:nil error:nil];
            
            AFHTTPRequestOperation *projectsOperation = [strongSelf.manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation * _Nonnull operation, id _Nonnull responseObject) {
                succeed([responseObject as:[NSArray class]]);
            } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                failed(error);
            }];
            
            [projectsOperation setResponseSerializer:[EXProjectsMetadataSerializer serializer]];
            
            [strongSelf.manager.operationQueue addOperation:projectsOperation];
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            failed(error);
        }];
        
        AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
        [serializer setAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
        
        [SAMLOperation setResponseSerializer:serializer];
        [strongSelf.manager.operationQueue addOperation:SAMLOperation];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error == nil) {
            NSDictionary *errInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed", nil),
                                      NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Incorrect email address or password", nil)};
            error = [[NSError alloc] initWithDomain:APPERI_SERVICE_ERROR_DOMAIN code:0 userInfo:errInfo];
        }
        
        failed(error);
    }];
    
    [loginOperation setResponseSerializer:[EXSAMLResponseSerializer serializer]];
    [self.manager.operationQueue addOperation:loginOperation];
}

- (void)quickLogout
{
    [self removeLocalAuthentication];
    [self changeLoggedStatusTo:NO];
}

- (void)cancelAllOperation
{
    [self.manager.operationQueue cancelAllOperations];
}

- (void)logoutSucceed:(void (^)(void))succeed failed:(void (^)(NSError *))failed
{
    NSAssert(succeed != nil, @"succeed callback block is not specified");
    NSAssert(failed != nil, @"failed callback block is not specified");
    
    [self throwExceptionIfServiceIsLoggedOut];
    
    NSString *logoutUrlStr = [[@"https://" stringByAppendingString: self.baseUrl] URLByAddingResourceComponent:LOGOUT_PATH_URL_STRING];
    NSURLRequest *request = [self.manager.requestSerializer requestWithMethod:@"GET" URLString:logoutUrlStr parameters:nil error:nil];
    
    AFHTTPRequestOperation *logoutOperation = [self.manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        succeed();
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        failed(error);
    }];
    
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    [serializer setAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    
    [logoutOperation setResponseSerializer:serializer];
    [self.manager.operationQueue addOperation:logoutOperation];
    
    [self quickLogout];
}

- (void)loadProjectsMetadata:(void (^)(NSArray *))succeed failed:(void (^)(NSError *))failed
{
    NSAssert(succeed != nil, @"succeed callback block is not specified");
    NSAssert(failed != nil, @"failed callback block is not specified");
    
    [self throwExceptionIfServiceIsLoggedOut];
    
    NSString *projectsUrlStr = [[@"https://" stringByAppendingString:self.baseUrl] URLByAddingResourceComponent:PROJECTS_PATH_URL_STRING];
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:projectsUrlStr parameters:nil error:nil];
    
    AFHTTPRequestOperation *projectsOperation = [self.manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation * _Nonnull operation, id _Nonnull responseObject) {
        succeed([responseObject as:[NSArray class]]);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        failed(error);
    }];
    
    [projectsOperation setResponseSerializer:[EXProjectsMetadataSerializer serializer]];
    
    [self.manager.operationQueue addOperation:projectsOperation];
}

- (void)loadProjectForMetadata:(EXProjectMetadata *)projectMetadata
                       succeed:(void (^)(NSString *projectLocation, NSString *startPageName))succeed
                        failed:(void (^)(NSError *error))failed
{
    NSAssert(projectMetadata != nil, @"projectMetadata is undefined");
    NSAssert(succeed != nil, @"succeed callback block is not specified");
    NSAssert(failed != nil, @"failed callback block is not specified");
    
    [self throwExceptionIfServiceIsLoggedOut];
    
    NSString *loadProjectUrlStr = [[@"https://" stringByAppendingString: self.baseUrl] URLByAddingResourceComponent:[NSString stringWithFormat:PROJECT_PATH_URL_STRING, projectMetadata.guid]];
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:loadProjectUrlStr parameters:nil error:nil];
    
    AFHTTPRequestOperation *projectsOperation = [self.manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation * _Nonnull operation, id _Nonnull responseObject) {
        // Run extraction operation, like synchronous
        NSOperationQueue *operationQueue = [NSOperationQueue new];
        EXProjectExtractionOperation *extractOperation = [[EXProjectExtractionOperation alloc] initWithName:projectMetadata.name data:[responseObject as:[NSData class]]];
        [operationQueue addOperations:@[extractOperation] waitUntilFinished:YES];
        
        succeed(extractOperation.projectLocation, extractOperation.projectStartPageName);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        failed(error);
    }];
    
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    [serializer setAcceptableContentTypes:[NSSet setWithObject:@"application/zip"]];
    
    [projectsOperation setResponseSerializer:serializer];
    [self.manager.operationQueue addOperation:projectsOperation];
}

- (void)loadProjectForAppCode:(NSString *) appCode
                      succeed:(void (^)(NSString *projectLocation, NSString *startPageName))succeed
                       failed:(void (^)(NSError *error)) failed
{
    NSAssert(appCode != nil, @"application code is undefined");
    NSAssert(succeed != nil, @"succeed callback block is not specified");
    NSAssert(failed != nil, @"failed callback block is not specified");
    
    NSString *loadProjectUrlStr = [[@"https://" stringByAppendingString: self.baseUrl] URLByAddingResourceComponent:[NSString stringWithFormat:SHARE_PROJECT_PATH_URL_STRING, appCode]];
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:loadProjectUrlStr parameters:nil error:nil];
    
    AFHTTPRequestOperation *projectsOperation = [self.manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation * _Nonnull operation, id _Nonnull responseObject) {
        // Run extraction operation, like synchronous
        NSOperationQueue *operationQueue = [NSOperationQueue new];
        EXProjectExtractionOperation *extractOperation = [[EXProjectExtractionOperation alloc] initWithName:appCode data:[responseObject as:[NSData class]]];
        [operationQueue addOperations:@[extractOperation] waitUntilFinished:YES];
        
        succeed(extractOperation.projectLocation, extractOperation.projectStartPageName);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        //404 (Invalid access code) - No app is associated with this code.
        //403 (Invalid access code) - The code you have entered has expired or no longer valid.
        
        if(operation.response.statusCode == 404) {
            NSDictionary *errInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed", nil),
                                      NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"No app is associated with this code", nil)};
            error = [[NSError alloc] initWithDomain:APPERI_SERVICE_ERROR_DOMAIN code:0 userInfo:errInfo];
        }
        else if(operation.response.statusCode == 403) {
            NSDictionary *errInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed", nil),
                                      NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"The code you have entered has expired or no longer valid", nil)};
            error = [[NSError alloc] initWithDomain:APPERI_SERVICE_ERROR_DOMAIN code:0 userInfo:errInfo];
        }
        
        failed(error);
    }];
    
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    [serializer setAcceptableContentTypes:[NSSet setWithObject:@"application/zip"]];
    
    [projectsOperation setResponseSerializer:serializer];
    [self.manager.operationQueue addOperation:projectsOperation];
}

#pragma mark - Private interface implementation

- (void)throwExceptionIfServiceIsLoggedOut
{
    if (self.isLoggedOut) {
        @throw [NSException exceptionWithName:@"IllegalStateException"
                                       reason:@"Service is already logged out" userInfo:nil];
    }
}

- (void)throwExceptionIfServiceIsLoggedIn
{
    if (self.isLoggedIn) {
        @throw [NSException exceptionWithName:@"IllegalStateException"
                                       reason:@"Service is already logged in" userInfo:nil];
    }
}

- (void)changeLoggedStatusTo:(BOOL)status
{
    _isLoggedIn = status;
}

- (void)rememberUserName:(NSString *)userName password:(NSString *)password
{
    NSAssert(userName != nil, @"userName is not specified");
    NSAssert(password != nil, @"password is not specified");
    
    self.userName = userName;
    self.userPassword = password;
}

- (void)removeLocalAuthentication
{
    self.userName = nil;
    self.userPassword = nil;
    
    [self removeAutenticationCookies];
}

- (void)removeAutenticationCookies
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in [self findAuthenticationCookies]) {
        [cookieStorage deleteCookie:cookie];
    }
}

- (NSArray *)findAuthenticationCookies
{
    NSMutableArray *authenticationCookies = [[NSMutableArray alloc] init];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
        if ([cookie.name isEqualToString:@"JSESSIONID"] || [cookie.name isEqualToString:@"APP"]) {
            [authenticationCookies addObject: cookie];
        }
    }
    
    return authenticationCookies;
}

@end
