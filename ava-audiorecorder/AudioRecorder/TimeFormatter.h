//
//  TimeFormatter.h
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import <Foundation/Foundation.h>

@interface TimeFormatter : NSObject

- (id)initWithTimeInterval:(NSTimeInterval)duration;
- (id)initWithDurationString:(NSString*)durationString withFormatterString:(NSString*)formatterString;

@property (readonly) NSTimeInterval timeInterval;
@property (readonly) NSString *durationString;

@end
