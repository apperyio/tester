//
//  EXProjectControllerActionDelegate.h
//  Appery
//
//  Created by Pavel Gorb on 8/26/15.
//  Copyright (c) 2015 Exadel Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EXProjectMetadata;

@protocol EXProjectControllerActionDelegate <NSObject>

@required
- (void)masterControllerDidLogout;
- (void)masterControllerDidLoadMetadata:(EXProjectMetadata *)metadata;
- (void)masterControllerDidAcquireAppCode:(NSString *)appCode;

@end
