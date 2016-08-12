/*
 Copyright (c) 2015
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

// Vendor dependencies
#import <SystemConfiguration/SystemConfiguration.h>

// Local dependencies
#import "VPNAuthorizations.h"
#import "VPNController.h"
#import "VPNKeychain.h"
#import "VPNServiceConfig.h"

// Exit status codes: 30-59
@implementation VPNController

+ (CFStringRef)nameOfPPPService:(SCNetworkServiceRef)service{
    CFStringRef serviceName = SCNetworkServiceGetName(service);
    return serviceName;
}
/********************
 * INTERNAL METHODS *
 ********************/

// This method is responsible for obtaining authorization in order to perform
// privileged system modifications. It is mandatory for creating network interfaces.
+ (int) create:(NSString*)endpoint1 username:(NSString*)username1 password:(NSString*)password1 secret:(NSString*)secret1 type:(int)type1 {
    
    // Obtaining permission to modify network settings
    SCPreferencesRef prefs = SCPreferencesCreateWithAuthorization(NULL, CFSTR("PrivateVPN"), NULL, [VPNAuthorizations create]);
    
    // Making sure other process cannot make configuration modifications
    // by obtaining a system-wide lock over the system preferences.
    if (SCPreferencesLock(prefs, TRUE)) {
        NSLog(@"Gained superhuman rights.");
    } else {
        NSLog(@"Sorry, without superuser privileges I won't be able to add any VPN interfaces.");
        return 31;
    }
    
    // If everything will work out fine, we will return exit code 0
    int exitCode = 0;
    
    //VPN Configuration.
    VPNServiceConfig* config = [VPNServiceConfig new];
    config.type = type1;
    config.name = @"PrivateVPN";
    config.endpointPrefix = @"";
    config.endpointSuffix = @"";
    if(endpoint1){
        config.endpoint = endpoint1;
    }else {
        NSLog(@"Error: You didn't provide an endpoint for service <%@>", config.name);
        exit(50);
    }
    
    config.username = username1;
    config.password = password1;
    config.sharedSecret = secret1;//"privatvpn"
    
    //TO DO. Need to check. Maybe remove item from keychain.
    //CFMutableArrayRef servicesList = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
    
    SCNetworkServiceRef	service;
    CFArrayRef services = SCNetworkServiceCopyAll(prefs);
    
    for (int i = 0; i < CFArrayGetCount(services); i++) {
        service = CFArrayGetValueAtIndex(services, i);
        CFStringRef serviceName = [self nameOfPPPService:service];
        NSString* strServiceName= (__bridge NSString *)(serviceName);
        if ([strServiceName isEqualToString:@"PrivateVPN"])
        {
            SecKeychainItemRef itemRef = NULL;
            // Does the item already exists?
            OSStatus status;
            NSString* serviceID = (__bridge NSString *)(SCNetworkServiceGetServiceID(service));
            
            status = SecKeychainFindGenericPassword(NULL,
                                                    (UInt32)[serviceID length],
                                                    [[serviceID dataUsingEncoding:NSUTF8StringEncoding] bytes],
                                                    0,NULL,NULL,NULL,
                                                    &itemRef);
            if (itemRef !=NULL)
            {
                SecKeychainItemDelete(itemRef);
            }
            
            NSString* serviceID1 = [NSString stringWithFormat:@"%@.SS",serviceID];
            
            status = SecKeychainFindGenericPassword(NULL,
                                                    (UInt32)[serviceID1 length],
                                                    [[serviceID1 dataUsingEncoding:NSUTF8StringEncoding] bytes],
                                                    0,NULL,NULL,NULL,
                                                    &itemRef);
            if (itemRef !=NULL)
            {
                SecKeychainItemDelete(itemRef);
            }
            NSString* serviceID2 = [NSString stringWithFormat:@"%@.XAUTH",serviceID];
            
            status = SecKeychainFindGenericPassword(NULL,
                                                    (UInt32)[serviceID2 length],
                                                    [[serviceID2 dataUsingEncoding:NSUTF8StringEncoding] bytes],
                                                    0,NULL,NULL,NULL,
                                                    &itemRef);
            if (itemRef !=NULL)
            {
                SecKeychainItemDelete(itemRef);
            }
            if(!SCNetworkServiceRemove(service))
                NSLog(@"Remove PrivateVPN in Network Preference Failed.");
            SCPreferencesApplyChanges(prefs);
        }
    }
    
    exitCode = [self createService:config usingPreferencesRef:prefs];
    
    // We're done, other processes may modify the system configuration again
    SCPreferencesUnlock(prefs);
    return exitCode;
}

// This method creates one VPN interface according to the desired configuration
+ (int) createService:(VPNServiceConfig*)config usingPreferencesRef:(SCPreferencesRef)prefs {
    NSLog(@"Creating new %@ Service using %@", config.humanType, config);
    
    // These variables will hold references to our new interfaces
    SCNetworkInterfaceRef topInterface;
    SCNetworkInterfaceRef bottomInterface;
    
    switch (config.type) {
        case VPNServiceL2TPOverIPSec:
            // L2TP on top of IPv4
            bottomInterface = SCNetworkInterfaceCreateWithInterface(kSCNetworkInterfaceIPv4,kSCNetworkInterfaceTypeL2TP);
            // PPP on top of L2TP
            topInterface = SCNetworkInterfaceCreateWithInterface(bottomInterface, kSCNetworkInterfaceTypePPP);
            break;
            
        case VPNServiceCiscoIPSec:
            // Cisco IPSec (without underlying interface)
            topInterface = SCNetworkInterfaceCreateWithInterface (kSCNetworkInterfaceIPv4, kSCNetworkInterfaceTypeIPSec);
            break;
        case VPNServicePPTP:
            // PPTP on top of IPv4
            bottomInterface = SCNetworkInterfaceCreateWithInterface(kSCNetworkInterfaceIPv4, kSCNetworkInterfaceTypePPTP);
            // PPP on top of PPTP
            topInterface = SCNetworkInterfaceCreateWithInterface(bottomInterface, kSCNetworkInterfaceTypePPP);
            break;
        default:
            NSLog(@"Sorry, this service type is not yet supported");
            return 32;
            break;
    }
    
    //Creating a new, fresh VPN service in memory using the interface we already created.
    SCNetworkServiceRef service = SCNetworkServiceCreate(prefs, topInterface);
    SCNetworkServiceSetName(service, (__bridge CFStringRef)config.name);
    
    NSString *serviceID = (__bridge NSString *)(SCNetworkServiceGetServiceID(service));
    //It will be used to find the correct passwords in the system keychain.
    config.serviceID = serviceID;
    
    // Interestingly enough, the interface variables in itself are now worthless.
    // We used them to create the service and that's it, we cannot modify or use them any more.
    // Deallocating obsolete interface references...
    CFRelease(topInterface);
    topInterface = NULL;
    if (bottomInterface) {
        CFRelease(bottomInterface);
        bottomInterface = NULL;
    }
    
    // Because, if we would like to modify the interface, we first need to freshly fetch it from the service
    // See https://lists.apple.com/archives/macnetworkprog/2013/Apr/msg00016.html
    topInterface = SCNetworkServiceGetInterface(service);
    
    // Error Codes 50-59
    
    NSLog(@"Configuring %@ Service", config.humanType);
    switch (config.type) {
        case VPNServicePPTP:
            if (SCNetworkInterfaceSetConfiguration(topInterface, config.PPTPPPPConfig)) {
                NSLog(@"Successfully configured PPP interface of service %@", config.name);
            } else {
                NSLog(@"Error: Could not configure PPP interface for service %@", config.name);
                return 57;
            }
            break;
        case VPNServiceL2TPOverIPSec:
            // Let's apply all configuration to the PPP interface
            // Specifically, the servername, account username and password
            if (SCNetworkInterfaceSetConfiguration(topInterface, config.L2TPPPPConfig)) {
                NSLog(@"Successfully configured PPP interface of service %@", config.name);
            } else {
                NSLog(@"Error: Could not configure PPP interface for service %@", config.name);
                return 50;
            }
            
            // Now let's apply the shared secret to the IPSec part of the L2TP/IPSec Interface
            if (SCNetworkInterfaceSetExtendedConfiguration(topInterface, CFSTR("IPSec"), config.L2TPIPSecConfig)) {
                //NSLog(@"Successfully configured IPSec on PPP interface for service %@", config.name);
            } else {
                //NSLog(@"Error: Could not configure IPSec on PPP interface for service %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
                return 35;
            }
            break;
            
        case VPNServiceCiscoIPSec:
            // Let's apply all configuration data to the Cisco IPSec interface
            // As opposed to L2TP, here all configuration goes to the top Interface, i.e. the only Interface there is.
            if (SCNetworkInterfaceSetConfiguration(topInterface, config.ciscoConfig)) {
                NSLog(@"Successfully configured Cisco IPSec interface of service %@", config.name);
            } else {
                NSLog(@"Error: Could not configure Cisco IPSec interface for service %@", config.name);
                return 51;
            }
            break;
            
        default:
            NSLog(@"Error: I cannot handle this interface type yet.");
            return 59;
            break;
    }
    //Adding default protocols (DNS, etc.) to service.
    if (!SCNetworkServiceEstablishDefaultConfiguration(service)) {
        NSLog(@"Error: Could not establish a default service configuration for %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
        return 36;
    }
    //Fetching set of all available network services...");
    SCNetworkSetRef networkSet = SCNetworkSetCopyCurrent(prefs);
    if (!networkSet) {
        //Error: Could not fetch current network set.
        return 37;
    }
    
    if (!SCNetworkSetAddService (networkSet, service)) {
        if (SCError() == 1005) {
            NSLog(@"Skipping VPN Service %@ because it already exists.", config.humanType);
            return 0;
        } else {
            //Error: Could not add new VPN service to current network set.
            return 38;
        }
    }
    
    //Fetching IPv4 protocol of service.
    SCNetworkProtocolRef protocol = SCNetworkServiceCopyProtocol(service, kSCNetworkProtocolTypeIPv4);
    
    if (!protocol) {
        NSLog(@"Error: Could not fetch IPv4 protocol of %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
        return 39;
    }
    
    //Configuring IPv4 protocol of service.
    if (!SCNetworkProtocolSetConfiguration(protocol, config.L2TPIPv4Config)) {
        //NSLog(@"Error: Could not configure IPv4 protocol of %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
        return 40;
    }
    
    //Commiting all changes including service.
    if (!SCPreferencesCommitChanges(prefs)) {
        NSLog(@"Error: Could not commit preferences with service %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
        return 41;
    }
    
    //Preparing to add Keychain items for service.
    
    // The password and the shared secret are not stored directly in the System Preferences .plist file
    // Instead we put them into the KeyChain. I know we're creating new items each time you run this application
    // But this actually is the same behaviour you get using the official System Preferences Network Pane
    if (config.password) {
        [VPNKeychain createPasswordKeyChainItem:config.name forService:serviceID withAccount:config.username andPassword:config.password];
    }
    
    if (config.sharedSecret) {
        [VPNKeychain createSharedSecretKeyChainItem:config.name forService:serviceID withPassword:config.sharedSecret];
    }
    
    if (!SCPreferencesApplyChanges(prefs)) {
        //NSLog(@"Error: Could not apply changes with service %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
        return 42;
    }
    
    NSLog(@"Successfully created %@ VPN %@ with ID %@", config.humanType, config.name, serviceID);
    return 0;
}

@end
