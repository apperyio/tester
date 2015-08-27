//
//  UINavigationController+StackUtils.h
//  ClientMobile
//
//  Created by Max Gotlib on 18/04/14.
//  Copyright (c) 2014 UBS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (StackUtils)

- (void)pushTopViewController:(UIViewController*)viewController animated:(BOOL)animated;

@end
