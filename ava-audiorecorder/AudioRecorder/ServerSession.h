//
// Created by John Akhtar on 12/18/13.
// Copyright (c) 2013 People Designs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"


@interface ServerSession : AFHTTPSessionManager

+(instancetype)loginSession;
+(instancetype)collectionSession;
+ (instancetype)uploadSession;
@end