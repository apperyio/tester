//
//  EXToolbarItemActionDelegate.h
//  Appery
//
//  Created by Pavel Gorb on 8/28/15.
//
//

#import <Foundation/Foundation.h>

@class EXToolbarItem;

@protocol EXToolbarItemActionDelegate <NSObject>

@optional
- (void)didActivateToolbarItem:(EXToolbarItem *)item;

@end
