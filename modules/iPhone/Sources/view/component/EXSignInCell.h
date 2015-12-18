//
//  EXSignInCell.h
//  Appery
//
//  Created by Pavel Gorb on 8/18/15.
//  Copyright (c) 2015 Exadel Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SignInCellType) {
    SignInCellTypeUnknown = -1,
    SignInCellTypeLogin,
    SignInCellTypePassword
};

@protocol EXSignInCellActionDelegate;

@interface EXSignInCell : UITableViewCell

@property (nonatomic, weak) id<EXSignInCellActionDelegate> delegate;
@property (nonatomic, assign, readonly) SignInCellType type;

+ (CGFloat)height;
- (void)configureCellForType:(SignInCellType)type;
- (void)configureCellForType:(SignInCellType)type withText:(NSString *)text;

@end

@protocol EXSignInCellActionDelegate <NSObject>

- (void)cell:(EXSignInCell *)cell didUpdateText:(NSString *)text;
- (void)needToExecuteActionForCell:(EXSignInCell *)cell;

@end
