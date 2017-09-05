//
//  Recording.h
//  AVA Recorder
//
//  Created by Tristan Freeman on 9/16/16.
//  Copyright © 2016 People Designs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define TEMP_FILE_NAME_EXTENSION @"m4a"
#define FILE_NAME_EXTENSION @"m4a"
#define RECODINGS_PATH @"Recordings"

@protocol RecordingDelegate <NSObject>

@optional
- (void)statedPlaying;
- (void)stoppedPlaying:(BOOL)success;
- (void)currentTime:(NSTimeInterval)currentTime;

@end
@interface Recording : NSObject <NSCoding,AVAudioPlayerDelegate, AVAudioRecorderDelegate>
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSData *audioData;
@property (copy, nonatomic) NSData *decryptedData;
@property (strong, nonatomic) AVAudioRecorder* recorder;
@property (strong, nonatomic) AVAudioPlayer* player;
@property(readonly) NSString *recordingsDirectory;
@property (copy, nonatomic) NSString *selectedName;
@property  BOOL isRecordingIntialized;
@property (strong, nonatomic) id<RecordingDelegate> delegate;

- (Recording *)init;
- (Recording *)initWithName:(NSString *)aName;
- (Recording *)initWithName:(NSString *)aName andAudioData:(NSData *)audioData; // this is the designated initializer

- (void)saveFile;
- (void)deleteFile;
- (void)deleteTemporaryFile;

- (void)initializeRecorder;
- (void)startRecording;
- (void)pauseRecording;
- (void)stopRecording;

- (void)initializePlayer;
- (void)startPlayback;
- (void)pausePlayback;
- (void)stopPlayback;

@end
