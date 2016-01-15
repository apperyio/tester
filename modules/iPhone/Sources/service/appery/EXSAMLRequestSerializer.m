//
//  EXSAMLRequestSerializer.m
//  Appery
//
//  Created by Sergey Tkachenko on 12/4/15.
//  Copyright 2015 Exadel Inc. All rights reserved.
//

#import "EXSAMLRequestSerializer.h"

#import "NSObject+Utils.h"
#import "NSString+URLUtility.h"

@implementation EXSAMLRequestSerializer

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(nullable id)parameters
                                     error:(NSError * __nullable __autoreleasing *)error
{
    NSMutableURLRequest *SAMLReuest = [super requestWithMethod:method URLString:URLString parameters:nil error:error];
    
    NSString *post = [NSString stringWithFormat:@"SAMLResponse=%@", [[parameters as:[NSString class]] encodedUrlString]];
    NSData   *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    [SAMLReuest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [SAMLReuest setHTTPBody:postData];
    
    return SAMLReuest;
}

@end
