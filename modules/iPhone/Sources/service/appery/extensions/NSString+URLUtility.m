//
//  NSString+URLUtility.m
//  Appery
//
//  Created by Sergey Seroshtan on 03.07.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "NSString+URLUtility.h"

@implementation NSString (URLUtility)

- (NSString *) decodedUrlString
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(NULL, (CFStringRef)[self mutableCopy], CFSTR("")));
}

- (NSString *) encodedUrlString
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[self mutableCopy], NULL, 
                                                               (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                               kCFStringEncodingUTF8 ));
}

- (NSString *) URLByAddingResourceComponent: (NSString *)resourcePath
{
    if (self.length > 0) {
        return [self stringByAppendingString: resourcePath];
    } else {
        return [resourcePath copy];
    }
}

- (NSString *) removeTrailingSlashes
{
    if (self.length > 0) {
        NSUInteger nonSlashSymbolPos = self.length;
        for (; nonSlashSymbolPos > 0; --nonSlashSymbolPos) {
            if ([self characterAtIndex: nonSlashSymbolPos - 1] != '/') {
                break;
            }
        }
        return [self substringToIndex: nonSlashSymbolPos];
    } else {
        return [self copy];
    }
}

@end
