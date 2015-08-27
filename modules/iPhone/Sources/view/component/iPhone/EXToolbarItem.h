//
//  EXToolbarItem.h
//  Appery
//
//  Created by Pavel Gorb on 8/27/15.
//
//

#import <UIKit/UIKit.h>

@interface EXToolbarItem : UIView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title;

- (void)addTarget:(NSObject *)target selector:(SEL)selector;

@end
