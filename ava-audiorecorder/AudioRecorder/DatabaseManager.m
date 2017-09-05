//
//  DatabaseManager.m
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import "DatabaseManager.h"
#import "Recorder.h"
#import "AudioRecorderAppDelegate.h"
#import "AudioData.h"
@implementation DatabaseManager

@synthesize context;

- (id)init
{
    self =[super init];
    if(self)
    {
        AudioRecorderAppDelegate *appDelegate=[AudioRecorderAppDelegate sharedDelegate];
        self.context = [appDelegate managedObjectContext];
    }
    return self;
}

- (void)saveAudioData:(NSString *)fileName withDate: (NSDate *)createdDate duration:(NSTimeInterval)audioDuration status:(BOOL)uploadStatus name:(NSString*)name
{
    static NSLock *saveDataLock;
    if(!saveDataLock)
    {
        saveDataLock = [[NSLock alloc]init];
    }
    [saveDataLock lock];
    
    @try
    {
        // Save the audio details in DB
        Recorder *newRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Recorder" inManagedObjectContext:self.context];
        [newRecord setValue:fileName forKey:@"filename"];
        [newRecord setValue:createdDate forKey:@"createdDate"];
        [newRecord setValue:[NSNumber numberWithDouble:audioDuration] forKey:@"audioDuration"];
        [newRecord setValue:[NSNumber numberWithBool:uploadStatus] forKey:@"uploadStatus"];
        [newRecord setValue:name forKey:@"name"];
        
        NSError *error = nil;
        [self.context save:&error];
        if(![self.context save:&error])
        {
            NSLog(@"Coredata Data Insertion Error= %@",[error localizedDescription]);
        }
        newRecord=nil;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error while saving data %@",exception);
    }
    @finally
    {
        [saveDataLock unlock];
    }
}

- (void)updateFileUploadStatus: (NSString *)filename withUploadStatus: (BOOL)status nameOnServer: (NSString *)nameOnServer uploadedDate: (NSDate *)uploadDate
{
    // Update the upload status, name on server and uploaded date
    NSError *error = nil;
    Recorder * record = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Recorder" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"filename=%@",filename]];
    
    record = [[context executeFetchRequest:request error:&error] lastObject];
    //Update the object
    record.uploadStatus = [NSNumber numberWithBool:status];
    record.uploadedDate = uploadDate;
    record.nameOnServer = nameOnServer;
    //Save it
    error = nil;
    if (![context save:&error]) {
        NSLog(@"  %@", [error localizedDescription]);
        return;
    }
}
- (void)updateFilename:(NSString *)oldname withNewName: (NSString *)newName
{
    NSError *error = nil;
    Recorder * record = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Recorder" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@",oldname]];
    
    record = [[context executeFetchRequest:request error:&error] lastObject];
    //Update the object
    record.name = newName;
    //Save it
    error = nil;
    if (![context save:&error]) {
        NSLog(@"  %@", [error localizedDescription]);
        return;
    }
 
}

- (void)deleteFileFromDatabase:(NSString *)filename
{
    // Delete the specified file
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Recorder" inManagedObjectContext:context];
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:entity];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"filename == %@",filename];
    [fetch setPredicate:predicate];
    NSError *fetchError;
    Recorder *record = nil;
    record =  [[context executeFetchRequest:fetch error:&fetchError]lastObject];
    [context deleteObject:record];
    NSError *error;
    [self.context save:&error];
    if(error)
    {
        NSLog(@"Error = %@",[error localizedDescription]);
        return;
    }
 
}
- (void)deleteAllFilesFromDatabase
{
    // Delete all the audio files in DB
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Recorder" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    [request setIncludesPropertyValues:NO];
    NSError * error = nil;
    NSArray * objects = [context executeFetchRequest:request error:&error];
    if ([objects count] > 0)
    {
        for (NSManagedObject * obj in objects)
        {
            [context deleteObject:obj];
        }
    }
    NSError *saveError = nil;
    [context save:&saveError];
    if(error)
    {
        NSLog(@"Error = %@",[error localizedDescription]);
        return;
    }
}
- (AudioData *)fetchAudioDescription:(NSString *)filename
{
    // fetch the audio details of the specified file
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Recorder" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"filename == %@",filename];
    [request setPredicate:predicate];
    
    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    AudioData *audioData = [[AudioData alloc] init];
    if ([objects count] == 0) {
        return  nil;
    }
    else
    {
        matches = [objects objectAtIndex:0];
        audioData.fileName = [matches valueForKey:@"filename"];
        audioData.audioDuration = [[matches valueForKey:@"audioDuration"]doubleValue];
        audioData.createdDate = [matches valueForKey:@"createdDate"];
        audioData.uploadStatus = [[matches valueForKey:@"uploadStatus"]boolValue];
        audioData.uploadedDate = [matches valueForKey:@"uploadedDate"];
        audioData.nameOnServer = [matches valueForKey:@"nameOnServer"];
        audioData.name = [matches valueForKey:@"name"];
    }
    return audioData;

}

- (NSArray *)fetchAudioDetailsFromDatabase
{
    // fetch the details of all audio files in database
    int dataCount =0;
    NSMutableArray *listFromDatabase = [[NSMutableArray alloc]init];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Recorder" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"createdDate"
                                        ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if ([objects count] == 0) {
        return  nil;
    }
    else {
        
        while (dataCount< [objects count])
        {
            AudioData *audioData = [[AudioData alloc] init];
            matches = [objects objectAtIndex:dataCount];
            audioData.fileName = [matches valueForKey:@"filename"];
            audioData.audioDuration = [[matches valueForKey:@"audioDuration"]doubleValue];
            audioData.createdDate = [matches valueForKey:@"createdDate"];
            audioData.uploadStatus = [[matches valueForKey:@"uploadStatus"]boolValue];
            audioData.uploadedDate = [matches valueForKey:@"uploadedDate"];
            audioData.nameOnServer = [matches valueForKey:@"nameOnServer"];
            audioData.name = [matches valueForKey:@"name"];
            [listFromDatabase addObject:audioData];
            dataCount++;
        }
    }
    return listFromDatabase;
}

#pragma mark - Filename Methods
- (NSArray *)fetchAudioNameFromDatabase
{
    // fetch the details of all audio files in database
    int dataCount =0;
    NSMutableArray *listFromDatabase = [[NSMutableArray alloc]init];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Name" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name"
                                        ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if ([objects count] == 0) {
        return  nil;
    }
    else {
        
        while (dataCount< [objects count])
        {
           matches = [objects objectAtIndex:dataCount];
            NSString *name = [matches valueForKey:@"name"];
            [listFromDatabase addObject:name];
            dataCount++;
        }
    }
    return listFromDatabase;
}

@end
