//
//  Passcode.h
//  AVA Recorder
//
//  Created by Tristan Freeman on 8/29/16.
//  Copyright © 2016 People Designs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CustomPasscodeConfig.h"

typedef void (^PasscodeCompletionBlock)(BOOL success, NSError *error);

typedef NS_ENUM(NSInteger, UnlockErrorCodes)
{
    ErrorUnlocking = -1,
};

@interface Passcode : NSObject
@property (nonatomic, strong)NSString *identifier;
/**
 *  Setup a new passcode.
 *
 *  @param viewController The view controller in which the passcode screen will be presented
 *  @param completion     The completion block with a BOOL to inidcate if authentication was successful (and NSError if not)
 */
+ (void)setupPasscodeInViewController:(UIViewController *)viewController completion:(PasscodeCompletionBlock)completion;

/**
 *  Authenticate the user.
 *
 *  @param viewController The view controller in which the passcode screen will be presented
 *  @param completion     The completion block with a BOOL to inidcate if the authentication was successful (and NSError if not)
 */
+ (void)showPasscodeInViewController:(UIViewController *)viewController completion:(PasscodeCompletionBlock)completion;

+ (void)showPasscodeForChange:(UIViewController *)viewController completion:(PasscodeCompletionBlock) completion;

/**
 *  Remove the passcode from the keychain.
 */
+ (void)removePasscode;

/**
 *  Check if a passcode is already set.
 *
 *  @return BOOL indicating if a passcode is set
 */
+ (BOOL)isPasscodeSet;

/**
 *  Set a configuration.
 *
 *  @param config configuration which should be uses.
 */
+ (void)setConfig:(CustomPasscodeConfig *)config;


@end
