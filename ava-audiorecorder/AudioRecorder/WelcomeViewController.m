//
//  WelcomeViewController.m
//  AVA Recorder
//
//  Created by Tristan Freeman on 1/26/17.
//  Copyright © 2017 People Designs Inc. All rights reserved.
//

#import "WelcomeViewController.h"
#import "AccountConnectionViewController.h"
#import "CustomPasscodeConfig.h"
#import "Passcode.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"AVA Recorder";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onButtonPressed:(id)sender {
//    AccountConnectionViewController *accountConnectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountConnectionViewController"];
//    accountConnectionVC.navigationItem.hidesBackButton = YES;
//    [self.navigationController pushViewController:accountConnectionVC animated:YES];
    CustomPasscodeConfig *passCodeConfig = [[CustomPasscodeConfig alloc]init];
    
    
    passCodeConfig.navigationBarTitle = @"AVA Recorder";
    passCodeConfig.identifier = @"changePass";
    [Passcode setConfig:passCodeConfig];
    
    passCodeConfig.navigationBarBackgroundColor = [UIColor colorWithRed:0.32 green:0.75 blue:0.24 alpha:1.0];
    passCodeConfig.navigationBarTitleColor = [UIColor whiteColor];
    [Passcode setupPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
        if (success && [[NSUserDefaults standardUserDefaults]boolForKey:@"firstLaunch"]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else if (success){
            NSLog(@"passcode setup appeared");
            AccountConnectionViewController *accountConnectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountConnectionViewController"];
            accountConnectionVC.navigationItem.hidesBackButton = YES;
            [self.navigationController pushViewController:accountConnectionVC animated:YES];
            //[self dismissViewControllerAnimated:YES completion:nil];
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstLaunch"];
            
        }else{
            NSLog(@"%@", [error localizedDescription]);
        }
    }];


    
}
@end
