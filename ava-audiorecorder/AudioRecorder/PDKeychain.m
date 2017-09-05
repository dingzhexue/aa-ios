//
//  PDKeychain.m
//  AVA Recorder
//
//  Created by Tristan Freeman on 8/29/16.
//  Copyright © 2016 People Designs Inc. All rights reserved.
//

#import "PDKeychain.h"
#import <Availability.h>

@implementation NSObject (PDKeychainPropertyListCoding)

- (id)PDKeychain_propertyListRepresentation
{
    return self;
}

@end

#if !PDKeychain_USE_NSCODING

@implementation NSNull (PDKeychainPropertyListCoding)

- (id)PDKeychain_propertyListRepresentation
{
    return nil;
}

@end


@implementation NSArray (BMPropertyListCoding)

- (id)PDKeychain_propertyListRepresentation
{
    NSMutableArray *copy = [NSMutableArray arrayWithCapacity:[self count]];
    for (id obj in self)
    {
        id value = [obj PDKeychain_propertyListRepresentation];
        if (value) [copy addObject:value];
    }
    return copy;
}

@end

@implementation NSDictionary (BMPropertyListCoding)

- (id)PDKeychain_propertyListRepresentation
{
    NSMutableDictionary *copy = [NSMutableDictionary dictionaryWithCapacity:[self count]];
    [self enumerateKeysAndObjectsUsingBlock:^(__unsafe_unretained id key, __unsafe_unretained id obj, __unused BOOL *stop) {
        
        id value = [obj PDKeychain_propertyListRepresentation];
        if (value) copy[key] = value;
    }];
    return copy;
}

@end

#endif
@implementation PDKeychain
+ (instancetype)defaultKeychain
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *bundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
        sharedInstance = [[PDKeychain alloc] initWithService:bundleID
                                                 accessGroup:nil];
    });
    
    return sharedInstance;
}

- (id)init
{
    return [self initWithService:nil accessGroup:nil];
}

- (id)initWithService:(NSString *)service
          accessGroup:(NSString *)accessGroup
{
    return [self initWithService:service
                     accessGroup:accessGroup
                   accessibility:PDKeychainAccessibleWhenUnlocked];
}

- (id)initWithService:(NSString *)service
          accessGroup:(NSString *)accessGroup
        accessibility:(PDKeychainAccess)accessibility
{
    if ((self = [super init]))
    {
        _service = [service copy];
        _accessGroup = [accessGroup copy];
        _accessibility = accessibility;
    }
    return self;
}
- (NSData *)dataForKey:(id)key
{
    //generate query
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    if ([self.service length]) query[(__bridge NSString *)kSecAttrService] = self.service;
    query[(__bridge NSString *)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge NSString *)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    query[(__bridge NSString *)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    query[(__bridge NSString *)kSecAttrAccount] = [key description];
    
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    
    if ([_accessGroup length]) query[(__bridge NSString *)kSecAttrAccessGroup] = _accessGroup;
    
#endif
    
    //recover data
    CFDataRef data = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&data);
    if (status != errSecSuccess && status != errSecItemNotFound)
    {
        NSLog(@"PDKeychain failed to retrieve data for key '%@', error: %ld", key, (long)status);
    }
    return CFBridgingRelease(data);
}

- (BOOL)setObject:(id)object forKey:(id)key
{
    NSParameterAssert(key);
    
    //generate query
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    if ([self.service length]) query[(__bridge NSString *)kSecAttrService] = self.service;
    query[(__bridge NSString *)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge NSString *)kSecAttrAccount] = [key description];
    
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    
    if ([_accessGroup length]) query[(__bridge NSString *)kSecAttrAccessGroup] = _accessGroup;
    
#endif
    //encode object
    NSData *data = nil;
    NSError *error = nil;
    if ([(id)object isKindOfClass:[NSString class]])
    {
        //check that string data does not represent a binary plist
        NSPropertyListFormat format = NSPropertyListBinaryFormat_v1_0;
        if (![object hasPrefix:@"bplist"] || ![NSPropertyListSerialization propertyListWithData:[object dataUsingEncoding:NSUTF8StringEncoding]
                                                                                        options:NSPropertyListImmutable
                                                                                         format:&format
                                                                                          error:NULL])
        {
            //safe to encode as a string
            data = [object dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    
    //if not encoded as a string, encode as plist
    if (object && !data)
    {
        data = [NSPropertyListSerialization dataWithPropertyList:[object PDKeychain_propertyListRepresentation]
                                                          format:NSPropertyListBinaryFormat_v1_0
                                                         options:0
                                                           error:&error];
#if PDKeychain_USE_NSCODING
        
        //property list encoding failed. try NSCoding
        if (!data)
        {
            data = [NSKeyedArchiver archivedDataWithRootObject:object];
        }
        
#endif
        
    }
    
    //fail if object is invalid
    NSAssert(!object || (object && data), @"PDKeychain failed to encode object for key '%@', error: %@", key, error);
    
    if (data)
    {
        //update values
        NSMutableDictionary *update = [@{(__bridge NSString *)kSecValueData: data} mutableCopy];
        
#if TARGET_OS_IPHONE || __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_9
        
        update[(__bridge NSString *)kSecAttrAccessible] = @[(__bridge id)kSecAttrAccessibleWhenUnlocked,
                                                            (__bridge id)kSecAttrAccessibleAfterFirstUnlock,
                                                            (__bridge id)kSecAttrAccessibleAlways,
                                                            (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                            (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
                                                            (__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly][self.accessibility];
#endif
        
        //write data
        OSStatus status = errSecSuccess;
        if ([self dataForKey:key])
        {
            //there's already existing data for this key, update it
            status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)update);
        }
        else
        {
            //no existing data, add a new item
            [query addEntriesFromDictionary:update];
            status = SecItemAdd ((__bridge CFDictionaryRef)query, NULL);
        }
        if (status != errSecSuccess)
        {
            NSLog(@"PDKeychain failed to store data for key '%@', error: %ld", key, (long)status);
            return NO;
        }
    }
    else if (self[key])
    {
        //delete existing data
        
#if TARGET_OS_IPHONE
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
#else
        CFTypeRef result = NULL;
        query[(__bridge id)kSecReturnRef] = (__bridge id)kCFBooleanTrue;
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
        if (status == errSecSuccess)
        {
            status = SecKeychainItemDelete((SecKeychainItemRef) result);
            CFRelease(result);
        }
#endif
        if (status != errSecSuccess)
        {
            NSLog(@"PDKeychain failed to delete data for key '%@', error: %ld", key, (long)status);
            return NO;
        }
    }
    return YES;
}

- (BOOL)setObject:(id)object forKeyedSubscript:(id)key
{
    return [self setObject:object forKey:key];
}

- (BOOL)removeObjectForKey:(id)key
{
    return [self setObject:nil forKey:key];
}
- (id)objectForKey:(id)key
{
    NSData *data = [self dataForKey:key];
    if (data)
    {
        id object = nil;
        NSError *error = nil;
        NSPropertyListFormat format = NSPropertyListBinaryFormat_v1_0;
        
        //check if data is a binary plist
        if ([data length] >= 6 && !strncmp("bplist", data.bytes, 6))
        {
            //attempt to decode as a plist
            object = [NSPropertyListSerialization propertyListWithData:data
                                                               options:NSPropertyListImmutable
                                                                format:&format
                                                                 error:&error];
            
            if ([object respondsToSelector:@selector(objectForKey:)] && object[@"$archiver"])
            {
                //data represents an NSCoded archive
                
#if PDKeychain_USE_NSCODING
                
                //parse as archive
                object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
#else
                //don't trust it
                object = nil;
#endif
                
            }
        }
        if (!object || format != NSPropertyListBinaryFormat_v1_0)
        {
            //may be a string
            object = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        if (!object)
        {
            NSLog(@"PDKeychain failed to decode data for key '%@', error: %@", key, error);
        }
        return object;
    }
    else
    {
        //no value found
        return nil;
    }
}

- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}
@end
