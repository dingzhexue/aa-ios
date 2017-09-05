//
//  DataCryptor.m
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import "DataCryptor.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"
#import "Base64.h"
#import "Constants.h"
#import "PDKeychain.h"

@implementation DataCryptor
- (id)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}
- (NSData *)encryptDataWithAES256Settings :(NSData *)data error:(NSError **)anError
{
    // Encrypt data with AES256Settings
    NSError *error = nil;
    
    NSData *encryptedData = [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:[[PDKeychain defaultKeychain]objectForKey:KEY_ENCRYPTION] error:&error];
    if(error)
    {
        NSLog(@"Error occured on encryption = %@",[error localizedDescription]);
        
        return nil;
    }
    else
        return encryptedData;
}
- (NSString *)base64EncodeData :(NSData *)encryptedData 
{
    // base64 encode the encrypted data
    return [encryptedData base64EncodedString];
}
- (NSData *)decryptDataWithAES256Settings :(NSData *)decodedData error:(NSError **)anError
{
    NSError *error=nil;
    NSData *decryptedData = [RNDecryptor decryptData:decodedData withPassword:[[PDKeychain defaultKeychain]objectForKey:KEY_ENCRYPTION] error:&error];
    if(error)
    {
        NSLog(@"Error occured on decryption = %@",[error localizedDescription]);
        *anError = error;
        return nil;
    }
    else
        return decryptedData;
}
- (NSData *)base64DecodeData :(NSString *)string
{
    return [string base64DecodedData];
}
- (NSString *)encryptAndEncodeDataWithAES256Settings :(NSData *)data error:(NSError **)anError
{
    NSData *encryptedData=[self encryptDataWithAES256Settings:data error:anError];
    NSString *str = [self base64EncodeData:encryptedData];
    return str;
    
}
- (NSData *)decodeAndDecryptStringWithAES256Settings : (NSString *)string error:(NSError **)anError
{
    NSData *decodedData=[self base64DecodeData:string];
    return [self decryptDataWithAES256Settings:decodedData error:anError];
}
@end
