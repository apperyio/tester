//
//  RootViewControllerManager.m
//  Appery.io
//

#include <objc/runtime.h>

#import "RootViewControllerManager.h"
#import "RootNavigationController.h"
#import "RootViewController.h"

#import "UINavigationController+StackUtils.h"
#import "NSObject+Utils.h"

#import "EXMainWindowAppDelegate.h"
#import "EXBaseViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface RootViewControllerManager () <UINavigationControllerDelegate>

/// Instance properties with redefined access.
@property (nonatomic, assign) BOOL isSidebarShown;

@property (atomic, assign) BOOL animating;

@property (atomic, assign) BOOL mainControllerAnimating;

/// Navigation controller for the sidebar content.
@property (nonatomic, strong) UINavigationController* sidebarNavigationController;

/// Navigation controller for the root screen area content.
@property (nonatomic, strong) RootNavigationController* rootNavigationController;

/// Block, which contains navigation action, which is stored due to active navigation taking place.
@property (nonatomic, copy) void (^deferredNavigation)();

/**
 * Replace existing root view controller, attached to the main application window, with the new one.
 *
 * @param rootController New view controller instance to be set as the root.
 * @param animated Perform root view controllers substitution animated.
 * @param completionBlock Code block to call on animation completion. If no animation was requested or given controller already was set as the root, the code block will be called in context og this method.
 */
- (void)setRootViewController:(UIViewController *)rootController animated:(BOOL)animated completionBlock:(void (^)(void))completionBlock;
- (void)hideSidebarControllerByTappingOnMainView;

@end

@implementation RootViewControllerManager

@synthesize sidebarNavigationController = _sidebarNavigationController;
@synthesize rootNavigationController = _rootNavigationController;
@synthesize isSidebarShown = _isSidebarShown;
@synthesize sidebarEnabled = _sidebarEnabled;
@synthesize maskSidebarView = _maskSidebarView;
@synthesize shadowView = _shadowView;
@synthesize animating = _animating;
@synthesize mainControllerAnimating = _mainControllerAnimating;
@synthesize deferredNavigation = _deferredNavigation;

#pragma mark - Singleton manager implementation

+ (RootViewControllerManager *)sharedInstance
{
    static RootViewControllerManager* rootViewControllerManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rootViewControllerManager = [[RootViewControllerManager alloc] init];
    });
    return rootViewControllerManager;
}

#pragma mark - Initialization and configuration

- (instancetype)init {
    if ((self = [super init]) == nil) {
        return nil;
    }
    
    self.sidebarNavigationController = [[UINavigationController alloc] init];
    self.sidebarNavigationController.delegate = self;
    
    self.rootNavigationController = [[RootNavigationController alloc] init];
    self.rootNavigationController.delegate = self;
    
    self.maskSidebarView = [[UIView alloc] init];
    self.maskSidebarView.backgroundColor = [UIColor blackColor];
    self.maskSidebarView.alpha = 0.5f;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSidebarControllerByTappingOnMainView)];
    [self.maskSidebarView addGestureRecognizer:tapGesture];
    self.shadowView = [[UIView alloc] init];
    self.shadowView.backgroundColor = [UIColor blackColor];
    
    RootViewController *rootViewController = [[RootViewController alloc] init];
    __weak RootViewControllerManager *weakSelf = self;
    [self setRootViewController:rootViewController animated:NO completionBlock:^{
        RootViewControllerManager *blockSelf = weakSelf;
      
        UIViewController *sidebar = [blockSelf topSidebarController];
        
        CGRect rootGeom = rootViewController.view.bounds;
        CGRect sidebarGeom = rootGeom;
        sidebarGeom.size.width = (sidebar == nil) ? 320. : sidebar.preferredContentSize.width;
        sidebarGeom.origin.x = -sidebarGeom.size.width;
        
        [rootViewController addChildViewController:blockSelf.sidebarNavigationController];
        [rootViewController addChildViewController:blockSelf.rootNavigationController];
        
        blockSelf.rootNavigationController.view.frame = rootGeom;
        [rootViewController.view addSubview:blockSelf.rootNavigationController.view];
        
        blockSelf.sidebarNavigationController.view.frame = sidebarGeom;
        blockSelf.sidebarNavigationController.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        [rootViewController.view addSubview:blockSelf.sidebarNavigationController.view];
    }];
    
    return self;
}

- (void)dealloc {
    assert("RootViewControllerManager deallocated!" == NULL);
}

#pragma mark - Public API implementation

- (void)setSidebarEnabled:(BOOL)sidebarEnabled {
    [self setSidebarEnabled:sidebarEnabled animated:NO completionBlock:nil];
}

- (void)setSidebarEnabled:(BOOL)sidebarEnabled animated:(BOOL)animated completionBlock:(void (^)(void))completionBlock {
    if( sidebarEnabled == _sidebarEnabled )
    {
        if( completionBlock != nil )
        {
            completionBlock();
        }
        return;
    }
    _sidebarEnabled = sidebarEnabled;
    if( !sidebarEnabled )
    {
        [self hideSidebarControllerAnimated:animated completionBlock:completionBlock];
    }
    else if( completionBlock != nil )
    {
        completionBlock();
    }
}

- (void)hideSidebarControllerAnimated:(BOOL)animated completionBlock:(void (^)(void))completionBlock {
    if (self.isSidebarShown) {
        if (self.animating) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self hideSidebarControllerAnimated:animated completionBlock:completionBlock];
            });
            return;
        }
        
        void (^processingBlock)(void) = ^(void) {
            self.rootNavigationController.view.transform = CGAffineTransformIdentity;
            self.sidebarNavigationController.view.transform = CGAffineTransformIdentity;
        };
        
        if (animated) {
            self.animating = YES;
            [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                processingBlock();
                self.maskSidebarView.alpha=0;
                self.shadowView.alpha=0;
            } completion:^(BOOL __unused finished) {
                [self.maskSidebarView removeFromSuperview];
                [self.shadowView removeFromSuperview];
                
                self.isSidebarShown = NO;
                self.animating = NO;
                
                if (completionBlock != nil) {
                    completionBlock();
                }
            }];
            return;
        }
        
        processingBlock();
        [self.maskSidebarView removeFromSuperview];
        [self.shadowView removeFromSuperview];
        
        self.isSidebarShown = NO;
        self.animating = NO;
    }
    
    if (completionBlock != nil) {
        completionBlock();
    }
}

- (void)showSidebarController:(UIViewController *)sidebarContentController animated:(BOOL)animated completionBlock:(void (^)(void))completionBlock {
    if (sidebarContentController == nil) {
        sidebarContentController = [self.sidebarNavigationController.viewControllers firstObject];
    }
    if (!self.sidebarEnabled || self.isSidebarShown || sidebarContentController == nil) {
        if (completionBlock != nil) {
            completionBlock();
        }
        return;
    }
    
    if (self.animating) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showSidebarController:sidebarContentController animated:animated completionBlock:completionBlock];
        });
        return;
    }
    
    UINavigationController* rootNavController = self.rootNavigationController;
    UINavigationController* sidebarNavController = self.sidebarNavigationController;
    
    void (^presentationBlock)(void) = ^(void) {
        if (sidebarContentController != nil && sidebarNavController.topViewController != sidebarContentController) {
            [sidebarNavController pushTopViewController:sidebarContentController animated:NO];
        }
        
        CGFloat offset = sidebarContentController.preferredContentSize.width;
        if (offset == 0.0f) {
            offset = sidebarContentController.view.frame.size.width;
        }
        CGAffineTransform rootNavTrx = CGAffineTransformMakeTranslation(offset, 0);
        
        self.maskSidebarView.frame = CGRectMake(0, 0, rootNavController.view.frame.size.width, rootNavController.view.frame.size.height);
        self.shadowView.frame = CGRectMake(-20, 0, 20, rootNavController.view.frame.size.height);
        self.shadowView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.shadowView.layer.shadowOffset = CGSizeMake(5, 0);
        self.shadowView.layer.shadowRadius = 10.0f;
        self.shadowView.layer.shadowOpacity = 1.0f;
        
        self.maskSidebarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.shadowView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        
        
        
        if (animated) {
            self.shadowView.alpha = self.maskSidebarView.alpha = 0;
            self.animating = YES;
            [rootNavController.view addSubview:self.maskSidebarView];
            [rootNavController.view addSubview:self.shadowView];
            [UIView animateWithDuration:.3 animations:^{
                rootNavController.view.transform = rootNavTrx;
                sidebarNavController.view.transform = rootNavTrx;
                self.shadowView.alpha = 1;
                self.maskSidebarView.alpha = 0.5;
            } completion:^(BOOL __unused finished) {
                self.isSidebarShown = YES;
                self.animating = NO;
                
                if (completionBlock != nil) {
                    completionBlock();
                }
            }];
        }
        else {
            rootNavController.view.transform = rootNavTrx;
            sidebarNavController.view.transform = rootNavTrx;
            [rootNavController.view addSubview:self.maskSidebarView];
            [rootNavController.view addSubview:self.shadowView];
            self.isSidebarShown = YES;
            self.animating = NO;
            
            if (completionBlock != nil) {
                completionBlock();
            }
        }
    };
    
    if (!CGAffineTransformIsIdentity(rootNavController.view.transform)) {
        [self hideSidebarControllerAnimated:animated completionBlock:^{
            presentationBlock();
        }];
        return;
    }
    
    presentationBlock();
}

- (void)toggleSidebarControllerAnimated:(BOOL)animated completionBlock:(void (^)(void))completionBlock {
    if (self.isSidebarShown) {
        [self hideSidebarControllerAnimated:animated completionBlock:completionBlock];
    }
    else if (self.sidebarEnabled) {
        [self showSidebarController:nil animated:animated completionBlock:completionBlock];
    }
}

- (void)hideSidebarControllerByTappingOnMainView {
    [self hideSidebarControllerAnimated:YES completionBlock:nil];
}

- (void)setSidebarViewController:(UIViewController *)controller {
    if (controller == nil) {
        [self.sidebarNavigationController setViewControllers:@[] animated:NO];
    }
    else {
        [self.sidebarNavigationController setViewControllers:@[ controller ] animated:NO];
  
        RootViewController *root = [[[EXMainWindowAppDelegate mainWindow] rootViewController] as:[RootViewController class]];
        CGRect rootGeom = root.view.bounds;
        CGRect sidebarGeom = rootGeom;
        sidebarGeom.size.width = controller.preferredContentSize.width;
        sidebarGeom.origin.x = -sidebarGeom.size.width;
        
        self.rootNavigationController.view.frame = rootGeom;
        self.sidebarNavigationController.view.frame = sidebarGeom;
        self.sidebarNavigationController.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    }
    
    
}

- (void)pushRootViewController:(UIViewController *)rootController animated:(BOOL)animated completionBlock:(void (^)(void))completionBlock {
    assert(rootController);
    if (self.mainControllerAnimating) {
        __weak RootViewControllerManager *weakSelf = self;
        @synchronized(self) {
            [self setDeferredNavigation:^{
                RootViewControllerManager *strongSelf = weakSelf;
                [strongSelf pushRootViewController:rootController animated:animated completionBlock:completionBlock];
            }];
        }
        return;
    }
    [self.maskSidebarView removeFromSuperview];
    [self.shadowView removeFromSuperview];
    if (rootController == nil || rootController == self.rootNavigationController.topViewController) {
        if (completionBlock != nil) {
            completionBlock();
        }
        return;
    }
    
    if (animated && completionBlock != nil) {
        objc_setAssociatedObject(rootController, "pushCompletionBlock", completionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
        self.mainControllerAnimating = YES;
    }
    
    BOOL hasTargetControllerOnStack = [self.rootNavigationController.viewControllers containsObject:rootController];
    if (hasTargetControllerOnStack) {
        if (self.rootNavigationController.topViewController != rootController) {
            [self.rootNavigationController popToViewController:rootController animated:YES];
        }
        if (!animated && completionBlock != nil) {
            completionBlock();
        }
        return;
    }
    
    UIWindow *window = [EXMainWindowAppDelegate mainWindow];
    assert(window != nil);
    
    void (^presentationBlock)(void) = ^(void) {
        [self.rootNavigationController setViewControllers:@[rootController] animated:animated];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self.rootNavigationController.view.superview == nil) {
            UIView* rootView = window.rootViewController.view;
            CGRect rootRect = rootView.bounds;
            self.rootNavigationController.view.frame = rootRect;
            [rootView addSubview:self.rootNavigationController.view];
        }
        if (!animated && completionBlock != nil) {
            completionBlock();
        }
    };
    
    if (CGAffineTransformIsIdentity(self.rootNavigationController.view.transform)) {
        [self hideSidebarControllerAnimated:animated completionBlock:presentationBlock];
        return;
    }
    
    presentationBlock();
}

- (void)popRootViewControllerAnimated:(BOOL)animated completionBlock:(void (^)(void))completionBlock {
    if( self.mainControllerAnimating ) {
        __weak RootViewControllerManager *weakSelf = self;
        @synchronized(self) {
            [self setDeferredNavigation:^{
                RootViewControllerManager *strongSelf = weakSelf;
                [strongSelf popRootViewControllerAnimated:animated completionBlock:completionBlock];
            }];
        }
        return;
    }
    [self.maskSidebarView removeFromSuperview];
    [self.shadowView removeFromSuperview];
    NSUInteger navStackDepth = [self.rootNavigationController.viewControllers count];
    if (navStackDepth <= 1) {
        if (completionBlock != nil) {
            completionBlock();
        }
        return;
    }
    
    UIViewController *controllerToPop = [self.rootNavigationController.viewControllers objectAtIndex:navStackDepth - 2];
    assert(nil != controllerToPop);
    if (animated && completionBlock != nil) {
        self.mainControllerAnimating = YES;
        objc_setAssociatedObject(controllerToPop, "popCompletionBlock", completionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    [self.rootNavigationController popViewControllerAnimated:YES];
    
    if (!animated && completionBlock != nil) {
        completionBlock();
    }
}

- (UIViewController *)topContentController {
    UIViewController* top = [self.rootNavigationController topViewController];
    return top;
}

- (UIViewController *)topSidebarController {
    UIViewController* top = [self.sidebarNavigationController topViewController];
    return top;
}

- (void)clearDeferredNavigation {
    @synchronized(self) {
        self.deferredNavigation = nil;
    }
}

#pragma mark - Utility methods

- (void)setRootViewController:(UIViewController *)rootController animated:(BOOL)animated completionBlock:(void (^)(void))completionBlock {
    UIWindow* window = [EXMainWindowAppDelegate mainWindow];
    assert(window != nil);
    
    if (window.rootViewController != rootController) {
        if (CGAffineTransformIsIdentity(self.sidebarNavigationController.view.transform)) {
            [self hideSidebarControllerAnimated:animated completionBlock:^{
                window.rootViewController = rootController;
                if (completionBlock != nil) {
                    completionBlock();
                }
            }];
            return;
        }
        window.rootViewController = rootController;
    }
    if (completionBlock != nil) {
        completionBlock();
    }
}

#pragma mark - UINavigationControllerDelegate implementation

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.maskSidebarView removeFromSuperview];
    [self.shadowView removeFromSuperview];
    EXBaseViewController *baseVC = [viewController as:[EXBaseViewController class]];
    if (baseVC != nil) {
        [navigationController setNavigationBarHidden:baseVC.shouldHideNavigationBar animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    #pragma unused(navigationController, animated)
    void (^completionBlock)(void) = objc_getAssociatedObject(viewController, "pushCompletionBlock");
    if (completionBlock != nil) {
        objc_setAssociatedObject(viewController, "pushCompletionBlock", nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
        completionBlock();
        self.mainControllerAnimating = NO;
        @synchronized(self) {
            if (self.deferredNavigation) {
                self.deferredNavigation();
            }
        }
    }
    else {
        completionBlock = objc_getAssociatedObject(viewController, "popCompletionBlock");
        if (completionBlock != nil) {
            objc_setAssociatedObject(viewController, "popCompletionBlock", nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
            completionBlock();
            self.mainControllerAnimating = NO;
            @synchronized(self) {
                if (self.deferredNavigation) {
                    self.deferredNavigation();
                }
            }
        }
    }
}

@end
