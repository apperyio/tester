//
//  EXToolbarItemActionDelegate.h
//  Appery
//
//  Created by Pavel Gorb on 8/28/15.
//  Copyright (c) 2015 Exadel Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EXToolbarItem;

@protocol EXToolbarItemActionDelegate <NSObject>

@optional
- (void)didActivateToolbarItem:(EXToolbarItem *)item;

@end
