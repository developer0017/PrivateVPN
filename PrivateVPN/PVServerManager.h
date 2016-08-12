//
//  PVServerManager.h
//  PrivateVPN
//
//  Created by oscar on 3/3/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVServerManager : NSObject

@property(strong, nonatomic) NSMutableArray* mServerList;

-(BOOL) isConnected;

-(id) init;
+(instancetype) sharedInstance;
-(void) initializeManager;
-(NSString*) getIPAddressByName:(NSString*)name;
-(NSString*) getFlagUrlByName:(NSString*)name;
-(int) getPortByName:(NSString*)name;

-(BOOL) loadServerListFromLocalstorage;
-(void) saveServerListToLocalstorage;

-(void) requestServerListWithCallback: (void (^)(int status)) callback;

@end
