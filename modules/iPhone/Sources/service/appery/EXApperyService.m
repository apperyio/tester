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
#import "NSString+URLUtility.h"
#import "Ono.h"
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

/**
 * Contains current executing operation reference. Used be cancelCurrentOperation method.
 */
@property (nonatomic, strong) EXApperyServiceOperation *currentOperation;

/**
 * Execute with HTML document
 */
- (NSError *) executeFormFromData:(NSData *) data completion:(void(^)(ONOXMLDocument *document))completion;

/**
 * Filter HTML source, remove coments
 */
- (NSString *) filterHtml:(NSString *) html;

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

@synthesize userName = _userName;
@synthesize userPassword = _userPassword;

#pragma mark - Lifecycle

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
    
    [self throwExceptionIfServiceIsLoggedIn];
    
    NSString *eUserName = [userName encodedUrlString];
    NSString *ePassword = [password encodedUrlString];
    NSString *eTarget = [[[@"https://" stringByAppendingString: self.baseUrl] URLByAddingResourceComponent: @"/app/"] encodedUrlString];
    NSString *loginString = [[@"https://idp." stringByAppendingString: self.baseUrl] URLByAddingResourceComponent: LOGIN_PATH_URL_STRING];
    loginString = [NSString stringWithFormat:@"%@?cn=%@&pwd=%@&target=%@", loginString , eUserName, ePassword, eTarget];
    NSURL *loginUrl = [NSURL URLWithString:loginString];
    NSMutableURLRequest *loginRequest = [NSMutableURLRequest requestWithURL:loginUrl
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:20.0];
    // I
    EXApperyServiceOperation *first = [[EXApperyServiceOperation alloc] initWithCompletionHendler:^(EXApperyServiceOperation *operation) {
        if (operation.isSuccessfull)
        {
            [self executeFormFromData:operation.receivedData completion:^(ONOXMLDocument *document) {
                [document.rootElement enumerateElementsWithXPath:@"BODY/FORM" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
                    [loginRequest setHTTPMethod:[element.attributes objectForKey:@"METHOD"]];
                    [loginRequest setURL:[NSURL URLWithString:[element.attributes objectForKey:@"ACTION"]]];
                }];
                
                [document.rootElement enumerateElementsWithXPath:@"BODY/FORM/INPUT" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
                    NSString *encoded = [[element.attributes valueForKey:@"VALUE"] encodedUrlString];
                    NSString *post = [NSString stringWithFormat:@"%@=%@", [element.attributes valueForKey:@"NAME"], encoded];
                    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
                    [loginRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
                    [loginRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                    [loginRequest setHTTPBody:postData];
                }];
            }];
            
            operation.nextOperation.request = loginRequest;
            self.currentOperation = operation.nextOperation;
            [operation.nextOperation start];
        }
        else
        {
            if (operation.error == nil)
            {
                NSDictionary *errInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed", nil),
                                          NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Incorrect email address or password", nil)};
                operation.error = [[NSError alloc] initWithDomain:APPERI_SERVICE_ERROR_DOMAIN code:0 userInfo:errInfo];
            }
            
            failed(operation.error);
            self.currentOperation = nil;
        }
    }];
    
    // II
    EXApperyServiceOperation *second = [[EXApperyServiceOperation alloc] initWithCompletionHendler:^(EXApperyServiceOperation *operation) {
        if (operation.isSuccessfull)
        {
            [self changeLoggedStatusTo: YES];
            [self rememberUserName: userName password: password];
            
            NSString *projectsUrlStr = [[@"https://" stringByAppendingString: self.baseUrl] URLByAddingResourceComponent: PROJECTS_PATH_URL_STRING];
            NSURL *projectsUrl = [NSURL URLWithString:projectsUrlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:projectsUrl
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:20.0];
            [request setURL:projectsUrl];
            [request setAllHTTPHeaderFields:@{@"Content-Type": @"application/json"}];
            
            operation.nextOperation.request = request;
            self.currentOperation = operation.nextOperation;
            [operation.nextOperation start];
        }
        else
        {
            failed(operation.error);
            self.currentOperation = nil;
        }
    }];
    
    // III
    EXApperyServiceOperationLoadProjectsMetadata *third = [[EXApperyServiceOperationLoadProjectsMetadata alloc] initWithCompletionHendler:^(EXApperyServiceOperation *operation) {
        if (operation.isSuccessfull)
        {
            succeed(((EXApperyServiceOperationLoadProjectsMetadata *)operation).projectsMetadata);
        }
        else
        {
            failed(operation.error);
        }
        self.currentOperation = nil;
    }];
    
    //Initialize start
    first.request = loginRequest;
    self.currentOperation = first;
    
    first.nextOperation = second;
    second.nextOperation = third;
    
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
    
    [self throwExceptionIfServiceIsLoggedOut];
    
    EXApperyServiceOperation *logoutOperation = [[EXApperyServiceOperation alloc] initWithCompletionHendler: ^(EXApperyServiceOperation *operation) {
            if (operation.isSuccessfull) {
                succeed();
            } else {
                failed(operation.error);
            }
        
            self.currentOperation = nil;
        }];
    
    self.currentOperation = logoutOperation;
    
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
    
    [self throwExceptionIfServiceIsLoggedOut];
    
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
    
    [self throwExceptionIfServiceIsLoggedOut];
    
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
    loadProjectOperation.request = loadProjectRequest;
    self.currentOperation = loadProjectOperation;
    
    [self.currentOperation start];
}

- (void) loadProjectForAppCode: (NSString *) appCode
                       succeed: (void (^)(NSString *projectLocation, NSString *startPageName)) succeed
                        failed: (void (^)(NSError *error)) failed
{
    NSAssert(appCode != nil, @"application code is undefined");
    NSAssert(succeed != nil, @"succeed callback block is not specified");
    NSAssert(failed != nil, @"failed callback block is not specified");
    
    EXApperyServiceOperationLoadProject *loadProjectOperation = [[EXApperyServiceOperationLoadProject alloc] initWithCompletionHendler: ^(EXApperyServiceOperation *operation) {
        EXApperyServiceOperationLoadProject *loadProjectOperation = (EXApperyServiceOperationLoadProject *)operation;
        
        if (operation.isSuccessfull) {
            succeed(loadProjectOperation.projectLocation, loadProjectOperation.projectStartPageName);
        } else {
            //404 (Invalid access code) - No app is associated with this code.
            //403 (Invalid access code) - The code you have entered has expired or no longer valid.
            
            if(((NSHTTPURLResponse *)operation.responce).statusCode == 404)
            {
                NSDictionary *errInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed", nil),
                                          NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"No app is associated with this code", nil)};
                operation.error = [[NSError alloc] initWithDomain:APPERI_SERVICE_ERROR_DOMAIN code:0 userInfo:errInfo];
            }
            else if(((NSHTTPURLResponse *)operation.responce).statusCode == 403)
            {
                NSDictionary *errInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed", nil),
                                          NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"The code you have entered has expired or no longer valid", nil)};
                operation.error = [[NSError alloc] initWithDomain:APPERI_SERVICE_ERROR_DOMAIN code:0 userInfo:errInfo];
            }
            
            failed (operation.error);
        }
        
        self.currentOperation = nil;
    }];
    
    NSString *loadProjectURLStr = [[@"https://" stringByAppendingString: self.baseUrl] URLByAddingResourceComponent:[NSString stringWithFormat:SHARE_PROJECT_PATH_URL_STRING, appCode]];
    NSURL *loadProjectURL = [NSURL URLWithString:loadProjectURLStr];
    NSMutableURLRequest *loadProjectRequest = [NSMutableURLRequest requestWithURL:loadProjectURL
                                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                  timeoutInterval:60.0];
    
    EXProjectMetadata *projectMetadata = [[EXProjectMetadata alloc] initWithMetadata: @{@"name": appCode}];
    loadProjectOperation.projectMetadata = projectMetadata;
    loadProjectOperation.request = loadProjectRequest;
    self.currentOperation = loadProjectOperation;
    
    [self.currentOperation start];
}

#pragma mark - Private interface implementation

- (NSError *) executeFormFromData:(NSData *) data completion:(void(^)(ONOXMLDocument *document))completion
{
    NSError *error = nil;
    if ([data length] > 0)
    {
        NSString *dirtyHtml = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *cleanHtml = [self filterHtml:dirtyHtml];
        ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithData:[cleanHtml dataUsingEncoding:NSUTF8StringEncoding] error:&error];
        
        if(!error && completion)
        {
            completion(document);
        }
        else
        {
            NSLog(@"Parse error");
        }
    }
    return error;
}

- (NSString *) filterHtml:(NSString *) html
{
    NSString *text = nil;
    NSScanner *scanner = [NSScanner scannerWithString:html];
    
    while ([scanner isAtEnd] == NO)
    {
        [scanner scanUpToString:@"<!--" intoString:NULL];
        [scanner scanUpToString:@"-->" intoString:&text];
        
        if (text != nil)
        {
            html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@-->", text] withString:@""];
        }
    }
    return html;
}

- (void) throwExceptionIfServiceIsLoggedOut
{
    if (self.isLoggedOut)
    {
        @throw [NSException exceptionWithName: @"IllegalStateException"
                                       reason: @"Service is already logged out" userInfo: nil];
    }
}

- (void) throwExceptionIfServiceIsLoggedIn
{
    if (self.isLoggedIn)
    {
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
        if ([cookie.name isEqualToString: @"JSESSIONID"] || [cookie.name isEqualToString: @"APP"]) {
            [authenticationCookies addObject: cookie];
        }
    }
    
    return authenticationCookies;
}

@end
