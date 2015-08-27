//
//  EXToolbarItem.m
//  Appery
//
//  Created by Pavel Gorb on 8/27/15.
//
//

#import "EXToolbarItem.h"
#import "UIColor+hexColor.h"

@interface EXToolbarItem ()

@property (nonatomic, strong) UIButton *bAction;
@property (nonatomic, strong) UIImageView *ivImage;
@property (nonatomic, strong) UILabel *lTitle;

@end

@implementation EXToolbarItem

@dynamic image;
@dynamic title;

@synthesize bAction = _bAction;
@synthesize ivImage = _ivImage;
@synthesize lTitle = _lTitle;

#pragma mark - Lifecycle

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title {
    self = [super initWithFrame:CGRectMake(0., 0., 44., 44.)];
    if (self == nil) {
        return nil;
    }
    
    _ivImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    _ivImage.image = image;
    [self addSubview:_ivImage];
    
    _lTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    _lTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:10.];
    _lTitle.textColor = [UIColor colorFromHEXString:@"#BDBDBD"];
    _lTitle.textAlignment = NSTextAlignmentCenter;
    _lTitle.text = title;
    [self addSubview:_lTitle];
    
    _bAction = [UIButton buttonWithType:UIButtonTypeCustom];
    _bAction.frame = self.frame;
    [self addSubview:_bAction];
    
    return self;
}

#pragma mark - Getter/Setter

- (UIImage *)image {
    return self.ivImage.image;
}

- (void)setImage:(UIImage *)image {
    self.ivImage.image = image;
}

- (NSString *)title {
    return self.lTitle.text;
}

- (void)setTitle:(NSString *)title {
    self.lTitle.text = title;
}

#pragma mark - Public class logic

- (void)addTarget:(NSObject *)target selector:(SEL)selector {
    [self.bAction addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - View management

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize imSize = self.ivImage.image.size;
    CGRect frm = self.ivImage.frame;
    frm.size.width = imSize.width;
    frm.size.height = imSize.height;
    frm.origin.x = self.frame.size.width / 2. - frm.size.width / 2.;
    frm.origin.y = 2.;
    self.ivImage.frame = frm;
    
    frm = self.lTitle.frame;
    frm.size.width = self.frame.size.width - 4.;
    frm.size.height = 12.;
    frm.origin.x = self.frame.size.width / 2. - frm.size.width / 2.;
    frm.origin.y = self.frame.size.height - frm.size.height - 2.;
    self.lTitle.frame = frm;

    _bAction.frame = self.bounds;
}

@end
