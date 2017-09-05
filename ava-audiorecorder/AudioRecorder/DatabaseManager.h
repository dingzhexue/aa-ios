//
//  DatabaseManager.h
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import <Foundation/Foundation.h>
@class AudioData;

@interface DatabaseManager : NSObject

@property(nonatomic,retain)NSManagedObjectContext *context;

- (void)saveAudioData:(NSString *)fileName withDate: (NSDate *)date duration:(NSTimeInterval)audioDuration status:(BOOL)uploadStatus name:(NSString*)name;
- (void)updateFileUploadStatus: (NSString *)filename withUploadStatus: (BOOL)status nameOnServer: (NSString *)nameOnServer uploadedDate: (NSDate *)uploadDate;
- (void)updateFilename:(NSString *)oldname withNewName: (NSString *)newName;
- (void)deleteFileFromDatabase:(NSString *)filename;
- (void)deleteAllFilesFromDatabase;
- (AudioData *)fetchAudioDescription:(NSString *)filename;
- (NSArray *)fetchAudioDetailsFromDatabase;
- (NSArray *)fetchAudioNameFromDatabase;


@end
