//
//  EXProjectsMetadataCell.h
//  Appery
//
//  Created by Sergey Seroshtan on 15.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EXProjectMetadataCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *projectNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *authorLabel;
@property (retain, nonatomic) IBOutlet UILabel *modificationDateLabel;
@property (retain, nonatomic) IBOutlet UIImageView *projectTypeIcon;

@end
