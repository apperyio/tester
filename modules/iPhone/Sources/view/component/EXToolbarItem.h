//
//  EXToolbarItem.h
//  Appery
//
//  Created by Pavel Gorb on 8/27/15.
//  Copyright (c) 2015 Exadel Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EXToolbarItemActionDelegate.h"

@interface EXToolbarItem : UIView

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *activeImageName;
@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign, readonly) BOOL isActive;
@property (nonatomic, weak) id<EXToolbarItemActionDelegate> delegate;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (instancetype)initWithImageName:(NSString *)imageName activeImageName:(NSString *)activeImageName title:(NSString *)title NS_DESIGNATED_INITIALIZER;

- (void)setStateToActive:(BOOL)active;

@end
