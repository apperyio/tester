//
//  NSString+XMLEscape.h
//

#import <Foundation/Foundation.h>

@interface NSString (XMLEscape)

+ (NSString *)stringWithPercentEscapesForString:(NSString *)srcString;
+ (NSString *)stringRemovePercentEscapesForString:(NSString*)srcString;

@end
