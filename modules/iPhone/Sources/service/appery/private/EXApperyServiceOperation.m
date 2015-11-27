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

/** Status at the end of the operation */
@property (nonatomic, assign, readwrite) BOOL isSuccessfull;

/** Reference to connection */
@property (nonatomic, strong) NSURLConnection *connection;
    
/** Finished code block reference */
@property (nonatomic, copy) void(^completion)(EXApperyServiceOperation *);

@end

@implementation EXApperyServiceOperation

#pragma mark - Life cycle

- (id)initWithCompletionHendler:(void (^)(EXApperyServiceOperation *))completion
{
    NSAssert(completion != nil, @"completion callback block is not defined");

    if (self = [super init]) {
        self.completion = [completion copy];
        self.request = nil;
        self.responce = nil;
    }
    
    return self;
}


#pragma mark - Public interface implementation

- (void)start
{
    NSAssert(self.connection != nil, @"Connection was not initialized");
    
    [self.connection start];
}

- (void)cancel
{
    [self.connection cancel];
}

- (NSMutableData *)receivedData
{
    if (!_receivedData) {
        _receivedData = [[NSMutableData alloc] init];
    }
    
    return _receivedData;
}

- (void)setRequest:(NSURLRequest *)request
{
    if (request != _request) {
        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        self.responce = nil;
        _request = request;
    }
}

#pragma mark - Protected interface

- (BOOL)processReceivedData:(NSData *)data
{
    // Do nothing for operations wich do not need data processing
    return (((NSHTTPURLResponse *)self.responce).statusCode == 200) ? YES : NO;
}

#pragma mark - NSURLConnectionDataDelegate protocol implementation

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSAssert(self.receivedData != nil, @"receivedData property was not initialized");
    
    self.receivedData.length = 0;
    self.responce = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData: data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.connection = nil;
    self.isSuccessfull = [self processReceivedData:self.receivedData];

    if(self.completion) {
        self.completion(self);
    }
}

#pragma mark - NSURLConnectionDelegate protocol implementation

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.connection = nil;
    self.isSuccessfull = NO;
    self.error = error;

    if(self.completion) {
        self.completion(self);
    }
}

@end
