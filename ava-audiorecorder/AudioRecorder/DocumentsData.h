//
//  DocumentsData.h
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface DocumentsData : NSObject

@property(readonly) NSString *recordingsDirectory;

- (BOOL)deleteRecordingFileWithName:(NSString*)fileName;
- (void)deleteAllFiles;
- (NSString *)getFilePathFromDocumentsFolder:(NSString *)filename;
- (void)renameFileInDocumentsFolder:(NSString *)oldFilename withNewName:(NSString *)newFilename;
- (BOOL)isFileAlreadyExists:(NSString *)filename;
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)path;

@end
