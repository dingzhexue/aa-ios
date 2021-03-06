//
//  CustomPasscodeConfig.h
//  AVA Recorder
//
//  Created by Tristan Freeman on 8/29/16.
//  Copyright © 2016 People Designs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomPasscodeConfig : NSObject

@property (nonatomic, strong) NSString* identifier;
/**
 *  Animations enabled inside the passcode view
 */
@property (nonatomic) BOOL animationsEnabled;

/**
 *  The background color of the passcode view
 */
@property (nonatomic, strong) UIColor* backgroundColor;

/**
 *  The background color of the navigation bar.
 */
@property (nonatomic, strong) UIColor* navigationBarBackgroundColor;

/**
 *  The foreground color (icon) of the navigation bar.
 */
@property (nonatomic, strong) UIColor* navigationBarForegroundColor;

/**
 *  The status bar style.
 */
@property (nonatomic) UIStatusBarStyle statusBarStyle;

/**
 *  The color of the round field.
 */
@property (nonatomic, strong) UIColor* fieldColor;

/**
 *  The color of the empty field.
 */
@property (nonatomic, strong) UIColor* emptyFieldColor;

/**
 *  The background color of the error message.
 */
@property (nonatomic, strong) UIColor* errorBackgroundColor;

/**
 *  The foreground color (text color) of the error message.
 */
@property (nonatomic, strong) UIColor* errorForegroundColor;


/**
 *  The text color of the description / instructions.
 */
@property (nonatomic, strong) UIColor* descriptionColor;

/**
 *  The appearance of the input keyboard.
 */
@property (nonatomic) UIKeyboardAppearance inputKeyboardAppearance;
/**
 * The font used for the title.
 */
@property (nonatomic, strong)UIFont *titleFont;
/**
 *  The font used for instructions.
 */
@property (nonatomic,strong) UIFont *instructionsFont;
@property (nonatomic,strong) UIFont *iPad_instructionsFont;

/**
 *  The font used for Error.
 */
@property (nonatomic,strong) UIFont *errorFont;

@property (nonatomic,strong) UIFont *iPad_errorFont;

/**
 *  The Navigation Bar Title.
 */
@property (nonatomic, strong) NSString * navigationBarTitle;

/**
 *  The font used for the Navigation Bar.
 */
@property (nonatomic, strong) UIFont * navigationBarFont;

/**
 *  The color used for the Navigation Bar Title.
 */
@property (nonatomic, strong) UIColor * navigationBarTitleColor;


@end
