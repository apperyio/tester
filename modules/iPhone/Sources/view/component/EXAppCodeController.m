//
//  EXAppCodeController.m
//  Appery
//

#import "EXAppCodeController.h"

#import "NSStringMask.h"

static const NSInteger kAppCodeTextFieldTag = 111;

@interface EXAppCodeController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, copy) EXAppControllerSucceedHandler succeedHandler;
@property (nonatomic, copy) EXAppControllerFailedHandler failedHandler;
@property (nonatomic, strong) NSStringMask *mask;

@end

@implementation EXAppCodeController

@synthesize succeedHandler = _succeedHandler;
@synthesize failedHandler = _failedHandler;
@synthesize mask = _mask;

#pragma mark - Lifecycle

- (instancetype)init
{
    if (self = [super init]) {
        _mask = [[NSStringMask alloc] initWithPattern:@"(\\d{3})-(\\d{3})-(\\d{3})" placeholder:@"_"];
    }
    
    return self;
}

#pragma mark - Public class logic

- (void)requestCodeWithSucceed:(EXAppControllerSucceedHandler)succeed failed:(EXAppControllerFailedHandler)failed
{
    self.succeedHandler = succeed;
    self.failedHandler = failed;
    
    UIAlertView *shareAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter an app code", @"Enter an app code")
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"Enter", nil];
    
    shareAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *textfield = [shareAlert textFieldAtIndex:0];
    textfield.backgroundColor = [UIColor clearColor];
    textfield.placeholder = @"App code";
    textfield.tag = kAppCodeTextFieldTag;
    textfield.keyboardType = UIKeyboardTypeNumberPad;
    textfield.returnKeyType = UIReturnKeyDone;
    textfield.delegate = self;
    [shareAlert show];
}

#pragma mark - UIAlertViewDelegate implementation

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    }
    
    NSError *error = nil;
    NSString *appCode = [[alertView textFieldAtIndex:0] text];
    
    if (appCode.length <= 0 || [appCode rangeOfString:@"_"].location != NSNotFound) {
        if (self.failedHandler == nil) {
            return;
        }
        
        NSDictionary *errInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed", nil),
                                  NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Incorrect app code. Please enter all 9 digit number", nil)};
        error = [[NSError alloc] initWithDomain:APPERI_SERVICE_ERROR_DOMAIN code:0 userInfo:errInfo];
        
        self.failedHandler(error);
        self.failedHandler = nil;
        
        return;
    }
    
    if (self.succeedHandler != nil) {
        self.succeedHandler(appCode);
        self.succeedHandler = nil;
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    return YES;
}

#pragma mark - UITextField delegaete

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag != kAppCodeTextFieldTag) {
        return YES;
    }
    
    NSRange newRange = NSMakeRange(0, 0);
    NSString *mutableString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *clean = [self.mask validCharactersForString:mutableString];
    mutableString = [self.mask format:mutableString];
    
    if (clean.length > 0) {
        newRange = [mutableString rangeOfString:[clean substringFromIndex:clean.length - 1] options:NSBackwardsSearch];
        if (newRange.location == NSNotFound) {
            newRange.location = mutableString.length;
        }
        else {
            newRange.location += newRange.length;
        }
        newRange.length = 0;
    }
    
    textField.text = mutableString;
    [textField setValue:[NSValue valueWithRange:newRange] forKey:@"selectionRange"];
    
    return NO;
}

@end
