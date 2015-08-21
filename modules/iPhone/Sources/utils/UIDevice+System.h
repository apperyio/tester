//
//  UIDevice+System.h
//

#import <UIKit/UIKit.h>

@interface UIDevice (System)

/**
 * Executed given code block only if the application is running under iOS-8.0 or higher version.
 *
 * @param block Code block to execute.
 */
+ (void)executeUnderIOS8AndHigher:(void (^)(void))block;

/**
 * Executed given code block only if the application is running under iOS with version lower, then 8.0.
 *
 * @param block Code block to execute.
 */
+ (void)executeUnderIOS7AndLower:(void (^)(void))block;

/**
 * Executed given code block only if the application is running under iOS-7.0 or higher version.
 *
 * @param block Code block to execute.
 */
+ (void)executeUnderIOS7AndHigher:(void (^)(void))block;

/**
 * Executed given code block only if the application is running under iOS with version lower, then 7.0.
 *
 * @param block Code block to execute.
 */
+ (void)executeUnderIOS6AndLower:(void (^)(void))block;

@end
