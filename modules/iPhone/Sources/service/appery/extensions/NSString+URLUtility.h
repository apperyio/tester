//
//  NSString+URLUtility.h
//  Appery
//
//  Created by Sergey Seroshtan on 03.07.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLUtility)

/**
 * @return - encoded URL string with adding percent escape to reserved URL characters.
 */
- (NSString*) encodedUrlString;

/**
 * @return - decoded URL string with replaced percent escape sequences with their character equivalent.
 */
- (NSString*) decodedUrlString;

/**
 * @return - string by adding resource component.
 */
- (NSString *) URLByAddingResourceComponent: (NSString *) resourcePath;

/**
 * Removes trailing slashes from the specified string.
 */
- (NSString *) removeTrailingSlashes;

@end
