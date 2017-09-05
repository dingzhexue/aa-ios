//
//  PDKeychain.h
//  AVA Recorder
//
//  Created by Tristan Freeman on 8/29/16.
//  Copyright © 2016 People Designs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"


#ifndef PDKeychain_USE_NSCODING
#if TARGET_OS_IPHONE
#define PDKeychain_USE_NSCODING 1
#else
#define PDKeychain_USE_NSCODING 0
#endif
#endif


typedef NS_ENUM(NSInteger, PDKeychainAccess)
{
    PDKeychainAccessibleWhenUnlocked = 0,
    PDKeychainAccessibleAfterFirstUnlock,
    PDKeychainAccessibleAlways,
    PDKeychainAccessibleWhenUnlockedThisDeviceOnly,
    PDKeychainAccessibleAfterFirstUnlockThisDeviceOnly,
    PDKeychainAccessibleAlwaysThisDeviceOnly
};
@interface PDKeychain : NSObject

+ (instancetype)defaultKeychain;

@property (nonatomic, readonly) NSString *service;
@property (nonatomic, readonly) NSString *accessGroup;
@property (nonatomic, assign) PDKeychainAccess accessibility;

- (id)initWithService:(NSString *)service
          accessGroup:(NSString *)accessGroup
        accessibility:(PDKeychainAccess)accessibility;

- (id)initWithService:(NSString *)service
          accessGroup:(NSString *)accessGroup;

- (BOOL)setObject:(id)object forKey:(id)key;
- (BOOL)setObject:(id)object forKeyedSubscript:(id)key;
- (BOOL)removeObjectForKey:(id)key;
- (id)objectForKey:(id)key;
- (id)objectForKeyedSubscript:(id)key;

@end
