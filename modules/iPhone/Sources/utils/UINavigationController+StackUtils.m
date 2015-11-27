//
//  UINavigationController+StackUtils.m
//
//  Created by Max Gotlib on 18/04/14.
//

#import "UINavigationController+StackUtils.h"

@implementation UINavigationController (StackUtils)

- (void)pushTopViewController:(UIViewController*)viewController animated:(BOOL)animated
{
    NSAssert(viewController != nil, @"The controller does not have to be nil");
    
    if( viewController == nil || self.topViewController == viewController ) {
        return;
    }
    
    if( [self.viewControllers containsObject:viewController] ) {
        [self popToViewController:viewController animated:animated];
    }
    else {
        [self setViewControllers:@[viewController] animated:animated];
    }
}

@end
