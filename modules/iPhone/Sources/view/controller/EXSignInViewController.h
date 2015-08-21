//
//  EXSignInViewController.h
//  Appery
//

#import <UIKit/UIKit.h>
#import "EXViewControllerProvider.h"

@class EXProjectViewController;
@class EXApperyService;

@interface EXSignInViewController : UIViewController <EXViewControllerProvider>

@property (nonatomic, strong) EXProjectViewController *projectViewController;
@property (nonatomic, retain) EXApperyService *apperyService;

- (void) updateProjectsMetadata:(NSArray *)projectsMetadata;

@end
