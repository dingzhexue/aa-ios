//
//  ARSettingsViewController.m
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//

#import "ARSettingsViewController.h"
#import "Constants.h"
#import "AudioRecorderAppDelegate.h"
#import "UserDefaults.h"
#import "Passcode.h"

@interface ARSettingsViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property(weak, nonatomic) IBOutlet UITextField *serverTextField;
@property(weak, nonatomic) IBOutlet UISwitch *passwordLockButton;
@property(weak, nonatomic) IBOutlet UISwitch *automaticRecordingButton;
@property(weak, nonatomic) IBOutlet UISwitch *automaticUploadButton;



- (IBAction)automaticRecordingButtonTapped:(id)sender;

- (IBAction)automaticUploadButtonTapped:(id)sender;

- (IBAction)closeButtonTapped:(id)sender;

- (IBAction)lockButtonTapped:(id)sender;

- (void)setInitialConditions;
@end

@implementation ARSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set the viewcontroller as currentViewcontroller
    AudioRecorderAppDelegate *appDelegate = [AudioRecorderAppDelegate sharedDelegate];
    appDelegate.currentViewController = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Set the initial conditions
    [self setInitialConditions];
}


#pragma mark - UITextFieldDelegate delegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField {

    if (textField.tag == SERVER_HOST_TAG) {
        UserDefaults *userDefaults = [UserDefaults sharedUserDefaults];
        userDefaults.serverHostName = textField.text;
        [userDefaults saveUserDefaults];
    }
}



#pragma mark - UIGestureRecognizer de;egate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

    // Disallow recognition of tap gestures in the button control.
    if ([touch.view isKindOfClass:[UIButton class]])
        return NO;

    else if ([touch.view.superview isKindOfClass:[UIToolbar class]])
        return NO;
    return YES;
}

#pragma mark -


- (void)setInitialConditions {
    
    if ([[UserDefaults sharedUserDefaults] automaticRecord]) {
        self.automaticRecordingButton.on = YES;
    }
    if ([[UserDefaults sharedUserDefaults] automaticUpload]) {
        self.automaticUploadButton.on = YES;
    }

    self.serverTextField.text = [UserDefaults sharedUserDefaults].serverHostName;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self enterPasscodeForChange];
    }else if(indexPath.section == 1 && indexPath.row == 0){
        [self enterAccount];
    }
    int section = indexPath.section;
    int row = indexPath.row;
    NSLog(@"section: %d / row: %d", section, row);
}

-(void)enterPasscodeForChange
{
    
    CustomPasscodeConfig *passCodeConfig = [[CustomPasscodeConfig alloc]init];
    
    
    passCodeConfig.navigationBarTitle = @"AVA Recorder";
    passCodeConfig.identifier = @"changePass";
    [Passcode setConfig:passCodeConfig];
    
    passCodeConfig.navigationBarBackgroundColor = [UIColor colorWithRed:0.32 green:0.75 blue:0.24 alpha:1.0];
    passCodeConfig.navigationBarTitleColor = [UIColor whiteColor];
    [Passcode showPasscodeForChange:self completion:^(BOOL success, NSError *error) {
        if (success && [Passcode isPasscodeSet]) {
            NSLog(@"PASSWORDS MATCH");
            [self dismissViewControllerAnimated:YES completion:nil];
            [self changePasscode];
        }else{
            NSLog(@"ERROR:%@", error.localizedDescription);
        }

    }];
    
    
    
    
}
-(void)changePasscode
{
    CustomPasscodeConfig *passCodeConfig = [[CustomPasscodeConfig alloc]init];
    
    
    passCodeConfig.navigationBarTitle = @"AVA Recorder";
    passCodeConfig.identifier = @"changePass";
    [Passcode setConfig:passCodeConfig];
    
    passCodeConfig.navigationBarBackgroundColor = [UIColor colorWithRed:0.32 green:0.75 blue:0.24 alpha:1.0];
    passCodeConfig.navigationBarTitleColor = [UIColor whiteColor];
    
    [Passcode setupPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
        
        if (success && [Passcode isPasscodeSet]) {
            NSLog(@"PASSWORDS MATCH");
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
    }];
}

-(void)enterAccount
{
    CustomPasscodeConfig *passCodeConfig = [[CustomPasscodeConfig alloc]init];
    
    
    passCodeConfig.navigationBarTitle = @"AVA Recorder";
    passCodeConfig.identifier = @"changePass";
    [Passcode setConfig:passCodeConfig];
    
    passCodeConfig.navigationBarBackgroundColor = [UIColor colorWithRed:0.32 green:0.75 blue:0.24 alpha:1.0];
    passCodeConfig.navigationBarTitleColor = [UIColor whiteColor];
    [Passcode showPasscodeForChange:self completion:^(BOOL success, NSError *error) {
        if (success && [Passcode isPasscodeSet]) {
            NSLog(@"PASSWORDS MATCH");
            [self dismissViewControllerAnimated:YES completion:nil];
            [self performSegueWithIdentifier:@"enterActCredientials" sender:self];
        }else{
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
        
    }];
}


#pragma mark - Button Action methods

//- (IBAction)lockOnAppLaunchButtonTapped:(UIButton *)sender {
//    // Set lock on app launch
//    if (_passwordLockButton.on) // check the button state
//    {
//        UserDefaults *userDefaults = [UserDefaults sharedUserDefaults];
//        if (userDefaults.unlockPassword.length == 0) {
//            _passwordLockButton.on = NO;
//            UIAlertView *passwordAlertView = [[UIAlertView alloc] initWithTitle:nil message:MSG_REQUIRED_PASSWORD delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//            [passwordAlertView show];
//        }
//        else {
//            userDefaults.isLocked = YES;
//            [userDefaults saveUserDefaults];
//        }
//    }
//    else {
//        UserDefaults *userDefaults = [UserDefaults sharedUserDefaults];
//        userDefaults.isLocked = NO;
//        [userDefaults saveUserDefaults];
//    }
//}
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

- (IBAction)automaticRecordingButtonTapped:(UIButton *)sender {
    UserDefaults *userDefaults = [UserDefaults sharedUserDefaults];
    userDefaults.automaticRecord = _automaticRecordingButton.on;
    [userDefaults saveUserDefaults];
}

- (IBAction)automaticUploadButtonTapped:(UIButton *)sender {
    UserDefaults *userDefaults = [UserDefaults sharedUserDefaults];
    userDefaults.automaticUpload = _automaticUploadButton.on;
    [userDefaults saveUserDefaults];
}

- (IBAction)closeButtonTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)lockButtonTapped:(UIButton *)sender {
    [self enterPasscode];
}
@end
