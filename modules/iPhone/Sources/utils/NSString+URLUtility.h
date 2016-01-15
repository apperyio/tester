//
//  NSString+URLUtility.h
//

#import <Foundation/Foundation.h>

@interface NSString (URLUtility)

- (NSString *)encodedUrlString;
- (NSString *)decodedUrlString;
- (NSString *)URLByAddingResourceComponent:(NSString *)resourcePath;
- (NSString *)removeTrailingSlashes;

@end
