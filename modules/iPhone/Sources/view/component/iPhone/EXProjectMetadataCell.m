//
//  EXProjectsMetadataCell.m
//  Appery
//
//  Created by Sergey Seroshtan on 15.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXProjectMetadataCell.h"
#import "EXProjectMetadata.h"
#import "UIColor+hexColor.h"

NSString *const kEXProjectMetadataCell = @"EXProjectMetadataCell";

@interface EXProjectMetadataCell ()

@property (weak, nonatomic) IBOutlet UIImageView *ivIcon;
@property (weak, nonatomic) IBOutlet UILabel *lTitle;
@property (weak, nonatomic) IBOutlet UILabel *lDetails;
@property (weak, nonatomic) IBOutlet UILabel *lDivider;

@end

@implementation EXProjectMetadataCell

@synthesize ivIcon = _ivIcon;
@synthesize lTitle = _lTitle;
@synthesize lDetails = _lDetails;
@synthesize lDivider = _lDivider;

#pragma mark - ViewManagement/Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UILabel *l = self.lDivider;
    l.backgroundColor = [UIColor colorFromHEXString:@"#989898"];
    l.text = nil;
    l.alpha = .4;
    
    l = self.lTitle;
    l.font = [UIFont fontWithName:@"HelveticaNeue" size:20.];
    l.textColor = [UIColor colorFromHEXString:@"#000000"];
    
    l = self.lDetails;
    l.font = [UIFont fontWithName:@"HelveticaNeue" size:10.];
    l.textColor = [UIColor colorFromHEXString:@"#4D4D4D"];
}

#pragma mark - Public class logic

- (void)updateWithMetadata:(EXProjectMetadata *)metadata {
    UIImageView *iv = self.ivIcon;
    iv.image = [self iconForProjectType:metadata.type];

    UILabel *l = self.lTitle;
    l.text = metadata.name;
    l = self.lDetails;
    l.text = [NSString stringWithFormat:@"%@, %@", metadata.creator, metadata.formattedModifiedDate];
}

+ (CGFloat) height {
    return 64.;
}

#pragma mark - Private class logic

- (UIImage *)iconForProjectType:(NSNumber *)type {
    UIImage *icon = nil;
    switch ([type integerValue]) {
        case 1:
            icon = [UIImage imageNamed:@"icon_jqm"];
            break;
        case 7:
            icon = [UIImage imageNamed:@"icon_bootsrap"];
            break;
        case 8:
            icon = [UIImage imageNamed:@"icon_ionic"];
            break;
        default:
            break;
    }
    
    return icon;
}

@end
