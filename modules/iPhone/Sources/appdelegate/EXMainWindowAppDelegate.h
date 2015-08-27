//
//  EXMainWindowAppDelegate.h
//  Appery
//
//  Created by Sergey Seroshtan on 30.07.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EXMainWindowAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

+ (EXMainWindowAppDelegate *)appDelegate;
+ (UIWindow *)mainWindow;

- (void)navigateToStartPage;

@end
