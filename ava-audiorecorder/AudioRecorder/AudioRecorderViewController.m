//
//  AudioRecorderViewController.m
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AudioRecorderViewController.h"

#import "Constants.h"
#import "AudioRecorderAppDelegate.h"
#import "UserDefaults.h"

@interface MainViewController ()

- (IBAction)lockButtonTapped:(id)sender;

@end

@implementation MainViewController

#pragma mark - View controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Make mainviewcontroller current viewcontroller 
    AudioRecorderAppDelegate *appDelegate=[AudioRecorderAppDelegate sharedDelegate];
    appDelegate.currentViewController=self;
    
    // Set the user defaults of new record created to NO for removing cell selection in recordingslist
    UserDefaults *userDefaults = [UserDefaults sharedUserDefaults];
    userDefaults.isNewAudioFileCreated = NO;
    [userDefaults saveUserDefaults];
    
    if(userDefaults.isFirstLaunch)
    {
        [appDelegate applicationDidBecomeActive:nil];
        userDefaults.isFirstLaunch=NO;
    }

    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            NSLog(@"WARNING: Record Permission Was Not Granted");

            [self performSelectorOnMainThread:@selector(warningAboutRecordPermission) withObject:nil waitUntilDone:NO];
        }
    }];
}

-(void)warningAboutRecordPermission {
    [[[UIAlertView alloc] initWithTitle:nil
                                message:@"Recording audio permission was not given. You must enable it from the privacy settings."
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:nil] show];
}

#pragma mark - Button Action method

- (IBAction)lockButtonTapped:(UIButton *)sender
{
    NSString *passwordString = [[UserDefaults sharedUserDefaults]unlockPassword];
    // check whether locked with password 
	if(passwordString.length != 0)
    {
        [self performSegueWithIdentifier:@"LockedViewIdentifier" sender:self];
    }
    else
    {
        UIAlertView *passwordAlertView = [[UIAlertView alloc]initWithTitle:nil message:MSG_SET_PASSWORD_ALERT  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [passwordAlertView show];
    }

}
@end
