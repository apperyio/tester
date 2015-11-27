//
//  RootNavigationController.m
//  Appery.io
//

#import "RootNavigationController.h"
#import "NSObject+Utils.h"

#warning Should be reviewed.
//When both the NavigationController and the TopViewController have the same orientation then IOS creates the following call sequence:
//
// - SomeTopViewController ViewWillDisappear
// - WillShowViewController viewController: the new TopViewController
// - SomeTopViewController ViewDidDisappear
// - DidShowViewController viewController: the new TopViewController
//
//When the NavigationController and the TopViewController have different orientations then the NavigationController delegate is not called as you described. The call sequence is therefore:
//
// - SomeTopViewController ViewWillDisappear
// - SomeTopViewController ViewDidDisappear

@interface RootNavigationControllerDelegate : NSObject <UINavigationControllerDelegate>

@property (assign, nonatomic) BOOL didCalled;

@end

@interface RootNavigationController ()

@property (strong, nonatomic) id<UINavigationControllerDelegate> desiredDelegate;
@property (strong, nonatomic) RootNavigationControllerDelegate* realDelegate;

@end

@implementation RootNavigationController

@synthesize desiredDelegate = _desiredDelegate;
@synthesize realDelegate = _realDelegate;


#pragma mark - Navigation logic overrides

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.realDelegate.didCalled = NO;
    
    [super pushViewController:viewController animated:animated];
    
    if (!self.realDelegate.didCalled) {
        [self.realDelegate navigationController:self willShowViewController:self.topViewController animated:animated];
        [self.realDelegate navigationController:self didShowViewController:self.topViewController animated:animated];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    self.realDelegate.didCalled = NO;
    
    UIViewController *vc = [super popViewControllerAnimated:animated];
    
    if (!self.realDelegate.didCalled) {
        [self.realDelegate navigationController:self willShowViewController:self.topViewController animated:animated];
        [self.realDelegate navigationController:self didShowViewController:self.topViewController animated:animated];
    }
    
    return vc;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.realDelegate.didCalled = NO;
    
    NSArray *stack = [super popToViewController:viewController animated:animated];
    
    if (!self.realDelegate.didCalled) {
        [self.realDelegate navigationController:self willShowViewController:self.topViewController animated:animated];
        [self.realDelegate navigationController:self didShowViewController:self.topViewController animated:animated];
    }
    
    return stack;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    self.realDelegate.didCalled = NO;
    
    NSArray* stack = [super popToRootViewControllerAnimated:animated];
    
    if (!self.realDelegate.didCalled) {
        [self.realDelegate navigationController:self willShowViewController:self.topViewController animated:animated];
        [self.realDelegate navigationController:self didShowViewController:self.topViewController animated:animated];
    }
    
    return stack;
}

#pragma mark - View management

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.desiredDelegate = self.delegate;
    self.realDelegate = [[RootNavigationControllerDelegate alloc] init];
    self.delegate = self.realDelegate;
}

#pragma mark - Rotation management

- (BOOL)managesRotation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return ([self.topViewController shouldAutorotate]);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    }
    else {
        return [self.topViewController supportedInterfaceOrientations];
    }
}

@end

@implementation RootNavigationControllerDelegate

@synthesize didCalled = _didCalled;

- (instancetype)init
{
    if (self = [super init]) {
        _didCalled = NO;
    }
    
    return self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    RootNavigationController *nc = [navigationController as:[RootNavigationController class]];
    [nc.desiredDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    self.didCalled = YES;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    RootNavigationController *nc = [navigationController as:[RootNavigationController class]];
    [nc.desiredDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
}

@end
