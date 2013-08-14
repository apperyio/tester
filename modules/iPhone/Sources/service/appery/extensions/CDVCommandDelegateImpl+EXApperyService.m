//
//  CDVCommandDelegateImpl+EXApperyService.m
//  Appery
//
//  Created by Sergey Seroshtan on 21.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "CDVCommandDelegateImpl+EXApperyService.h"
#import <Cordova/CDVViewController.h>

@implementation CDVCommandDelegateImpl (EXApperyService)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (NSString *) pathForResource: (NSString *)resourcepath {
    return [_viewController.wwwFolderName stringByAppendingPathComponent: resourcepath];
}
#pragma clang diagnostic pop

@end
