//
//  PVUserManager.h
//  PrivateVPN
//
//  Created by oscar on 3/2/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVUserManager : NSObject

@property (strong, nonatomic) NSString *strUsername;
@property (strong, nonatomic) NSString *strPassword;
@property (strong, nonatomic) NSString *strEmail;
@property (strong, nonatomic) NSString *strIPAddress;
@property (nonatomic) BOOL isPremium;
@property (nonatomic) BOOL isSecured;
@property (nonatomic) int premiumDaysLeft;

@property (nonatomic) BOOL isLoggedOut;


-(id) init;
+(instancetype) sharedInstance;
-(void) initializeManager;

-(BOOL) isUserLoggedIn;

-(void) removeUserLastLoginFromLocalstorage;
-(BOOL) loadUserLastLoginFromLocalstorage;
-(void) saveUserLastLoginToLocalstorage;

-(void) saveUserToKeychain;
-(BOOL) loadUserFromKeychain;
-(void) removeUserFromKeychain;

-(void)requestLoginWithCallback: (void (^)(int status)) callback;
//-(void)requestForgotPassword: (void (^)(int status)) callback;
@end
