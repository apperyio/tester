//
//  NSString+XMLEscape.m
//

#import "NSString+XMLEscape.h"

@implementation NSString (XMLEscape)

+ (NSString *)stringWithPercentEscapesForString:(NSString *)srcString {
    if (nil == srcString) {
        return nil;
    }
    CFStringRef result = CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)srcString, NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), kCFStringEncodingUTF8);
    return CFBridgingRelease(result);
}

+ (NSString *)stringRemovePercentEscapesForString:(NSString *)srcString {
    if (nil == srcString) {
        return nil;
    }
    
    CFStringRef result = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)srcString, CFSTR(""), kCFStringEncodingUTF8);
    return CFBridgingRelease(result);
}

@end
