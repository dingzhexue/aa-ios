//
//  PinViewController.h
//  AVA Recorder
//
//  Created by Tristan Freeman on 8/29/16.
//  Copyright © 2016 People Designs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PinViewControllerDelegate <NSObject>

-(void)enteredCode:(NSString*)code;
-(void)canceled;

@end

@class CustomPasscodeConfig;

@interface PinViewController : UIViewController<UITextFieldDelegate>

-(id)initWithDelegate:(id<PinViewControllerDelegate>)delegate config:(CustomPasscodeConfig *)config;
-(void)setErrorMessage:(NSString*)errorMessage;
-(void)setDirections:(NSString*)directions;
-(void)setDirections2:(NSString*)directions2;
-(void)setHeading:(NSString*)heading;
-(void)setTitle:(NSString *)title;
-(void)setBarButton:(NSString*)set;
-(void)reset;



@end
