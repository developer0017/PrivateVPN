//
//  LoginVC.h
//  PrivateVPN
//
//  Created by Star Developer on 2/26/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HomeVC.h"

@interface LoginVC : NSViewController

@property (weak) IBOutlet NSTextField *txtUsername;
@property (weak) IBOutlet NSTextField *txtPassword;
//@property (weak) IBOutlet NSSecureTextField *txtPassword1;
@property (weak) IBOutlet NSButton *chkRememberMe;
@property (weak) IBOutlet NSButton *btnForgotPassword;
@property (weak) IBOutlet NSButton *btnLogin;
@property (weak) IBOutlet NSTextField *txtErrorMessage;

@property (weak) IBOutlet NSView *viewLoggingIn;
@property (weak) IBOutlet NSView *viewLogin;

@property (weak) IBOutlet NSProgressIndicator *progressLoggingIn;

@property (nonatomic, retain) IBOutlet HomeVC * homeVC;
@end
