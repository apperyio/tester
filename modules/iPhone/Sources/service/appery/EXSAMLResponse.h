//
//  EXSAMLResponse.h
//  Appery
//
//  Created by Sergey Tkachenko on 12/3/15.
//  Copyright (c) 2015 Exadel Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EXSAMLResponse : NSObject

- (instancetype)initWithValue:(NSString *)value andActions:(NSString *)action NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy) NSString *action;
@property (nonatomic, copy) NSString *value;

@end

@interface NSURLRequest (SAML)

+ (NSURLRequest *)requestWithSAMLResponce:(EXSAMLResponse *)responce;

@end