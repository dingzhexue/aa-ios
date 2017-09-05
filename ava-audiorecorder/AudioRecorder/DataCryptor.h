//
//  DataCryptor.h
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import <Foundation/Foundation.h>

@interface DataCryptor : NSObject

@property(strong,nonatomic) NSString *cryptorSettings;
@property(strong,nonatomic) NSString *cryptorPassword;

- (NSString *)encryptAndEncodeDataWithAES256Settings :(NSData *)data error:(NSError **)anError;
- (NSData *)decodeAndDecryptStringWithAES256Settings : (NSString *)string error:(NSError **)anError;
- (NSData *)encryptDataWithAES256Settings :(NSData *)data error:(NSError **)anError;
- (NSString *)base64EncodeData :(NSData *)encryptedData;
- (NSData *)decryptDataWithAES256Settings :(NSData *)decodedData error:(NSError **)anError;
- (NSData *)base64DecodeData :(NSString *)string;

@end
