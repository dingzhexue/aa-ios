//
//  AudioData.h
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import <Foundation/Foundation.h>

@interface AudioData : NSObject

@property(nonatomic,strong)NSString *fileName;
@property(nonatomic,strong)NSDate *createdDate;
@property NSTimeInterval audioDuration;
@property BOOL uploadStatus;
@property(nonatomic,strong)NSDate *uploadedDate;
@property(nonatomic,strong)NSString *nameOnServer;
@property(nonatomic, strong)NSString *name;

@end
