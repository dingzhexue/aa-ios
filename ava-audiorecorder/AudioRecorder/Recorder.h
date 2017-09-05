//
//  Recorder.h
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Recorder : NSManagedObject

@property (nonatomic, retain) NSNumber * audioDuration;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSString * nameOnServer;
@property (nonatomic, retain) NSDate * uploadedDate;
@property (nonatomic, retain) NSNumber * uploadStatus;
@property (nonatomic, retain) NSString *name;

@end
