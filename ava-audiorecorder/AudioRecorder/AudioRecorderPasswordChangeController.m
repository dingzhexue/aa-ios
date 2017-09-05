//
//  AudioRecorderPasswordChangeController.m
//  AudioRecorder
//
//  Created by Jon Akhtar on 9/2/14.
//  Copyright (c) 2014 People Designs Inc. All rights reserved.
//

#import "AudioRecorderPasswordChangeController.h"
#import "UserDefaults.h"
#import "Constants.h"

@interface AudioRecorderPasswordChangeController()<UITextFieldDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmTextField;
@property (strong, nonatomic) IBOutlet UIButton *saveCodeButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UILabel *unlockConfirmationLabel;
- (IBAction)codeSavePressed:(id)sender;
@end

@implementation AudioRecorderPasswordChangeController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Set the initial conditions
    
    self.saveCodeButton.layer.cornerRadius = 3.;
    [self setInitialConditions];
}
-(void)viewWillDisappear:(BOOL)animated
{
    
}
- (void)setInitialConditions {
    NSString *passwordString = [[UserDefaults sharedUserDefaults]unlockPassword];
    if(passwordString.length != 0) {
        _passwordTextField.text = passwordString;
        _passwordConfirmTextField.text = passwordString;
    }
}

- (BOOL)passwordIsValid {
    return _passwordTextField.text.length > 0 && [_passwordConfirmTextField.text isEqualToString:_passwordTextField.text];
}

#pragma mark - UITextFieldDelegate delegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField {

    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextField)
    {
        [self.passwordConfirmTextField becomeFirstResponder];
    }
    else if (textField == self.passwordConfirmTextField)
    {
        [textField resignFirstResponder];
    }
    return YES;

}

#pragma mark -

- (IBAction)tapDetected:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}
//checks to ensure password and password confirm match. If they do, save them to user defaults. If they don't, warn the user that they don't match.
- (IBAction)codeSavePressed:(id)sender {
    if ([self.passwordConfirmTextField.text isEqualToString:self.passwordTextField.text]) {
        
        // Save the password for unlocking
        UserDefaults *userDefaults = [UserDefaults sharedUserDefaults];
        userDefaults.unlockPassword = _passwordConfirmTextField.text;
        userDefaults.isLocked = userDefaults.unlockPassword.length > 0 ? userDefaults.isLocked : NO;
        [userDefaults saveUserDefaults];
        [self.unlockConfirmationLabel setText:@"Unlock code saved!"];
        
    } else {
        
        if (self.passwordConfirmTextField.text.length > 0 && self.passwordTextField.text.length > 0) {
            UIAlertView *passwordAlertView = [[UIAlertView alloc] initWithTitle:nil message:MSG_REQUIRED_PASSWORD_CONFIRM delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [passwordAlertView show];
            
        }
        
    }
}
@end

