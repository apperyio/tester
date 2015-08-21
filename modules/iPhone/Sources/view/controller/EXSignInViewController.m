//
//  EXSignInViewController.m
//  Appery
//

#import "EXSignInViewController.h"
#import "EXSignInCell.h"
#import "NSObject+Utils.h"
#import "UIColor+hexColor.h"

#import "EXProjectViewController.h"
#import "EXApperyService.h"
#import "EXUserSettingsStorage.h"
#import "EXCredentialsManager.h"

#import "MBProgressHUD.h"
#import "NSStringMask.h"

static NSString *const kEXSignInCellIdentifier = @"EXSignInCell";
static const NSInteger kAppCodeTextFieldTag = 111;

@interface EXSignInViewController () <UITableViewDataSource, UITableViewDelegate, EXSignInCellActionDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *svScroll;
@property (nonatomic, weak) IBOutlet UIView *vContent;

@property (nonatomic, weak) IBOutlet UIImageView *ivLogo;
@property (nonatomic, weak) IBOutlet UITableView *tvSignIn;
@property (nonatomic, weak) IBOutlet UIButton *bAppCode;
@property (nonatomic, weak) IBOutlet UILabel *lCopyright;

@property (nonatomic, strong) NSStringMask *mask;

@property (nonatomic, strong) NSString *uname;
@property (nonatomic, strong) NSString *pwd;

- (IBAction)appCodeAction:(id)sender;

- (void)keyboardWillShowNotification:(NSNotification *)notification;
- (void)keyboardWillHideNotification:(NSNotification *)notification;

@end

@implementation EXSignInViewController

@synthesize projectViewController = _projectViewController;
@synthesize apperyService = _apperyService;

@synthesize svScroll = _svScroll;
@synthesize vContent = _vContent;

@synthesize ivLogo = _ivLogo;
@synthesize tvSignIn = _tvSignIn;
@synthesize bAppCode = _bAppCode;
@synthesize lCopyright = _lCopyright;

@synthesize mask = _mask;

@synthesize uname = _uname;
@synthesize pwd = _pwd;

#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if (self == nil) {
        return nil;
    }
   
    _mask = [[NSStringMask alloc] initWithPattern:@"(\\d{3})-(\\d{3})-(\\d{3})" placeholder:@"_"];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    return self;
}

#pragma mark - View management

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Login", @"EXSignInViewController title");
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.backgroundColor = [UIColor colorFromHEXString:@"#FBFBFB"];
    
    self.svScroll.backgroundColor = [UIColor clearColor];
    self.vContent.backgroundColor = [UIColor colorFromHEXString:@"#FBFBFB"];

    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.vContent attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.vContent attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    height.priority = 250.;
    [self.view addConstraints:@[ width, height ]];
    
    UITableView *tv = self.tvSignIn;
    [tv registerNib:[UINib nibWithNibName:kEXSignInCellIdentifier bundle:nil] forCellReuseIdentifier:kEXSignInCellIdentifier];
    
    tv.backgroundView = [[UIView alloc] init];
    tv.backgroundView.backgroundColor = [UIColor clearColor];
    tv.backgroundColor = [UIColor clearColor];
    tv.scrollEnabled = NO;
    
    tv.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIImageView *iv = self.ivLogo;
    iv.image = [UIImage imageNamed:@"logo"];
    
    UIButton *btn = self.bAppCode;
    btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.];
    [btn setTitleColor:[UIColor colorFromHEXString:@"#1E88E5"] forState:UIControlStateNormal];
    
    UILabel *l = self.lCopyright;
    l.text = NSLocalizedString(@"© 2015 Appery, LLC. All rights reserved.", @"© 2015 Appery, LLC. All rights reserved.");
    l.font = [UIFont fontWithName:@"HelveticaNeue" size:10.];
    l.textColor = [UIColor colorFromHEXString:@"#BDBDBD"];
    l.textAlignment = NSTextAlignmentCenter;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tvSignIn reloadData];
    });
}

#pragma mark - Public class logic

- (void)updateProjectsMetadata:(NSArray *)projectsMetadata {
    EXProjectViewController *nextViewController = (EXProjectViewController *)[self nextViewController];
    if ([nextViewController.projectsMetadataViewController respondsToSelector: @selector(initializeProjectsMetadata:)]) {
        [nextViewController.projectsMetadataViewController initializeProjectsMetadata:projectsMetadata];
    }
}

#pragma mark - Private class logic

- (void) signIn {
    UIView *rootView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo: rootView animated: YES];
    progressHud.labelText = NSLocalizedString(@"Login", @"Login progress hud title");
    
    [self.apperyService quickLogout];
    __weak EXApperyService *weakService = self.apperyService;
    [self.apperyService loginWithUsername:self.uname password:self.pwd succeed: ^(NSArray *projectsMetadata) {
        [progressHud hide: YES];
        
        EXApperyService *strongService = weakService;
        [self saveUserSettings];
        
        self.uname = nil;
        self.pwd = nil;
        
        [self navigateToNextViewController];
        [self updateProjectsMetadata:projectsMetadata];
        
        DLog(@"User %@ login to %@", self.uname, strongService.baseUrl);
    }
                                   failed:^(NSError *error) {
                                       [progressHud hide: YES];
                                       self.uname = nil;
                                       self.pwd = nil;
                                       EXApperyService *strongService = weakService;
                                       [[[UIAlertView alloc] initWithTitle: error.localizedDescription
                                                                   message: error.localizedRecoverySuggestion
                                                                  delegate: nil
                                                         cancelButtonTitle: NSLocalizedString(@"Ok", nil)
                                                         otherButtonTitles: nil] show];
                                       
                                       DLog(@"User %@ can't login to %@",self.uname, strongService.baseUrl);
                                   }];
}

- (void) saveUserSettings {
    EXUserSettingsStorage *usStorage = [EXUserSettingsStorage sharedUserSettingsStorage];
    
    // save user settings
    EXUserSettings *userSettings = [[EXUserSettings alloc] init];
    
    userSettings.userName = self.uname;
    userSettings.shouldRememberMe = YES;
    userSettings.sortMethodType = [[usStorage retreiveLastStoredSettings] sortMethodType];
    [usStorage storeSettings: userSettings];
    
//    // save user credentials
//    if ([EXCredentialsManager addPassword:self.pwd forUser:self.uname] == NO) {
//        // not critical
//        DLog(@"Can not add password for user: %@", self.uname);
//    }
}

- (void) navigateToNextViewController
{
    UIViewController *nextViewController = [self nextViewController];
    if ([self.navigationController.viewControllers containsObject: nextViewController]) {
        [self.navigationController popToViewController: nextViewController animated: YES];
    } else {
        [self.navigationController pushViewController:nextViewController animated: YES];
    }
}

#pragma mark - Action handlers

- (IBAction)appCodeAction:(id)sender {
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    #pragma unused(tableView)
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    #pragma unused(tableView, section)
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEXSignInCellIdentifier];
    if (cell == nil)
    {
        NSArray *content = [[NSBundle mainBundle] loadNibNamed:kEXSignInCellIdentifier owner:nil options:nil];
        cell = content[0];
    }
    EXSignInCell *siCell = [cell as:[EXSignInCell class]];
    siCell.delegate = self;
    if (indexPath.row == 0) {
        EXUserSettingsStorage *usStorage = [EXUserSettingsStorage sharedUserSettingsStorage];
        EXUserSettings *lastUserSettings = [usStorage retreiveLastStoredSettings];
        [siCell configureCellForType:SignInCellTypeLogin withText:lastUserSettings.userName];
        self.uname = lastUserSettings.userName;
    }
    else if (indexPath.row == 1) {
        [siCell configureCellForType:SignInCellTypePassword];
    }
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UNEXPECTED_CELL"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [EXSignInCell height];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(tintColor)]) {
        CGFloat cornerRadius = 5.;
        cell.backgroundColor = [UIColor clearColor];
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGRect bounds = CGRectInset(cell.bounds, 10., 0.);

        BOOL addLine = NO;
        
        if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
            CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
        }
        else if (indexPath.row == 0) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
            addLine = YES;
        }
        else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
        }
        else {
            CGPathAddRect(pathRef, nil, bounds);
            addLine = YES;
        }
        
        layer.path = pathRef;
        CFRelease(pathRef);
        layer.fillColor = [UIColor colorWithWhite:1. alpha:0.8].CGColor;
        
        if (addLine == YES) {
            CALayer *lineLayer = [[CALayer alloc] init];
            CGFloat lineHeight = (1. / [UIScreen mainScreen].scale);
            lineLayer.frame = CGRectMake(CGRectGetMinX(bounds), bounds.size.height - lineHeight, bounds.size.width, lineHeight);
            lineLayer.backgroundColor = tableView.separatorColor.CGColor;
            [layer addSublayer:lineLayer];
        }
        UIView *testView = [[UIView alloc] initWithFrame:bounds];
        [testView.layer insertSublayer:layer atIndex:0];
        testView.backgroundColor = UIColor.clearColor;
        cell.backgroundView = testView;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - ExSignInCellActionDelegate

- (void)cell:(EXSignInCell *)cell didUpdateText:(NSString *)text {
    switch (cell.type) {
        case SignInCellTypeLogin:
            self.uname = text;
            break;
        case SignInCellTypePassword:
            self.pwd = text;
            break;
        default:
            break;
    }
}

- (void)needToExecuteActionForCell:(EXSignInCell *)cell {
    switch (cell.type) {
        case SignInCellTypePassword:
            [self signIn];
            break;
        default:
            break;
    }
}

#pragma mark - EXViewControllerProvider protocol implementation

- (UIViewController *)nextViewController {
    return self.projectViewController;
}

#pragma mark - UIAlertViewDelegate implementation

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    }
    
    UIView *rootView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:rootView animated:YES];
    progressHud.labelText = NSLocalizedString(@"Loading app", @"Loading app progress hud title");
    
    NSString *appCode = [[alertView textFieldAtIndex:0] text];
    
    __weak EXApperyService *weakService = self.apperyService;
    [self.apperyService loadProjectForAppCode:appCode
                                      succeed:^(NSString *projectLocation, NSString *startPageName) {
                                          [progressHud hide: NO];
                                        
                                          EXApperyService *strongService = weakService;
                                          EXProjectViewController *projectViewController = [[EXProjectViewController alloc] initWithProjectCode:appCode];
                                          projectViewController.apperyService = strongService;
                                          projectViewController.wwwFolderName = projectLocation;
                                          projectViewController.startPage = startPageName;
                                            
                                          [self.navigationController pushViewController:projectViewController animated:YES];
                                            
                                          DLog(@"App %@ has been loaded.", appCode);
                                        }
                                       failed:^(NSError *error) {
                                           [progressHud hide: NO];
                                            
                                           [[[UIAlertView alloc] initWithTitle: error.localizedDescription
                                                                       message: error.localizedRecoverySuggestion
                                                                      delegate: nil
                                                             cancelButtonTitle: NSLocalizedString(@"Ok", nil)
                                                             otherButtonTitles: nil] show];
                                            
                                            DLog(@"App %@ loading has failed due to: %@", appCode, error.localizedDescription);
                                        }
     ];
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
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

#pragma mark - Keyboard notification handlers

- (void)keyboardWillShowNotification:(NSNotification *)notification {
    NSValue *val = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] as:[NSValue class]];
    CGRect keyboardEndFrame = val.CGRectValue;
    CGRect convertedKeyboardEndFrame = [self.view convertRect:keyboardEndFrame fromView:self.view.window];
    
    UIEdgeInsets inset = self.svScroll.contentInset;
    inset.bottom = convertedKeyboardEndFrame.size.height;
    self.svScroll.contentInset = inset;
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    #pragma unused(notification)
    self.svScroll.contentInset = UIEdgeInsetsZero;
}

@end
