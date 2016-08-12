//
//  PVGenericFunctionManager.m
//  PrivateVPN
//
//  Created by oscar on 3/3/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import "PVGenericFunctionManager.h"
#import "AppDelegate.h"

@implementation PVGenericFunctionManager

+ (NSString *) getAppVersionString{
    NSString *szVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return szVersion;
}

+ (NSString *) getAppBuildString{
    NSString *szVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    return szVersion;
}

+ (NSString *) refineNSString: (NSString *)sz{
    NSString *szResult = @"";
    if ((sz == nil) || ([sz isKindOfClass:[NSNull class]] == YES)) szResult = @"";
    else szResult = [NSString stringWithFormat:@"%@", sz];
    return szResult;
}
+ (BOOL) isValidEmailAddress: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}
+ (void) showAlertWithMessage: (NSString *) msg{
    NSAlert* alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert setMessageText:msg];
    [alert beginSheetModalForWindow:[APPDELEGATE window] completionHandler:nil];
}

@end
