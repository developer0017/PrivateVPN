//
//  Service.h
//  PrivateVPN
//
//  Created by Star Developer on 4/21/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Authorization.h>
#import <ServiceManagement/ServiceManagement.h>

@interface Service : NSObject
{
    AuthorizationRef authRef;
}
@property (nonatomic, strong) xpc_connection_t xpc_connection;
+(instancetype) sharedInstance;
-(void)checkHelper;
@end
