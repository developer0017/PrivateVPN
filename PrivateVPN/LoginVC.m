//
//  LoginVC.m
//  PrivateVPN
//
//  Created by Star Developer on 2/26/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import "LoginVC.h"
#import "AppDelegate.h"
#import "PVUserManager.h"
#import "PVGenericFunctionManager.h"

@interface LoginVC (){
    PVUserManager *userManager;
    BOOL rememberMe;
}

@end

@implementation LoginVC
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        // Initializatioin code here.
        userManager = [[PVUserManager sharedInstance] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
  
    self.view.wantsLayer = true;
    [self.view.layer setBackgroundColor:BACKGROUND_COLOR];
    
    self.btnLogin.wantsLayer = true;
    self.btnLogin.layer.cornerRadius = 10.0;

    [self setButtonTitleFor:self.btnLogin toString:[self.btnLogin title] withColor:[NSColor whiteColor]];
    [self setButtonTitleFor:self.chkRememberMe toString:[self.chkRememberMe title] withColor:[NSColor whiteColor]];
    
    self.viewLoggingIn.hidden = YES;
    [self.txtUsername becomeFirstResponder];
    
    //Auto Login
    //if([userManager loadUserLastLoginFromLocalstorage])
    if([userManager loadUserFromKeychain])
    {
        [self.txtUsername setStringValue:[userManager strUsername]];
        [self.txtPassword setStringValue:[userManager strPassword]];
        
        self.viewLogin.hidden = YES;
        self.viewLoggingIn.hidden = NO;
        [self.progressLoggingIn startAnimation:nil];
        
        [userManager requestLoginWithCallback:^(int status) {
            self.viewLogin.hidden = NO;
            self.viewLoggingIn.hidden = YES;
            [self.progressLoggingIn stopAnimation:nil];
            //[APPDELEGATE hideLoading];
            if(status == SUCCESS_WITH_NO_ERROR){
                self.homeVC = [[HomeVC alloc] initWithNibName:@"HomeVC" bundle:nil];
                [self.view.window setContentViewController:self.homeVC];
            }else if(status == ERROR_INVALID_REQUEST) {
                [self.txtErrorMessage setStringValue:@"Wrong username or password"];
            }else if(status == ERROR_CONNECTION_FAILED){
                [self.txtErrorMessage setStringValue:@"Connection failed"];
            }
        }];
    }
    
}
- (IBAction)onClickLogin:(NSButton *)sender {
    //[APPDELEGATE showLoading];
    [self.txtErrorMessage setStringValue:@""];
    //LoadingVC *loadingVC = [[LoadingVC alloc] initWithNibName:@"LoadingVC" bundle:nil];
    //[self.view addSubview:loadingVC.view];
    self.viewLogin.hidden = YES;
    self.viewLoggingIn.hidden = NO;
    [self.progressLoggingIn startAnimation:nil];

    userManager.strUsername = self.txtUsername.stringValue;
    userManager.strPassword = self.txtPassword.stringValue;
    [userManager requestLoginWithCallback:^(int status) {
       
        self.viewLogin.hidden = NO;
        self.viewLoggingIn.hidden = YES;
        [self.progressLoggingIn stopAnimation:nil];
        
        //[APPDELEGATE hideLoading];
        if(status == SUCCESS_WITH_NO_ERROR){
            if(rememberMe){
                //[userManager saveUserLastLoginToLocalstorage];
                [userManager saveUserToKeychain];
            } else {
                [userManager removeUserFromKeychain];
            }
            self.homeVC = [[HomeVC alloc] initWithNibName:@"HomeVC" bundle:nil];
            [self.view.window setContentViewController:self.homeVC];
        }else if(status == ERROR_INVALID_REQUEST) {
            //[PVGenericFunctionManager showAlertWithMessage:@"Wrong username or password"];
            [self.txtErrorMessage setStringValue:@"Wrong username or password"];
        }else if(status == ERROR_CONNECTION_FAILED){
            //[PVGenericFunctionManager showAlertWithMessage:@"Connection failed."];
            [self.txtErrorMessage setStringValue:@"Connection failed"];
        }
    }];

}
- (IBAction)onCheckRememberMe:(id)sender {
    NSLog(@"state %ld", (long)[sender state]);
    rememberMe = [sender state];
    
}
- (IBAction)onClickForgotPassword:(id)sender {
    [[self.txtUsername window] makeFirstResponder:nil];
    [[self.txtPassword window] makeFirstResponder:nil];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:FORGOT_PASSWORD_URL]];
    //self.forgotPasswordVC = [[ForgotPasswordVC alloc] initWithNibName:@"ForgotPasswordVC" bundle:nil];
    //[self.view addSubview:self.forgotPasswordVC.view];
}
- (IBAction)onPasswordTextFieldAction:(id)sender {
    [self onClickLogin:nil];
}

-(void)setButtonTitleFor:(NSButton*)button toString:(NSString*)title withColor:(NSColor*)color
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];;
    NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:color, NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:title attributes:attrDictionary];
    [button setAttributedTitle:attrString];
    [button setAttributedAlternateTitle:attrString];
}
@end
