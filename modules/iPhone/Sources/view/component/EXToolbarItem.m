//
//  EXToolbarItem.m
//  Appery
//
//  Created by Pavel Gorb on 8/27/15.
//  Copyright (c) 2015 Exadel Inc. All rights reserved.
//

#import "EXToolbarItem.h"
#import "UIColor+hexColor.h"

@interface EXToolbarItem ()

@property (nonatomic, strong) UIImageView *ivImage;
@property (nonatomic, strong) UILabel *lTitle;
@property (nonatomic, assign, readwrite) BOOL isActive;

@property (nonatomic, strong) UIButton *bAction;

- (void)toolbarItemAction:(id)sender;

@end

@implementation EXToolbarItem

@dynamic title;

@synthesize imageName = _imageName;
@synthesize activeImageName = _activeImageName;

@synthesize ivImage = _ivImage;
@synthesize lTitle = _lTitle;
@synthesize isActive = _isActive;
@synthesize delegate = _delegate;

@synthesize bAction = _bAction;

#pragma mark - Lifecycle

- (instancetype)initWithImageName:(NSString *)imageName activeImageName:(NSString *)activeImageName title:(NSString *)title
{
    self = [super initWithFrame:CGRectMake(0., 0., 44., 44.)];
    if (self == nil) {
        return nil;
    }
    
    _imageName = imageName;
    _activeImageName = activeImageName;
    
    _ivImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    _ivImage.image = (_imageName.length > 0) ? [UIImage imageNamed:imageName] : nil;
    [self addSubview:_ivImage];
    
    _lTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    _lTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:10.];
    _lTitle.textColor = [UIColor colorFromHEXString:@"#BDBDBD"];
    _lTitle.textAlignment = NSTextAlignmentCenter;
    _lTitle.text = title;
    [self addSubview:_lTitle];
    
    _bAction = [UIButton buttonWithType:UIButtonTypeCustom];
    _bAction.frame = self.bounds;
    [_bAction addTarget:self action:@selector(toolbarItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_bAction];
    
    return self;
}

#pragma mark - Getter/Setter

- (NSString *)title
{
    return self.lTitle.text;
}

- (void)setTitle:(NSString *)title
{
    self.lTitle.text = title;
}

#pragma mark - Public class logic

- (void)setStateToActive:(BOOL)active
{
    self.isActive = active;
    if (self.isActive) {
        self.lTitle.textColor = [UIColor colorFromHEXString:@"#2581FF"];
        if (self.activeImageName.length > 0) {
            self.ivImage.image = [UIImage imageNamed:self.activeImageName];
        }
    }
    else {
        self.lTitle.textColor = [UIColor colorFromHEXString:@"#666666"];
        if (self.imageName) {
            self.ivImage.image = [UIImage imageNamed:self.imageName];
        }
    }
}

#pragma mark - Action handler 

- (void)toolbarItemAction:(id)sender
{
    id<EXToolbarItemActionDelegate> del = self.delegate;
    if ([del respondsToSelector:@selector(didActivateToolbarItem:)]) {
        [del didActivateToolbarItem:self];
    }
}

#pragma mark - View management

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize imSize = self.ivImage.image.size;
    CGRect frm = self.ivImage.frame;
    frm.size.width = imSize.width;
    frm.size.height = imSize.height;
    frm.origin.x = self.frame.size.width / 2. - frm.size.width / 2.;
    frm.origin.y = 6.;
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
