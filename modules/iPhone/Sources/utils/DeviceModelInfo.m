//
//  DeviceModelInfo.m
//

#import "DeviceModelInfo.h"
#import <sys/utsname.h>

static NSDictionary *deviceDetailsByModel = nil;

@implementation DeviceModelInfo

+ (NSString *)deviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if (0 >= [deviceModel length]) {
        deviceModel = @"Unknown";
    }

    return deviceModel;
}

+ (NSString *)deviceModelDetails
{
    if (nil == deviceDetailsByModel) {
        deviceDetailsByModel = @{ @"i386"      :@"Simulator",
                                  @"iPod1,1"   :@"iPod Touch (1st Gen)",                      // (Original)
                                  @"iPod2,1"   :@"iPod Touch (2nd Gen)",                      // (Second Generation)
                                  @"iPod3,1"   :@"iPod Touch (3rd Gen)",                      // (Third Generation)
                                  @"iPod4,1"   :@"iPod Touch (4th Gen)",                      // (Fourth Generation)
                                  @"iPhone1,1" :@"iPhone",                                    // (Original)
                                  @"iPhone1,2" :@"iPhone 3G",                                 // (3G)
                                  @"iPhone2,1" :@"iPhone 3GS",                                // (3GS)
                                  @"iPad1,1"   :@"iPad",                                      // (Original)
                                  @"iPad2,1"   :@"iPad 2",                                    //
                                  @"iPad3,1"   :@"iPad (the New iPad)",                       // (3rd Generation)
                                  @"iPhone3,1" :@"iPhone 4 (GSM)",                            // (GSM)
                                  @"iPhone3,3" :@"iPhone 4 (CDMA)",                           // (CDMA/Verizon/Sprint)
                                  @"iPhone4,1" :@"iPhone 4S",                                 //
                                  @"iPhone5,1" :@"iPhone 5 (A1428)",                          // (model A1428, AT&T/Canada)
                                  @"iPhone5,2" :@"iPhone 5 (A1429)",                          // (model A1429, everything else)
                                  @"iPad3,4"   :@"iPad 4",                                    // (4th Generation)
                                  @"iPad2,5"   :@"iPad Mini",                                 // (Original)
                                  @"iPhone5,3" :@"iPhone 5c (A1456, A1532, GSM)",             // (model A1456, A1532 | GSM)
                                  @"iPhone5,4" :@"iPhone 5c (A1507, A1516, A1526, A1529)",    // (model A1507, A1516, A1526 (China), A1529 | Global)
                                  @"iPhone6,1" :@"iPhone 5s (A1433, A1533, GSM)",             // (model A1433, A1533 | GSM)
                                  @"iPhone6,2" :@"iPhone 5s (A1457, A1518, A1528, A1530)",    // (model A1457, A1518, A1528 (China), A1530 | Global)
                                  @"iPhone7,1" :@"iPhone 6 Plus",                             //
                                  @"iPhone7,2" :@"iPhone 6",                                  //
                                  @"iPad4,1"   :@"iPad Air (WIFI)",                           // 5th Generation iPad (iPad Air) - Wifi
                                  @"iPad4,2"   :@"iPad Air (Cellular)",                       // 5th Generation iPad (iPad Air) - Cellular
                                  @"iPad4,4"   :@"iPad Mini (WIFI)",                          // (2nd Generation iPad Mini - Wifi)
                                  @"iPad4,5"   :@"iPad Mini (Cellular)"                       // (2nd Generation iPad Mini - Cellular)
                                  };
    }
    
    NSString *deviceModel = [self deviceModel];
    NSString *deviceModelDetails = (NSString *)deviceDetailsByModel[deviceModel];
    
    if (0 >= [deviceModelDetails length]) {
        if ([deviceModel rangeOfString:@"iPod"].location != NSNotFound) {
            deviceModelDetails = @"iPod Touch";
        }
        else if([deviceModel rangeOfString:@"iPad"].location != NSNotFound) {
            deviceModelDetails = @"iPad";
        }
        else if([deviceModel rangeOfString:@"iPhone"].location != NSNotFound) {
            deviceModelDetails = @"iPhone";
        }
        else {
            deviceModelDetails = @"Unknown";
        }
    }
    
    return deviceModelDetails;
}

+ (NSNumber *)iPhone4Family
{
    NSString* device = [self deviceModel];
    
    if ([device isEqualToString:@"iPhone3,1"] || [device isEqualToString:@"iPhone3,3"] || [device isEqualToString:@"iPhone4,1"]) {
        return @YES;
    }
    
    return @NO;
}

+ (NSNumber *)iPhone5Family
{
    NSString* device = [self deviceModel];
    
    if ([device isEqualToString:@"iPhone5,1"] ||
        [device isEqualToString:@"iPhone5,2"] ||
        [device isEqualToString:@"iPhone5,3"] ||
        [device isEqualToString:@"iPhone5,4"] ||
        [device isEqualToString:@"iPhone6,1"] ||
        [device isEqualToString:@"iPhone6,2"]) {
        return @YES;
    }
    
    return @NO;
}

+ (NSNumber *)iPhone6
{
    NSString* device = [self deviceModel];
    if ([device isEqualToString:@"iPhone7,2"]) {
        return @YES;
    }
    
    return @NO;
}

+ (NSNumber *)iPhone6Plus
{
    NSString* device = [self deviceModel];
    
    if ([device isEqualToString:@"iPhone7,1"]) {
        return @YES;
    }
    
    return @NO;
}

+ (NSNumber *)iPadFamily
{
    NSString* device = [self deviceModel];
    
    if ([device isEqualToString:@"iPad1,1"] || [device isEqualToString:@"iPad2,1"] || [device isEqualToString:@"iPad2,5"]) {
        return @YES;
    }
    
    return @NO;
}

+ (NSNumber *)iPadRetinaFamily
{
    if (![[self iPadFamily] boolValue] && [[self deviceModel] rangeOfString:@"iPad"].location != NSNotFound) {
        return @YES;
    }
    
    return @NO;
}

@end
