//
//  PVUrlManager.m
//  PrivateVPN
//
//  Created by Star Developer on 3/1/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import "PVUrlManager.h"

@implementation PVUrlManager

+(NSString*) getEndpointForAccount
{
    return [NSString stringWithFormat:@"%@/account", BASEURL];
}
+(NSString*) getEndpointForServer
{
    return [NSString stringWithFormat:@"%@/servers", BASEURL];
}
+(NSString*) getEndpointForPort
{
    return [NSString stringWithFormat:@"%@/ports", BASEURL];
}
+(NSString*) getEndpointForVersion
{
    return [NSString stringWithFormat:@"%@/version", BASEURL];
}

@end
