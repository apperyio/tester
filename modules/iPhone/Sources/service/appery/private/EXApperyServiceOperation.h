//
//  EXApperyServiceOperation.h
//  Appery
//
//  Created by Sergey Seroshtan on 09.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This class provides common interface to perform operation on appery.io service.
 * @warning  This class should not be used directly
 */
@interface EXApperyServiceOperation : NSObject

/**
 * @name Credential properties
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userPassword;
 */

/**
 * @name Operation properties
 */
@property (nonatomic, assign, readonly) BOOL isSuccessfull;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLResponse *responce;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) EXApperyServiceOperation *nextOperation;

/** Accumulator for received data from appery.io service */
@property (nonatomic, strong) NSMutableData *receivedData;

/**
 * Initialize service operation with specified code blocks.
 *
 * @param url - full operation URL
 * @param finished - block of code invoked when operation performing is finished
 */
- (id) initWithCompletionHendler: (void (^)(EXApperyServiceOperation *operation)) completion;

/**
 *  Starts operation asynchronously.
 */
- (void) start;

/**
 * @name Protected section
 */

/**
 * Process received data.
 *
 * @warning Should be implemented by subclasses
 *
 * @param received raw data
 * @return result of processing received data (YES - successfull, NO - otherwise)
 */
- (BOOL) processReceivedData: (NSData *) data;

/**
 * Cancel operation.
 */
- (void) cancel;

@end
