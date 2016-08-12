//
//  HomeVC.h
//  PrivateVPN
//
//  Created by Star Developer on 2/26/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HomeVC : NSViewController
//@property (weak) IBOutlet NSComboBox *cbbServerList;

@property (weak) IBOutlet NSView *viewHeader;
@property (weak) IBOutlet NSTextField *lblDaysLeft;
@property (weak) IBOutlet NSTextField *lblUsername;
@property (weak) IBOutlet NSButton *btnLiveSupport;

@property (weak) IBOutlet NSView *viewContainer;
@property (weak) IBOutlet NSPopUpButton *popupServerList;
@property (weak) IBOutlet NSTextField *lblError;
@property (weak) IBOutlet NSPopUpButton *popupProtocolList;


@property (weak) IBOutlet NSButton *btnConnect;
@property (weak) IBOutlet NSImageView *imgConnectionStatus;
@property (weak) IBOutlet NSTextField *lblConnectionStatus;
@property (weak) IBOutlet NSButton *btnLogOut;
@property (weak) IBOutlet NSButton *btnAdvanced;

@property (weak) IBOutlet NSView *viewConnecting;
@property (weak) IBOutlet NSTextField *lblConnecting;
@property (weak) IBOutlet NSProgressIndicator *progressConnecting;
@property (weak) IBOutlet NSButton *btnCancelConnecting;


@property (strong) IBOutlet NSView *viewConnected;
@property (weak) IBOutlet NSTextField *lblConnectedServer;
@property (weak) IBOutlet NSTextField *lblConnectedIP;
@property (weak) IBOutlet NSButton *btnDisconnect;


@end
