//
//  EXSAMLResponse.m
//  Appery
//
//  Created by Sergey Tkachenko on 12/3/15.
//  Copyright (c) 2015 Exadel Inc. All rights reserved.
//

#import "EXSAMLResponse.h"

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
