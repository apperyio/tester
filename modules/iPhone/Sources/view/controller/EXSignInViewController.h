//
//  EXSignInViewController.h
//  Appery
//

#import <UIKit/UIKit.h>
#import "EXBaseViewController.h"

@class EXProjectViewController;
@class EXApperyService;

@interface EXSignInViewController : EXBaseViewController

@property (nonatomic, strong, readonly) EXApperyService *apperyService;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil service:(EXApperyService *)service NS_DESIGNATED_INITIALIZER;

@end
