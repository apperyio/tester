//
//  EXToolbarItem.h
//  Appery
//
//  Created by Pavel Gorb on 8/27/15.
//
//

#import <UIKit/UIKit.h>
#import "EXToolbarItemActionDelegate.h"

@interface EXToolbarItem : UIView

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *activeImageName;
@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign, readonly) BOOL isActive;
@property (nonatomic, weak) id<EXToolbarItemActionDelegate> delegate;

- (instancetype)initWithImageName:(NSString *)imageName activeImageName:(NSString *)activeImageName title:(NSString *)title;

- (void)setStateToActive:(BOOL)active;

@end
