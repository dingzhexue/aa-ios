//
//  AudioRecorderAppDelegate.h
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AudioRecorderViewController;

@interface AudioRecorderAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *currentViewController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, nonatomic) NSURL *serverURL;
@property(nonatomic) time_t lockAt;
@property  (nonatomic)UINavigationController *navController;
@property (nonatomic)NSString *recordPermissionRequested;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationLibraryDirectory;

+(AudioRecorderAppDelegate *)sharedDelegate;

@end
