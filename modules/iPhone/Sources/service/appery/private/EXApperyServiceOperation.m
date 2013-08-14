//
//  EXApperyServiceOperation.m
//  Appery
//
//  Created by Sergey Seroshtan on 09.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXApperyServiceOperation.h"

#pragma mark - Private interface declaration
@interface EXApperyServiceOperation () <NSURLConnectionDelegate> {
@private    
    /** Reference to connection */
    NSURLConnection *_connection;

    /** Accumulator for received data from appery.io service */
    NSMutableData *_receivedData;
    
    /**
     * Finished code block reference
     */
    void (^_completion)(EXApperyServiceOperation *);
}
@end

@implementation EXApperyServiceOperation

@synthesize userName = _userName;
@synthesize userPassword = _userPassword;

@synthesize isSuccessfull = _isSuccessfull;
@synthesize error = _error;

#pragma mark - Life cycle

- (id) initWithURL:(NSURL *)url completion: (void (^)(EXApperyServiceOperation *))completion {
    NSAssert(url != nil, @"Operation URL is udefined");
    NSAssert(completion != nil, @"completion callback block is not defined");

    self = [super init];
    if (self) {
        _completion = [completion copy];
        NSURLRequest *operationRequest = [NSURLRequest requestWithURL: url
                                                          cachePolicy: NSURLRequestUseProtocolCachePolicy 
                                                      timeoutInterval: 20.0];
        _connection = [[NSURLConnection alloc] initWithRequest: operationRequest delegate: self startImmediately: NO];
        _receivedData = [[NSMutableData alloc] init];

    }
    return self;
}

- (void) dealloc {
    self.userPassword = nil;
    self.userPassword = nil;
    self.error = nil;
    
    if (_completion) {
        [_completion release];
        _completion = nil;
    }
    [super dealloc];
}

#pragma mark - Public interface implementation
- (void) start {
    NSAssert(_connection != nil, @"Connection was not initialized");
    [_connection start];
}

- (void) cancel {
    [_connection cancel];
}

#pragma mark - Protected interface
- (BOOL) processReceivedData: (NSData *)data {
    // Do nothing for operations wich do not need data processing
    return YES;
}

#pragma mark - NSURLConnectionDelegate protocol implementation
- (void) connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response {
    NSAssert(_receivedData != nil, @"receivedData property was not initialized");
    _receivedData.length = 0;
}

- (void) connection: (NSURLConnection *)connection didReceiveData: (NSData *)data {
    [_receivedData appendData: data];
}

- (void) connectionDidFinishLoading: (NSURLConnection *)connection {
    [connection release];

    _isSuccessfull = [self processReceivedData: _receivedData];

    if(_completion) {
        _completion(self);
    }
}


- (BOOL) connection:(NSURLConnection *)connection
        canAuthenticateAgainstProtectionSpace: (NSURLProtectionSpace *)protectionSpace {
    return YES;
}

- (void) connection:(NSURLConnection *)connection
        didReceiveAuthenticationChallenge:( NSURLAuthenticationChallenge *)challenge {
    [self connection: connection willSendRequestForAuthenticationChallenge: challenge];
}

- (void) connection: (NSURLConnection *) connection
        willSendRequestForAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {
    if ([challenge previousFailureCount] == 0) {
        
        NSURLCredential *credential = [NSURLCredential credentialWithUser: self.userName
                                                                 password: self.userPassword
                                                              persistence: NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential: credential forAuthenticationChallenge: challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void) connection: (NSURLConnection *)connection didFailWithError: (NSError *)error {
    [connection release];
    _isSuccessfull = NO;
    
    if (error.code == kCFURLErrorUserCancelledAuthentication) {
        NSString *loginErrorDomain = NSLocalizedString(@"User name or password are incorrect",
                                                       @"Login failed message due to illegal credentials");
        self.error = [NSError errorWithDomain: loginErrorDomain code: 0 userInfo: nil];

    } else {
        self.error = error;
    }
    if(_completion) {
        _completion(self);
    }
}

@end
