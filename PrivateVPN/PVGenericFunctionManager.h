//
//  PVGenericFunctionManager.h
//  PrivateVPN
//
//  Created by oscar on 3/3/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVGenericFunctionManager : NSObject

#pragma mark -App

+ (NSString *) getAppVersionString;
+ (NSString *) getAppBuildString;

#pragma mark -String Manipulation

+ (NSString *) refineNSString: (NSString *)sz;
+ (BOOL) isValidEmailAddress: (NSString *) candidate;

#pragma mark -UI

+ (void) showAlertWithMessage: (NSString *) szMessage;

@end
