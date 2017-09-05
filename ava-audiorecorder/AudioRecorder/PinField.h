//
//  PinField.h
//  AVA Recorder
//
//  Created by Tristan Freeman on 8/29/16.
//  Copyright © 2016 People Designs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomPasscodeConfig;

@interface PinField : UIView

@property (nonatomic, strong, readonly)UIView *emptyIndicator;
@property (nonatomic, strong, readonly)UIView *filledIndicator;
@property (nonatomic, strong)NSString *text;

-(id)initWithFrame:(CGRect)frame config:(CustomPasscodeConfig*)config;

@end
