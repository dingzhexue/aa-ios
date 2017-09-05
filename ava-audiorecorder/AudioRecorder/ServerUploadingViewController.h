//
//  ServerUploadingViewController.h
//  AudioRecorder
//
//  
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import <UIKit/UIKit.h>

@interface ServerUploadingViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *changeUserButton;

@property (strong, nonatomic) NSString *nameString;
@property (strong, nonatomic) NSString *collectionId;
@property (strong, nonatomic) NSString *collectionName;
@property (strong, nonatomic) NSString *sectionIdentifier;
@property (strong, nonatomic) NSMutableArray *collectionArray;
@property (weak, nonatomic) IBOutlet UITableView *goTable;
@property (strong, nonatomic) IBOutlet UIButton *startUploadButton;
@property (strong, nonatomic) NSString *fileName;

@end
