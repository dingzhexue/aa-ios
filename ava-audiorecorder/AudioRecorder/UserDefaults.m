//
//  UserDefaults.m
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import "UserDefaults.h"
#import "Constants.h"
#import "DataCryptor.h"


@implementation UserDefaults

+ (UserDefaults *)sharedUserDefaults
{
    static dispatch_once_t pred = 0;
    __strong static id sharedUserDefaults = nil;
    dispatch_once(&pred, ^{
        sharedUserDefaults = [[self alloc]init];
    });
    return sharedUserDefaults;
}
-(id)init
{
    self = [super init];
    if(self)
    {
        [self readUserDefaults];

    }
    return self;
}
- (void)saveUserDefaults
{

//    [[NSUserDefaults standardUserDefaults] setObject:[self encryptUserDefaultValue:self.unlockPassword]forKey:KEY_UNLOCK_PASSWORD ];
    [[NSUserDefaults standardUserDefaults] setBool:self.automaticUpload forKey:KEY_AUTOMATIC_UPLOAD ];
    [[NSUserDefaults standardUserDefaults] setBool:self.automaticRecord forKey:KEY_AUTOMATIC_RECORDING ];
    [[NSUserDefaults standardUserDefaults] setBool:self.isLocked forKey:KEY_LOCK_ON_LAUNCH ];
    [[NSUserDefaults standardUserDefaults] setBool:self.isNewAudioFileCreated forKey:KEY_NEW_AUDIOFILE_CREATED ];
    [[NSUserDefaults standardUserDefaults] setObject:self.token forKey:KEY_TOKEN];
    [[NSUserDefaults standardUserDefaults] setObject:[self encryptUserDefaultValue:self.signInUserName] forKey:KEY_USER_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:[self encryptUserDefaultValue:self.signInPassword] forKey:KEY_USER_LOGIN_PASSWORD];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastLoginDate forKey:KEY_LAST_LOGIN_DATE];
    [[NSUserDefaults standardUserDefaults] setObject:self.serverHostName forKey:KEY_SERVER_HOST];
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedCollection forKey:KEY_SELECTED_COLLECTION];
	[[NSUserDefaults standardUserDefaults] synchronize];

}
- (void)readUserDefaults
{
//    self.unlockPassword = [self decryptUserDefaultValue:[[NSUserDefaults standardUserDefaults] stringForKey:KEY_UNLOCK_PASSWORD]];
    self.automaticUpload = [[NSUserDefaults standardUserDefaults] boolForKey:KEY_AUTOMATIC_UPLOAD];
    self.automaticRecord = [[NSUserDefaults standardUserDefaults] boolForKey:KEY_AUTOMATIC_RECORDING];
    self.isLocked = [[NSUserDefaults standardUserDefaults] boolForKey:KEY_LOCK_ON_LAUNCH];
    self.token = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_TOKEN];
    self.signInUserName = [self decryptUserDefaultValue:[[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_NAME]];
    self.signInPassword = [self decryptUserDefaultValue:[[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_LOGIN_PASSWORD]];
    self.lastLoginDate = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_LAST_LOGIN_DATE];
    self.serverHostName = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_SERVER_HOST];
    self.isNewAudioFileCreated = [[NSUserDefaults standardUserDefaults] boolForKey:KEY_NEW_AUDIOFILE_CREATED];
    self.selectedCollection = [[NSUserDefaults standardUserDefaults]objectForKey:KEY_SELECTED_COLLECTION];

}
- (NSString *)encryptUserDefaultValue:(NSString *)dataString
{
    DataCryptor *cryptor = [[DataCryptor alloc]init];
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    return  [cryptor encryptAndEncodeDataWithAES256Settings:data error:&error];
}
- (NSString *)decryptUserDefaultValue:(NSString *)dataString
{
    DataCryptor *cryptor = [[DataCryptor alloc]init];
    NSError *error = nil;
    NSData *decryptedData = [cryptor decodeAndDecryptStringWithAES256Settings:dataString error:&error];

    return [[NSString alloc] initWithData:decryptedData encoding:NSASCIIStringEncoding];
}

@end
