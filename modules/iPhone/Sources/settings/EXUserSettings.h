//
//  EXUserSettings.h
//  Appery
//
//  Created by Sergey Seroshtan on 03.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EXSortingMethodType) {
    EXSortingMethodType_DateDescending,
    EXSortingMethodType_DateAscending,
    EXSortingMethodType_NameDescending,
    EXSortingMethodType_NameAscending,
    EXSortingMethodType_ModificationdDescending,
    EXSortingMethodType_ModificationAscending,
    EXSortingMethodType_CreatorDescending,
    EXSortingMethodType_CreatorAscending,
};

/**
 * This class provides access to user settings which define this application's behaviour.
 */
@interface EXUserSettings : NSObject <NSCoding>

/**
 * Defines user name
 */
@property (nonatomic, strong) NSString *userName;

/**
 * Defines sort method type for projects list.
 */
@property (nonatomic, assign) EXSortingMethodType sortMethodType;

@end
