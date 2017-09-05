//
//  LockoutViewController.m
//  AVA Recorder
//
//  Created by Tristan Freeman on 12/20/16.
//  Copyright © 2016 People Designs Inc. All rights reserved.
//

#import "LockoutViewController.h"

@interface LockoutViewController ()
@property (strong, nonatomic) IBOutlet UILabel *LockoutMessage;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;


@end

@implementation LockoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([_mode isEqualToString:@"1"]) {
        [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(dismissVC) userInfo:nil repeats:NO];
        _LockoutMessage.text = @"Please try loggin in again in 30 seconds";
        //code here
    } else if ([_mode isEqualToString:@"2"]) {
        [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(dismissVC) userInfo:nil repeats:NO];
        _LockoutMessage.text = @"Please try loggin in again in one minute";
    }else if ([_mode isEqualToString:@"3"]) {
        [NSTimer scheduledTimerWithTimeInterval:120.0 target:self selector:@selector(dismissVC) userInfo:nil repeats:NO];
        _LockoutMessage.text = @"Please try loggin in again in two minutes";
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)startTimerForDuration:(NSTimeInterval *) interval {
    
    
}
-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:^{
        //code here
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
