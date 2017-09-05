//
//  ARAboutViewController.m
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import "ARAboutViewController.h"

#import "Constants.h"
#import "AudioRecorderAppDelegate.h"
#import "UserDefaults.h"
#import "Passcode.h"

@interface ARAboutViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *closeButton;

- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)openBrowserButtonTapped:(id)sender;
- (IBAction)lockButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation ARAboutViewController

@synthesize closeButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - View controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    NSString * appVersionString = [[NSBundle mainBundle]
            objectForInfoDictionaryKey:@"CFBundleVersion"];

    self.versionLabel.text = [NSString stringWithFormat:@"Version %@", appVersionString];

    AudioRecorderAppDelegate *appDelegate=[AudioRecorderAppDelegate sharedDelegate];
    appDelegate.currentViewController=self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload
{
    [self setCloseButton:nil];
    [super viewDidUnload];
}

#pragma mark - Button action methods

- (IBAction)closeButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)openBrowserButtonTapped:(UIButton *)sender
{
    //Open the URL using native browser of the device
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_ABOUT]];
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

@end
