//
//  EXBaseViewController.m
//  Appery
//
//  Created by Pavel Gorb on 8/27/15.
//  Copyright (c) 2015 Exadel Inc. All rights reserved.
//

#import "EXBaseViewController.h"

@implementation EXBaseViewController

@synthesize shouldHideNavigationBar = _shouldHideNavigationBar;

#pragma mark - Interface rotation handling

- (BOOL)shouldAutorotate
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end
