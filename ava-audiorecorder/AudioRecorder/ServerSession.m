//
// Created by John Akhtar on 12/18/13.
// Copyright (c) 2013 People Designs Inc. All rights reserved.
//

#import "ServerSession.h"
#import "Constants.h"
#import "AudioRecorderAppDelegate.h"


@implementation ServerSession {

}

+ (instancetype)loginSession {
    static ServerSession *sessionModel = nil;

    NSURLSessionConfiguration *configuration =
            [NSURLSessionConfiguration defaultSessionConfiguration];

    NSURL *baseURL = [AudioRecorderAppDelegate sharedDelegate].serverURL;

    sessionModel = [[self alloc] initWithBaseURL:baseURL
                            sessionConfiguration:configuration];

    sessionModel.responseSerializer = [AFHTTPResponseSerializer serializer];

    return sessionModel;
}

+ (instancetype)collectionSession {
    static ServerSession *sessionModel = nil;

    NSURLSessionConfiguration *configuration =
            [NSURLSessionConfiguration defaultSessionConfiguration];

    configuration.HTTPAdditionalHeaders = [NSDictionary dictionaryWithObject:@"XMLHttpRequest" forKey:@"X-Requested-With"];

    NSURL *baseURL = [AudioRecorderAppDelegate sharedDelegate].serverURL;

    sessionModel = [[self alloc] initWithBaseURL:baseURL
                            sessionConfiguration:configuration];


    // Accept JSON even when content type is HTML
    sessionModel.responseSerializer.acceptableContentTypes =
            [sessionModel.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    //sessionModel.responseSerializer = [AFHTTPResponseSerializer serializer];
    return sessionModel;
}

+ (instancetype)uploadSession {
    static dispatch_once_t onceQueue;
    static ServerSession *sessionModel = nil;

    NSURLSessionConfiguration *configuration =
            [NSURLSessionConfiguration defaultSessionConfiguration];
//        NSURLSessionConfiguration *configuration =
//                [NSURLSessionConfiguration backgroundSessionConfiguration:@"upload"];

    configuration.HTTPAdditionalHeaders = [NSDictionary dictionaryWithObject:@"XMLHttpRequest" forKey:@"X-Requested-With"];
    configuration.timeoutIntervalForRequest = MAXFLOAT;

    NSURL *baseURL = [AudioRecorderAppDelegate sharedDelegate].serverURL;

    sessionModel = [[self alloc] initWithBaseURL:baseURL
                            sessionConfiguration:configuration];


//        // Accept JSON even when content type is HTML
//        sessionModel.responseSerializer.acceptableContentTypes =
//                [sessionModel.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    sessionModel.responseSerializer = [AFHTTPResponseSerializer serializer];

    return sessionModel;
}

@end