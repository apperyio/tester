//
//  MainCommandQueue.m
//  PhoneGapTest
//
//  Created by sergey tkachenko on 10.02.14.
//
//

#import "MainCommandQueue.h"

@implementation MainCommandQueue
{
    NSInteger _lastCommandQueueFlushRequestId;
}

- (void)resetRequestId
{
    _lastCommandQueueFlushRequestId = 0;
}

- (void)maybeFetchCommandsFromJs:(NSNumber*)requestId
{
    NSInteger rid = [requestId integerValue];

    if (rid > _lastCommandQueueFlushRequestId) {
        _lastCommandQueueFlushRequestId = [requestId integerValue];
        [self fetchCommandsFromJs];
    }
}

@end
