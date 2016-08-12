//
//  Service.m
//  PrivateVPN
//
//  Created by Star Developer on 4/21/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import "Service.h"
#import "AppDelegate.h"
NSString *const executableLabel = @"com.PrivateVPN.helper";

@implementation Service
+(instancetype) sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(id) init
{
    if(self = [super init]){
    }
    return self;
}
#pragma mark INSTALL
-(void)checkHelper
{
    CFDictionaryRef dataRef = SMJobCopyDictionary(kSMDomainSystemLaunchd, (__bridge CFStringRef)executableLabel);
    NSDictionary* installedHelperJobData = (__bridge NSDictionary*)dataRef;

    if(installedHelperJobData)
    {
        NSLog(@"HelperJobData: %@", installedHelperJobData);
        [self create_xpc_connection];
        NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
        
        NSString* msg=@"GetBuild";
        xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
        const char* request =[msg UTF8String];
        xpc_dictionary_set_string(message, "request", request);
        
        //Send message to Helper.
        xpc_connection_send_message_with_reply(self.xpc_connection, message, dispatch_get_main_queue(), ^(xpc_object_t event) {
            const char* response = xpc_dictionary_get_string(event, "reply");
            if(response == nil)
            {
                if(![self initAuthorizationRef]){
                    [[NSApplication sharedApplication] terminate:nil];
                    return;
                }
                [self removeFileWithElevatedPrivilegesFromLocation];
                [self installHelper];
            } else {
                NSString* buildSvc = [NSString stringWithUTF8String:response];
                if(![build isEqualToString:buildSvc]) {
                    if(![self initAuthorizationRef]){
                        [[NSApplication sharedApplication] terminate:nil];
                        return;
                    }
                    [self uninstallHelper];
                    [self removeFileWithElevatedPrivilegesFromLocation];
                    [self installHelper];
                }
            }
            sleep(1);
            [self create_xpc_connection];
        });
        
    } else {
        if(![self initAuthorizationRef]){
            [[NSApplication sharedApplication] terminate:nil];
            return;
        }
        [self installHelper];
        sleep(1);
        [self create_xpc_connection];
    }
    
}
-(BOOL)initAuthorizationRef {
    AuthorizationItem authItem		= { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
    AuthorizationRights authRights	= { 1, &authItem };
    AuthorizationFlags flags		=	kAuthorizationFlagDefaults				|
    kAuthorizationFlagInteractionAllowed	|
    kAuthorizationFlagPreAuthorize			|
    kAuthorizationFlagExtendRights;
    
    /* Obtain the right to install our privileged helper tool (kSMRightBlessPrivilegedHelper). */
    OSStatus status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &authRef);
    if (status != errAuthorizationSuccess) {
        NSLog(@"Failed to create AuthorizationRef.");
        return false;
    }
    return true;
}
- (void)create_xpc_connection {
    self.xpc_connection = xpc_connection_create_mach_service([executableLabel UTF8String], NULL, XPC_CONNECTION_MACH_SERVICE_PRIVILEGED);
    if(!self.xpc_connection) {
        NSLog(@"Failed to create XPC connection.");
        return;
    }
    
    xpc_connection_set_event_handler(self.xpc_connection, ^(xpc_object_t event) {
        xpc_type_t type = xpc_get_type(event);
        if(type == XPC_TYPE_ERROR) {
            if(event == XPC_ERROR_CONNECTION_INTERRUPTED) {
                NSLog(@"XPC connection interupted.");
            } else if(event == XPC_ERROR_CONNECTION_INVALID) {
                NSLog(@"XPC connection invalid.");
            } else {
                NSLog(@"Unexpected XPC connection error.");
            }
        } else {
            NSLog(@"Unexpected XPC connection event.");
        }
        
    });
    
    xpc_connection_resume(self.xpc_connection);
}
- (BOOL)installHelper
{
    CFErrorRef  error;
        
    /* This does all the work of verifying the helper tool against the application
     * and vice-versa. Once verification has passed, the embedded launchd.plist
     * is extracted and placed in /Library/LaunchDaemons and then loaded. The
     * executable is placed in /Library/PrivilegedHelperTools.
     */
    SMJobBless(kSMDomainSystemLaunchd, (__bridge CFStringRef)executableLabel, authRef, &error);
    AuthorizationFree(authRef, kAuthorizationFlagDestroyRights);
    if(error == nil){
        NSLog(@"Helper installed.");
        return true;
    }
    NSString *rep = [NSString stringWithFormat:@"%@", CFBridgingRelease(error)];
    NSLog(@"Helper install error: %@", rep);
    return false;
}
-(BOOL)uninstallHelper
{
    
    //tell the service to shut down
    //[self->service shutdown];
    
    CFErrorRef error = nil;
    SMJobRemove(kSMDomainSystemLaunchd, (__bridge CFStringRef)executableLabel, authRef, 1, &error);
    if(error == nil){
        return true;
    }
    
    NSString *rep = [NSString stringWithFormat:@"%@", CFBridgingRelease(error)];
    NSLog(@"Helper uninstall error: %@", rep);
    return false;
}

- (BOOL)removeFileWithElevatedPrivilegesFromLocation
{
    NSString *location = @"/Library/PrivilegedHelperTools/com.PrivateVPN.helper";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileSystemRepresentationWithPath:location]) {
        return NO;
    }
    
    // Create authorization reference
    OSStatus status;
   
    // use rm tool with -rf
    char *tool = "/bin/rm";
    char *args[] = {"-rf", (char *)[location UTF8String], NULL};
    FILE *pipe = NULL;
    
    status = AuthorizationExecuteWithPrivileges(authRef, tool, kAuthorizationFlagDefaults, args, &pipe);
    if (status != errAuthorizationSuccess)
    {
        NSLog(@"Error: %d", status);
        return NO;
    }
    return YES;
}



@end
