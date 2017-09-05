//
//  SelectedRecordingViewController.m
//  AudioRecorder
//
//  
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import "SelectedRecordingViewController.h"

#import "RecordingsViewController.h"
#import "ServerSignInViewController.h"
#import "ServerUploadingViewController.h"
#import "NewRecordingViewController.h"
#import "Constants.h"
#import "DocumentsData.h"
#import "AudioData.h"
#import "AudioRecorderAppDelegate.h"
#import "TimeFormatter.h"
#import "NSDate+DateFormatter.h"
#import "UserDefaults.h"
#import "Passcode.h"
#import "Recording.h"

@interface PlayBackViewController ()
{
    AVAudioPlayer *audioPlayer;
    NSURL *urlForSelectedAudio;
    DatabaseManager *dbManager;
    Recording *currentRecording;
    DocumentsData *docData;
}

//- (IBAction)backTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *recordedDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *uploadedDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameOnServer;
@property (strong, nonatomic) IBOutlet UILabel *lengthLabel;



@property BOOL uploadStatus;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;

@property (strong, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (strong, nonatomic)UserDefaults *userDefaults;
@property (strong, nonatomic)NSString *loginName;
@property (strong, nonatomic)NSString *loginPass;
@property (strong, nonatomic)AudioData *audioData;

- (IBAction)sliderMoved:(id)sender;
- (IBAction)lockButtonTapped:(id)sender;
- (IBAction)playButtonTapped:(id)sender;
- (IBAction)uploadButtonTapped:(id)sender;
//- (IBAction)deleteButtonTapped:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)sliderTapGestureRecognized:(UITapGestureRecognizer *)sender;
- (void)initializeAudioPlayer;
@end

@implementation PlayBackViewController
@synthesize fileNameTextField = _fileNameTextField;
@synthesize sliderControl = _sliderControl;
@synthesize elapsedTimeLabel = _elapsedTimeLabel;
@synthesize playButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentRecording = nil;
    }
    return self;
}
#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    NSLog(@"%@",_sectionIdentifier);
   self.title = @"Recording";
    _loginName = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:KEY_USER_NAME]];
    
    _loginPass = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:KEY_USER_LOGIN_PASSWORD]];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.uploadButton.layer.cornerRadius = 3.;
    self.fileNameTextField.text = _nameString;
//    sliderControl.value = 0.0;
//    self.navigationItem.title = _nameString;
    playButton.enabled = YES;
    
    // Disable AutoCorrection in textfield
    _fileNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // Set Image of Button for different control states
    [playButton setImage:[UIImage imageNamed:@"play_btn.png"] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:@"pause_btn.png"] forState:UIControlStateSelected];
    

    dbManager = [[DatabaseManager alloc]init];
    
    // Initialize Audio player
   // [currentRecording initializeRecorder];
    
    // Add gester recognizer
    UITapGestureRecognizer *tapGesterRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDetected:)];
    tapGesterRecognizer.numberOfTapsRequired = 1;
    tapGesterRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGesterRecognizer];

    AudioRecorderAppDelegate *appDelegate=[AudioRecorderAppDelegate sharedDelegate];
    appDelegate.currentViewController=self;

    //add label as a subview of the slider
    //[self.sliderControl addSubview:self.elapsedTimeLabel];
    //[self sliderMoved:self.sliderControl];
//            NSArray *tempVCA = [self.navigationController viewControllers];
//            for(UIViewController *tempVC in tempVCA)
//            {
//                if ([tempVC isKindOfClass:[NewRecordingViewController class]]) {
//                    
//                    [tempVC removeFromParentViewController];
//                }
//            }
    [self.navigationItem setHidesBackButton:YES animated:YES];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonTapped:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playerFinished:) name:@"didPlayerFinish" object:nil];
}
-(void)playerFinished:(NSNotification*)notification
{
    self.playButton.selected = NO;
}
- (void)viewWillAppear:(BOOL)animated
{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    _userDefaults = [UserDefaults sharedUserDefaults];
    
    // Fetch the file description fronm the database
    _audioData = [[AudioData alloc]init];
    _audioData  = [dbManager fetchAudioDescription:_fileName];
    TimeFormatter *timeFormatter = [[TimeFormatter alloc]initWithTimeInterval:_audioData.audioDuration];
    self.recordedDateLabel.text = [_audioData.createdDate dateStringWithFormatterString:DATE_FORMATTER_STRING_PLAYBACK timeZone:nil];
    self.totalTimeLabel.text = timeFormatter.durationString;//audioData.audioDuration;
    self.nameOnServer.text = [_audioData.nameOnServer stringByDeletingPathExtension];
    
    self.sliderControl.maximumValue = _audioData.audioDuration;
    self.uploadStatus = _audioData.uploadStatus;
    if (_uploadStatus) {
        self.uploadedDateLabel.text = [_audioData.uploadedDate dateStringWithFormatterString:DATE_FORMATTER_STRING_PLAYBACK timeZone:nil];
    }else{
        self.uploadedDateLabel.text = @"Never";
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [currentRecording.player stop];
}
    

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTimeLabel:nil];
    [self setRecordedDateLabel:nil];
    [self setUploadedDateLabel:nil];
    [self setNameOnServer:nil];
    [self setLengthLabel:nil];
    [self setSliderControl:nil];
    [self setFileNameTextField:nil];
    [self setPlayButton:nil];
    [super viewDidUnload];
}
#pragma mark -

//- (void)initializeAudioPlayer
//{
//    NSError *error;
//    // Get the audio from documents folder for playback
//    DocumentsData *docData = [[DocumentsData alloc]init];
//    NSString *fullPath = [docData getFilePathFromDocumentsFolder:_fileNameTextField.text];
//    NSURL *url = [NSURL URLWithString:fullPath];//WORKS
//    NSData *data = [NSData dataWithContentsOfFile:[url path]options:0 error:&error];//WORKS
//    //NSData *data = [[NSData alloc]initWithContentsOfFile:fullPath];
//    [[NSFileManager defaultManager]createFileAtPath:fullPath contents:data attributes:nil];//WORKS
//    NSData *d = [[NSData alloc]initWithContentsOfFile:fullPath];//WORKS
//    NSLog(@"%@", [data description]);
//    urlForSelectedAudio = [NSURL fileURLWithPath:fullPath];
//    NSLog(@"%@", urlForSelectedAudio);
//    
//    if(!audioPlayer)
//    {
//        NSError *error=nil;
//        audioPlayer = [[AVAudioPlayer alloc]initWithData:d error:&error];
////        audioPlayer = [[AVAudioPlayer alloc]
////                       initWithContentsOfURL:urlForSelectedAudio
////                       error:&error];
//        if (error)
//            NSLog(@"Error: %@", [error localizedDescription]);
//        else
//        {
//            if(_sliderControl.maximumValue != [currentRecording.player duration])
//                _sliderControl.maximumValue = [currentRecording.player duration];
//            
//            currentRecording.player.delegate = self;
//            
//            // Create an audio session for playback to start
//            AVAudioSession *session = [AVAudioSession sharedInstance];
//            [session setCategory:AVAudioSessionCategoryPlayback error:nil];
//            [session setActive:YES error:nil];
//            
//            // Get ready to for playback
//            [audioPlayer prepareToPlay];
//        }
//    }
// 
//}

#pragma mark - Button actions

- (IBAction)playButtonTapped:(UIButton *)sender
{
    
    if (!playButton.selected)
    {   currentRecording.selectedName = _fileNameTextField.text;
        currentRecording = [[Recording alloc]initWithName:_fileName andAudioData:[NSData data]];
        currentRecording.player.delegate = self;
        
        // Play audio
        [currentRecording startPlayback];
        
        audioPlayer = currentRecording.player;
        
        if(_sliderControl.maximumValue != [audioPlayer duration])
            _sliderControl.maximumValue = [audioPlayer duration];
            
        
        
        NSLog(@"NAME:%@", _fileNameTextField.text);
        playButton.selected = YES; // Change the button state
        
        
        
        
        
        
        currentRecording.player.currentTime = _sliderControl.value;
//        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sliderMoved:) userInfo:nil repeats:YES];
        
        // timer for controlling the slider. Set the interval to .02 in order to make the slider movement smooth
        [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        
    }
    else
    {
        playButton.selected = NO;
        // Pause audio player 
        [currentRecording pausePlayback];
    }
}

- (IBAction)uploadButtonTapped:(UIButton *)sender
{
    // If the audio player is playing, stop it before upload
    if(currentRecording.player.playing)
        [currentRecording.player stop];
    
    // Check whether file is already uploaded
    if (self.uploadStatus)
    {
        UIAlertView *fileUploadAlertView = [[UIAlertView alloc]initWithTitle:MSG_ALREADY_UPLOADED message:nil  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [fileUploadAlertView show];
    }
    else if(_fileNameTextField.text.length == 0) // Check whether field is empty
    {
        UIAlertView *emptyNameAlertView = [[UIAlertView alloc]initWithTitle:MSG_ENTER_NAME message:nil  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [emptyNameAlertView show];
        [_fileNameTextField becomeFirstResponder];

    }
    else
    {
      
        
        
        //get instance of userDefaults
        _userDefaults = [UserDefaults sharedUserDefaults];
        //read userDefaults to get username and password decrypted.
        [_userDefaults readUserDefaults];
        //if the username and password length is 0, there are no credentials saved so take user to signin.
        if ([_userDefaults.signInUserName length]==0 && [_userDefaults.signInPassword length]==0) {
            NSLog(@"should send to signin");
            [self performSegueWithIdentifier:@"SignInIdentifier" sender:self];
        
        }else{//otherwise, take user to upload
            NSLog(@"user defaults has username and password");
            [self performSegueWithIdentifier:@"UploadIdentifier" sender:self];
            

        }
    }
}

//- (IBAction)deleteButtonTapped:(UIButton *)sender
//{
//    // If audio player is playing, Stop it before delete
//    if(audioPlayer.playing)
//        [audioPlayer stop];
//
//    UIAlertView *deleteFileAlertView = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:MSG_DELETE_FILE,_fileNameTextField.text] message:nil  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//    [deleteFileAlertView show];
//
//}

- (IBAction)sliderMoved:(id)sender
{
    // Change the audio player time based on current slider value
    audioPlayer.currentTime = _sliderControl.value;
    [self updateElapsedTime];
    
    
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
    // If audio player is playing stop it before locking the screen
    if(audioPlayer.playing)
    {
        playButton.selected = NO;
        [audioPlayer stop];
    }
    [self enterPasscode];
    

}

- (IBAction)closeButtonTapped:(UIButton *)sender
{
    [audioPlayer stop];
    // Remove the audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];

    [session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    if([_sectionIdentifier isEqualToString:@"SavedRecording"])
    {
        NSLog(@"SAVED RECORDING");
        self.fileNameTextField.delegate = nil;
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if([self.sectionIdentifier isEqualToString:@"NewRecording"])
    {
        self.fileNameTextField.delegate = nil;
        
        // Set the userdefaults for New audio file created to TRUE
        UserDefaults *userDefaults = [UserDefaults sharedUserDefaults];
        userDefaults.isNewAudioFileCreated = YES;
        [userDefaults saveUserDefaults];
        
        NSLog(@"NEW RECORDING");
        // Push the Recordings List viewcontroller
        UIViewController *mainViewController=[self.navigationController.viewControllers objectAtIndex:0];
        //setting the title and hiding the back button here just to be sure that it's done on navigation. These two lines may not be needed though.
        mainViewController.navigationItem.title = @"AVA";
        mainViewController.navigationItem.hidesBackButton = YES;
        //pop to the main list, removing this view from the navigation stack, thereby eliminating the back button and wrong title issues on the main view.
        [self.navigationController popToViewController:mainViewController animated:YES];
    }
    

}

//- (IBAction)backTapped:(id)sender {
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}

- (IBAction)sliderTapGestureRecognized:(UITapGestureRecognizer *)sender
{
    UISlider* slider = (UISlider*)sender.view;
    if (slider.highlighted)
        return; // tap on thumb, let slider deal with it
    CGPoint tapPoing = [sender locationInView: slider];
    CGFloat percentageChange = tapPoing.x / slider.bounds.size.width;
    CGFloat deltaChange = percentageChange * (slider.maximumValue - slider.minimumValue);
    CGFloat newSliderValue = slider.minimumValue + deltaChange;
    [slider setValue:newSliderValue animated:YES];
    
    [self sliderMoved:slider];

}

#pragma mark -

- (void)tapDetected:(UITapGestureRecognizer *)recognizer
{
    [self.fileNameTextField resignFirstResponder];
}

#pragma mark -UIGestureRecognizer delegate method

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([touch.view isKindOfClass:[UIButton class]])
        return NO;
    else if ([touch.view.superview isKindOfClass:[UIToolbar class]])
        return NO;
    return YES;
}

#pragma mark - Segue



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SignInIdentifier"])
    {
        ServerSignInViewController *serverSignIn;
        serverSignIn = segue.destinationViewController;
        serverSignIn.navigationTitle = _nameString;
        serverSignIn.sectionIdentifier = self.sectionIdentifier ?: @"PlayBack";
        NSString *nameString = _fileNameTextField.text;
        
        serverSignIn.recordingName = nameString;
        serverSignIn.fileName = _audioData.fileName;
    }else if([segue.identifier isEqualToString:@"UploadIdentifier"])
    {
        ServerUploadingViewController *uploadVc;
        uploadVc = segue.destinationViewController;
        uploadVc.sectionIdentifier = self.sectionIdentifier ?:@"SavedRecording";
        uploadVc.nameString = _fileNameTextField.text;
        uploadVc.fileName = _audioData.fileName;
    }else //if([segue.identifier isEqualToString:@"CustomSegue"])
    {
//        RecordingsListViewController *backVC;
//        backVC = segue.destinationViewController;
//        backVC.sectionIdentifier = self.sectionIdentifier ?: @"BackToMain";
        //backVC.navigationItem.title = @"AVA";
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
#pragma mark - UITextField delegate method

-(void)textFieldDidEndEditing:(UITextField *)textField
{
   // DocumentsData *docData = [[DocumentsData alloc]init];
   // NSString *oldPath = [docData getFilePathFromDocumentsFolder:_fileName];
    if (textField.text.length == 0)
    {
        UIAlertView *emptyNameAlertView = [[UIAlertView alloc]initWithTitle:nil message:MSG_ENTER_NAME delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [emptyNameAlertView show];
        textField.text = _nameString;
        [textField becomeFirstResponder];
        
    }
    
    else  if(![_fileNameTextField.text isEqualToString:_nameString])
    {
        if([docData isFileAlreadyExists:_fileNameTextField.text])
        {
            UIAlertView *nameExistsAlertView = [[UIAlertView alloc]initWithTitle:nil message:MSG_NAME_EXISTS delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [nameExistsAlertView show];
            [textField becomeFirstResponder];
            
            
        }
        else
        {
            // rename file
           // DocumentsData *docData = [[DocumentsData alloc]init];
           
            [dbManager updateFilename:_nameString withNewName:textField.text];
            _nameString = textField.text;
        }
    }
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.fileNameTextField)
    {
		[self.fileNameTextField resignFirstResponder];
	}
    return YES;
    
}
#pragma mark - AudioPlayer delegate method

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag == YES) {
        playButton.selected = NO;
        _sliderControl.value = audioPlayer.duration;
    }else{
        NSLog(@"audioPlayer finished with error");
    }
    //playButton.selected = NO;
    
    //NSLog(@"audioPlayerDidFinishPlaying successfully");
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    if(error)
    {
        NSLog(@"Decode Error occurred = %@",[error localizedDescription]);
        return;
    }
}
#pragma mark -
//-(void)adjustLabelForSlider:(NSTimer*)timer
//{
//    CGRect trackRect = [self.sliderControl trackRectForBounds:self.sliderControl.bounds];
//    CGRect thumbRect = [self.sliderControl thumbRectForBounds:self.sliderControl.bounds
//                                                    trackRect:trackRect
//                                                        value:self.sliderControl.value];
//    
//    _elapsedTimeLabel.center = CGPointMake(thumbRect.origin.x + self.sliderControl.frame.origin.x*2,  self.sliderControl.frame.origin.y - 5);
//
//    
//}
- (void)updateTime:(NSTimer *)timer
{
    if(!currentRecording.player.playing)
    {
        [timer invalidate];
        //        return;
    }
    
    _sliderControl.value = currentRecording.player.currentTime;
    NSLog(@"CurrentTime: %f", currentRecording.player.currentTime);
    
    [self updateElapsedTime];
    
    
}
-(void)updateElapsedTime
{
    int hour = _sliderControl.value/CONSTANT_HOUR_IN_SECONDS;
    int mins = _sliderControl.value/CONSTANT_MINUTE_IN_SECONDS;
    int secs =ceil(fmodf(_sliderControl.value, CONSTANT_MINUTE_IN_SECONDS));
    NSString *hourString = hour < CONSTANT_VALUE_TEN ? [NSString stringWithFormat:@"0%d", hour] : [NSString stringWithFormat:@"%d", hour];
    NSString *minsString = mins < CONSTANT_VALUE_TEN ? [NSString stringWithFormat:@"0%d", mins] : [NSString stringWithFormat:@"%d", mins];
    NSString *secsString = secs < CONSTANT_VALUE_TEN ? [NSString stringWithFormat:@"0%d", secs] : [NSString stringWithFormat:@"%d", secs];
    //_elapsedTimeLabel.text = [NSString stringWithFormat:@"%@:%@:%@",hourString, minsString, secsString];
    NSString *timeTest = [NSString stringWithFormat:@"%@:%@:%@",hourString, minsString, secsString];
    NSLog(@"%@", timeTest);
    
    _elapsedTimeLabel.text = timeTest;
}
#pragma mark - UIAlertView delegate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:[NSString stringWithFormat:MSG_DELETE_FILE,_nameString]])
    {
        if(buttonIndex == INDEX_ONE)
        {
            // remove file from DB
            [dbManager deleteFileFromDatabase: [_nameString stringByAppendingPathExtension:@"m4a"]];
           
            // remove the file from documents folder
            DocumentsData *docData = [[DocumentsData alloc]init];
            if(![docData deleteRecordingFileWithName:[NSString stringWithFormat:@"%@.m4a",_nameString]])
                NSLog(@"Error while deleting file in documents folder");
            
            // Redirect to saved recordings after deletion
            //UIViewController *mainViewController=[self.navigationController.viewControllers objectAtIndex:0];
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
        else if (buttonIndex == INDEX_ZERO)
        {
            [playButton setImage:[UIImage imageNamed:@"play_btn.png"] forState:UIControlStateNormal];
            
        }
    }
    else if ([alertView.title isEqualToString:MSG_ALREADY_UPLOADED])
    {
        if(buttonIndex == INDEX_ONE)
        {
            //ADD FUNCTIONALITY TO CHECK CREDENTIALS AND BYPASS SIGNIN IF CREDENTIALS ARE SAVED.
            //get instance of userDefaults
            _userDefaults = [UserDefaults sharedUserDefaults];
            //read userDefaults to get username and password decrypted.
            [_userDefaults readUserDefaults];
            //if the username and password length is 0, there are no credentials saved so take user to signin.
            if ([_userDefaults.signInUserName length]==0 && [_userDefaults.signInPassword length]==0) {
                NSLog(@"should send to signin");
                [self performSegueWithIdentifier:@"SignInIdentifier" sender:self];
                
            }else{//otherwise, take user to upload
                NSLog(@"user defaults has username and password");
                [self performSegueWithIdentifier:@"UploadIdentifier" sender:self];
                
                
            }
            //[self performSegueWithIdentifier:@"SignInIdentifier" sender:self];
        }
    }
}


@end
