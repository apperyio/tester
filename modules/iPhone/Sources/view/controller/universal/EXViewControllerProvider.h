//
//  EXViewControllerProvider.h
//  Appery
//
//  Created by Sergey Seroshtan on 22.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This protocol aims to decouple dependecies between view controllers.
 *     So specific view controller (Phone/iPad) could provide correct next view controller.
 */
@protocol EXViewControllerProvider <NSObject>

@required
/**
 * Should to return UIViewController that corresponds to the current platform (iPhone/iPad).
 */
- (UIViewController *) nextViewController;

@end
