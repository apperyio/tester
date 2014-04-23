//
//  EXLoginViewController~iPad.m
//  Appery
//
//  Created by Sergey Seroshtan on 16.05.13.
//
//

#import "EXLoginViewController~iPad.h"

@interface EXLoginViewController_iPad ()

@end

@implementation EXLoginViewController_iPad

#pragma mark - iOS 5 rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - iOS 6 rotation

- (BOOL) shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
