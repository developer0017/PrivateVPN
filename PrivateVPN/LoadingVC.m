//
//  LoadingVC.m
//  PrivateVPN
//
//  Created by Star Developer on 2/26/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import "LoadingVC.h"
#import "LoginVC.h"
#import "PVVersionManager.h"
#import "PVGenericFunctionManager.h"

@interface LoadingVC ()

@end

@implementation LoadingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.view.wantsLayer = true;
    [self.view.layer setBackgroundColor:BACKGROUND_COLOR];
    
    [self.circular startAnimation:nil];
    [self checkVersionUpdate];
   
}
-(void)awakeFromNib
{
    //[self.circular startAnimation:nil];
}
-(void)checkVersionUpdate
{
//    NSString *curVersion = [PVGenericFunctionManager getAppVersionString];
//    NSString *curBuild = [PVGenericFunctionManager getAppBuildString];
//    PVVersionManager *manager = [[PVVersionManager sharedInstance] init];
    LoginVC *loginVC = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
    [self.view.window setContentViewController:loginVC];
    /*[manager requestVersionWithCallback:^(int status) {
        if(status == SUCCESS_WITH_NO_ERROR){
            if ([curVersion isEqualToString:manager.mVersion] && [curBuild isEqualToString:manager.mBuild]){
                
                [self.view.window setContentViewController:loginVC];
            }else {
                
            }
            
        }else if(status == ERROR_INVALID_REQUEST) {
            NSLog(@"Version check failed. Invalid request.");
            
            [self.view.window setContentViewController:loginVC];
            
        }else if(status == ERROR_CONNECTION_FAILED){
            NSLog(@"Version check failed. Connection failed.");
            
            [self.view.window setContentViewController:loginVC];
        }
        
    }];*/

}
@end
