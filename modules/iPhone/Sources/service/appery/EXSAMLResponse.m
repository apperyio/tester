//
//  EXSAMLResponse.m
//  Appery
//
//  Created by Sergey Tkachenko on 12/3/15.
//  Copyright (c) 2015 Exadel Inc. All rights reserved.
//

#import "EXSAMLResponse.h"

#import "NSString+URLUtility.h"

@implementation EXSAMLResponse

- (instancetype)init
{
    return [self initWithValue:nil andActions:nil];
}

- (instancetype)initWithValue:(NSString *)value andActions:(NSString *)action
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _value = value;
    _action = action;
    
    return self;
}

@end

@implementation NSURLRequest (SAML)

+ (NSURLRequest *)requestWithSAMLResponce:(EXSAMLResponse *)responce
{
    NSURL *url = [NSURL URLWithString:responce.action];
    NSMutableURLRequest *SAMLReuest = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:20.0];
    [SAMLReuest setHTTPMethod:@"POST"];
    
    NSString *post = [NSString stringWithFormat:@"SAMLResponse=%@", [responce.value encodedUrlString]];
    NSData   *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    [SAMLReuest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [SAMLReuest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [SAMLReuest setHTTPBody:postData];
    
    return SAMLReuest;
}

@end