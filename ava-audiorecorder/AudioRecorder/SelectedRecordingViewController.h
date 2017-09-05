//
//  SelectedRecordingViewController.h
//  AudioRecorder
//
//  
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DatabaseManager.h"

@interface PlayBackViewController : UIViewController<UIGestureRecognizerDelegate,AVAudioPlayerDelegate,UIAlertViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *fileNameTextField;
@property (strong, nonatomic) NSString *nameString;
@property (strong, nonatomic) NSString *sectionIdentifier;
@property (strong, nonatomic) IBOutlet UISlider *sliderControl;
@property (strong, nonatomic) IBOutlet UILabel *elapsedTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) NSString *fileName;
@end
