//
//  EXProjectsMetadataCell.h
//  Appery
//
//  Created by Sergey Seroshtan on 15.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kEXProjectMetadataCell;

@class EXProjectMetadata;

@interface EXProjectMetadataCell : UITableViewCell

- (void)updateWithMetadata:(EXProjectMetadata *)metadata;

+ (CGFloat)height;

@end
