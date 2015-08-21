//
//  DeviceModelInfo.h

#import <Foundation/Foundation.h>

@interface DeviceModelInfo : NSObject

+ (NSString *)deviceModel;
+ (NSString *)deviceModelDetails;

+ (NSNumber *)iPhone4Family;
+ (NSNumber *)iPhone5Family;
+ (NSNumber *)iPhone6;
+ (NSNumber *)iPhone6Plus;
+ (NSNumber *)iPadFamily;
+ (NSNumber *)iPadRetinaFamily;

@end
