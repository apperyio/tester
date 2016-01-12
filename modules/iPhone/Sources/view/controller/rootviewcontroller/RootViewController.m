//
//  RootViewController.m
//  Appery.io
//

#import "RootViewController.h"
#import "RootViewControllerManager.h"
#import "EXMainWindowAppDelegate.h"

#import "UIViewController+RotationManagement.h"

@implementation RootViewController

#pragma mark - Private class logic

- (UIViewController *)childResponsibleForRotation
{
    for (UIViewController *child in self.childViewControllers) {
        if ([child managesRotation]) {
            return child;
        }
    }
    
    return nil;
}

#pragma mark - Overloaded UIViewController methods

- (void)loadView
{
    UIWindow *window = [EXMainWindowAppDelegate mainWindow];
    CGRect viewFrame = window.bounds;
    self.view = [[UIView alloc] initWithFrame:viewFrame];
    self.view.backgroundColor = [UIColor clearColor];
}

#pragma mark - Interface rotation handling

- (BOOL)shouldAutorotate
{
    UIViewController *child = [self childResponsibleForRotation];
    if (nil == child) {
        return YES;
    }
    
    return [child shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIViewController *child = [self childResponsibleForRotation];
    if (nil == child) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return UIInterfaceOrientationMaskAll;
        }
        else {
            return UIInterfaceOrientationMaskAllButUpsideDown;
        }
    }
    else {
        return [child supportedInterfaceOrientations];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIView *sView = self.view;
    CGRect sBounds = sView.bounds;
    
    for (UIViewController *ctrl in self.childViewControllers) {
        UIView *v = ctrl.view;
        if (v.superview != sView) {
            continue;
        }
        
        CGRect vFrame = v.frame;
        if (CGRectIntersectsRect(sBounds, vFrame)) {
            continue;
        }
        
        v.hidden = YES;
    }
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIView *sView = self.view;
    CGRect sBounds = sView.bounds;
    
    for (UIViewController* ctrl in self.childViewControllers) {
        UIView *v = ctrl.view;
        if (v.superview != sView) {
            continue;
        }
        
        CGRect vFrame = v.frame;
        if (CGRectIntersectsRect(sBounds, vFrame)) {
            continue;
        }
        
        v.hidden = NO;
    }
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end
