//
//  NSThread+BlockExecution.m
//

#import "NSThread+BlockExecution.h"

@interface NSThread (BlockExecutionPrivate)

- (void)__performBlock:(void(^)(void))block;

@end

@implementation NSThread (BlockExecutionPrivate)

- (void)__performBlock:(void(^)(void))block {
    if (block != nil) {
        block();
    }
}

@end

@implementation NSThread (BlockExecution)

- (void)performBlockAsync:(void(^)(void))block {
    if ([NSThread currentThread] == self) {
        block();
        return;
    }
    
    [self performSelector:@selector(__performBlock:) onThread:self withObject:block waitUntilDone:NO];
}

- (void)performBlockSync:(void(^)(void))block {
    if ([NSThread currentThread] == self) {
        block();
        return;
    }
    
    [self performSelector:@selector(__performBlock:) onThread:self withObject:block waitUntilDone:YES];
}

@end
