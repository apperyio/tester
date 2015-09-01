//
//  EXSignInCell.m
//  Appery
//
//  Created by Pavel Gorb on 8/18/15.
//
//

#import "EXSignInCell.h"
#import "UIColor+hexColor.h"
#import "UIView+LayerManagement.h"

@interface EXSignInCell () <UITextFieldDelegate>

@property (nonatomic, assign, readwrite) SignInCellType type;

@property (nonatomic, weak) IBOutlet UITextField *tfCredential;
@property (nonatomic, weak) IBOutlet UIButton *bProceed;

- (IBAction)proceedAction:(id)sender;

@end

@implementation EXSignInCell

@synthesize delegate = _delegate;
@synthesize type = _type;
@synthesize tfCredential = _tfCredential;
@synthesize bProceed = _bProceed;

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    self.type = SignInCellTypeUnknown;
    
    UIImage *img = [UIImage imageNamed:@"arrow_right"];
    
    UIButton *btn = self.bProceed;
    btn.hidden = YES;
    [btn setTitle:nil forState:UIControlStateNormal];
    [btn setImage:img forState:UIControlStateNormal];
    
    UITextField *tf = self.tfCredential;
    tf.borderStyle = UITextBorderStyleNone;
    tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    tf.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.];
    tf.textColor = [UIColor colorFromHEXString:@"#BDBDBD"];
}

#pragma mark - Action handlers

- (IBAction)proceedAction:(id)sender {
    #pragma unused(sender)
    id<EXSignInCellActionDelegate> del = self.delegate;
    if ([del respondsToSelector:@selector(needToExecuteActionForCell:)]) {
        [del needToExecuteActionForCell:self];
    }
}

#pragma mark - Public class logic

+ (CGFloat)height {
    return 54.;
}

- (void)configureCellForType:(SignInCellType) type {
    [self configureCellForType:type withText:nil];
}

- (void)configureCellForType:(SignInCellType)type withText:(NSString *)text {
    UIButton *btn = self.bProceed;
    UITextField *tf = self.tfCredential;
    self.type = type;
    switch (self.type) {
        case SignInCellTypeLogin:
            btn.hidden = YES;
            tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Email", @"Email") attributes:@{ NSFontAttributeName : tf.font, NSForegroundColorAttributeName: tf.textColor }];
            break;
        case SignInCellTypePassword:
            btn.hidden = NO;
            tf.secureTextEntry = YES;
            tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Password", @"Password") attributes:@{ NSFontAttributeName : tf.font, NSForegroundColorAttributeName: tf.textColor }];
            break;
        default:
            btn.hidden = YES;
            tf.hidden = YES;
            break;
    }
    
    tf.text = text;
    [self bringSubviewToFront:tf];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    id<EXSignInCellActionDelegate> del = self.delegate;
    if ([del respondsToSelector:@selector(cell:didUpdateText:)]) {
        [del cell:self didUpdateText:[textField.text stringByReplacingCharactersInRange:range withString:string]];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
