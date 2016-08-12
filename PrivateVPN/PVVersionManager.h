//
//  PVVersionManager.h
//  PrivateVPN
//
//  Created by oscar on 3/10/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVVersionManager : NSObject

@property(strong, nonatomic) NSString* mAppUrl;
@property(strong, nonatomic) NSString* mBuild;
@property(strong, nonatomic) NSString* mVersion;

-(id) init;
+(instancetype) sharedInstance;
-(void) initializeManager;

-(BOOL) loadVersionFromLocalstorage;
-(void) saveVersionToLocalstorage;

-(void) requestVersionWithCallback: (void (^)(int status)) callback;

@end
