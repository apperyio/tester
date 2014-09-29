//
//  EXApperyServiceOperation.m
//  Appery
//
//  Created by Sergey Seroshtan on 09.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXApperyServiceOperation.h"

#pragma mark - Private interface declaration

@interface EXApperyServiceOperation () <NSURLConnectionDelegate>

@property (nonatomic, assign, readwrite) BOOL isSuccessfull;

/** Reference to connection */
@property (nonatomic, strong) NSURLConnection *connection;

/** Accumulator for received data from appery.io service */
@property (nonatomic, strong) NSMutableData *receivedData;
    
/**
 * Finished code block reference
 */
@property (nonatomic, copy) void(^completion)(EXApperyServiceOperation *);

@end

@implementation EXApperyServiceOperation

#pragma mark - Life cycle

- (id) initWithURL:(NSURL *)url completion: (void (^)(EXApperyServiceOperation *))completion
{
    NSAssert(url != nil, @"Operation URL is udefined");
    NSAssert(completion != nil, @"completion callback block is not defined");

    self = [super init];
    if (self) {
        self.completion = [completion copy];
        NSURLRequest *operationRequest = [NSURLRequest requestWithURL: url
                                                          cachePolicy: NSURLRequestUseProtocolCachePolicy 
                                                      timeoutInterval: 60.0];
        self.connection = [[NSURLConnection alloc] initWithRequest: operationRequest delegate: self startImmediately: NO];
        self.receivedData = [[NSMutableData alloc] init];

    }
    return self;
}


#pragma mark - Public interface implementation

- (void) start
{
    NSAssert(self.connection != nil, @"Connection was not initialized");
    
    [self.connection start];
}

- (void) cancel
{
    [self.connection cancel];
}

#pragma mark - Protected interface

- (BOOL) processReceivedData: (NSData *)data
{
    // Do nothing for operations wich do not need data processing
    return YES;
}

#pragma mark - NSURLConnectionDelegate protocol implementation

- (void) connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response
{
    NSAssert(self.receivedData != nil, @"receivedData property was not initialized");
    
    self.receivedData.length = 0;
}

- (void) connection: (NSURLConnection *)connection didReceiveData: (NSData *)data
{
    [self.receivedData appendData: data];
}

- (void) connectionDidFinishLoading: (NSURLConnection *)connection
{
    self.connection = nil;
    self.isSuccessfull = [self processReceivedData: self.receivedData];

    if(self.completion) {
        self.completion(self);
    }
}


- (BOOL) connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}

- (void) connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [self connection: connection willSendRequestForAuthenticationChallenge: challenge];
}

- (void) connection: (NSURLConnection *) connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *credential = [NSURLCredential credentialWithUser: self.userName
                                                                 password: self.userPassword
                                                              persistence: NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential: credential forAuthenticationChallenge: challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void) connection: (NSURLConnection *)connection didFailWithError: (NSError *)error
{
    self.connection = nil;
    self.isSuccessfull = NO;
    
    if (error.code == kCFURLErrorUserCancelledAuthentication) {
        self.error = [NSError errorWithDomain: NSLocalizedString(@"User name or password are incorrect", nil) code: 0 userInfo: nil];
    } else {
        self.error = error;
    }
    
    if(self.completion) {
        self.completion(self);
    }
}

@end
