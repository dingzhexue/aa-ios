  //
//  Passcode.m
//  AVA Recorder
//
//  Created by Tristan Freeman on 8/29/16.
//  Copyright © 2016 People Designs Inc. All rights reserved.
//

#import "Passcode.h"
#import "PinViewController.h"
#import "PDPasscodeNavigationController.h"
#import "PDKeychain.h"
#import "LockoutViewController.h"


#ifdef __IPHONE_8_0
#import <LocalAuthentication/LocalAuthentication.h>
#endif

static Passcode* instance;
static const NSString* KEYCHAIN_NAME = @"passcode";
static NSBundle* bundle;
NSString* const PDUnlockErrorDomain = @"com.peopledesigns.error.unlock";

@interface Passcode()<PinViewControllerDelegate>

@end

@implementation Passcode {
    PasscodeCompletionBlock _completion;
    PinViewController *_pinViewController;
    LockoutViewController *_lockoutViewController;
    int _mode;
    int _count;
    NSString* _prevCode;
    CustomPasscodeConfig* _config;
    //NSString * identifier;
    int numTries;
}
@synthesize identifier = _identifier;

+ (void)initialize {
    [super initialize];
    instance = [[Passcode alloc] init];
    bundle = [Passcode bundleWithName:@"Passcode.bundle"];
}

- (instancetype)init {
    if (self = [super init]) {
        _config = [[CustomPasscodeConfig alloc] init];
        _identifier = _config.identifier;
    }
    return self;
}

+ (NSBundle*)bundleWithName:(NSString*)name {
    NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
    NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:frameworkBundlePath]){
        return [NSBundle bundleWithPath:frameworkBundlePath];
    }
    return nil;
}

#pragma mark - Public
+ (void)setupPasscodeInViewController:(UIViewController *)viewController completion:(PasscodeCompletionBlock)completion {
    [instance setupPasscodeInViewController:viewController completion:completion];
}

+ (void)showPasscodeInViewController:(UIViewController *)viewController completion:(PasscodeCompletionBlock)completion {
    [instance showPasscodeInViewController:viewController completion:completion];
}

+ (void)showPasscodeForChange:(UIViewController *)viewController completion:(PasscodeCompletionBlock) completion{
    [instance showPasscodeForChange:viewController completion:completion];
}

+ (void)removePasscode {
    [instance removePasscode];
}

+ (BOOL)isPasscodeSet {
    return [instance isPasscodeSet];
}


+ (void)setConfig:(CustomPasscodeConfig *)config {
    [instance setConfig:config];
}

#pragma mark - Instance methods

- (void)setupPasscodeInViewController:(UIViewController *)viewController completion:(PasscodeCompletionBlock)completion {
    _completion = completion;
    [self openPasscodeWithMode:0 viewController:viewController];
}
- (void)showPasscodeInViewController:(UIViewController *)viewController completion:(PasscodeCompletionBlock)completion {
    //NSAssert([self isPasscodeSet], @"No passcode set");
    
    [self openPasscodeWithMode:1 viewController:viewController];
    
    _completion = completion;
//    LAContext* context = [[LAContext alloc] init];
//    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
//        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"Unlock with your fingerprint", nil) reply:^(BOOL success, NSError* error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (error) {
//                    switch (error.code) {
//                        case LAErrorUserCancel:
//                            //When user cancels fingerprint login, display passcode.
//                            [self openPasscodeWithMode:1 viewController:viewController];
//                            //_completion(NO, nil);
//                            break;
//                        case LAErrorSystemCancel:
//                            _completion(NO, nil);
//                            break;
//                        case LAErrorAuthenticationFailed:
//                            _completion(NO, error);
//                            break;
//                        case LAErrorPasscodeNotSet:
//                        case LAErrorTouchIDNotEnrolled:
//                        case LAErrorTouchIDNotAvailable:
//                        case LAErrorUserFallback:
//                            [self openPasscodeWithMode:1 viewController:viewController];
//                            break;
//                    }
//                } else {
//                    _completion(success, nil);
//                }
//            });
//        }];
//    } else {
//        // no touch id available
//        [self openPasscodeWithMode:1 viewController:viewController];
//    }
}

- (void)showPasscodeForChange:(UIViewController *)viewController completion:(PasscodeCompletionBlock) completion
{
    NSAssert([self isPasscodeSet], @"No passcode set");
    
    _completion = completion;
    [self openPasscodeWithMode:2 viewController:viewController];
//    LAContext* context = [[LAContext alloc] init];
//    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
//        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"Unlock with your fingerprint", nil) reply:^(BOOL success, NSError* error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (error) {
//                    switch (error.code) {
//                        case LAErrorUserCancel:
//                            _completion(NO, nil);
//                            break;
//                        case LAErrorSystemCancel:
//                            _completion(NO, nil);
//                            break;
//                        case LAErrorAuthenticationFailed:
//                            _completion(NO, error);
//                            break;
//                        case LAErrorPasscodeNotSet:
//                        case LAErrorTouchIDNotEnrolled:
//                        case LAErrorTouchIDNotAvailable:
//                        case LAErrorUserFallback:
//                            [self openPasscodeWithMode:2 viewController:viewController];
//                            break;
//                    }
//                } else {
//                    _completion(success, nil);
//                }
//            });
//        }];
//    } else {
//        // no touch id available
//        [self openPasscodeWithMode:2 viewController:viewController];
//    }

}
- (void)removePasscode {
    [[PDKeychain defaultKeychain] removeObjectForKey:KEYCHAIN_NAME];
}

- (BOOL)isPasscodeSet {
    BOOL ret = [[PDKeychain defaultKeychain] objectForKey:KEYCHAIN_NAME] != nil;
    return ret;
}


- (void)setConfig:(CustomPasscodeConfig *)config {
    _config = config;
}

#pragma mark - Private
//- (void)setIdentifier:(NSString*)identifier
//{
//    _identifier = _config.identifier;
//}

- (void)openPasscodeWithMode:(int)mode viewController:(UIViewController *)viewController{
    _mode = mode;
    _count = 0;
    _pinViewController = [[PinViewController alloc] initWithDelegate:self config:_config];
    NSLog(@"IDENT:%@", _identifier);
    PDPasscodeNavigationController* nc = [[PDPasscodeNavigationController alloc] initWithRootViewController:_pinViewController];
    
    [viewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [viewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    //[viewController.navigationController pushViewController:nc animated:YES];
    [viewController presentViewController:nc animated:YES completion:nil];
    if (_mode == 0) {
        NSLog(@"IDENT:%@", _identifier);
        
        _pinViewController.navigationItem.leftBarButtonItem = nil;
        [_pinViewController setHeading:NSLocalizedString(@"", nil)];
        if ([_identifier isEqualToString:@"changePass"]) {
            [_pinViewController setBarButton:@"yes"];
        }else{
            [_pinViewController setBarButton:@"no"];
        }
        
        [_pinViewController setDirections:NSLocalizedString(@"Create a passcode for the AVA Recorder.", nil)];
        [_pinViewController setDirections2:NSLocalizedString(@"Remember it. It cannot be recovered!", nil)];
    } else if (_mode == 1) {
        
        NSLog(@"Current VC %@", ((UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController).topViewController
              );
        nc.navigationItem.leftBarButtonItem = nil;
        //_pinViewController.navigationController.navigationItem.hidesBackButton = YES;
        [_pinViewController setHeading:NSLocalizedString(@"", nil)];
        [_pinViewController setBarButton:@"no"];
        [_pinViewController setDirections:NSLocalizedString(@"Locked! Enter your AVA Recorder passcode to unlock.", nil)];
        
    }else if (_mode == 2) {
        
        [_pinViewController setHeading:NSLocalizedString(@"", nil)];
        [_pinViewController setBarButton:@"yes"];
        [_pinViewController setDirections:NSLocalizedString(@"Enter your AVA Recorder passcode to proceed.", nil)];
        
    }
}


- (void)closeAndNotify:(BOOL)success withError:(NSError *)error {
    [_pinViewController dismissViewControllerAnimated:YES completion:^() {
        _completion(success, error);
        
    }];
    
}
#pragma mark - PDPasscodeInternalViewControllerDelegate
- (void)enteredCode:(NSString *)code {
    if (_mode == 0) {//mode 0 = App has no passcode
        if (_count == 0) {
            _prevCode = code;
            [_pinViewController setDirections:NSLocalizedString(@"Confirm your new passcode.", nil)];
            [_pinViewController setErrorMessage:@""];
            [_pinViewController reset];
            
        } else if (_count == 1) {
            if ([code isEqualToString:_prevCode]) {
                [[PDKeychain defaultKeychain] setObject:code forKey:KEYCHAIN_NAME];
                [self closeAndNotify:YES withError:nil];
            } else {
                [_pinViewController setDirections:NSLocalizedString(@"Enter a new passcode.", nil)];
                [_pinViewController setErrorMessage:NSLocalizedString(@"Passcodes do not match. Try again.", nil)];
                [_pinViewController reset];
                _count = 0;
                return;
            }
        }//mode 1 = App is locked
    } else if (_mode == 1) {
        if ([code isEqualToString:[[PDKeychain defaultKeychain] objectForKey:KEYCHAIN_NAME]]) {
            [self closeAndNotify:YES withError:nil];
        } else {
            if (_count == 10) {
                [_pinViewController setErrorMessage:NSLocalizedString(@"1 attempt left", nil)];
            } else {
                [_pinViewController setErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"%d attempts left", nil), 10 - _count]];
            }
            [_pinViewController reset];
            if (_count >= 10) { // max 10 attempts
               // if (numTries < 2) {
                    [_pinViewController reset];
                    [_pinViewController setErrorMessage:@""];
                    //creat the alertview
                    __block UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unlock Failed" message:@"You must wait 30 seconds before trying again." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
                    
                    [alert show];
                    
                    //dismiss the alert automaticall after 30 seconds
                    double delayInSeconds = 30;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^{
                        _count = 0;
                        [alert dismissWithClickedButtonIndex:0 animated:YES];
                        numTries++;
                    });

//                }else{
//                                    NSError *errorMatchingPins = [NSError errorWithDomain:PDUnlockErrorDomain code:ErrorUnlocking userInfo:nil];
//                                    [self closeAndNotify:NO withError:errorMatchingPins];
//                }
    
                
            }
        }
    } else if(_mode == 2) {// mode 2 = Change passcode
        if ([code isEqualToString:[[PDKeychain defaultKeychain] objectForKey:KEYCHAIN_NAME]]) {
            [self closeAndNotify:YES withError:nil];
        } else {
            if (_count == 1) {
                [_pinViewController setErrorMessage:NSLocalizedString(@"1 attempt left", nil)];
            } else {
                [_pinViewController setErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"%d attempts left", nil), 2 - _count]];
            }
            [_pinViewController reset];
            if (_count >= 2) { // max 3 attempts
                NSError *errorMatchingPins = [NSError errorWithDomain:PDUnlockErrorDomain code:ErrorUnlocking userInfo:nil];
                [self closeAndNotify:NO withError:errorMatchingPins];
            }
        }
    }
    _count++;
}

- (void)canceled {
    _completion(NO, nil);
    
}
@end
