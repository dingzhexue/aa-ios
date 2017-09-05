//
//  UploadProgressViewController.h
//  AVA Recorder
//
//  Created by Tristan Freeman on 8/10/16.
//  Copyright © 2016 People Designs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomProgressView.h"

@interface UploadProgressViewController : UIViewController<CustomProgressViewDelegate>
@property (strong, nonatomic)NSString *fileNameString;
@property (strong, nonatomic)NSString *userName;
@property (strong, nonatomic)NSString *collectionName;
@property (strong, nonatomic) NSString *collectionId;
@property (strong, nonatomic) NSString *fileName;


@end
