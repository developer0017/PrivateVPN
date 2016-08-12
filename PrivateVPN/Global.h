//
//  Global.h
//  PrivateVPN
//
//  Created by Star Developer on 3/1/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#ifndef Global_h
#define Global_h

#define BASEURL @"https://xu595.privatevpn.com/v3/mac"
#define FORGOT_PASSWORD_URL @"https://privatevpn.com/prices/retrieve-account"
#define LIVE_SUPPORT_URL @"https://messenger.providesupport.com/messenger/1wg8eb6q10hor1es948pi7y939.html"
#define BACKGROUND_COLOR CGColorCreateGenericRGB(57.0/255, 155.0/255, 205.0/255, 1.0)

//Keychain
#define KEYCHAIN_SERVICE_ID            @"com.PrivateVPN"


#define SUCCESS_WITH_NO_ERROR       0
#define ERROR_CONNECTION_FAILED     1
#define ERROR_INVALID_PARAMETER     2
#define ERROR_INVALID_REQUEST       3

#define LOCALSTORAGE_PREFIX         @"PV_LOCAL_"
#define LOCALSTORAGE_USERLASTLOGIN  @"USERLASTLOGIN"
#define LOCALSTORAGE_SERVERLIST     @"SERVERLIST"
#define LOCALSTORAGE_VERSION        @"VERSION"

#endif /* Global_h */
