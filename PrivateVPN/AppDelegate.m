//
//  AppDelegate.m
//  PrivateVPN
//
//  Created by Star Developer on 2/26/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import "AppDelegate.h"
#import "Service.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self.window setMovableByWindowBackground:YES];
    [self.window setMovable:YES];
    
    [[self.window contentView] setWantsLayer:YES];
    [[[self.window contentView] layer] setBorderWidth:1.0];
    [[[self.window contentView] layer] setContentsGravity:kCAGravityResize];
    
    self.loginVC = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
    [self.window setContentViewController:self.loginVC];
    
    [self.window orderFront:nil];
    [self.window makeKeyWindow];
    
    //Sparkle Updater configuration.
    SUUpdater* updater = [SUUpdater sharedUpdater];
    [updater setAutomaticallyChecksForUpdates:true];
    [updater setAutomaticallyDownloadsUpdates:false];
    [updater setUpdateCheckInterval:86400];
    [updater checkForUpdatesInBackground];
    
    //XPC Configuration.
    [[Service sharedInstance] checkHelper];
    
}

- (void)showErrorMessage:(NSString*)msg{
    NSAlert* alert = [[NSAlert alloc] init];
    [alert setAlertStyle:2];
    [alert setMessageText:msg];
    [alert beginSheetModalForWindow:APPDELEGATE.window completionHandler:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if(flag){
        return NO;
    } else {
        [self.window makeKeyAndOrderFront:nil];
        return YES;
    }
}

@end
