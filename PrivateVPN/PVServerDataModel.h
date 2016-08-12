//
//  PVServerDataModel.h
//  PrivateVPN
//
//  Created by oscar on 3/3/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVServerDataModel : NSObject

@property (strong, nonatomic) NSString* mIP;
@property (strong, nonatomic) NSString* mName;
@property (nonatomic) int mPort;
@property (nonatomic) BOOL mByPass;
@property (strong, nonatomic) NSString* mFlagUrl;
@property (strong, nonatomic) NSString* mCountry;

-(instancetype) init;
-(void) setWithDictionary: (NSDictionary *)dict;
-(NSDictionary *) serializeToDictionary;
@end
