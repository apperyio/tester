//
//  NSObject+Utils.h
//

#import <Foundation/Foundation.h>

@interface NSObject (Utils)

- (id)as:(Class)expectedClass;

- (id)asStringOrNumber;

@end
