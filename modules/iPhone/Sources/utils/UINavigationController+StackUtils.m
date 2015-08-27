//
//  UINavigationController+StackUtils.m
//  ClientMobile
//
//  Created by Max Gotlib on 18/04/14.
//  Copyright (c) 2014 UBS. All rights reserved.
//

#import "UINavigationController+StackUtils.h"

@implementation UINavigationController (StackUtils)

- (void)pushTopViewController:(UIViewController*)viewController animated:(BOOL)animated
{
    assert(viewController != nil);
    if( viewController == nil || self.topViewController == viewController )
    {
        return;
    }
    
    if( [self.viewControllers containsObject:viewController] )
    {
        [self popToViewController:viewController animated:animated];
    }
    else
    {
        [self setViewControllers:@[viewController] animated:animated];
    }
}

@end
