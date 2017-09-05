//
//  TimeFormatter.m
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import "TimeFormatter.h"

@implementation TimeFormatter

- (id)initWithTimeInterval:(NSTimeInterval)duration
{
    self = [super init];
    if(self)
    {
        _timeInterval = duration;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_timeInterval];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        _durationString = [dateFormatter stringFromDate:date];

    }
    return self;
}
- (id)initWithDurationString:(NSString*)durationString withFormatterString:(NSString*)formatterString
{
    self = [super init];
    if(self)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:formatterString];
        NSDate *dateFromString = [[NSDate alloc] init];
        dateFromString = [dateFormatter dateFromString:durationString];
        _durationString = [dateFormatter stringFromDate:dateFromString];
    }
    return self;
}


@end
