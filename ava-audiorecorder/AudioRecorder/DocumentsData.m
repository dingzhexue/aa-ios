//
//  DocumentsData.m
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import "DocumentsData.h"
#import "AudioRecorderAppDelegate.h"
#import "Constants.h"
#import <sys/xattr.h>

@implementation DocumentsData

- (id)init
{
    self = [super init];
    if(self)
    {
        AudioRecorderAppDelegate *appDelegate=[AudioRecorderAppDelegate sharedDelegate];
        _recordingsDirectory = [[[appDelegate applicationLibraryDirectory] path] stringByAppendingPathComponent:@"Recordings"];
        
        NSFileManager *fileManager=[NSFileManager defaultManager];
        BOOL isDirectory;
        
        if(![fileManager fileExistsAtPath:_recordingsDirectory isDirectory:&isDirectory])
        {
            NSError *error=nil;
            [fileManager createDirectoryAtPath:_recordingsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
            if(error)
            {
                NSLog(@"Error creating Recordings directory :%@",error);
                return nil;
            }
        }
        else if(!isDirectory)
        {
            NSLog(@"Error creating Recordings directory :A file named 'Recordings' exists in the app's documents directory");
            return nil;
        }
        BOOL setBackUpAttribute = [self addSkipBackupAttributeToItemAtURL:[[appDelegate applicationDocumentsDirectory]path]];
        if(!setBackUpAttribute)
        {
            NSLog(@"Could not set the backup attribute for iOS version below 5.0.1");
        }
    }
    
    return self;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)path
{
    if (SYSTEM_VERSION_LESS_THAN(CONSTANT_VERSION_5_0_1))
    {
        return NO;
    }
    else
    {
        if(SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(CONSTANT_VERSION_5_0_1)) {
            const char* filePath = [path fileSystemRepresentation];
            const char* attrName = ATTRIBUTE_BACKUP;
            u_int8_t attrValue = 1;
            int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
            return result;
        }
        else {
            NSURL *URL = [NSURL fileURLWithPath:path];
            //assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
            if([[NSFileManager defaultManager] fileExistsAtPath: [URL path]])
            {
                NSError *error = nil;
                BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                              forKey: NSURLIsExcludedFromBackupKey error: &error];
                if(!success){
                    NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
                }
                return success;
            }
            else
            {
                return NO;
            }
            
        }
    }
}
- (BOOL)deleteRecordingFileWithName:(NSString*)fileName
{
    // remove the file from documents folder
    NSError *error = nil;
    NSString *pathToDelete = [_recordingsDirectory stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] removeItemAtPath: pathToDelete error: &error];
    if(error)
    {
        return -1;
    }
    return YES;
}
-(void)deleteAllFiles
{
    // Path to the Documents directory

        NSError *error = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // Print out the path to verify we are in the right place
        // For each file in the directory, create full path and delete the file
    NSArray *directoryListing=[fileManager contentsOfDirectoryAtPath:_recordingsDirectory error:&error];
        for (NSString *file in directoryListing)
        {
            NSString *filePath = [_recordingsDirectory stringByAppendingPathComponent:file];
            BOOL fileDeleted = [fileManager removeItemAtPath:filePath error:&error];
            
            if (fileDeleted != YES || error != nil)
            {
                // Deal with the error...
            }
        }
        
//    }
}
-(NSString *)getFilePathFromDocumentsFolder:(NSString *)filename
{
    NSString *filePath = [_recordingsDirectory stringByAppendingPathComponent:filename];
    return filePath;
}
- (void)renameFileInDocumentsFolder:(NSString *)oldFilename withNewName:(NSString *)newFilename
{
    // Rename the file in documents folder with newname
    NSError *error = nil;
    NSString *oldPath = [self getFilePathFromDocumentsFolder:oldFilename];
    
    NSString *newPath = [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFilename];
    //[[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];
    [[NSFileManager defaultManager]createFileAtPath:newPath contents:[newPath dataUsingEncoding:NSUTF8StringEncoding] attributes:[NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey]];
   
//    NSData *newData = [[NSData alloc]initWithContentsOfFile:oldPath options:NSDataWritingAtomic error:&error];
//    [newData writeToFile:newPath options:NSDataWritingAtomic error:&error];
   
    //[newData writeToFile:newPath options:NSDataWritingAtomic error:&error];
}
- (BOOL)isFileAlreadyExists:(NSString *)filename
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *writablePath = [_recordingsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",filename]];
    if([fileManager fileExistsAtPath:writablePath])
    {
        return YES;
    }
    return NO;
}
@end
