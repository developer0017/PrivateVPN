//
//  PVLocalStorageManager.h
//  PrivateVPN
//
//  Created by oscar on 3/2/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVLocalStorageManager : NSObject

+ (void) removeObject: (NSString*) key;
+ (void) removeGlobalObject: (NSString*) key;

+ (void) saveObject: (id)obj Key:(NSString*) key;
+ (void) saveGlobalObject: (id)obj Key:(NSString*) key;

+(id) loadObjectWithKey:(NSString*) key;
+(id) loadGlobalObjectWithKey:(NSString*) key;

@end
