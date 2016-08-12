//
//  PVUrlManager.h
//  PrivateVPN
//
//  Created by Star Developer on 3/1/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVUrlManager : NSObject

+(NSString*) getEndpointForAccount;
+(NSString*) getEndpointForServer;
+(NSString*) getEndpointForPort;
+(NSString*) getEndpointForVersion;

@end
