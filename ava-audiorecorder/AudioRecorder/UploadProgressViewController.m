//
//  UploadProgressViewController.m
//  AVA Recorder
//
//  Created by Tristan Freeman on 8/10/16.
//  Copyright © 2016 People Designs Inc. All rights reserved.
//

#import "UploadProgressViewController.h"
#import "Constants.h"
#import "AudioRecorderAppDelegate.h"
#import "ServerSession.h"
#import "DocumentsData.h"
#import "DatabaseManager.h"
#import "ServerUploadingViewController.h"
#import "RecordingsViewController.h"
#import "RNDecryptor.h"
#import "M13ProgressViewRing.h"
#import "PDKeychain.h"


@interface UploadProgressViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UILabel *userLabel;
@property (strong, nonatomic) IBOutlet UILabel *collectionLabel;
@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) IBOutlet M13ProgressViewRing *progressRing;
@property (strong, nonatomic) UIBarButtonItem *cancelItem;
@property (strong, nonatomic) UIBarButtonItem *closeItem;
- (IBAction)uploadButtonPressed:(id)sender;

@property (strong, nonatomic) NSURLSessionDataTask *connectTask;
@property(nonatomic, strong) NSNumber *fileSize;
//@property(nonatomic,strong)CustomProgressView *customProgressView;
@property (strong, nonatomic) IBOutlet UILabel *uploadLabel;
//@property (strong, nonatomic)NSString *newFileName;
@end

@implementation UploadProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _nameTextField.text = self.fileNameString;
    _userLabel.text = self.userName;
    _collectionLabel.text = self.collectionName;
    
    _progressRing.primaryColor = [UIColor colorWithRed:0.32 green:0.75 blue:0.24 alpha:1.0];
    _progressRing.secondaryColor = [UIColor clearColor];
    //_progressRing.backgroundColor =
    _cancelItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = _cancelItem;
    
    _closeItem = [[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    
   // _progressView.delegate = self;
    //self.progressRing = [[M13ProgressViewRing alloc]initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
    //[self.view addSubview:_progressRing];
    
    [self connectToServerForAudioUpload:_fileName];
    
    //get the user entered name
    NSString *enteredNameString = _nameTextField.text;
    //set the character set of characters that are not allowed in filename due to the way it messes up the filesystem paths
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"\/:"];
    //create new filename by replacing unwanted characters with white space.
    //_newFileName = [[enteredNameString componentsSeparatedByCharactersInSet:doNotWant]componentsJoinedByString:@" "];

    
    //set the progress to 100% with no delay
    //[self performSelector:@selector(setProgress:) withObject:[NSNumber numberWithFloat:1.0] afterDelay:0.0];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)back
{
    if (self.connectTask.currentRequest) {
        [self.connectTask cancel];
        [self performSegueWithIdentifier:@"uploadClosedIdentifier" sender:self];
    }
}
-(void)setCloseItem:(UIBarButtonItem *)closeItem{
    [self performSegueWithIdentifier:@"uploadClosedIdentifier" sender:self];
}
//method to set custom progress bar progress
//-(void)setProgress:(NSNumber*)value
//{
//    [_progressView performSelectorOnMainThread:@selector(setProgress:) withObject:value waitUntilDone:NO];
//}
//-(void)didFinishAnimation:(CustomProgressView *)progressView
//{
//    
//    [_uploadLabel setText:@"Upload complete!"];
//    [_uploadButton setTitle:@"Close" forState:UIControlStateNormal];
//    [[self navigationItem]setHidesBackButton:YES];
//    
//    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
//    self.navigationItem.hidesBackButton = YES;
//    self.navigationItem.leftBarButtonItem = closeItem;
//    
//}

-(void)close
{
    //NSArray *tempVCA = [self.navigationController viewControllers];
    //for (UIViewController *tempVC in tempVCA) {
        //if ([tempVC isKindOfClass:[UploadProgressViewController class]]) {
            // No, go to playback
            [self performSegueWithIdentifier:@"uploadClosedIdentifier" sender:self];
           // [tempVC removeFromParentViewController];
        //}
    //}
}

-(void)connectToServerForAudioUpload:(NSString *)fileName
{
    DocumentsData *data =[[DocumentsData alloc]init];
    NSString *filePath = [data getFilePathFromDocumentsFolder:fileName];
    NSURL *fileUploadURL = [[NSURL alloc] initFileURLWithPath:filePath];
    
    NSString *urlUpload = [NSString stringWithFormat:URL_UPLOAD, _collectionId];
    
    self.connectTask = [[ServerSession uploadSession]POST:urlUpload
                                               parameters:nil
                                constructingBodyWithBlock:^(id <AFMultipartFormData> formData){
                                    [formData appendPartWithFileData:[self decryptedData] name:@"file" fileName:fileName mimeType:@"audio/.m4a"];
                                    //[formData appendPartWithFileURL:fileUploadURL name:@"file" error:nil];
                                    [formData appendPartWithFormData:[_nameTextField.text dataUsingEncoding:NSUTF8StringEncoding] name:@"file_name"];
                                    [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding] name:@"file_description"];
                                    [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding] name:@"file_custom_id"];
                                }
                        
                        
                                                 progress:^(NSProgress * _Nonnull uploadProgress){
                                                     dispatch_async(dispatch_get_main_queue(), ^{
//                                                         NSNumber *progressNumber = [NSNumber numberWithDouble:uploadProgress.fractionCompleted];
                                                         [_progressRing setProgress:uploadProgress.fractionCompleted animated:YES];
                                                         if (uploadProgress.fractionCompleted == 1) {
                                                             [_uploadLabel setText:@"Upload complete!"];
                                                             [_uploadButton setTitle:@"Close" forState:UIControlStateNormal];
                                                             
                                                         }
                                                         //[_progressView setProgress:progressNumber];
                                                     });
                                                 }
                                                  success:^(NSURLSessionDataTask *task, id _Nullable responseObject) {
                                                      NSLog(@"File upload response: %@", responseObject);
                                                      NSString* response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                                      NSLog(@"File upload response: %@", response);
                                                      
                                                      self.navigationItem.leftBarButtonItem = _closeItem;
                                                      
                                                      [UIApplication sharedApplication].idleTimerDisabled = NO;
                                                      
                                                      // update the upload status of the file in database
                                                      DatabaseManager *dbManager = [[DatabaseManager alloc]init];
                                                      [dbManager updateFileUploadStatus:fileName  withUploadStatus:YES nameOnServer:_nameTextField.text uploadedDate:[NSDate date]];
                                                  }//success block close
                                                  failure:^(NSURLSessionDataTask * _Nullable task, NSError *error){
                                                      
                                                      NSLog(@"Upload Error: %@",[error localizedDescription]);
                                                      [UIApplication sharedApplication].idleTimerDisabled = NO;
                                                      
                                                  }];
   
    

    
    
    self.fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] valueForKey:NSFileSize];
    [[ServerSession uploadSession] setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%lld", bytesSent);
            NSLog(@"%lld", totalBytesExpectedToSend);
            NSLog(@"%lld", [self.fileSize longLongValue]);
            
        });
    }];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

-(NSData*)decryptedData {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *recordingsDirectory = [paths objectAtIndex:0];
    recordingsDirectory = [recordingsDirectory stringByAppendingPathComponent:@"Recordings"];
    
    NSLog(@"SEL NAME:%@", _nameTextField.text);
    NSString *filePath = [recordingsDirectory stringByAppendingPathComponent: _fileName];
    NSData *audioData = [[NSData alloc]initWithContentsOfFile:filePath];
    NSData *decryptedData = [RNDecryptor decryptData:audioData withPassword:[[PDKeychain defaultKeychain]objectForKey:KEY_ENCRYPTION]error:&error];
    
    return decryptedData;
}
- (IBAction)uploadButtonPressed:(id)sender {
    if (self.connectTask.currentRequest) {
        [self.connectTask cancel];
        [self performSegueWithIdentifier:@"uploadClosedIdentifier" sender:self];
    }else{
        NSArray *tempVCA = [self.navigationController viewControllers];
        for (UIViewController *tempVC in tempVCA) {
            if ([tempVC isKindOfClass:[UploadProgressViewController class]]) {
                // No, go to playback
                RecordingsListViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SavedRecording"];
                listVC.cameFromUpload = YES;
                [self performSegueWithIdentifier:@"uploadClosedIdentifier" sender:self];
                [tempVC removeFromParentViewController];
            }
        }
        //[self performSegueWithIdentifier:@"uploadClosedIdentifier" sender:self];
    }
}
#pragma mark - Navigation

//In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"uploadCancelIdentifier"])
    {
        ServerUploadingViewController *cancelUpload;
        cancelUpload = segue.destinationViewController;
        cancelUpload.nameString = _nameTextField.text;
    }else if([segue.identifier isEqualToString:@"uploadClosedIdentifier"]) {
        RecordingsListViewController *recordingVC;
        recordingVC = segue.destinationViewController;
        recordingVC.cameFromUpload = YES;
    }
    
}

@end
