//
//  RootViewControllerManager.h
//  Appery.io
//

#import <Foundation/Foundation.h>

@class RootNavigationController;

/**
 * Singleton manager for the main application window's content.
 */
@interface RootViewControllerManager : NSObject

#pragma mark - Singleton definition

/**
 * Shared root view controller manager instance accessor method.
 *
 * @return Shared (singleton) instance of the root view controller manager.
 */
+ (RootViewControllerManager *)sharedInstance;

#pragma mark - Sidebar management

/// Enable (if YES) or deisable (if NO) sidebar presenting.
@property (nonatomic, assign) BOOL sidebarEnabled;

/// Sidebar controller visibility flag.
@property (nonatomic, assign, readonly) BOOL isSidebarShown;

/// Navigation controller for the root screen area content.
@property (nonatomic, strong, readonly) RootNavigationController *rootNavigationController;

/// Mask view for main controller when sidebar is shown
@property (nonatomic, strong) UIView *maskSidebarView;

@property (nonatomic, strong) UIView *shadowView;

/**
 * Disable or enable sidebar presentation.
 *
 * @param sidebarEnabled If YES, then sidebar presentation will be enabled. If NO, then sidebar will be hidden (if necessary) and its presentation will be disabled.
 * @param animated Animate sidebar hiding.
 * @param completionBlock Code block, called on animation (if it was used) completion or immediately (in context of this method) if anomation was not used or sidebar was already hidden.
 */
- (void)setSidebarEnabled:(BOOL)sidebarEnabled animated:(BOOL)animated completionBlock:(void (^)(void))completionBlock;

/**
 * Hide sidebar controller (if it not) by shifting the whole main application window content left.
 *
 * @param animated Flag to perform animated shift of the main window content.
 * @param completionBlock Code block to call on animation completion. If no animation was requested or sidebar controller was already hidden, the code block will be called in context og this method.
 */
- (void)hideSidebarControllerAnimated:(BOOL)animated completionBlock:(void (^)(void))completionBlock;

/**
 * Show sidebar controller (if it not) by shifting the whole main application window content right.
 *
 * @param sidebarContentController Content controller to set as the only (root) child od the sidebar navigation controller. If nil, then existing sidebar navigation stack is shown.
 * @param animated Flag to perform animated shift of the main window content.
 * @param completionBlock Code block to call on animation completion. If no animation was requested or sidebar controller was already visible, the code block will be called in context og this method.
 */
- (void)showSidebarController:(UIViewController *)sidebarContentController animated:(BOOL)animated completionBlock:(void (^)(void))completionBlock;

/**
 * Toggle sidebar controller visibility by shifting the whole main application window content left or right.
 *
 * @param animated Flag to perform animated shift of the main window content.
 * @param completionBlock Code block to call on animation completion. If no animation was requested, the code block will be called in context og this method.
 */
- (void)toggleSidebarControllerAnimated:(BOOL)animated completionBlock:(void (^)(void))completionBlock;

/**
 * Set sidebar controller
 *
 * @param controller Content controller to set as the only (root) child od the sidebar navigation controller.
 */
- (void)setSidebarViewController:(UIViewController *)controller;

#pragma mark - Main navigation stack management

/**
 * Push new content controller on top the existing stack on the root screen area. If given controller already is on stach, the stack is reduced so, that this controller appears on top.
 *
 * @param rootController View controller instance to appear on top the root area navigation stack.
 * @param animated Flag to perform animated shift of the root navigation area.
 * @param completionBlock Code block to call on animation completion. If no animation was requested or given controller already was on top the stack, the code block will be called in context of this method.
 */
- (void)pushRootViewController:(UIViewController *)rootController animated:(BOOL)animated completionBlock:(void (^)(void))completionBlock;

/**
 * Remove the top-most content controller from the existing stack on the root screen area.
 *
 * @param animated Flag to perform animated shift of the root navigation area.
 * @param completionBlock Code block to call on animation completion. If no animation was requested or there is only one controller in the stack, the code block will be called in context of this method.
 */
- (void)popRootViewControllerAnimated:(BOOL)animated completionBlock:(void (^)(void)) completionBlock;

/**
 * Replace the top-most content controller from the existing stack on the root screen area to new controller
 *
 * @param controller New the top-most content controller
 */
- (void)replaceTopContentViewController:(UIViewController *)controller animated:(BOOL)animated;

/**
 * Returns controller which is currently on the top of the stack.
 * If top controller exists and is BaseContentViewController or its descendant - it is returned.
 * Otherwise returns nil.
 */
- (UIViewController *)topContentController;

/**
 * Returns controller which is currently on the top of the stack of the sidebar.
 * If top sidebar controller exists and is BaseContentViewController or its descendant - it is returned.
 * Otherwise returns nil.
 */
- (UIViewController *)topSidebarController;

/**
 * Sets deferred navigation block to nil, if there was any.
 */
- (void)clearDeferredNavigation;

@end
