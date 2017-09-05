//
//  NSDate+DateFormatter.m
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import "NSDate+DateFormatter.h"

@implementation NSDate (DateFormatter)

- (NSString *)dateStringWithFormatterString:(NSString *)dateFormatterString timeZone:(NSTimeZone *)timeZone
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormatterString];
    if(timeZone)
        [dateFormatter setTimeZone:timeZone];
    else
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *dateString = [dateFormatter stringFromDate:self];
    return dateString;
}
@end
