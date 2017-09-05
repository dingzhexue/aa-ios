//
//  AccountConnectionViewController.m
//  AVA Recorder
//
//  Created by Tristan Freeman on 8/30/16.
//  Copyright © 2016 People Designs Inc. All rights reserved.
//

#import "AccountConnectionViewController.h"
#import "RecordingsViewController.h"
#import "ServerSession.h"
#import "UserDefaults.h"
#import "Constants.h"

@interface AccountConnectionViewController ()<UIGestureRecognizerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) NSURLSessionDataTask *connectTask;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *userPassField;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UILabel *confirmationLabel;
- (IBAction)submitPressed:(id)sender;



@end

@implementation AccountConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _usernameField.delegate = self;
    _userPassField.delegate = self;
    
    // Add gester recognizer
    UITapGestureRecognizer *tapGesterRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    tapGesterRecognizer.numberOfTapsRequired = 1;
    tapGesterRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGesterRecognizer];
    
    [self validateTextFields];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tapDetected:(UITapGestureRecognizer *)recognizer {
    [self.usernameField resignFirstResponder];
    [self.userPassField resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self validateTextFields];
}
//-(void)textFieldDidEndEditing:(UITextField *)textField
//{
//    [textField resignFirstResponder];
//    [self validateTextFields];
//    
//}
//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    [self validateTextFields];
//    return YES;
//}
-(void)validateTextFields
{
    if ((_usernameField.text.length == 0) && _userPassField.text.length == 0) {
        [_submitButton setEnabled:NO];
    }else{
        [_submitButton setEnabled:YES];
        
    }
}
- (IBAction)submitPressed:(id)sender {
    //SAVE CREDENTIALS FOR ACCOUNT
    [self signInToServer];
}
//Method resigns first responsder of text field, dismissing the keyboard when enter is pressed.
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
    
}
//Method dismisses keyboard when user taps anywhere on screen.
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (IBAction)skipPressed:(id)sender {
    //CLOSE VIEW AND TRANSITION TO RECORDING LIST VIEW
    RecordingsListViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SavedRecording"];
    listVC.cameFromAccountConnection = YES;
    [self.navigationController pushViewController:listVC animated:YES];
}
-(void)signInToServer
{
    self.connectTask = [[ServerSession loginSession] POST:URL_LOGIN
                                               parameters:nil
                                constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
                                    [formData appendPartWithFormData:[_usernameField.text dataUsingEncoding:NSUTF8StringEncoding] name:@"login"];
                                    [formData appendPartWithFormData:[_userPassField.text dataUsingEncoding:NSUTF8StringEncoding] name:@"password"];
                                }
                                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                                      //[self enableUserInteraction];
                                                      
                                                      NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                                                      
                                                      NSString* response = [responseDict objectForKey:@"status"];
                                                      NSString *user = [responseDict objectForKey:@"username"];
                                                      NSLog(@"Login Task Response: %@", response);
                                                      if ([response isEqualToString:STATUS_SUCCESS]) {
                                                          UserDefaults *userDefaults = [UserDefaults sharedUserDefaults];
                                                          userDefaults.signInUserName = user;
                                                          userDefaults.signInPassword = _userPassField.text;
                                                          userDefaults.lastLoginDate = [NSDate date];
                                                          userDefaults.credentialsSaved = YES;
                                                          [userDefaults saveUserDefaults];
                                                         
                                                          
                                                          RecordingsListViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SavedRecording"];
                                                          listVC.cameFromAccountConnection = YES;
                                                          [self.navigationController pushViewController:listVC animated:YES];
                                                      }
                                                      else {
                                                          //_accountConfirmationLabel.text = @"Could not authenticate credentials.";
                                                           _confirmationLabel.text = @"An AVA account matching the entered user name and password could not be found.";
                                                      }
                                                  }
                                                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                    //  [self enableUserInteraction];
                                                      //[UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
                                                       _confirmationLabel.text = @"An AVA account matching the entered user name and password could not be found.";
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
