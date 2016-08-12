//
//  PVServerManager.m
//  PrivateVPN
//
//  Created by oscar on 3/3/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import "PVServerManager.h"
#import "PVUrlManager.h"
#import "PVUserManager.h"
#import "PVServerDataModel.h"
#import "PVLocalStorageManager.h"
#import "AFNetworking.h"

@implementation PVServerManager


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
    self.mServerList = [[NSMutableArray alloc] init];
    
}

-(BOOL)isConnected
{
    return false;
}
-(NSString*) getIPAddressByName:(NSString*)name
{
    NSString *strIP = nil;
    if(self.mServerList.count == 0){
        return nil;
    }
    for(PVServerDataModel *server in self.mServerList)
    {
        if([server.mName isEqualToString:name])
        {
            strIP = server.mIP;
            break;
        }
        
    }
    return strIP;
}
-(NSString*) getFlagUrlByName:(NSString*)name
{
    NSString * strUrl;
    if(self.mServerList.count == 0){
        return nil;
    }
    for(PVServerDataModel *server in self.mServerList)
    {
        if([server.mName isEqualToString:name])
        {
            strUrl = server.mFlagUrl;
            break;
        }
        
    }
    return strUrl;
    
}
-(int) getPortByName:(NSString*)name
{
    int port = -1;
    if(self.mServerList.count == 0){
        return -1;
    }
    for(PVServerDataModel *server in self.mServerList)
    {
        if([server.mName isEqualToString:name])
        {
            port = server.mPort;
            break;
        }
    }
    return port;
}
-(BOOL) loadServerListFromLocalstorage
{
    NSArray *arr = [PVLocalStorageManager loadGlobalObjectWithKey:LOCALSTORAGE_SERVERLIST];
    if(arr ==nil)
        return NO;
    [self setServerListWithArray:arr];
    return YES;
    
}
-(void) saveServerListToLocalstorage
{
    if(self.mServerList.count == 0)
        return;
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i=0; i<[self.mServerList count]; i++) {
        PVServerDataModel * server = [self.mServerList objectAtIndex:i];
        NSDictionary *dict = [server serializeToDictionary];
        [arr addObject:dict];
    }
    [PVLocalStorageManager saveGlobalObject:arr Key:LOCALSTORAGE_SERVERLIST];
}

-(void)requestServerListWithCallback: (void (^)(int status)) callback
{
    NSString *strUrl = [PVUrlManager getEndpointForServer];
    NSLog(@"API URL: %@", strUrl);
    //    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //Security: bypass ssl checking.
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [securityPolicy setValidatesDomainName:NO];
    [securityPolicy setAllowInvalidCertificates:YES];
    manager.securityPolicy = securityPolicy;
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:[PVUserManager sharedInstance].strUsername password:[PVUserManager sharedInstance].strPassword];
    
    [manager POST:strUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Server list fetching - Success");
        int status = SUCCESS_WITH_NO_ERROR;
        
        [self setServerListWithArray:responseObject];
        [self sortServerList];
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

#pragma mark - Internal Methods
-(void) setServerListWithArray: (NSArray*) arr
{
    [self.mServerList removeAllObjects];
    if(arr==nil || [arr isKindOfClass:[NSArray class]]==NO){
        NSLog(@"Error: ServerList is empty.");
        return;
    }
    
    for(int i=0; i<(int)[arr count]; i++){
        NSDictionary *dict = [arr objectAtIndex:i];
        PVServerDataModel *server = [[PVServerDataModel alloc] init];
        [server setWithDictionary:dict];
        [self.mServerList addObject:server];
    }
    
}
-(void) sortServerList
{
    //Sort the array according to name.
    [self.mServerList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *first = [(PVServerDataModel*)obj1 mName];
        NSString *second = [(PVServerDataModel*)obj2 mName];
        return [first compare:second];
    }];
}

@end
