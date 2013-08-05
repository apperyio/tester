//
//  EXProjectsMetadataCell.m
//  Appery
//
//  Created by Sergey Seroshtan on 15.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXProjectMetadataCell.h"

@implementation EXProjectMetadataCell

- (id) initWithStyle: (UITableViewCellStyle)style reuseIdentifier: (NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed: @"EXProjectMetadataCell" owner: self options: nil];
        self = [nibs objectAtIndex: 0];
    }
    return self;
}

@end
