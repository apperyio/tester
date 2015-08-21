//
//  UIView+LayerManagement.m
//

#import "UIView+LayerManagement.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (LayerManagement)

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)color
{
    if (nil == color)
    {
        color = [UIColor clearColor];
    }
    self.layer.borderColor = [color CGColor];
}

- (void)setCornerRadius:(CGFloat)radius
{
    self.layer.cornerRadius = radius;
}

@end
