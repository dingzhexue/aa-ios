//
//  NSDate+DateFormatter.h
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import <Foundation/Foundation.h>

@interface NSDate (DateFormatter)

- (NSString *)dateStringWithFormatterString:(NSString *)dateFormatterString timeZone:(NSTimeZone *)timeZone;

@end
