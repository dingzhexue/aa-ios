//
//  CustomPasscodeConfig.m
//  AVA Recorder
//
//  Created by Tristan Freeman on 8/29/16.
//  Copyright © 2016 People Designs Inc. All rights reserved.
//

#import "CustomPasscodeConfig.h"

@implementation CustomPasscodeConfig

- (instancetype)init {
    if (self = [super init]) {
        self.identifier = @"";
        self.animationsEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.navigationBarBackgroundColor = nil;
        self.navigationBarForegroundColor = nil;
        self.statusBarStyle = UIStatusBarStyleDefault;
        self.fieldColor = [UIColor grayColor];
        self.emptyFieldColor = [UIColor grayColor];
        self.errorBackgroundColor = [UIColor colorWithRed:0.63 green:0.00 blue:0.00 alpha:1.00];
        self.errorForegroundColor = [UIColor whiteColor];
        self.descriptionColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        self.inputKeyboardAppearance = UIKeyboardAppearanceDefault;
        self.titleFont = [UIFont systemFontOfSize:20];
        self.errorFont = [UIFont systemFontOfSize:14];
        self.iPad_errorFont = [UIFont systemFontOfSize:20];
        self.instructionsFont = [UIFont systemFontOfSize:16];
        self.iPad_instructionsFont = [UIFont systemFontOfSize:22];
        self.navigationBarTitle = @"";
        self.navigationBarFont = [UIFont systemFontOfSize:16];
        self.navigationBarTitleColor = [UIColor darkTextColor];
    }
    return self;
}

@end
