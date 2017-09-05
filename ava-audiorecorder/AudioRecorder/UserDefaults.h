//
//  UserDefaults.h
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface UserDefaults : NSObject

@property BOOL isLocked;
@property BOOL automaticUpload;
@property BOOL automaticRecord;
@property (nonatomic, retain)NSString *token;
@property (nonatomic, retain)NSString *signInUserName;
@property (nonatomic, retain)NSString *signInPassword;
@property (nonatomic, retain)NSString *unlockPassword;
@property (nonatomic, retain)NSString *selectedCollection;
@property BOOL isNewAudioFileCreated;
@property BOOL isFirstLaunch;
@property (nonatomic, retain)NSDate *lastLoginDate;
@property (nonatomic, retain)NSString *serverHostName;
@property BOOL credentialsSaved;

+ (UserDefaults *)sharedUserDefaults;
- (void)saveUserDefaults;
- (void)readUserDefaults;
- (NSString *)encryptUserDefaultValue:(NSString *)dataString;
- (NSString *)decryptUserDefaultValue:(NSString *)dataString;

@end
