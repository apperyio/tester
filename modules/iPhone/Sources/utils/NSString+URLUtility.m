//
//  NSString+URLUtility.m
//

#import "NSString+URLUtility.h"

@implementation NSString (URLUtility)

- (NSString *)encodedUrlString
{
    CFStringRef result = CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)[self copy], NULL, CFSTR("￼=,.!$&%[]{}'()*+;@?\n\"<>#\t :/"), kCFStringEncodingUTF8);
    return CFBridgingRelease(result);
}

- (NSString *)decodedUrlString
{
    CFStringRef result = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)[self copy], CFSTR(""), kCFStringEncodingUTF8);
    return CFBridgingRelease(result);
}

- (NSString *)URLByAddingResourceComponent:(NSString *)resourcePath
{
    if (self.length > 0) {
        return [self stringByAppendingString: resourcePath];
    } else {
        return [resourcePath copy];
    }
}

- (NSString *)removeTrailingSlashes
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
