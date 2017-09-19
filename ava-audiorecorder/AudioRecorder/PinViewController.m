//
//  PinViewController.m
//  AVA Recorder
//
//  Created by Tristan Freeman on 8/29/16.
//  Copyright © 2016 People Designs Inc. All rights reserved.
//

#import "PinViewController.h"
#import "PinField.h"
#import "CustomPasscodeConfig.h"

@interface PinViewController ()<UITextFieldDelegate>

@end

@implementation PinViewController {
    __weak id<PinViewControllerDelegate>_delegate;
    NSMutableArray *_textFields;
    UITextField *_input;
    UILabel *_titleLabel;
    UILabel *_directions;
    UILabel *_directions2;
    UILabel *_directions3;
    UILabel *_error;
    UIImageView  *_markView;
    CustomPasscodeConfig *_config;
    NSString *identifier;
}
-(id)initWithDelegate:(id<PinViewControllerDelegate>)delegate config:(CustomPasscodeConfig *)config
{
    if (self = [super init]) {
        _delegate = delegate;
        _config = config;
        
        _titleLabel = [[UILabel alloc]init];
        _directions = [[UILabel alloc]init];
        _directions2 = [[UILabel alloc]init];
        _directions3 = [[UILabel alloc] init];
        
        _error = [[UILabel alloc]init];
        _textFields = [[NSMutableArray alloc]init];
        
        
        _markView = [[UIImageView alloc] init];
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = _config.backgroundColor;
    self.navigationController.navigationBar.barTintColor = _config.navigationBarBackgroundColor;
    
    
    
    self.navigationController.navigationBar.barStyle = (UIBarStyle)_config.statusBarStyle;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName :_config.navigationBarFont,
                                                                    NSForegroundColorAttributeName: _config.navigationBarTitleColor};
    self.title = _config.navigationBarTitle;
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        _titleLabel.frame = CGRectMake(0, 85, self.view.frame.size.width, 30);
        _titleLabel.font = _config.titleFont;
        _titleLabel.textColor = _config.descriptionColor;
        
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self.view addSubview:_titleLabel];
        
        
        _directions.frame = CGRectMake(15, 140, self.view.frame.size.width - 30, 90);
        _directions.font = _config.iPad_instructionsFont;
        _directions.textColor = _config.descriptionColor;
        _directions.numberOfLines = 2;
        _directions.textAlignment = NSTextAlignmentCenter;
        _directions.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_directions];
        
        _directions2.frame = CGRectMake(15, 160, self.view.frame.size.width -30, 120);
        _directions2.font = _config.iPad_instructionsFont;
        _directions2.textColor = [UIColor redColor];
        _directions2.numberOfLines = 2;
        _directions2.textAlignment = NSTextAlignmentCenter;
        _directions2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_directions2];
        
        
        _directions3.frame = CGRectMake(15, 160, self.view.frame.size.width - 30, 120);
        _directions3.font = _config.iPad_instructionsFont;
        _directions3.textColor = _config.descriptionColor;
        _directions3.numberOfLines = 2;
        _directions3.textAlignment = NSTextAlignmentCenter;
        _directions3.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_directions3];
        
        
        _error.frame = CGRectMake(0, 360, 0, 0); // size set when text is set
        _error.font = _config.errorFont;
        _error.textColor = _config.errorForegroundColor;
        _error.backgroundColor = _config.errorBackgroundColor;
        _error.textAlignment = NSTextAlignmentCenter;
        _error.layer.cornerRadius = 4;
        _error.clipsToBounds = YES;
        _error.alpha = 0;
        _error.numberOfLines = 0;
        _error.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:_error];
        
        _markView.frame = CGRectMake((self.view.frame.size.width - 80)/2, 100, 80, 80);
        [self.view addSubview:_markView];
        
        CGFloat y_padding = 275;
        CGFloat itemWidth = 50;
        CGFloat space = 50;
        CGFloat totalWidth = (itemWidth * 4) + (space * 3);
        CGFloat x_padding = (self.view.bounds.size.width - totalWidth) / 4;
        
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(x_padding, y_padding, totalWidth, itemWidth)];
        container.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        for (int i = 0; i < 6; i++) {
            PinField* field = [[PinField alloc] initWithFrame:CGRectMake(((itemWidth + space) * i), 0, itemWidth, itemWidth) config:_config];
            UITapGestureRecognizer* singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
            [field addGestureRecognizer:singleFingerTap];
            [container addSubview:field];
            [_textFields addObject:field];
        }
        [self.view addSubview:container];
        
        
        _input = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_input setDelegate:self];
        [_input addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
        _input.keyboardType = UIKeyboardTypeNumberPad;
        _input.keyboardAppearance = _config.inputKeyboardAppearance;
        [self.view addSubview:_input];
    }
    else
    {
        
        _titleLabel.frame = CGRectMake(0, 85, self.view.frame.size.width, 30);
        _titleLabel.font = _config.titleFont;
        _titleLabel.textColor = _config.descriptionColor;
        
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self.view addSubview:_titleLabel];
        
        
        _directions.frame = CGRectMake(15, 70, self.view.frame.size.width - 30, 90);
        _directions.font = _config.instructionsFont;
        _directions.textColor = _config.descriptionColor;
        _directions.numberOfLines = 2;
        _directions.textAlignment = NSTextAlignmentCenter;
        _directions.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_directions];
        
        _directions2.frame = CGRectMake(15, 95, self.view.frame.size.width -30, 120);
        _directions2.font = [_config.instructionsFont fontWithSize:16];
        _directions2.textColor = [UIColor redColor];
        _directions2.numberOfLines = 2;
        _directions2.textAlignment = NSTextAlignmentCenter;
        _directions2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_directions2];
        
        
        _directions3.frame = CGRectMake(15, 95, self.view.frame.size.width - 30, 90);
        _directions3.font = _config.instructionsFont;
        _directions3.textColor = _config.descriptionColor;
        _directions3.numberOfLines = 2;
        _directions3.textAlignment = NSTextAlignmentCenter;
        _directions3.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_directions3];
        
        
        _error.frame = CGRectMake(0, 210, 0, 0); // size set when text is set
        _error.font = _config.errorFont;
        _error.textColor = _config.errorForegroundColor;
        _error.backgroundColor = _config.errorBackgroundColor;
        _error.textAlignment = NSTextAlignmentCenter;
        _error.layer.cornerRadius = 4;
        _error.clipsToBounds = YES;
        _error.alpha = 0;
        _error.numberOfLines = 0;
        _error.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:_error];
        
        _markView.frame = CGRectMake((self.view.frame.size.width - 40)/2, 75, 40, 40);
        [self.view addSubview:_markView];
        
        CGFloat y_padding = 180;
        CGFloat itemWidth = 24;
        CGFloat space = 20;
        CGFloat totalWidth = (itemWidth * 4) + (space * 3);
        CGFloat x_padding = (self.view.bounds.size.width - totalWidth) / 4;
        
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(x_padding, y_padding, totalWidth, itemWidth)];
        container.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        for (int i = 0; i < 6; i++) {
            PinField* field = [[PinField alloc] initWithFrame:CGRectMake(((itemWidth + space) * i), 0, itemWidth, itemWidth) config:_config];
            UITapGestureRecognizer* singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
            [field addGestureRecognizer:singleFingerTap];
            [container addSubview:field];
            [_textFields addObject:field];
        }
        [self.view addSubview:container];
        
        
        _input = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_input setDelegate:self];
        [_input addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
        _input.keyboardType = UIKeyboardTypeNumberPad;
        _input.keyboardAppearance = _config.inputKeyboardAppearance;
        [self.view addSubview:_input];
        
    }
    
    
    [_input becomeFirstResponder];
    
}
//Method handles single tap of the textfields by resigning the first responder of the current text field and making the next one the first responder.
-(void)handleSingleTap:(UITapGestureRecognizer*)recognizer{
    if ([_input isFirstResponder]) {
        [_input resignFirstResponder];
    }
    [_input becomeFirstResponder];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    return newLength <= 6|| returnKey;
    
}

- (void)editingChanged:(UITextField *)sender {
    for (int i = 0; i < sender.text.length; i++) {
        PinField* field = [_textFields objectAtIndex:i];
        NSRange range;
        range.length = 1;
        range.location = i;
        field.text = [sender.text substringWithRange:range];
    }
    for (int i = (int)sender.text.length; i < 6; i++) {
        PinField* field = [_textFields objectAtIndex:i];
        field.text = @"";
    }
    
    NSString* code = sender.text;
    if (code.length == 6) {
        [_delegate enteredCode:code];
        //[_input resignFirstResponder];//resign first responder of input keys in order to dismiss them properly.
    }
    
}

-(void)close:(id)sender
{
    [_input resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
    [_delegate canceled];
}

-(void)reset
{
    for (PinField *field in _textFields){
        field.text = @"";
    }
    _input.text = @"";
    
    
}

-(void)setBarButton:(NSString*)set
{
    NSLog(@"SET:%@", set);
    if ([set isEqualToString:@"yes"]) {
        UIBarButtonItem* closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(close:)];
        closeItem.tintColor = _config.navigationBarForegroundColor;
        self.navigationItem.leftBarButtonItem = closeItem;
    }else if([set isEqualToString:@"no"]){
        self.navigationItem.leftBarButtonItem = nil;
    }
}
- (void)setErrorMessage:(NSString *)errorMessage {
    _error.text = errorMessage;
    _error.alpha = errorMessage.length > 0 ? 1.0f : 0.0f;
    
    CGSize size = [_error.text sizeWithAttributes:@{NSFontAttributeName: _error.font}];
    size.width += 28;
    size.height += 20;
    _error.frame = CGRectMake(self.view.frame.size.width / 2 - size.width / 2, _error.frame.origin.y, size.width, size.height);
}
-(void)setHeading:(NSString*)heading
{
    _titleLabel.text = heading;
}

- (void)setDirections:(NSString *)directions {
    _directions.text = directions;
}

- (void)setDirections2:(NSString *)directions2 {
    _directions2.text = directions2;
}

- (void)setDirections3:(NSString *)directions3 {
    _directions3.text = directions3;
}

-(void)setMarkImage{
    [_markView setImage:[UIImage imageNamed:@"mark.png"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
