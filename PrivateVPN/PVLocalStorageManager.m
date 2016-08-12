//
//  PVLocalStorageManager.m
//  PrivateVPN
//
//  Created by oscar on 3/2/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import "PVLocalStorageManager.h"
#import "PVUserManager.h"

@implementation PVLocalStorageManager

+ (void) removeObject: (NSString*) key
{
    NSString *strKey = [NSString stringWithFormat:@"%@%@_%@", LOCALSTORAGE_PREFIX, [PVUserManager sharedInstance].strUsername, key];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:strKey];
    [userDefaults synchronize];
}
+ (void) removeGlobalObject: (NSString*) key
{
    NSString *strKey = [NSString stringWithFormat:@"%@_%@", LOCALSTORAGE_PREFIX, key];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:strKey];
    [userDefaults synchronize];
}

+ (void) saveObject: (id)obj Key:(NSString*) key
{
    NSString *strKey = [NSString stringWithFormat:@"%@%@_%@", LOCALSTORAGE_PREFIX, [PVUserManager sharedInstance].strUsername, key];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:obj forKey:strKey];
    [userDefaults synchronize];
}
+ (void) saveGlobalObject: (id)obj Key:(NSString*) key
{
    NSString *strKey = [NSString stringWithFormat:@"%@_%@", LOCALSTORAGE_PREFIX, key];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:obj forKey:strKey];
    [userDefaults synchronize];
}

+(id) loadObjectWithKey:(NSString*) key
{
    NSString *strKey = [NSString stringWithFormat:@"%@%@_%@", LOCALSTORAGE_PREFIX, [PVUserManager sharedInstance].strUsername, key];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:strKey];
    
}
+(id) loadGlobalObjectWithKey:(NSString*) key
{
    NSString *strKey = [NSString stringWithFormat:@"%@_%@", LOCALSTORAGE_PREFIX, key];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:strKey];
}


@end
