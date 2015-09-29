//
//  EXAppCodeController.h
//  Appery
//

#import <Foundation/Foundation.h>

typedef void(^EXAppControllerCompletionHandler)(NSString *appCode);

@interface EXAppCodeController : NSObject

- (void)requestCodeWithCompletionHandler:(EXAppControllerCompletionHandler)completionHandler;

@end

