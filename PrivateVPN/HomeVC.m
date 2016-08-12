//
//  HomeVC.m
//  PrivateVPN
//
//  Created by Star Developer on 2/26/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import "HomeVC.h"
#import "LoginVC.h"
#import "PVServerManager.h"
#import "PVServerDataModel.h"
#import "PVUserManager.h"
#import "AppDelegate.h"
#import "VPNServiceConfig.h"
#import "Service.h"

//#import <NetworkExtension/NetworkExtension.h>

@interface HomeVC (){
    PVServerManager * serverManager;
    PVUserManager *userManager;
    int connection_retry_counter;
    BOOL isSetExternalIP;
    
    
}

@end

@implementation HomeVC
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        // Initializatioin code here.
        serverManager = [[PVServerManager sharedInstance] init];
        userManager = [PVUserManager sharedInstance];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.view.wantsLayer = true;
    [self.view.layer setBackgroundColor:BACKGROUND_COLOR];
    
    [self.viewHeader setWantsLayer:YES];
    [self.viewHeader.layer setBackgroundColor:CGColorCreateGenericRGB(44.0/255, 117.0/255, 154.0/255, 1)];
    
    self.btnLogOut.layer.cornerRadius = 10.0;
    self.btnAdvanced.layer.cornerRadius = 10.0;
    self.btnConnect.layer.cornerRadius = 10.0;
    self.btnDisconnect.layer.cornerRadius = 10.0;
    self.btnCancelConnecting.layer.cornerRadius = 10.0;
    
    [self setButtonTitleFor:self.btnLogOut toString:[self.btnLogOut title] withColor:[NSColor whiteColor]];
    [self setButtonTitleFor:self.btnAdvanced toString:[self.btnAdvanced title] withColor:[NSColor whiteColor]];
    [self setButtonTitleFor:self.btnConnect toString:[self.btnConnect title] withColor:[NSColor whiteColor]];
    [self setButtonTitleFor:self.btnDisconnect toString:[self.btnDisconnect title] withColor:[NSColor whiteColor]];
    [self setButtonTitleFor:self.btnCancelConnecting toString:[self.btnCancelConnecting title] withColor:[NSColor whiteColor]];
    
    NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, [NSNumber numberWithInt:NSUnderlineStyleSingle], NSUnderlineStyleAttributeName, nil];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[self.btnLiveSupport title] attributes:attrDictionary];
    [self.btnLiveSupport setAttributedTitle:attrString];
    [self.btnLiveSupport setAttributedAlternateTitle:attrString];
        
    self.viewConnecting.hidden = YES;
    self.viewConnected.hidden = YES;
    self.viewContainer.hidden = NO;
    
    [self.lblError setStringValue:@""];
    
    [self.lblUsername setStringValue:userManager.strUsername];
    [self.lblDaysLeft setStringValue:[NSString stringWithFormat:@"%d Days left", [userManager premiumDaysLeft]]];
    self.lblDaysLeft.layer.borderWidth = 0.5;
    self.lblDaysLeft.layer.cornerRadius = 2.0;
    self.lblDaysLeft.layer.borderColor = [NSColor blackColor].CGColor;
    
    [self.view.layer setBackgroundColor:BACKGROUND_COLOR];
    [self loadServerList];
    [self loadProtocolList];
    //[self getIPWithNSHost];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timer1) userInfo:nil repeats:YES];
   
}
- (void)loadProtocolList {
    NSArray *arrProtocols = @[@"PPTP", @"L2TP"];
    [self.popupProtocolList removeAllItems];
    for(NSString * protocolName in arrProtocols)
    {
        [self.popupProtocolList addItemWithTitle:protocolName];
    }
    
}
- (BOOL)loadServerList {
    /*if([serverManager loadServerListFromLocalstorage]){
        [self.popupServerList removeAllItems];
        PVServerDataModel* server;
        for(server in serverManager.mServerList)
        {
            [self.popupServerList addItemWithTitle:server.mName];
        }
    } else {*/
        [self.popupServerList setEnabled:NO];
        [serverManager requestServerListWithCallback:^(int status) {
            [self.popupServerList setEnabled:YES];
            if(status == SUCCESS_WITH_NO_ERROR){
                [serverManager saveServerListToLocalstorage];
                [self.popupServerList removeAllItems];
                PVServerDataModel* server;
                for(server in serverManager.mServerList)
                {
                    [self.popupServerList addItemWithTitle:server.mName];
                }
            }else if(status == ERROR_INVALID_REQUEST) {
                NSLog(@"Fetching server list failed. Invalid request.");
                
            }else if(status == ERROR_CONNECTION_FAILED){
                NSLog(@"Fetching server list failed. Connection failed.");
            }
            
        }];
    //}
    
    return true;
}
- (IBAction)onClickConnect:(id)sender {
    [self.lblError setStringValue:@""];
    if (APPDELEGATE.networkConnectionRef==NULL ||
        !(SCNetworkConnectionGetStatus(APPDELEGATE.networkConnectionRef)==kSCNetworkConnectionConnecting ||
          SCNetworkConnectionGetStatus(APPDELEGATE.networkConnectionRef)==kSCNetworkConnectionConnected)
        )
    {
        NSString* serverVal = self.popupServerList.title;
        NSString* connectionVal = self.popupProtocolList.title;//@"L2TP";
        if (serverVal==nil || [serverVal isEqualToString:@""])
            return;
        
        NSString *ss_servername,*ss_secret;
        ss_servername = [serverManager getIPAddressByName:serverVal];
        ss_secret = @"privatvpn";
        
        
        int con_type = 0;
        if ([connectionVal isEqualToString:@"L2TP"]){
            con_type = VPNServiceL2TPOverIPSec;
        }
        if ([connectionVal isEqualToString:@"IPSEC"])
        {
            con_type = VPNServiceCiscoIPSec;
            //ss_servername = [NSString stringWithFormat:@"ip-%@",ss_servername];
        }
        if ([connectionVal isEqualToString:@"PPTP"]){
            con_type =VPNServicePPTP;
        }
        
        NSString* msg=[NSString stringWithFormat:@"%@ %@ %@ %@ %d",ss_servername, userManager.strUsername, userManager.strPassword, ss_secret ,con_type];
        xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
        const char* request =[msg UTF8String];
        xpc_dictionary_set_string(message, "request", request);
        
        //Send message to Helper.
        xpc_connection_send_message_with_reply([Service sharedInstance].xpc_connection, message, dispatch_get_main_queue(), ^(xpc_object_t event) {
            const char* response = xpc_dictionary_get_string(event, "reply");
            if(response == nil) {
                NSLog(@"xpc connection error in onClickConnect");
                return;
            }
            NSString* str = [NSString stringWithUTF8String:response];
            if ([str isEqualToString:@"Success"])
            {
                self.viewContainer.hidden = YES;
                self.viewConnecting.hidden = NO;
                self.btnCancelConnecting.hidden = NO;
                [self.progressConnecting startAnimation:nil];
                [self.lblConnecting setStringValue:@"Connecting..."];
                
                APPDELEGATE.connect_pressed=YES;
                //connection_retry_counter = 3;
                //[self connectVPN];
                
                //Not sure, But it seems to be the way to avoid connecting twice.
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (0.5*(NSEC_PER_SEC))), dispatch_get_main_queue(), ^{
                    isSetExternalIP = false;
                    [self connectVPN];
                });
            }
            else
            {
                NSLog(@"XPC Error in send message.");
            }
        });
    }
    
}
- (IBAction)onClickLogOut:(id)sender {
    PVUserManager* manager = [PVUserManager sharedInstance];
    //[manager removeUserLastLoginFromLocalstorage];
    [manager removeUserFromKeychain];
    manager.isLoggedOut = true;
    LoginVC * loginVC = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
    [self.view.window setContentViewController:loginVC];
}
- (IBAction)onClickLiveSupport:(id)sender {
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:LIVE_SUPPORT_URL]];
}
- (IBAction)onClickAdvanced:(id)sender {
    
}
- (IBAction)onClickCancelConnecting:(id)sender {
    if (SCNetworkConnectionGetStatus(APPDELEGATE.networkConnectionRef)==kSCNetworkConnectionConnecting)
    {
        [self stopWithService:APPDELEGATE.currentService successfullBlock:nil failureBlock:nil];
    }
    
}
- (IBAction)onClickDisconnect:(id)sender {
    if (SCNetworkConnectionGetStatus(APPDELEGATE.networkConnectionRef)==kSCNetworkConnectionConnected)
    {
        [self stopWithService:APPDELEGATE.currentService successfullBlock:nil failureBlock:nil];
    }
}


-(void)connectVPN
{
    SCNetworkServiceRef	service;
    
    SCPreferencesRef prefs = SCPreferencesCreate(NULL, CFSTR("SCNetworkConnectionCopyAvailableServices"), NULL);
    if (prefs != NULL) {
        CFArrayRef services = SCNetworkServiceCopyAll(prefs);
        
        for (int i = 0; i < CFArrayGetCount(services); i++) {
            service = CFArrayGetValueAtIndex(services, i);
            
            CFStringRef interfaceType = SCNetworkServiceGetName(service);
            
            NSString* st= (__bridge NSString *)(interfaceType);
            if ([st isEqualToString:@"PrivateVPN"])
            {
                APPDELEGATE.currentService = service;
                APPDELEGATE.networkConnectionRef = [self createAConnectionWithService:service];
                [self startWithService:APPDELEGATE.currentService successfullBlock:nil failureBlock:nil];
                break;
            }
        }
        CFRelease(prefs);
    }
    
}
- (void)startWithService:(SCNetworkServiceRef )service successfullBlock:(void (^)())successfullBlock failureBlock:(void (^)(NSError *))faulureBlock{
    SCNetworkConnectionRef connection = APPDELEGATE.networkConnectionRef;
    switch (SCNetworkConnectionGetStatus(connection)) {
        case kSCNetworkConnectionDisconnected: {
            if (!SCNetworkConnectionStart(connection, NULL, FALSE)) {
                NSLog(@"Failed!");
                if (faulureBlock) faulureBlock(nil);
            }
            else {
                NSLog(@"Connection Start!");
                if (successfullBlock) successfullBlock();
            }
        }
            break;
        case kSCNetworkConnectionConnecting:
            NSLog(@"Connecting...");
            break;
        case kSCNetworkConnectionDisconnecting:
            NSLog(@"Disconnecting...");
            break;
        case kSCNetworkConnectionConnected:
            NSLog(@"Already connected.");
            break;
        case kSCNetworkConnectionInvalid:
            NSLog(@"Connection Invalid.");
            break;
        default:
            NSLog(@"Unknown connection error.");
            break;
    }
}
- (void)stopWithService:(SCNetworkServiceRef )service successfullBlock:(void (^)())successfullBlock failureBlock:(void (^)(NSError *))faulureBlock{
    SCNetworkConnectionRef connection = APPDELEGATE.networkConnectionRef;
    switch (SCNetworkConnectionGetStatus(connection)) {
        case kSCNetworkConnectionDisconnected: {
            NSLog(@"Disconnected!");
            break;
        case kSCNetworkConnectionConnecting:
            NSLog(@"Connecting...");
            if (!SCNetworkConnectionStop(connection, TRUE)) {
                NSLog(@"Cancel Failed!");
                if (faulureBlock) faulureBlock(nil);
            }
            else {
                NSLog(@"Cancel Success!");
                if (successfullBlock) successfullBlock();
            }
            break;
        case kSCNetworkConnectionDisconnecting:
            NSLog(@"Disconnecting...");
            break;
        case kSCNetworkConnectionConnected: {
            if (!SCNetworkConnectionStop(connection, TRUE)) {
                NSLog(@"Disconnection Failed!");
                if (faulureBlock) faulureBlock(nil);
            }
            else {
                NSLog(@"Disconnection Success!");
                if (successfullBlock) successfullBlock();
            }
        }
            break;
        case kSCNetworkConnectionInvalid:
            NSLog(@"Connection Invalid.");
            break;
        default:
            NSLog(@"Unknown disconnection error.");
            break;
        }
    }
}

- (SCNetworkConnectionRef )createAConnectionWithService:(SCNetworkServiceRef )service {
    if (service == NULL) return NULL;
    SCNetworkConnectionContext context = { 0, NULL, NULL, NULL, NULL };
    CFStringRef service_id = SCNetworkServiceGetServiceID(service);
    SCNetworkConnectionRef networkConnectionRef = SCNetworkConnectionCreateWithServiceID(NULL, service_id, connectionCallBack, &context);
    return networkConnectionRef;
}
//To do
void connectionCallBack(SCNetworkConnectionRef connection,SCNetworkConnectionStatus stat,void *info)
{
    SCNetworkConnectionStatus status = SCNetworkConnectionGetStatus(connection);
    
    switch(status) {
        case kSCNetworkConnectionInvalid:
        {
            NSLog(@"Connection Invalid");
        }
            break;
        case kSCNetworkConnectionDisconnected:
        {
            NSLog(@"Connection Disconnected");
        }
            break;
        case kSCNetworkConnectionConnecting:
        {
            NSLog(@"Connection Connecting");
        }
            break;
        case kSCNetworkConnectionConnected:
        {
            NSLog(@"Connection Connected");
        }
            break;
        case kSCNetworkConnectionDisconnecting:
        {
            NSLog(@"Connection Disconnecting");
        }
            break;
    }
}

-(void)timer1
{
    if (APPDELEGATE.networkConnectionRef!=NULL)
    {
        int constatus=SCNetworkConnectionGetStatus(APPDELEGATE.networkConnectionRef);
        switch (constatus) {
            case kSCNetworkConnectionDisconnected:
            {
                NSLog(@"Inside Timer: Disconnected.");
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!APPDELEGATE.connect_pressed)
                    {
                        self.viewContainer.hidden = NO;
                        self.viewConnecting.hidden = YES;
                        self.viewConnected.hidden = YES;
                        [self.lblError setStringValue:@"Disconnected"];

                    }
                });
            }
                break;
            case kSCNetworkConnectionConnecting:
            {
                APPDELEGATE.connect_pressed=NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.viewContainer.hidden = YES;
                    self.viewConnecting.hidden = NO;
                    self.viewConnected.hidden = YES;
                    
                    [self.lblConnecting setStringValue:@"Connecting..."];
                    self.btnCancelConnecting.hidden = NO;
                    
                });
            }
                break;
            case kSCNetworkConnectionDisconnecting:
            {
                APPDELEGATE.connect_pressed=NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.viewContainer.hidden = YES;
                    self.viewConnecting.hidden = NO;
                    self.viewConnected.hidden = YES;
                    
                    //Disconnecting title
                    [self.lblConnecting setStringValue:@"Disconnecting..."];
                    self.btnCancelConnecting.hidden = YES;
                });
            }
                break;
            case kSCNetworkConnectionConnected:
            {
                APPDELEGATE.connect_pressed=NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.viewContainer.hidden = YES;
                    self.viewConnecting.hidden = YES;
                    self.viewConnected.hidden = NO;
                    
                    [self.lblConnectedServer setStringValue:[NSString stringWithFormat:@"Connected to %@", self.popupServerList.title]];
                    //Set External IP Address.
                    if(!isSetExternalIP){
                        [userManager requestLoginWithCallback:^(int status) {
                            if(status == SUCCESS_WITH_NO_ERROR){
                                [self.lblConnectedIP setStringValue:userManager.strIPAddress];
                                isSetExternalIP = YES;
                            }else if(status == ERROR_INVALID_REQUEST) {
                                
                            }else if(status == ERROR_CONNECTION_FAILED){
                                
                            }
                        }];
                    }

                });
            }
                break;
            case kSCNetworkConnectionInvalid:
            {
                APPDELEGATE.connect_pressed=NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.viewContainer.hidden = NO;
                    self.viewConnecting.hidden = YES;
                    self.viewConnected.hidden = YES;
                    [self.lblError setStringValue:@"The connection was lost"];
                });
            }
                break;
            default:
                NSLog(@"Unexpected status.\n");
                break;
        }
        
        
        /*CFDictionaryRef cdf=  SCNetworkConnectionCopyStatistics(APPDELEGATE.networkConnectionRef);
        NSDictionary* ddf = (__bridge NSDictionary *)(cdf);
        if (ddf!=nil)
        {
            NSLog(@"VPN Network Status: %@",ddf);
        }*/
    }
    else
    {
        /*if (prev_status==kSCNetworkConnectionConnected)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setStatusMsg:@"Disconnected" color:[NSColor redColor]];
                [self.btn_connect setEnabled:YES];
                [self.btn_connect setHidden:NO];
                [self.btn_disconnect setEnabled:NO];
                [self.btn_disconnect setHidden:YES];
                [[UIAppDelegate.window contentView] layer].contents=[NSImage imageNamed:@"app_bg_red.png"];
            });
            
            prev_status = kSCNetworkConnectionConnected;
        }*/
    }
}

-(void) getIPWithNSHost{
    NSArray *addresses = [[NSHost currentHost] addresses];
    NSString *strAddress;
    for(NSString *anAddress in addresses) {
        if(![anAddress hasPrefix:@"127"] && [[anAddress componentsSeparatedByString:@"."] count]==4)
        {
            strAddress = anAddress;
            NSLog(@"IP: %@", strAddress);
            //break;
        }
    }
    NSLog(@"Login IP:%@", userManager.strIPAddress);
}
-(void)setButtonTitleFor:(NSButton*)button toString:(NSString*)title withColor:(NSColor*)color
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];;
    NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:color, NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:title attributes:attrDictionary];
    [button setAttributedTitle:attrString];
    [button setAttributedAlternateTitle:attrString];
}
@end
