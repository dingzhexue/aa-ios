//
//  NewRecordingViewController.h
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface NewRecordingViewController : UIViewController

@property (strong, nonatomic) NSString *sectionIdentifier;

@property  BOOL isRecordingIntialized;
//@property (strong, nonatomic) NSTimer *stopWatchTimer;
//@property (strong, nonatomic) NSDate *startDate;
//@property (nonatomic) NSTimeInterval pauseTimeInterval;

@end
