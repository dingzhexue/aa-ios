//
//  ServerSignInViewController.m
//  AudioRecorder
//
//  
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import "ServerSignInViewController.h"
#import "Constants.h"
#import "ServerUploadingViewController.h"
#import "AudioRecorderAppDelegate.h"
#import "UserDefaults.h"
#import "ServerSession.h"
#import "Passcode.h"

@interface ServerSignInViewController ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate,NSURLConnectionDelegate,UITextFieldDelegate>
{
}

@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) NSURLSessionDataTask *connectTask;
@property (strong, nonatomic) IBOutlet UITextField *recordingNameField;

- (IBAction)signInButtonTapped:(id)sender;
- (IBAction)lockButtonTapped:(id)sender;
- (IBAction)cancelButtonTapped:(id)sender;
- (void)signInToServer;
- (void)enableUserInteraction;
- (void)disableUserInteraction;

@end

@implementation ServerSignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    self.navigationItem.title = _navigationTitle;
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate: [[UserDefaults sharedUserDefaults]lastLoginDate]];
    NSInteger days = interval/CONSTANT_TWENTYFOUR_HOURS_IN_SECONDS;
    if(days < CONSTANT_VALUE_THIRTY)
    {
        self.userNameTextField.text = [[UserDefaults sharedUserDefaults]signInUserName];
        self.passwordTextField.text = [[UserDefaults sharedUserDefaults]signInPassword];
    }
    [self enableUserInteraction];
    
    // Disable AutoCorrection in textfield
    _userNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _recordingNameField.text = _recordingName;
    self.signInButton.layer.cornerRadius = 3;
    
    // Add tap gester recognizer
    UITapGestureRecognizer *tapGesterRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDetected:)];
    tapGesterRecognizer.numberOfTapsRequired = 1;
    tapGesterRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGesterRecognizer];

    AudioRecorderAppDelegate *appDelegate=[AudioRecorderAppDelegate sharedDelegate];
    appDelegate.currentViewController=self;

}
- (void)viewDidUnload {
    [self setUserNameTextField:nil];
    [self setPasswordTextField:nil];
    [self setSignInButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.signInButton.hidden = [self allFieldsEmpty];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


#pragma mark - Tap/Gesture Recognizers

- (void)tapDetected:(UITapGestureRecognizer *)recognizer
{
    [self.userNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
//    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
//        [self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
//    } completion:nil];

}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(touch.view == _signInButton)
        return NO;
    else if ([touch.view.superview isKindOfClass:[UIToolbar class]])
        return NO;
    return YES;
}
#pragma mark - UITextField delegate methods

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
//    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
//        [self.view setFrame:CGRectMake(0,-60,self.view.frame.size.width,self.view.frame.size.height)];
//    } completion:nil];

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSRange textFieldRange = NSMakeRange(0, [textField.text length]);
    if (NSEqualRanges(range, textFieldRange) && [string length] == 0) {
        self.signInButton.hidden = (self.userNameTextField == textField && self.passwordTextField.text.length == 0 ) ||
            (self.passwordTextField == textField && self.userNameTextField.text.length == 0);
    } else {
        self.signInButton.hidden = NO;
    }
    return YES;
}

-(BOOL)allFieldsEmpty {
    return self.passwordTextField.text.length == 0 && self.userNameTextField.text.length == 0;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.signInButton.hidden = [self allFieldsEmpty];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
    if (textField == self.userNameTextField)
    {
        [self.userNameTextField resignFirstResponder];
		[self.passwordTextField becomeFirstResponder];
	}
	else if (textField == self.passwordTextField)
    {
        if(_userNameTextField.text.length == 0 || _passwordTextField.text.length == 0)
        {
            UIAlertView *enterDetailsAlertView = [[UIAlertView alloc]initWithTitle:nil message:MSG_ENTER_LOGIN_DETAILS  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [enterDetailsAlertView show];
            [textField becomeFirstResponder];

        }
        else
        {
            
            [textField resignFirstResponder];
            
//            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
//                [self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
//            } completion:nil];

            [self signInToServer];
            [self disableUserInteraction];

        }
        
	}
	return YES;
}

#pragma mark - User Interaction

- (void)disableUserInteraction
{
    _signInButton.enabled = NO;
    _userNameTextField.enabled = NO;
    _passwordTextField.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}
- (void)enableUserInteraction
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    _signInButton.enabled = YES;
    _userNameTextField.enabled = YES;
    _passwordTextField.enabled = YES;
}

#pragma mark - Button Actions

- (IBAction)signInButtonTapped:(UIButton *)sender
{
    if(_userNameTextField.text.length == 0 || _passwordTextField.text.length == 0)
    {
        UIAlertView *enterDetailsAlertView = [[UIAlertView alloc]initWithTitle:nil message:MSG_ENTER_LOGIN_DETAILS  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [enterDetailsAlertView show];
        [_userNameTextField becomeFirstResponder];

    }
    else
    {
        // Sign in to server
        [self signInToServer];
        [self disableUserInteraction];
       
    }
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
- (IBAction)lockButtonTapped:(UIButton *)sender
{
    [self enterPasscode];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];

    cell.textLabel.text = @"Connect";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    tableView.allowsSelection = YES;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self signInButtonTapped:nil];
}



- (IBAction)cancelButtonTapped:(UIButton *)sender
{
 
    if(self.connectTask != nil) // If attempted Sign In
    {
        [self.connectTask cancel]; // cancel request
        self.connectTask = nil;
    }
  
    if([self.sectionIdentifier isEqualToString:@"NewRecording"])
    {
        [self.navigationController popViewControllerAnimated:YES];
//        UIViewController *mainViewController=[self.navigationController.viewControllers objectAtIndex:1];
//        [self.navigationController popToViewController:mainViewController animated:NO];
//        [mainViewController performSegueWithIdentifier:@"RecordingIdentifier" sender:nil];
        
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }

}

#pragma mark - Server Signin

-(void)signInToServer
{
    self.connectTask = [[ServerSession loginSession] POST:URL_LOGIN
                                                parameters:nil
                                 constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
                                     [formData appendPartWithFormData:[_userNameTextField.text dataUsingEncoding:NSUTF8StringEncoding] name:@"login"];
                                     [formData appendPartWithFormData:[_passwordTextField.text dataUsingEncoding:NSUTF8StringEncoding] name:@"password"];
                                 }
                                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                                       [self enableUserInteraction];

//                                                       NSString* response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                                       
                                                       NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                                                       NSString *response = [responseDict objectForKey:@"status"];
                                                      NSString *user = [responseDict objectForKey:@"username"];
                                                       NSLog(@"USER:%@", user);
                                                       NSLog(@"RESPONSE:%@", responseDict);
                                                       NSLog(@"Login Task Response: %@", response);
                                                       if ([response isEqualToString:STATUS_SUCCESS]) {
                                                           UserDefaults *userDefaults = [UserDefaults sharedUserDefaults];
                                                           userDefaults.signInUserName = user;
                                                           userDefaults.signInPassword = _passwordTextField.text;
                                                           userDefaults.lastLoginDate = [NSDate date];
                                                           userDefaults.credentialsSaved = YES;
                                                           [userDefaults saveUserDefaults];
                                                           [self performSegueWithIdentifier:@"ServerUploadIdentifier" sender:self];
                                                       }
                                                       else {
                                                            UIAlertView *incorrectDataAlertView = [[UIAlertView alloc]initWithTitle:nil message:@"An AVA account matching the entered user name and password could not be found." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                                            [incorrectDataAlertView show];
                                                       }
                                                   }
                                                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                       [self enableUserInteraction];
                                                       //[UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
                                                   }];

    
}


#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ServerUploadIdentifier"])
    {
        ServerUploadingViewController *serverUpload;
        serverUpload= segue.destinationViewController;
        serverUpload.nameString = _recordingName;
        serverUpload.sectionIdentifier = @"SignIn";
        serverUpload.fileName = _fileName;
        self.connectTask = nil;
    }
}
-(IBAction)prepareForUnwind:(UIStoryboardSegue*)segue
{
    
}
 @end
