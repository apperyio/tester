//
//  UIDevice+System.m
//

#import "UIDevice+System.h"

@implementation UIDevice (System)

+ (void)executeUnderIOS8AndHigher:(void (^)(void))block {
    assert(block);
    if (block != nil && [[self currentDevice].systemVersion floatValue] >= 8.0f) {
        block();
    }
}

+ (void)executeUnderIOS7AndLower:(void (^)(void))block {
    assert(block);
    if (block != nil && [[self currentDevice].systemVersion floatValue] < 8.0f) {
        block();
    }
}


+ (void)executeUnderIOS7AndHigher:(void (^)(void))block {
    assert(block);
    if(block != nil && [[self currentDevice].systemVersion floatValue] >= 7.0f) {
        block();
    }
}

+ (void)executeUnderIOS6AndLower:(void (^)(void))block {
    assert(block);
    if (block != nil && [[self currentDevice].systemVersion floatValue] < 7.0f) {
        block();
    }
}

@end
