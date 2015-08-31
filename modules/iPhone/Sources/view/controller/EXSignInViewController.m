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

#import "RootViewControllerManager.h"
#import "EXMainWindowAppDelegate.h"

#import "MBProgressHUD.h"
#import "EXAppCodeController.h"

static NSString *const kEXSignInCellIdentifier = @"EXSignInCell";

@interface EXSignInViewController () <UITableViewDataSource, UITableViewDelegate, EXSignInCellActionDelegate, UITextFieldDelegate>

@property (nonatomic, strong, readwrite) EXApperyService *apperyService;

@property (nonatomic, weak) IBOutlet UIScrollView *svScroll;
@property (nonatomic, weak) IBOutlet UIView *vContent;

@property (nonatomic, weak) IBOutlet UIImageView *ivLogo;
@property (nonatomic, weak) IBOutlet UITableView *tvSignIn;
@property (nonatomic, weak) IBOutlet UIButton *bAppCode;
@property (nonatomic, weak) IBOutlet UILabel *lCopyright;

@property (nonatomic, strong) NSString *uname;
@property (nonatomic, strong) NSString *pwd;

@property (nonatomic, strong) EXAppCodeController *appCodeController;

- (IBAction)appCodeAction:(id)sender;

- (void)keyboardWillShowNotification:(NSNotification *)notification;
- (void)keyboardWillHideNotification:(NSNotification *)notification;

- (void) composeUIForMetadata:(NSArray *)metadata appCode:(NSString *)appCode location:(NSString *)location startPage:(NSString *)startPage;

@end

@implementation EXSignInViewController

@synthesize apperyService = _apperyService;

@synthesize svScroll = _svScroll;
@synthesize vContent = _vContent;

@synthesize ivLogo = _ivLogo;
@synthesize tvSignIn = _tvSignIn;
@synthesize bAppCode = _bAppCode;
@synthesize lCopyright = _lCopyright;

@synthesize uname = _uname;
@synthesize pwd = _pwd;

@synthesize appCodeController = _appCodeController;

#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil service:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil service:(EXApperyService *)service {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self == nil) {
        return nil;
    }
    
    _apperyService = service;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.shouldHideNavigationBar = YES;
    
    return self;
}

#pragma mark - View management

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Login", @"EXSignInViewController title");
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
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
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

#pragma mark - Private class logic

- (void) signIn {
    UIView *rootView = [[[EXMainWindowAppDelegate mainWindow] rootViewController] view];
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo: rootView animated: YES];
    progressHud.labelText = NSLocalizedString(@"Login", @"Login progress hud title");
    
    [self.apperyService quickLogout];
    __weak EXApperyService *weakService = self.apperyService;
    [self.apperyService loginWithUsername:self.uname password:self.pwd succeed: ^(NSArray *projectsMetadata) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressHud hide: YES];
            EXApperyService *strongService = weakService;

            DLog(@"User %@ login to %@", self.uname, strongService.baseUrl);
            [self saveUserSettings];
            
            self.uname = nil;
            self.pwd = nil;
            [self.tvSignIn reloadData];
            [self composeUIForMetadata:projectsMetadata appCode:nil location:@"www" startPage:@"index.html"];
        });
    }
                                    failed:^(NSError *error) {
                                        EXApperyService *strongService = weakService;
                                        DLog(@"User %@ can't login to %@",self.uname, strongService.baseUrl);
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [progressHud hide: YES];
                                            self.uname = nil;
                                            self.pwd = nil;
                                            [[[UIAlertView alloc] initWithTitle: error.localizedDescription
                                                                        message: error.localizedRecoverySuggestion
                                                                       delegate: nil
                                                              cancelButtonTitle: NSLocalizedString(@"Ok", nil)
                                                              otherButtonTitles: nil] show];
                                        });
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
}

- (void) composeUIForMetadata:(NSArray *)metadata appCode:(NSString *)appCode location:(NSString *)location startPage:(NSString *)startPage {
    RootViewControllerManager *manager = [RootViewControllerManager sharedInstance];
    if (metadata != nil) {
        EXProjectsMetadataViewController *pmvc = [[EXProjectsMetadataViewController alloc] initWithNibName:nil bundle:nil service:self.apperyService projectsMetadata:metadata];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            EXProjectViewController *pvc = [[EXProjectViewController alloc] initWithService:self.apperyService projectMetadata:nil];
            
            pvc.wwwFolderName = location;
            pvc.startPage = startPage;
            pmvc.delegate = pvc;
            
            [manager setSidebarViewController:pmvc];
            [manager setSidebarEnabled:YES];
            [manager pushRootViewController:pvc animated:YES completionBlock:nil];
        }
        else {
            [manager pushRootViewController:pmvc animated:YES completionBlock:nil];
        }
    }
    
    if (appCode != nil) {
        EXProjectViewController *pvc = [[EXProjectViewController alloc] initWithService:self.apperyService projectCode:appCode];
        pvc.wwwFolderName = location;
        pvc.startPage = startPage;
        [manager pushRootViewController:pvc animated:YES completionBlock:nil];
        [pvc updateContent];
    }
}

#pragma mark - Action handlers

- (IBAction)appCodeAction:(id)sender {
    self.appCodeController = [[EXAppCodeController alloc] init];
    [self.appCodeController requestCodeWithCompletionHandler:^(NSString *appCode){
        [self composeUIForMetadata:nil appCode:appCode location:@"www" startPage:@"index.html"];
        self.appCodeController = nil;
    }];
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
