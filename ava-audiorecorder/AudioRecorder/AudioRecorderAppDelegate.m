//
//  AudioRecorderAppDelegate.m
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//

#import "AudioRecorderAppDelegate.h"

#import "AudioRecorderViewController.h"

#import "UserDefaults.h"

#import "AFNetworkActivityIndicatorManager.h"
#import "Constants.h"
#import "Passcode.h"
#import "PDKeychain.h"
#import "AccountConnectionViewController.h"
#import "WelcomeViewController.h"



@implementation AudioRecorderAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   
    
    if (![[PDKeychain defaultKeychain]objectForKey:KEY_ENCRYPTION]) {
        NSString *encryptionPassString = [self randomStringWithLength:30];
        [[PDKeychain defaultKeychain]setObject:encryptionPassString forKey:KEY_ENCRYPTION];
    } else {
        NSLog(@"encryption string exists");
    }
    
    _currentViewController = ((UINavigationController*)self.window.rootViewController).topViewController;
    _currentViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    _currentViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
 
    
   
    
   // UIImage *img = [UIImage imageNamed:@"top_bar.png"];//resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
   //[[UINavigationBar appearance] setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:111/255.0f green:205/255.0f blue:96/255.0f alpha:1.0f]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    [[UIToolbar appearance] setBarTintColor:[UIColor colorWithRed:150/255.0f green:150/255.0f blue:150/255.0f alpha:1.0f]];
    [[UIToolbar appearance] setTintColor:[UIColor whiteColor]];
    
    [UITextField appearance].layer.cornerRadius = 3.0f;
    [UITextField appearance].layer.borderColor = [UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1.0f].CGColor;

    [UIButton appearance].layer.cornerRadius = 3.0f;

//     UserDefaults *defaults = [UserDefaults sharedUserDefaults];
//    if (!defaults.isFirstLaunch) {
//        defaults.automaticRecord = YES;
//    }
//    defaults.isFirstLaunch=YES;
//    [defaults saveUserDefaults];
    
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    return YES;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOption
{
   
    
//    //get an instance of userDefaults
//    UserDefaults *defaults = [UserDefaults sharedUserDefaults];
//    //get an instance of the launch key that started the application
//    NSString *startKey = [launchOption objectForKey:UIApplicationLaunchOptionsSourceApplicationKey];
//    //check that the launch key is valid and that it's not the first launch of the application. If both checks pass, check that lockOnLaunch setting is active and password exists and load the locked view controller.
//    if (startKey && !defaults.isFirstLaunch) {
//        defaults.automaticRecord = YES;
//        if([[UserDefaults sharedUserDefaults]isLocked] && [[[UserDefaults sharedUserDefaults] unlockPassword] length]>0)
//        {
//            NSLog(@"willFinishLaunchingWithOptions hit");
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//            LockedViewController *loginVC = (LockedViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LockIdentifier"];
//            
//            [self.currentViewController presentViewController:loginVC animated:YES completion:NULL];
//            
//        }
    //}
//    if (!defaults.isFirstLaunch) {
//        
//        
//    }
//    defaults.isFirstLaunch=YES;
//    [defaults saveUserDefaults];

    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   
    self.lockAt = time(0) + 10;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //[self enterPasscode];
    //dismiss the view controller when the application enters the background to prevent the lock screen from being displayed twice and breaking.
    //[_currentViewController dismissViewControllerAnimated:YES completion:nil];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  
}
-(void)setPasscode
{
    CustomPasscodeConfig *passCodeConfig = [[CustomPasscodeConfig alloc]init];
    
    
    passCodeConfig.navigationBarTitle = @"AVA Recorder";
    passCodeConfig.identifier = @"changePass";
    [Passcode setConfig:passCodeConfig];
    
    passCodeConfig.navigationBarBackgroundColor = [UIColor colorWithRed:0.32 green:0.75 blue:0.24 alpha:1.0];
    passCodeConfig.navigationBarTitleColor = [UIColor whiteColor];
    [Passcode setupPasscodeInViewController:_currentViewController completion:^(BOOL success, NSError *error) {
        if (success && [[NSUserDefaults standardUserDefaults]boolForKey:@"firstLaunch"]) {
            [_currentViewController dismissViewControllerAnimated:YES completion:nil];
            
        }else if (success){
            NSLog(@"passcode setup appeared");
            AccountConnectionViewController *accountConnectionVC = [_currentViewController.storyboard instantiateViewControllerWithIdentifier:@"AccountConnectionViewController"];
            accountConnectionVC.navigationItem.hidesBackButton = YES;
            [_currentViewController.navigationController pushViewController:accountConnectionVC animated:YES];
            //[self dismissViewControllerAnimated:YES completion:nil];
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstLaunch"];
            
        }else{
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
    
    
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    NSLog(@"%@", [self.navController presentedViewController]);
//    UIViewController *currentVC = [self.navController presentedViewController];

//    [[NSNotificationCenter defaultCenter]removeObserver:self];
//    
//    if(![[NSUserDefaults standardUserDefaults]boolForKey:@"firstLaunch"])
//    {
//        [self displayWelcome];
//        //[self setPasscode];
//    }
//    else{
//        [self enterPasscode];
//    }
    //[self displayLockScreen];
   
    //[self enterPasscode];
    
//    UserDefaults *defaults = [UserDefaults sharedUserDefaults];

    if (time(0) > self.lockAt) {
        [self enterPasscode];
    }
}
-(void)displayWelcome {
    WelcomeViewController *welcomeVC = [_currentViewController.storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
    welcomeVC.navigationItem.hidesBackButton = YES;
    [_currentViewController.navigationController pushViewController:welcomeVC animated:YES];
    
    
    
}
-(void)enterPasscode
{
    
    
    CustomPasscodeConfig *passCodeConfig = [[CustomPasscodeConfig alloc]init];
    
    
    passCodeConfig.navigationBarTitle = @"AVA Recorder";
    passCodeConfig.identifier = @"changePass";
    [Passcode setConfig:passCodeConfig];
    
    passCodeConfig.navigationBarBackgroundColor = [UIColor colorWithRed:0.32 green:0.75 blue:0.24 alpha:1.0];
    passCodeConfig.navigationBarTitleColor = [UIColor whiteColor];
    NSLog(@"VC %@", [UIApplication sharedApplication].keyWindow.rootViewController
);
    [Passcode showPasscodeInViewController:_currentViewController completion:^(BOOL success, NSError *error) {
        if (success && [Passcode isPasscodeSet]) {
            NSLog(@"PASSWORDS MATCH");
            [_currentViewController dismissViewControllerAnimated:YES completion:nil];
        }else{
            
            passCodeConfig.identifier = @"";
            [self setPasscode];
            //NSLog(@"ERROR:%@", error.localizedDescription);
        }
    }];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
//[self displayLockScreen];

//    if([[UserDefaults sharedUserDefaults]isLocked] && [[[UserDefaults sharedUserDefaults] unlockPassword] length]>0)
//    {
//        NSLog(@"did become active hit");
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//        LockedViewController *loginVC = (LockedViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LockIdentifier"];
//        
//        [self.currentViewController presentViewController:loginVC animated:YES completion:NULL];
//        
//    }
//    BOOL fl = [[NSUserDefaults standardUserDefaults]boolForKey:@"firstLaunch"];
//    NSLog(@"%@", fl);
    NSString *a = _recordPermissionRequested;
//    //check to see if it's the first launch of the app and, if so, display the welcome screen and passcode set flow.
    if(![[NSUserDefaults standardUserDefaults]boolForKey:@"firstLaunch"])
    {
        [self displayWelcome];
        //[self setPasscode];
    }
//    else if([_recordPermissionRequested  isEqual: @"YES"]){
//        
//    }else{
//        [self enterPasscode];
//    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

//-(void)displayLockScreen {
//    NSLog(@"Current VC %@", self.currentViewController);
//    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    
//    CustomPasscodeConfig *passCodeConfig = [[CustomPasscodeConfig alloc]init];
//    
//    
//    passCodeConfig.navigationBarTitle = @"AVA Recorder";
//    
//    [Passcode setConfig:passCodeConfig];
//    
//    passCodeConfig.navigationBarBackgroundColor = [UIColor colorWithRed:0.32 green:0.75 blue:0.24 alpha:1.0];
//    passCodeConfig.navigationBarTitleColor = [UIColor whiteColor];
//    [Passcode showPasscodeInViewController:self.currentViewController completion:^(BOOL success, NSError *error) {
//        if (success && [Passcode isPasscodeSet]) {
//            NSLog(@"PASSWORDS MATCH");
//            [self.currentViewController dismissViewControllerAnimated:YES completion:nil];
//        }
//    }];
//}
//Method to create random string for encryption/decryption password
-(NSString*)randomStringWithLength: (int)length
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for(int i=0; i<length; i++){
        [randomString appendFormat:@"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    return randomString;
}
- (NSURL *)serverURL {
    NSString *hostName = [UserDefaults sharedUserDefaults].serverHostName;
    return [[NSURL alloc] initWithString:[NSString stringWithFormat:URL_BASE, [hostName length] > 0 ? hostName: URL_DEFAULT_HOST]];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AudioRecorder" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AudioRecorder.sqlite"];
    
    NSError *error = nil;
//    _persistentStoreCoordinator = [EncryptedStore makeStore:[self managedObjectModel] passcode:@"SOME_PASSCODE"];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationLibraryDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (AudioRecorderAppDelegate *)sharedDelegate {
   return (AudioRecorderAppDelegate *) [UIApplication sharedApplication].delegate;
}




@end
