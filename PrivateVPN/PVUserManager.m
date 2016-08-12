//
//  PVUserManager.m
//  PrivateVPN
//
//  Created by oscar on 3/2/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import "PVUserManager.h"
#import "PVUrlManager.h"
#import "PVLocalStorageManager.h"
#import "AFNetworking.h"
#import "SSKeychain.h"

@implementation PVUserManager

+(instancetype) sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(id) init
{
    if(self = [super init]){
        [self initializeManager];
    }
    return self;
}
-(void) initializeManager
{
    self.strPassword = @"";
    self.strUsername = @"";
    self.strEmail = @"";
    self.strIPAddress = @"";
    self.isPremium = false;
    self.isSecured = false;
    self.premiumDaysLeft = 0;
    
    self.isLoggedOut = false;
}
-(BOOL) isUserLoggedIn
{
    if(self.strUsername.length == 0 || self.strPassword.length ==0)
        return NO;
    return YES;
}
-(void) removeUserLastLoginFromLocalstorage
{
    [PVLocalStorageManager removeGlobalObject:LOCALSTORAGE_USERLASTLOGIN];
}
-(BOOL) loadUserLastLoginFromLocalstorage
{
    NSDictionary* dict = [PVLocalStorageManager loadGlobalObjectWithKey:LOCALSTORAGE_USERLASTLOGIN];
    if(dict == nil) return NO;
    @try {
        self.strUsername = [dict objectForKey:@"username"];
        self.strPassword = [dict objectForKey:@"password"];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Error occured in LoadUserLastLoginFromLocalstorage.");
        return NO;
    }
    
}
-(void) saveUserLastLoginToLocalstorage
{
    NSDictionary *dict = @{@"username": self.strUsername,
                           @"password": self.strPassword
                           };
    [PVLocalStorageManager saveGlobalObject:dict Key:LOCALSTORAGE_USERLASTLOGIN];
}

- (NSDictionary*) serializeDictionary {
    NSDictionary *dict = @{@"email": self.strEmail,
                           @"ip": self.strIPAddress,
                           @"is_premium": [NSNumber numberWithBool:self.isPremium],
                           @"secured": [NSNumber numberWithBool:self.isSecured],
                           @"premium_days_left": [NSNumber numberWithInt:self.premiumDaysLeft],
                           };
    return dict;
}
-(void) saveUserToKeychain
{
    [SSKeychain setPassword:self.strPassword forService:KEYCHAIN_SERVICE_ID account:self.strUsername];
}
-(BOOL) loadUserFromKeychain
{
    NSArray * arr = [SSKeychain accountsForService:KEYCHAIN_SERVICE_ID];
    if(arr == nil)
        return NO;
    NSDictionary* dict = [arr objectAtIndex:0];
    
    self.strUsername = [dict objectForKey:kSSKeychainAccountKey];
    self.strPassword = [SSKeychain passwordForService:KEYCHAIN_SERVICE_ID account:self.strUsername];
    if(self.strPassword ==nil)
        return NO;
    return YES;
}
-(void) removeUserFromKeychain
{
    [SSKeychain deletePasswordForService:KEYCHAIN_SERVICE_ID account:self.strUsername];
}

-(void)requestLoginWithCallback: (void (^)(int status)) callback
{
    NSString *strUrl = [PVUrlManager getEndpointForAccount];
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //Security: bypass ssl checking.
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [securityPolicy setValidatesDomainName:NO];
    [securityPolicy setAllowInvalidCertificates:YES];
    manager.securityPolicy = securityPolicy;
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:self.strUsername password:self.strPassword];
    [manager POST:strUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"User login - Success");
        int status = SUCCESS_WITH_NO_ERROR;
        self.strEmail = [responseObject objectForKey:@"email"];
        self.strIPAddress = [responseObject objectForKey:@"ip"];
        self.isPremium = [[responseObject objectForKey:@"is_premium"] boolValue];
        self.isSecured = [[responseObject objectForKey:@"secured"] boolValue];
        if ([responseObject objectForKey:@"premium_days_left"] == [NSNull null]) {
            self.premiumDaysLeft = 0;
        } else {
            self.premiumDaysLeft = [[responseObject objectForKey:@"premium_days_left"] intValue];
        }
        
        if(callback)
            callback(status);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"requestLoginWithCallback error: %@", error);
        int status = ERROR_CONNECTION_FAILED;
        if(task.response != nil){
            status = ERROR_INVALID_REQUEST;
        }
        if(callback)
            callback(status);
    }];
    
}

@end
