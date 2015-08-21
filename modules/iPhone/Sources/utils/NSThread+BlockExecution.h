//
//  NSThread+BlockExecution.h
//

#import <Foundation/Foundation.h>

@interface NSThread (BlockExecution)

- (void)performBlockAsync:(void(^)(void))block;
- (void)performBlockSync:(void(^)(void))block;

@end
