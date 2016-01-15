//
//  EXAppCodeController.h
//  Appery
//

#import <Foundation/Foundation.h>

typedef void(^EXAppControllerSucceedHandler)(NSString *appCode);
typedef void(^EXAppControllerFailedHandler)(NSError *error);

@interface EXAppCodeController : NSObject

- (void)requestCodeWithSucceed:(EXAppControllerSucceedHandler)succeed failed:(EXAppControllerFailedHandler)failed;

@end

