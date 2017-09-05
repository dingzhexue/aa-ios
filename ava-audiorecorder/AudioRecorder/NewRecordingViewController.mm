//
//  NewRecordingViewController.m
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import "NewRecordingViewController.h"
#import "SelectedRecordingViewController.h"
#import "Constants.h"
#import "DocumentsData.h"
#import "AudioData.h"
#import "ServerSignInViewController.h"
#import "AudioRecorderAppDelegate.h"
#import "NSDate+DateFormatter.h"
#import "UserDefaults.h"
#import "CALevelMeter.h"
#import "CustomPasscodeConfig.h"
#import "Passcode.h"
#import "Recording.h"

@interface NewRecordingViewController () <UIGestureRecognizerDelegate, AVAudioRecorderDelegate, UIAlertViewDelegate, UITextFieldDelegate, AVAudioSessionDelegate> {
    DocumentsData *docData;
    DatabaseManager *dbManager;
    AVAudioRecorder *audioRecorder;
    NSTimer *stopWatchTimer;
    NSDate *startDate;
    NSDate *audioCreationDate;
    NSTimeInterval pauseTimeInterval;
    NSString *soundFilePath, *fileName, *defaultFilename, *newFileName;
    BOOL isRecordingIntialized;
    
    Recording *currentRecording;

}
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property(strong, nonatomic) IBOutlet UITextField *nameTextField;
@property(strong, nonatomic) IBOutlet UILabel *timeLabel;
@property(strong, nonatomic) IBOutlet UIButton *playbackButton;
@property(strong, nonatomic) IBOutlet UILabel *recodingStatusLabel;
@property(retain, nonatomic) IBOutlet CALevelMeter *inputLevelMeter;
@property(retain, nonatomic)NSString *timeStamp;
@property(retain, nonatomic)NSString *uniqueFileName;
@property(nonatomic)int counter;
@property(nonatomic)int count;


- (IBAction)cancelButtonTapped:(id)sender;

- (IBAction)startRecordingButtonTapped:(id)sender;

- (IBAction)doneRecordingButtonTapped:(id)sender;


- (IBAction)lockButtonTapped:(id)sender;

//- (void)startAudioRecording;
//
//- (void)initializeAudiorecording;

- (void)controlTimerForNewRecording;

@end

@implementation NewRecordingViewController
@synthesize isRecordingIntialized = isRecordingIntialized;
//@synthesize inputLevelMeter;
//@synthesize stopWatchTimer = _stopWatchTimer;
//@synthesize startDate = _startDate;
//@synthesize timeLabel = _timeLabel;
//@synthesize pauseTimeInterval = _pauseTimeInterval;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        docData = [[DocumentsData alloc] init];
        dbManager = [[DatabaseManager alloc] init];
        self.inputLevelMeter.hidden = YES;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isRecordingIntialized = NO;
    }
    return self;
}

//-(void)dealloc
//{
//    currentRecording = nil;
//}
#pragma mark - View Controller LifeCycle


- (void)viewDidLoad {
    [[AudioRecorderAppDelegate sharedDelegate]setRecordPermissionRequested:@"YES"];
    [self checkPermissions];
//            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
//            if (granted) {
//                NSLog(@"Permission granted");
//            } else {
//                NSLog(@"Permission denied");
//            }
//        }];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(audioSessionWasInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];
    
//        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
//        if (granted) {
//            NSLog(@"Permission granted");
//        } else {
//            NSLog(@"Permission denied");
//        }
//    }];
    //            // Create audio session for the recording
    //            AVAudioSession *session = [AVAudioSession sharedInstance];
    //            [session setCategory:AVAudioSessionCategoryRecord error:nil];
    //            [session setActive:YES error:nil];
    [super viewDidLoad];
    self.title = @"New Recording";
    
    [self getFileName];
    
    
    // Do any additional setup after loading the view from its nib.
    
    
    //_nameTextField.text = [NSString stringWithFormat:@"Recording %d", counter];
//    _nameTextField.text = [[NSDate date] dateStringWithFormatterString:DATE_FORMATTER_STRING_FOR_FILENAME timeZone:nil];
    // set text clear button in name text field
    [self.nameTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    self.doneButton.layer.cornerRadius = 3.0;
    // Save the default file name so that whenever user make an empty field the default name will be set for the textfiled
    defaultFilename = _nameTextField.text;

    
    
    //Set Initial time 
    _timeLabel.text = @"00:00:00";
    pauseTimeInterval = 0.0;

    _recodingStatusLabel.text = nil;

    // Disable AutoCorrection in textfield
    _nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;

    // Set Image of Button for different control states
    [_playbackButton setImage:[UIImage imageNamed:@"record_btn.png"] forState:UIControlStateNormal];
    [_playbackButton setImage:[UIImage imageNamed:@"pause_btn.png"] forState:UIControlStateSelected];

    // Check whether automatic recording is ON
    if ([[UserDefaults sharedUserDefaults] automaticRecord]) {
        _uniqueFileName = [self getUniqueFileName];
        
        currentRecording = [[Recording alloc]initWithName:_uniqueFileName andAudioData:[NSData data]];
        self.isRecordingIntialized = YES;
        audioCreationDate = [NSDate date];
       
            // change button image to pause state
            _playbackButton.selected = YES;
            // change label
            _recodingStatusLabel.text = STATUS_RECORDING;
        

            
            self.inputLevelMeter.hidden = NO;
        
        
        
        
            //[currentRecording initializeRecorder];
            // Start recording
            [currentRecording startRecording];
            audioRecorder = currentRecording.recorder;
            // Control the timer
            [self controlTimerForNewRecording];
            [self.inputLevelMeter setPlayer:audioRecorder];
            
        
    }
    // Add gester recognizer
    UITapGestureRecognizer *tapGesterRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    tapGesterRecognizer.numberOfTapsRequired = 1;
    tapGesterRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGesterRecognizer];

    // Make this viewcontroller currentviewcontroller
    AudioRecorderAppDelegate *appDelegate = [AudioRecorderAppDelegate sharedDelegate];
    appDelegate.currentViewController = self;

}
-(void)checkPermissions {
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance]recordPermission];
    
    switch (permissionStatus) {
        case AVAudioSessionRecordPermissionUndetermined: {
            [[AVAudioSession sharedInstance]requestRecordPermission:^(BOOL granted) {
                if (granted) {
                    //Microphone enabled
                    NSLog(@"Permission granted");
                } else{
                    //Michrophone disabled
                    NSLog(@"Permission denied");
                }
            }];
            break;
        }
            
        case AVAudioSessionRecordPermissionDenied:
            //direct to settings
            NSLog(@"Permission already denied");
            
            break;
            
        case AVAudioSessionRecordPermissionGranted:
            //permission granted
            NSLog(@"Permission already granted");
            break;
            
        default:
            break;
    }
    
}

-(void)audioSessionWasInterrupted:(NSNotification *)notification {
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
        NSLog(@"Interruption notification");
        
        if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey]isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]]) {
            NSLog(@"Interruption began");
            // change button image record state
            _playbackButton.selected = NO;
            // change label
            _recodingStatusLabel.text = STATUS_PAUSED;
            // Pause recording
            [currentRecording pauseRecording];
            
            self.inputLevelMeter.hidden = YES;
            
            // Invalidate the timer
            [self controlTimerForNewRecording];
        }else{
            NSLog(@"Interruption ended");
            
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTimeLabel:nil];
    [self setPlaybackButton:nil];
    [self setNameTextField:nil];
    [self setRecodingStatusLabel:nil];
    [self.inputLevelMeter setPlayer:nil];
    [super viewDidUnload];
    //_counter = 1;
    if (!(currentRecording == nil)) {
        [currentRecording deleteTemporaryFile];
    } else {
        NSLog(@"No temporary file to delete. currentRecording is nil");
    }
    
}
-(void)viewWillDisappear:(BOOL)animated{
    //[self.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
   
    
    [super viewWillDisappear:YES];
}

//-(void)checkDefaultFilename {
//    NSArray *recordings = [dbManager fetchAudioNameFromDatabase];
//    //int count = 0;
//    
//    _counter = 1;
//    
//    for (int i = 0; i < recordings.count; i++) {
//        NSString *name = recordings[i];
//        if ([name containsString:[NSString stringWithFormat:@"Recording %d", _counter]]) {
//            NSLog(@"%@", name);
//            NSLog(@"%d", _counter);
//        }
//        
//        _counter++;
//        
//    }
//    
//    _nameTextField.text = [NSString stringWithFormat:@"Recording %d", _counter];
//    
//}

-(void)getFileName{
    _counter = [[NSUserDefaults standardUserDefaults]integerForKey:@"recordingNumber"]+1;
    _nameTextField.text = [NSString stringWithFormat:@"Recording %d", _counter];
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
#pragma mark -
- (void)tapDetected:(UITapGestureRecognizer *)recognizer {
    [self.nameTextField resignFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]])
        return NO;
    else if ([touch.view.superview isKindOfClass:[UIToolbar class]])
        return NO;
    return YES;
}

-(NSString*)getUniqueFileName {
    NSString *prefixString = @"Recording";
    NSString *guid = [[NSProcessInfo processInfo]globallyUniqueString];
    NSString *uniqueName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    
    return uniqueName;
}
-(NSString*)getTimeStamp {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"TIMESTAMP: %@", timeStamp);
    
    return timeStamp;
}
#pragma mark - Button Actions

- (IBAction)startRecordingButtonTapped:(UIButton *)sender {
    if (!isRecordingIntialized) {
        // Initialize recording
        _uniqueFileName = [self getUniqueFileName];
        //_timeStamp = [self getTimeStamp];
        currentRecording = [[Recording alloc]initWithName:_uniqueFileName andAudioData:[NSData data]];
        
        //[currentRecording initializeRecorder];
        isRecordingIntialized = YES;
        audioCreationDate = [NSDate date];
        
    }
    // If recording is going to be performed
    if (!_playbackButton.selected) {
        if (!currentRecording.recorder.recording) {
            // change button image to pause state
            _playbackButton.selected = YES;
            // change label
            _recodingStatusLabel.text = STATUS_RECORDING;
            
   
            
             self.inputLevelMeter.hidden = NO;
            //currentRecording = [[Recording alloc]initWithName:_nameTextField.text andAudioData:[NSData data]];
                

            
            //currentRecording = [[Recording alloc]initWithName:_nameTextField.text andAudioData:[NSData data]];
            
            // Start recording
            [currentRecording startRecording];
//            // Create audio session for the recording
//                        AVAudioSession *session = [AVAudioSession sharedInstance];
//                        [session setCategory:AVAudioSessionCategoryRecord error:nil];
//                        [session setActive:YES error:nil];
            audioRecorder = currentRecording.recorder;
            //if ([currentRecording.recorder isRecording]) {
            [self controlTimerForNewRecording];
            [self.inputLevelMeter setPlayer:audioRecorder];
            
            
            //}
            // Control the timer
//            [self controlTimerForNewRecording];
//            [self.inputLevelMeter setPlayer:currentRecording.recorder];
            
        }
    }
    else {
        // change button image record state
        _playbackButton.selected = NO;
        // change label
        _recodingStatusLabel.text = STATUS_PAUSED;
        // Pause recording
        [currentRecording pauseRecording];
        
        self.inputLevelMeter.hidden = YES;
        
        // Invalidate the timer
        [self controlTimerForNewRecording];
        
    }
    
}
- (IBAction)doneRecordingButtonTapped:(UIButton *)sender {
    // Performed recording
    if (_nameTextField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:MSG_ENTER_NAME delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        _nameTextField.text = defaultFilename;
        [_nameTextField becomeFirstResponder];

    }
    else if (currentRecording)// Performed recording
    {
        [[NSUserDefaults standardUserDefaults]setInteger:_counter forKey:@"recordingNumber"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        // Rename the file
        //[docData renameFileInDocumentsFolder:fileName withNewName:[_nameTextField.text stringByAppendingPathExtension:@"m4a"]];
        NSError *error = nil;
        // Stop recording
        [currentRecording stopRecording];
        //get the user entered name
        NSString *enteredNameString = _nameTextField.text;
        //set the character set of characters that are not allowed in filename due to the way it messes up the filesystem paths
        NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"\/:"];
        //create new filename by replacing unwanted characters with white space.
        newFileName = [[enteredNameString componentsSeparatedByCharactersInSet:doNotWant]componentsJoinedByString:@" "];
        NSLog(@"FILENAME:%@", newFileName);
        currentRecording.name = _uniqueFileName;
        [currentRecording saveFile];
        AVAudioSession *session = [AVAudioSession sharedInstance];

        [session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
        if (error) {
            NSLog(@"ERROR:%@", [error localizedDescription]);
        }
        // Stop timer
        [stopWatchTimer invalidate];
        stopWatchTimer = nil;

        self.inputLevelMeter.hidden = YES;

        NSLog(@"PAUSE TIME:%f", pauseTimeInterval);
        // Save audio data into database
        [dbManager saveAudioData:[_uniqueFileName stringByAppendingPathExtension:@"m4a"] withDate:audioCreationDate duration:pauseTimeInterval status:NO name:newFileName];

                    //set inputMeter player to nil in order to avoid a zombie object of inputMeter
                    [self.inputLevelMeter setPlayer:nil];
//                    go to playback
                    [self performSegueWithIdentifier:@"RecordingIdentifier" sender:self];
            
//                    [tempVC removeFromParentViewController];
//                }
//            }
            
            
        //}
    }
    else {
        // If not recorded
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"No recording" delegate:nil
                                                  cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }


}




- (IBAction)cancelButtonTapped:(UIButton *)sender {    if (currentRecording) // Performed recording
    {
        UIAlertView *cancelRecordingAlertView = [[UIAlertView alloc] initWithTitle:MSG_CANCEL_RECORDING message:nil
                                                                          delegate:self cancelButtonTitle:@"Cancel"
                                                                 otherButtonTitles:@"OK", nil];
        [cancelRecordingAlertView show];
    }
    else {
        
        self.nameTextField.delegate = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }

}

- (IBAction)lockButtonTapped:(UIButton *)sender {
    [self enterPasscode];
}


#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RecordingIdentifier"]) {
        //Playback Viewcontroller
        AudioData *audioData = [[AudioData alloc] init];
        audioData = [dbManager fetchAudioDescription:[_uniqueFileName stringByAppendingPathExtension:@"m4a"]];
        PlayBackViewController *playBackVC;
        playBackVC = segue.destinationViewController;
        playBackVC.nameString = audioData.name;
        playBackVC.fileName = audioData.fileName;
        playBackVC.sectionIdentifier = @"NewRecording";
        //UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:nil action:nil];
        //[[self navigationItem]setBackBarButtonItem:backButton];
        //[self.navigationController popViewControllerAnimated:NO];
//        NSArray *tempVCA = [self.navigationController viewControllers];
//        for(UIViewController *tempVC in tempVCA)
//        {
//            if ([tempVC isKindOfClass:[NewRecordingViewController class]]) {
//                [self performSegueWithIdentifier:@"RecordingIdentifier" sender:self];
//                [tempVC removeFromParentViewController];
//            }
//        }
    }
    else if ([segue.identifier isEqualToString:@"NewSignInIdentifier"]) {
        //SignIn Viewcontroller
        ServerSignInViewController *serverSignIn;
        serverSignIn = segue.destinationViewController;
        serverSignIn.navigationTitle = newFileName;
        serverSignIn.sectionIdentifier = @"NewRecording";
    }


}



#pragma mark - UITextField delegate method

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.nameTextField clearsOnBeginEditing];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    // check if name field is empty
    if (_nameTextField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:MSG_ENTER_NAME delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        self.nameTextField.text = defaultFilename;
        [textField becomeFirstResponder];
    }else if([_nameTextField.text containsString:@"/"])
    {
        
    }
    else if (![_nameTextField.text isEqualToString:fileName]) {
        // Check whether file already exists
        if ([docData isFileAlreadyExists:_nameTextField.text]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:MSG_NAME_EXISTS delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
//            self.nameTextField.text = defaultFilename;
            [textField becomeFirstResponder];

        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameTextField) {
        [self.nameTextField resignFirstResponder];
    }
    return YES;

}


#pragma mark - AVAudioRecorder delegate methods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    [self.inputLevelMeter setPlayer:nil];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    if (error) {
        NSLog(@"Encode Error occurred = %@", [error localizedDescription]);
        return;
    }

}
#pragma mark - 
- (void)updateTimer {
    
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSString *timeString = [timerDate dateStringWithFormatterString:DATE_FORMATTER_STRING_FOR_TIME timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    _timeLabel.text = timeString;
    pauseTimeInterval = timeInterval;
    
}

- (void)controlTimerForNewRecording {
    //=============================new update with start pause==================
    if ([currentRecording.recorder isRecording]) {
        startDate = [NSDate date];
        startDate = [startDate dateByAddingTimeInterval:((-1) * (pauseTimeInterval))];
        stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 10.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    }
    else {
        [stopWatchTimer invalidate];
        stopWatchTimer = nil;
        [self updateTimer];
    }
    
}





#pragma mark - UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:MSG_CANCEL_RECORDING]) {
        if (buttonIndex == INDEX_ONE) {
            // Stop the recording
            [currentRecording.recorder stop];

            // Remove the audio session
            AVAudioSession *session = [AVAudioSession sharedInstance];

            [session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];

            if (![docData deleteRecordingFileWithName:[NSString stringWithFormat:@"%@.m4a", _nameTextField.text]]) {
                NSLog(@"Error while deleting file in documents folder");
                return;
            }
            
            self.nameTextField.delegate = nil;
            [self.inputLevelMeter setPlayer:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


@end
