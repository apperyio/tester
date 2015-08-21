//
//  NSObject+Utils.m
//

#import "NSObject+Utils.h"

@implementation NSObject (Utils)

- (id)as:(Class)expectedClass {
    if ([self isKindOfClass:expectedClass]) {
        return self;
    }
    return nil;
}

- (id)asStringOrNumber {
    if ([self isKindOfClass:[NSString class]]) {
        return self;
    }
    if([self isKindOfClass:[NSNumber class]]) {
        return self;
    }
    return nil;
}

@end
