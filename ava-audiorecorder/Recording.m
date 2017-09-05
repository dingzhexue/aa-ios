//
//  Recording.m
//  AVA Recorder
//
//  Created by Tristan Freeman on 9/16/16.
//  Copyright © 2016 People Designs Inc. All rights reserved.
//

#import "Recording.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"
#import "NewRecordingViewController.h"
#import "SelectedRecordingViewController.h"
#import "DocumentsData.h"
#import "AudioRecorderAppDelegate.h"
#import "Constants.h"
#import "NSDate+DateFormatter.h"
#import "PDKeychain.h"

@interface Recording ()
{
    NSString* tempFilePath;
    NSTimer* currentTimeFetch;
    PlayBackViewController *selectedRecording;
    NewRecordingViewController *newRecording;
}

@end

@implementation Recording
@synthesize name = _name;
@synthesize audioData = _audioData;
@synthesize delegate = _delegate;
@synthesize player = _player;
@synthesize recorder = _recorder;
@synthesize decryptedData = _decryptedData;
@synthesize selectedName = _selectedName;

#pragma mark -
#pragma Initialization

- (Recording *)initWithName:(NSString *)aName andAudioData:(NSData *)audioData
{
    self = [super init];
    if (self) {
        self.name = [aName copy];
        self.audioData = [audioData copy];
        self.isRecordingIntialized = NO;
    }
    return self;
}

- (Recording *)initWithName:(NSString *)aName
{
    self = [super init];
    if (self) {
        self = [self initWithName:aName andAudioData:nil];
    }
    return self;
}

- (Recording *)init
{
    self = [super init];
    if (self) {
        self = [self initWithName:nil andAudioData:nil];
    }
    return self;
}

//- (void)dealloc
//{
//    self.name = nil;
//    self.audioData = nil;
//}

#pragma mark -
#pragma mark NSCoding Implementation

#define kNameKey @"name"
#define kAudioDataKey @"audioData"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:kNameKey];
    [aCoder encodeObject:_audioData forKey:kAudioDataKey];
}

- (Recording *)initWithCoder:(NSCoder *)aCoder
{
    NSString *name = [aCoder decodeObjectForKey:kNameKey];
    NSData *audioData = [aCoder decodeObjectForKey:kAudioDataKey];
    newRecording = [[NewRecordingViewController alloc]init];
    return [self initWithName:name andAudioData:audioData];
}

- (NSData *)audioData {
    if (_audioData != nil) return _audioData;
    _audioData = [[NSData alloc] initWithContentsOfFile:[self filePath]];
    return _audioData;
}
-(NSData*)decryptedData {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *recordingsDirectory = [paths objectAtIndex:0];
    recordingsDirectory = [recordingsDirectory stringByAppendingPathComponent:RECODINGS_PATH];
//    AudioRecorderAppDelegate *appDelegate=[AudioRecorderAppDelegate sharedDelegate];
//    _recordingsDirectory = [[[appDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"Recordings"];
    
    NSLog(@"SEL NAME:%@", _name);
    NSString *filePath = [recordingsDirectory stringByAppendingPathComponent:_name];
    _audioData = [[NSData alloc]initWithContentsOfFile:filePath];
//    _decryptedData = [RNDecryptor decryptData:_audioData withPassword:[[PDKeychain defaultKeychain]objectForKey:KEY_ENCRYPTION] error:&error];
    _decryptedData = [RNDecryptor decryptData:_audioData withPassword:[[PDKeychain defaultKeychain]objectForKey:KEY_ENCRYPTION] error:&error];
    return _decryptedData;
}
#pragma mark -
#pragma mark File Saving and Deleting

+ (NSString *)recodingsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *recodingsDirectory = [paths objectAtIndex:0];
    recodingsDirectory = [recodingsDirectory stringByAppendingPathComponent:RECODINGS_PATH];
    return recodingsDirectory;
}

+ (BOOL)createPath {
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:[self recodingsDirectory] withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"Error creating data path: %@", [error localizedDescription]);
    }
    return success;
}

- (NSString *)filePath
{
    [[self class] createPath];
    return [[[[self class] recodingsDirectory] stringByAppendingPathComponent:self.name] stringByAppendingPathExtension:FILE_NAME_EXTENSION];
}

- (NSString*)tempFilePath
{
    [[self class]createPath];
    return [[NSTemporaryDirectory() stringByAppendingPathComponent:self.name]stringByAppendingPathExtension:TEMP_FILE_NAME_EXTENSION];
}
- (void)saveFile
{   //NSLog(@"%@", _audioData);
    if (self.audioData == nil) return;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self filePath]]) {
        [self.audioData writeToFile:[self filePath] atomically:YES];
    } else {
        NSLog(@"File Exists");
    }
    
    //DebugLog(@"Save file with name %@ to %@", self.name, [self filePath]);
}

- (void)deleteTemporaryFile
{
    NSError *error;
    BOOL success = [[NSFileManager defaultManager]removeItemAtPath:[self tempFilePath] error:&error];
    
    if (!success) {
        NSLog(@"error removing item at path %@ : %@", [self tempFilePath], error.localizedDescription);
    }
}

- (void)deleteFile
{
    NSError *error;
    BOOL success = [[NSFileManager defaultManager]
                    removeItemAtPath:[self filePath]
                    error:&error];
    if (!success) {
        NSLog(@"Error removing document at path %@ : %@",
              [self filePath],
              error.localizedDescription
              );
    }
}

#pragma mark -
#pragma mark Audio Recording

- (void)initializeRecorder
{

//******set path to [self filePath] in order to create the direcotry prior to initializing the initial recording.
    //NSString *path = [self filePath];
    tempFilePath = [self tempFilePath];

        NSDictionary *recordSettings =
        @{AVFormatIDKey : @(kAudioFormatMPEG4AAC),
          AVSampleRateKey : @44100.0,
          AVNumberOfChannelsKey : @1,
          AVEncoderAudioQualityKey : @(AVAudioQualityHigh)};
        NSError* error = nil;
        
        self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:tempFilePath]
                                                    settings:recordSettings
                                                       error:&error];
        
        
        if (error) {
            NSLog(@"ERROR:%@", error.localizedDescription);
            //DebugLog(@"Error initializing recorder : %@", error);
        }
//        } else {
//            //NSError *error;
//            AVAudioSession *session = [AVAudioSession sharedInstance];
//            
//            [session setCategory:AVAudioSessionCategoryRecord error:&error];
//            [session setActive:YES error:&error];
//            if (error) {
//                NSLog(@"Error Setting Audio Catgory %@", error);
//            }

            [self.recorder prepareToRecord];
            [self.recorder setMeteringEnabled:YES];
       // }
    
}

- (void)startRecording
{
    if (!_isRecordingIntialized) {
        [self initializeRecorder];
        _isRecordingIntialized = YES;
    }
    NSError *error;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    [session setCategory:AVAudioSessionCategoryRecord error:&error];
    [session setActive:YES error:&error];
        if (error) {
            NSLog(@"Error Setting Audio Catgory %@", error);
        }
    //[newRecording.inputLevelMeter setPlayer:self.recorder];
    [self.recorder record];
    //[self controlTimerForNewRecording];
}

- (void)pauseRecording
{
    [self.recorder pause];
    //[self controlTimerForNewRecording];
}
- (void)stopRecording
{
    NSError *error;
    [self.recorder stop];
    NSData* soundData = [[NSData alloc] initWithContentsOfFile:tempFilePath];
//    NSData* encryptedData = [RNEncryptor encryptData:soundData withSettings:kRNCryptorAES256Settings password:[[PDKeychain defaultKeychain]objectForKey:KEY_ENCRYPTION] error:&error];
    NSData* encryptedData = [RNEncryptor encryptData:soundData withSettings:kRNCryptorAES256Settings password:[[PDKeychain defaultKeychain]objectForKey:KEY_ENCRYPTION] error:&error];
    self.audioData = encryptedData;
    [self.recorder deleteRecording];
    
}

#pragma mark -
#pragma Audio Playback

- (void)initializePlayer
{
//    NSString *fileName = selectedRecording.fileNameTextField.text;
//    DocumentsData *docData = [[DocumentsData alloc]init];
//    NSString *fullPath = [docData getFilePathFromDocumentsFolder:fileName];
//    //NSString *filePath = [_recordingsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",fileName]];
      NSError* error = nil;
//    NSData *playbackData = [[NSData alloc]initWithContentsOfFile:fullPath];
    
    self.player = [[AVAudioPlayer alloc] initWithData:self.decryptedData error:&error];
    self.player.delegate = self;
    
    if (error) {
        //DebugLog(@"Error initializing player : %@", error);
        
        NSLog(@"Error: %@", [error localizedDescription]);
        
    }else
    {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:&error];
        [session setActive:YES error:&error];
//        selectedRecording = [[PlayBackViewController alloc]init];
//        if(selectedRecording.sliderControl.maximumValue != [self.player duration])
//            selectedRecording.sliderControl.maximumValue = [self.player duration];
        NSLog(@"Duration:%f", self.player.duration);
    }
}

- (void)startPlayback
{
    [self initializePlayer];
    currentTimeFetch = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                interval:1
                                                  target:self
                                                selector:@selector(fetchCurrentTimeWithTimer:)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:currentTimeFetch
                                 forMode:NSDefaultRunLoopMode];
    //self.player.currentTime = selectedRecording.sliderControl.value;
    [self.player play];
    
    if ([self.delegate respondsToSelector:@selector(statedPlaying)]) {
        [self.delegate statedPlaying];
    }
}

- (void)stopPlayback
{
    if (currentTimeFetch != nil) {
        [currentTimeFetch invalidate];
    }
    if ([self.delegate respondsToSelector:@selector(stoppedPlaying:)]) {
        [self.delegate stoppedPlaying:YES];
    }
    [self.player stop];
}

- (void)pausePlayback
{
    if (currentTimeFetch != nil) {
        [currentTimeFetch invalidate];
    }
    if ([self.delegate respondsToSelector:@selector(stoppedPlaying:)]) {
        [self.delegate stoppedPlaying:YES];
    }
    [self.player pause];
}

- (void)fetchCurrentTimeWithTimer:(NSTimer *)timer
{
    if ([self.delegate respondsToSelector:@selector(currentTime:)]) {
        [self.delegate currentTime:[self.player currentTime]];
    }
}

//-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
//{
//    NewRecordingViewController *vc = [[NewRecordingViewController alloc]init];
//    [vc.inputLevelMeter setPlayer:nil];
//}
//-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
//{
//    NSLog(@"ERROR:%@", error.localizedDescription);
//}
#pragma mark -
#pragma mark AudioPlayerDelegate Methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"didPlayerFinish" object:self userInfo:nil];
    
    [selectedRecording.playButton setImage:[UIImage imageNamed:@"play_btn.png"] forState:UIControlStateNormal];
    if (currentTimeFetch) {
        [currentTimeFetch invalidate];
        
    }
    if ([self.delegate respondsToSelector:@selector(stoppedPlaying:)]) {
        [self.delegate stoppedPlaying:YES];
        
    }
    
    //DebugLog(@"Finished playing audio with %@", flag ? @"success" : @"errors");
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    if (currentTimeFetch) {
        [currentTimeFetch invalidate];
    }
    if ([self.delegate respondsToSelector:@selector(stoppedPlaying:)]) {
        [self.delegate stoppedPlaying:NO];
    }
    //DebugLog(@"Error decoding audio data : %@", error);
}

//- (void)updateTimer {
//    
//    NSDate *currentDate = [NSDate date];
//    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:newRecording.startDate];
//    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
//    NSString *timeString = [timerDate dateStringWithFormatterString:DATE_FORMATTER_STRING_FOR_TIME timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
//    newRecording.timeLabel.text = timeString;
//    newRecording.pauseTimeInterval = timeInterval;
//    
//}
//
//- (void)controlTimerForNewRecording {
//    //=============================new update with start pause==================
//    if (self.recorder.recording) {
//        newRecording.startDate = [NSDate date];
//        newRecording.startDate = [newRecording.startDate dateByAddingTimeInterval:((-1) * (newRecording.pauseTimeInterval))];
//        newRecording.stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 10.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
//    }
//    else {
//        [newRecording.stopWatchTimer invalidate];
//        newRecording.stopWatchTimer = nil;
//        [self updateTimer];
//    }
//    
//}

@end
