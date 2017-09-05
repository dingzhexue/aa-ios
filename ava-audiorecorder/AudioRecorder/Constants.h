//
//  Constants.h
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#ifndef AudioRecorder_Constants_h
#define AudioRecorder_Constants_h

#define MSG_SET_PASSWORD_ALERT @"You must set an unlock code before you can use the lock function."
#define MSG_ENTER_NAME @"Enter a name for this recording."
#define MSG_NAME_EXISTS @"Name already in use. Choose another name."
#define MSG_DELETE_ALL @"Delete ALL recordings?"
#define MSG_DELETE_SELECTED @"Delete Selected recordings?"
#define MSG_DELETE_PERMANENTLY @"This will permanently delete all recordings. Are you sure?"
#define MSG_ENTER_SERVER_FILENAME @"Enter a name for this recording on the server."
#define MSG_SELECT_COLLECTION @"Select a collection to upload to."
#define MSG_ENTER_LOGIN_DETAILS @"Enter the user name and password for an AVA account."
#define MSG_ALREADY_UPLOADED @"Already uploaded. \n Upload again?"
#define MSG_CANCEL_RECORDING @"Cancel Recording?"
#define MSG_CANCEL_UPLOAD @"Cancel uploading?"
#define MSG_DELETE_FILE @"%@ has not been uploaded. Still delete?"
#define MSG_REQUIRED_PASSWORD @"Password required"
#define MSG_REQUIRED_PASSWORD_CONFIRM @"The entered passcodes do not match."
#define MSG_NO_COLLECTION @"No Collections found."
// Settings NSUserDefaults Key
#define KEY_LOCK_ON_LAUNCH @"RequirePasswordAtLaunch"
#define KEY_AUTOMATIC_RECORDING @"RequireAutomaticRecording"
#define KEY_AUTOMATIC_UPLOAD @"RequireAutomaticUpload"
#define KEY_UNLOCK_PASSWORD @"UnlockPassword"
#define KEY_TOKEN @"ReceivedTokenFromServer"
#define KEY_USER_NAME @"UsernameForServerLogin"
#define KEY_USER_LOGIN_PASSWORD @"UserLoginPassword"
#define KEY_NEW_AUDIOFILE_CREATED @"NewAudioFileCreated"
#define KEY_CREDENTIALS_SAVED @"CredentialsSaved"
#define KEY_LAST_LOGIN_DATE @"LastLoginDate"
#define KEY_SERVER_HOST @"ServerHostName"
#define KEY_SELECTED_COLLECTION @"SelectedCollection"
#define KEY_ENCRYPTION @"encryptionPassword"

// Server Connection URLs
//http://dev.cabotprojects.com/AudioRecorder/
#define URL_SESSION_ID @"ARSession"
#define URL_BASE @"https://%@/"
#define URL_DEFAULT_HOST @"avanalyze.com"
#define URL_LOGIN @"auth/login_by_post"
#define URL_UPLOAD @"collections/%@/upload_file"
#define URL_COLLECTION_REQUEST @"collections/get_collections_by_post"

#define CRYPTO_SECRET_KEY @"12345678901234561234567890123456"


#define BUTTON_DELETE_ALL @"Delete All"
#define BUTTON_DELETE @"Delete"
#define BUTTON_SETTINGS @"Settings"


// About URL
#define URL_ABOUT @"https://avanalyze.com/about"

// BackUp Attribute
#define ATTRIBUTE_BACKUP "com.apple.MobileBackup"

// Server Response Login status
#define STATUS_SUCCESS @"success"
#define STATUS_USER_NOT_FOUND 20
#define STATUS_INCORRECT_PASSWORD 21
#define STATUS_DELETED_USER 22
#define STATUS_OTHER_FAILURE 100
#define STATUS_CONNECTION_FAILED @"Connection Failed"

// Constants used for audio playback slider time update
#define CONSTANT_VALUE_THIRTY 30
#define CONSTANT_TWENTYFOUR_HOURS_IN_SECONDS 86400
#define CONSTANT_HOUR_IN_SECONDS 3600 
#define CONSTANT_MINUTE_IN_SECONDS 60
#define CONSTANT_VALUE_TEN 10
#define CONSTANT_VERSION_5_0_1 @"5.0.1"
#define CONSTANT_VALUE_400 400

// Checking device iOS version
#define SYSTEM_VERSION_LESS_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

// Index constants
#define INDEX_ZERO 0
#define INDEX_ONE 1
#define INDEX_TWO 2

// Date formatter string
#define DATE_FORMATTER_STRING_PLAYBACK @"MM/dd/yyy hh:mm a"
#define DATE_FORMATTER_STRING_RECORDINGS_LIST @"MM/dd/yyyy"
#define DATE_FORMATTER_STRING_FOR_FILENAME @"yyyy-MM-dd_hh-mm-ss"
#define DATE_FORMATTER_STRING_FOR_TIME @"HH:mm:ss"
//New Recording
#define STATUS_RECORDING @"Recording"
#define STATUS_PAUSED @"Paused"

#endif
