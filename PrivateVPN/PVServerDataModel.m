//
//  PVServerDataModel.m
//  PrivateVPN
//
//  Created by oscar on 3/3/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import "PVServerDataModel.h"
#import "PVGenericFunctionManager.h"

@implementation PVServerDataModel

-(instancetype) init
{
    self = [super init];
    if(self){
        [self initialize];
    }
    return self;
}
-(void) initialize{
    self.mIP = @"";
    self.mCountry = @"";
    self.mFlagUrl = @"";
    self.mName = @"";
    self.mPort = 21000;
    self.mByPass = true;
    
}
-(void) setWithDictionary:(NSDictionary *)dict{
    @try {
        self.mIP = [PVGenericFunctionManager refineNSString:[dict objectForKey:@"ip"]];
        self.mPort = [[dict objectForKey:@"port"] intValue];
        self.mByPass = [[dict objectForKey:@"bypass"] boolValue];
        self.mName = [PVGenericFunctionManager refineNSString:[dict objectForKey:@"name"]];
        self.mFlagUrl = [PVGenericFunctionManager refineNSString:[dict objectForKey:@"flag_url"]];
        self.mCountry = [PVGenericFunctionManager refineNSString:[dict objectForKey:@"country"]];
    }
    @catch (NSException *exception) {
        [self initialize];
    }
}
-(NSDictionary *) serializeToDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.mIP forKey:@"ip"];
    [dict setObject:self.mCountry forKey:@"country"];
    [dict setObject:self.mFlagUrl forKey:@"flag_url"];
    [dict setObject:self.mName forKey:@"name"];
    [dict setObject:[NSNumber numberWithInt:self.mPort] forKey:@"port"];
    [dict setObject:[NSNumber numberWithBool:self.mByPass] forKey:@"bypass"];
    
    return dict;
}
@end
