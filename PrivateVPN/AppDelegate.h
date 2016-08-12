//
//  AppDelegate.h
//  PrivateVPN
//
//  Created by Star Developer on 2/26/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LoadingVC.h"
#import "LoginVC.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <Sparkle/Sparkle.h>

#define APPDELEGATE ((AppDelegate *)[[NSApplication sharedApplication] delegate])

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSWindow *window;

@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* password;

@property (nonatomic, strong) IBOutlet LoginVC* loginVC;
@property (nonatomic, strong) IBOutlet LoadingVC* loadingVC;

@property (nonatomic, assign) SCNetworkConnectionRef    networkConnectionRef;
@property (nonatomic, assign) SCNetworkServiceRef       currentService;

@property (nonatomic,assign) BOOL connect_pressed;

@end

