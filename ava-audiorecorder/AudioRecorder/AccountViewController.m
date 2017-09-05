//
//  AccountViewController.m
//  AVA Recorder
//
//  Created by Tristan Freeman on 8/2/16.
//  Copyright © 2016 People Designs Inc. All rights reserved.
//

#import "AccountViewController.h"
#import "UserDefaults.h"
#import "ServerSession.h"
#import "Constants.h"
#import "Passcode.h"

@interface AccountViewController ()

@property (strong, nonatomic) NSURLSessionDataTask *connectTask;
@property (strong, nonatomic) IBOutlet UITextField *accountNameField;
@property (strong, nonatomic) IBOutlet UITextField *accountPassField;
@property (strong, nonatomic) IBOutlet UILabel *accountConfirmationLabel;
@property (strong, nonatomic) IBOutlet UIButton *testButton;

- (IBAction)onTest:(id)sender;

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UserDefaults *defaults = [[UserDefaults alloc]init];
    NSString *userName = [defaults decryptUserDefaultValue:[[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_NAME]];
    self.accountNameField.text = userName;
    self.accountPassField.text = [[UserDefaults sharedUserDefaults]signInPassword];
    self.testButton.layer.cornerRadius = 3.0;
    
}
-(void)enterPasscode
{
    CustomPasscodeConfig *passCodeConfig = [[CustomPasscodeConfig alloc]init];
    
    
    passCodeConfig.navigationBarTitle = @"AVA Recorder";
    [Passcode setConfig:passCodeConfig];
    
    passCodeConfig.navigationBarBackgroundColor = [UIColor colorWithRed:0.32 green:0.75 blue:0.24 alpha:1.0];
    passCodeConfig.navigationBarTitleColor = [UIColor whiteColor];
    [Passcode showPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
        if (success && [Passcode isPasscodeSet]) {
            NSLog(@"PASSWORDS MATCH");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
    
}
- (IBAction)lockButtonTapped:(UIButton *)sender {
    [self enterPasscode];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)enableUserInteraction
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    _testButton.enabled = YES;
    _accountNameField.enabled = YES;
    _accountPassField.enabled = YES;
}
- (void)disableUserInteraction
{
    _testButton.enabled = NO;
    _accountNameField.enabled = NO;
    _accountPassField.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}
- (IBAction)onTest:(id)sender{
    if(_accountNameField.text.length == 0 || _accountPassField.text.length == 0)
    {
        UIAlertView *enterDetailsAlertView = [[UIAlertView alloc]initWithTitle:nil message:MSG_ENTER_LOGIN_DETAILS  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [enterDetailsAlertView show];
        [_accountNameField becomeFirstResponder];
        
    }
    else
    {
        // Sign in to server
        [self signInToServer];
        [self disableUserInteraction];
        
    }

}

-(void)signInToServer
{
    self.connectTask = [[ServerSession loginSession] POST:URL_LOGIN
                                               parameters:nil
                                constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
                                    [formData appendPartWithFormData:[_accountNameField.text dataUsingEncoding:NSUTF8StringEncoding] name:@"login"];
                                    [formData appendPartWithFormData:[_accountPassField.text dataUsingEncoding:NSUTF8StringEncoding] name:@"password"];
                                }
                                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                                      [self enableUserInteraction];
                                                      
                                                       NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                                                      
                                                      NSString* response = [responseDict objectForKey:@"status"];
                                                      NSString *user = [responseDict objectForKey:@"username"];
                                                      NSLog(@"Login Task Response: %@", response);
                                                      if ([response isEqualToString:STATUS_SUCCESS]) {
                                                          UserDefaults *userDefaults = [UserDefaults sharedUserDefaults];
                                                          userDefaults.signInUserName = user;
                                                          userDefaults.signInPassword = _accountPassField.text;
                                                          userDefaults.lastLoginDate = [NSDate date];
                                                          userDefaults.credentialsSaved = YES;
                                                          [userDefaults saveUserDefaults];
                                                          _accountConfirmationLabel.text = @"Account Confirmed!";
                                                      }
                                                      else {
                                                          _accountConfirmationLabel.text = @"An AVA account matching the entered user name and password could not be found.";
                                                      }
                                                  }
                                                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                      [self enableUserInteraction];
                                                      //[UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
                                                  }];
    
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
