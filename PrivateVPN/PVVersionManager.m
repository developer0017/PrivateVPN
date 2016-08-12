//
//  PVVersionManager.m
//  PrivateVPN
//
//  Created by oscar on 3/10/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import "PVVersionManager.h"
#import "PVUrlManager.h"
#import "PVLocalStorageManager.h"
#import "AFNetworking.h"

@implementation PVVersionManager

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
    self.mVersion = @"";
    self.mBuild = @"";
    
}
-(BOOL) loadVersionFromLocalstorage
{
    NSDictionary* dict = [PVLocalStorageManager loadGlobalObjectWithKey:LOCALSTORAGE_VERSION];
    if(dict == nil) return NO;
    @try {
        self.mBuild = [dict objectForKey:@"build"];
        self.mVersion = [dict objectForKey:@"version"];
        self.mAppUrl = [dict objectForKey:@"app_url"];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Error occured in LoadUserLastLoginFromLocalstorage.");
        return NO;
    }

}
-(void) saveVersionToLocalstorage
{
    NSDictionary *dict = @{@"build": self.mBuild,
                           @"version": self.mVersion,
                           @"app_url": self.mAppUrl
                           };
    [PVLocalStorageManager saveGlobalObject:dict Key:LOCALSTORAGE_VERSION];
}

-(void)requestVersionWithCallback: (void (^)(int status)) callback
{
    NSString *strUrl = [PVUrlManager getEndpointForVersion];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:strUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Version fetching - Success");
        int status = SUCCESS_WITH_NO_ERROR;
        self.mAppUrl = [responseObject objectForKey:@"build"];
        self.mVersion = [responseObject objectForKey:@"version"];
        self.mAppUrl = [responseObject objectForKey:@"app_url"];
        if(callback)
            callback(status);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        int status = ERROR_CONNECTION_FAILED;
        if(task.response != nil){
            status = ERROR_INVALID_REQUEST;
        }
        if(callback)
            callback(status);
    }];
}

@end
