//
//  RecordingsViewController.h
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface RecordingsListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString *sectionIdentifier;
@property (nonatomic)BOOL *cameFromAccountConnection;
@property (nonatomic)BOOL *cameFromUpload;
@end
