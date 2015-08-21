//
//  UIColor+hexColor.m
//

#import "UIColor+hexColor.h"

@implementation UIColor (hexColor)

+ (UIColor *)colorFromHEXString:(NSString *)hexString
{
    NSString* realColorStr = ([hexString hasPrefix:@"#"]) ? [hexString substringFromIndex:1] : hexString;
    unsigned int rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:realColorStr];
    [scanner scanHexInt:&rgbValue];
    UIColor* rgbColor = [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.
                                        green:((rgbValue & 0xFF00) >> 8) / 255.
                                         blue:(rgbValue & 0xFF) / 255. alpha:1.0];
    return rgbColor;
}

@end
