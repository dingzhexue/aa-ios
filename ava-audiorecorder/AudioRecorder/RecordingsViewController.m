//
    //  RecordingsViewController.m
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import "RecordingsViewController.h"
#import "SelectedRecordingViewController.h"

#import "ServerSignInViewController.h"
#import "Constants.h"
#import "DatabaseManager.h"
#import "AudioData.h"
#import "AudioRecorderAppDelegate.h"
#import "TimeFormatter.h"
#import "NSDate+DateFormatter.h"
#import "UserDefaults.h"
#import "RecorderTableCell.h"
#import "DocumentsData.h"
#import "NewRecordingViewController.h"
#import "SAMKeychain.h"
#import "DateTools.h"
#import "Passcode.h"
#import "PDKeychain.h"

#import "AccountConnectionViewController.h"
#import "WelcomeViewController.h"

static NSInteger lastSelectedCellIndex;

@interface RecordingsListViewController ()<UITableViewDataSource,UITableViewDelegate,CustomCellDelegate,UIAlertViewDelegate>
{
    NSMutableArray *fileArray;
    DocumentsData *docData;
    NSString *fileName,*selectedFileName,*fileToDelete;
    NSDate *fileCreatedDate;
        NSInteger selectedCellIndex;
        DatabaseManager *dbManager;
    AudioData *audioData;
}

@property (strong, nonatomic) IBOutlet UITableView *recordingsTableView;
@property (strong, nonatomic) IBOutlet UILabel *listLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteAndSettingsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lockButton;
@property (weak, nonatomic) IBOutlet UIButton *addRecordingButton;
@property (strong, nonatomic) AudioData *data;

@property(nonatomic, strong) UIBarButtonItem *privateEditButtonItem;

- (IBAction)lockButtonTapped:(id)sender;
- (IBAction)deleteAndSettingsButtonTapped:(UIBarButtonItem*)sender;
- (IBAction)doneButtonTapped:(id)sender;
- (IBAction)addButtonTapped:(id)sender;

@end

@implementation RecordingsListViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        docData = [[DocumentsData alloc]init];
        dbManager = [[DatabaseManager alloc]init];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
    }
    return self;
}

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated
{
        //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(unlock) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
    
   // UserDefaults *defaults = [UserDefaults sharedUserDefaults];
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationItem setTitle:@"AVA"];
    
    
//    if(![[NSUserDefaults standardUserDefaults]boolForKey:@"firstLaunch"])
//    {
//        
//        [self setPasscode];
//    }else if(_cameFromAccountConnection){
//        NSLog(@"Came from account connection");
//    }else if(_cameFromUpload){
//        NSLog(@"Came from upload");
//    }else{
//        [self enterPasscode];
//    }
    
    [super viewWillAppear:YES];
    self.editing = NO;
    NSArray *listArray = [dbManager fetchAudioDetailsFromDatabase];
    if(!fileArray)
        fileArray = [[NSMutableArray alloc]init];
    else
        [fileArray removeAllObjects];
    
    [fileArray addObjectsFromArray:listArray];
    
    // Check whether the list is empty
    
    if(fileArray.count == 0)
    {
        _listLabel.hidden = NO;
        self.navigationItem.leftBarButtonItem = nil;
    }
    else {
        _listLabel.hidden = YES;
        //self.navigationItem.leftBarButtonItem = self.editButtonItem;//COMMENTED OUT TO ELIMINATE BUTTON ON UI
    }
    [self.recordingsTableView reloadData];
    
    self.navigationItem.title = @"AVA";
    [[self navigationItem]setHidesBackButton:YES];
    //    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    //[self updateButtons];
    
    
    
}

- (void)viewDidLoad
{
    if(![[NSUserDefaults standardUserDefaults]boolForKey:@"firstLaunch"] || _cameFromAccountConnection || _cameFromUpload)
    {
        return;
    } else{
        [self enterPasscode];
    }
//    if (![[PDKeychain defaultKeychain]objectForKey:KEY_ENCRYPTION]) {
//        NSString *encryptionPassString = [self randomStringWithLength:30];
//        [[PDKeychain defaultKeychain]setObject:encryptionPassString forKey:KEY_ENCRYPTION];
//    }
    
    //display enter passcode called here because there was an issue trying to display it from the app delegate.
    //if it is the first launch of the app or it came from the account connection, do nothing, else display lock screen.
//    if(![[NSUserDefaults standardUserDefaults]boolForKey:@"firstLaunch"] || _cameFromAccountConnection)
//    {
//        //DO NOTHING
//        //[self setPasscode];
//    }
//    else {
//        [self enterPasscode];
//    }
    //[self enterPasscode];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([_sectionIdentifier isEqualToString:@"BackToMain"]) {
        self.navigationItem.title = @"AVA";
        self.navigationItem.hidesBackButton = YES;
    }
    _listLabel.hidden = YES;

    self.addRecordingButton.layer.cornerRadius = 3.0f;
    self.recordingsTableView.sectionHeaderHeight = 0;
    self.navigationItem.rightBarButtonItem.tintColor = self.navigationItem.leftBarButtonItem.tintColor;

//    self.privateEditButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone  target:self action:@selector(endEditing)];
    
    // check whether the view loaded from New recording. If yes, highlight the first cell in table
    if([[UserDefaults sharedUserDefaults]isNewAudioFileCreated])
        lastSelectedCellIndex = 0;
    else
        lastSelectedCellIndex = -1; // remove the selection of cells

    AudioRecorderAppDelegate *appDelegate=[AudioRecorderAppDelegate sharedDelegate];
    appDelegate.currentViewController=self;

    [self.navigationItem setHidesBackButton:YES];
    [self.navigationItem setTitle:@"AVA"];
    self.title = @"AVA";
}

- (void)endEditing {
    self.editing = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated
{
    

}
- (void)viewDidUnload
{
    [self setRecordingsTableView:nil];
    [self setListLabel:nil];
    [super viewDidUnload];
}
////Method to create random string for encryption/decryption password
//-(NSString*)randomStringWithLength: (int)length
//{
//    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
//    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
//    
//    for(int i=0; i<length; i++){
//        [randomString appendFormat:@"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
//    }
//    return randomString;
//}

//-(void)displayWelcome {
//    WelcomeViewController *welcomeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
//    welcomeVC.navigationItem.hidesBackButton = YES;
//    [self.navigationController pushViewController:welcomeVC animated:YES];
//    
//   
//
//}
-(void)setPasscode
{
    CustomPasscodeConfig *passCodeConfig = [[CustomPasscodeConfig alloc]init];
    
    
    passCodeConfig.navigationBarTitle = @"AVA Recorder";
    passCodeConfig.identifier = @"changePass";
    [Passcode setConfig:passCodeConfig];
    
    passCodeConfig.navigationBarBackgroundColor = [UIColor colorWithRed:0.32 green:0.75 blue:0.24 alpha:1.0];
    passCodeConfig.navigationBarTitleColor = [UIColor whiteColor];
    [Passcode setupPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
        if (success && [[NSUserDefaults standardUserDefaults]boolForKey:@"firstLaunch"]) {
            [self dismissViewControllerAnimated:YES completion:nil];
           
        }else if (success){
            NSLog(@"passcode setup appeared");
            AccountConnectionViewController *accountConnectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountConnectionViewController"];
            accountConnectionVC.navigationItem.hidesBackButton = YES;
            [self.navigationController pushViewController:accountConnectionVC animated:YES];
            //[self dismissViewControllerAnimated:YES completion:nil];
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstLaunch"];
            
        }else{
            NSLog(@"%@", [error localizedDescription]);
        }
    }];

    
}
- (void)passcodeViewControllerWillClose
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)unlock
{
    CustomPasscodeConfig *passCodeConfig = [[CustomPasscodeConfig alloc]init];
    
    
    passCodeConfig.navigationBarTitle = @"AVA Recorder";
    passCodeConfig.identifier = @"changePass";
    [Passcode setConfig:passCodeConfig];
    
    passCodeConfig.navigationBarBackgroundColor = [UIColor colorWithRed:0.32 green:0.75 blue:0.24 alpha:1.0];
    passCodeConfig.navigationBarTitleColor = [UIColor whiteColor];
    [Passcode showPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"PASSWORDS MATCH");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
}
-(void)enterPasscode
{
   
        CustomPasscodeConfig *passCodeConfig = [[CustomPasscodeConfig alloc]init];
        
        
        passCodeConfig.navigationBarTitle = @"AVA Recorder";
        passCodeConfig.identifier = @"changePass";
        [Passcode setConfig:passCodeConfig];
        
        passCodeConfig.navigationBarBackgroundColor = [UIColor colorWithRed:0.32 green:0.75 blue:0.24 alpha:1.0];
        passCodeConfig.navigationBarTitleColor = [UIColor whiteColor];
        [Passcode showPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
            if (success && [Passcode isPasscodeSet]) {
                NSLog(@"PASSWORDS MATCH");
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                
                passCodeConfig.identifier = @"";
                [self setPasscode];
                //NSLog(@"ERROR:%@", error.localizedDescription);
            }
        }];
}

#pragma mark- UITableView Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return fileArray.count > 0 ? fileArray.count : 1;
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? 70 : 44;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    _recordingsTableView.backgroundColor = [UIColor clearColor];

    if (indexPath.section == 0 && fileArray.count > 0 && indexPath.row < fileArray.count) {
        static NSString *recordCellIdentifier = @"CustomCellIdentifier";

        // Custom cell
        RecorderTableCell *customCell = (RecorderTableCell *) [tableView dequeueReusableCellWithIdentifier:recordCellIdentifier forIndexPath:indexPath];
//    if(customCell == nil)
//    {
//        NSArray *cellObjects = [[NSBundle mainBundle] loadNibNamed:@"RecorderTableCell" owner:self options:nil];
//        customCell = [cellObjects objectAtIndex:0];
//    }

        // Get the file details from the database
        //AudioData *audioData;
        audioData = (AudioData *) [fileArray objectAtIndex:indexPath.row];
        NSLog(@"NAME:%@", audioData.name);
        customCell.fileName.text = [audioData.name stringByDeletingPathExtension];

        // Get the duration of audio in required format
        TimeFormatter *timeFormatter = [[TimeFormatter alloc] initWithTimeInterval:audioData.audioDuration];

        customCell.lengthOfRecord.text = timeFormatter.durationString;

//    if(indexPath.row == lastSelectedCellIndex)
//        customCell.backgroundColor = [UIColor colorWithRed:246.0 green:250.0 blue:246.0 alpha:1.0];
//    else
//        customCell.backgroundColor = [UIColor colorWithRed:0.825 green:0.825 blue:0.825 alpha:1.0];

        //create NSDate of created date
        NSDate *createdDate = audioData.createdDate;
        //initialize dateComponentsFormatter and set the style and allowed units.
        NSDateComponentsFormatter *dateFormatter = [[NSDateComponentsFormatter alloc]init];
        dateFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleAbbreviated;
        dateFormatter.allowedUnits = NSCalendarUnitMinute|NSCalendarUnitHour|NSCalendarUnitDay;
        
        //create string from date calculation for recordDate cell label
        NSString *timeAgo = createdDate.shortTimeAgoSinceNow;
        
        customCell.recordDate.text = [NSString stringWithFormat:@"%@ ago", timeAgo];
        
        
       
       
        

        // Check whether file uploaded to server
        if (audioData.uploadStatus) {
            customCell.uploaded.text = @"UPLOADED";
        }
        else {
            customCell.uploaded.text = @"";
        }
        customCell.deleteButton.tag = indexPath.row;
        customCell.uploadButton.tag = indexPath.row;
        customCell.delegate = self;

        return customCell;
    }

    if (indexPath.section == 0 && fileArray.count == 0 && indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"add-button"];
        cell.textLabel.text = @"No Recordings";
        cell.textLabel.textAlignment =   NSTextAlignmentCenter;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }

    return nil;
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    audioData = (AudioData *)[fileArray objectAtIndex:indexPath.row];
    selectedFileName = [audioData.fileName stringByDeletingPathExtension];

    // Save the last indexpath
    lastSelectedCellIndex = indexPath.row;

    // Push the playback viewcontroller
    [self performSegueWithIdentifier:@"SelectedRecordingIdentifier" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Check whether file uploaded to server
        //if (audioData.uploadStatus) {
          //  NSLog(@"upload status checked within delete");
            [self deleteClickedForSelectedCell:indexPath.row updated:audioData.uploadStatus];
        //}
        //else {
          //  NSLog(@"delete not hit");
        //}

        
    }
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return tableView.editing;
//}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
//    if (self.navigationItem.leftBarButtonItem == self.editButtonItem && editing) {
//        self.navigationItem.leftBarButtonItem = self.privateEditButtonItem;
//    }
//
//    if (self.navigationItem.leftBarButtonItem == self.privateEditButtonItem && !editing) {
//        self.navigationItem.leftBarButtonItem = self.editButtonItem;
//    }

    self.recordingsTableView.allowsMultipleSelectionDuringEditing = editing;
    [self.recordingsTableView setEditing:editing animated:animated];
    
    [self updateButtons];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (fileArray.count == 0 || indexPath.row >= fileArray.count)
        return;
//    if (!tableView.editing) {
//    RecorderTableCell *cell = (RecorderTableCell*)[tableView cellForRowAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor colorWithRed:246.0 green:250.0 blue:246.0 alpha:1.0];
//
//
//    }

    if (!tableView.editing) {
        audioData = (AudioData *)[fileArray objectAtIndex:indexPath.row];
        selectedFileName = [audioData.fileName stringByDeletingPathExtension];

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }

    [self updateButtons];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateButtons];
}


-(void)updateButtons {
    if (self.recordingsTableView.editing) {
        int count = self.recordingsTableView.indexPathsForSelectedRows.count;
        self.deleteAndSettingsButton.tintColor = [UIColor redColor];
        self.deleteAndSettingsButton.title = count > 0 ? BUTTON_DELETE : BUTTON_DELETE_ALL;
    } else {
//        if(fileArray.count == 0)
//        {
//            self.navigationItem.leftBarButtonItem = nil;
//         }
//        else {
//            self.navigationItem.leftBarButtonItem = self.editButtonItem;
//        }
        self.deleteAndSettingsButton.tintColor = self.lockButton.tintColor;
        self.deleteAndSettingsButton.title = BUTTON_SETTINGS;
    }
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SelectedRecordingIdentifier"])
    {
        RecorderTableCell *cell = sender;
        audioData = (AudioData *) [fileArray objectAtIndex:(NSUInteger) [cell getIndexPath].row];
        NSString *selectedFile = [audioData.name stringByDeletingPathExtension];

        PlayBackViewController *record;
        record = segue.destinationViewController;
        record.nameString = selectedFile;
        record.fileName = audioData.fileName;
        record.sectionIdentifier = @"SavedRecording";
    }
    else if([segue.identifier isEqualToString:@"SavedToSignInIdentifier"])
    {
        ServerSignInViewController *serverSignIn;
        serverSignIn = segue.destinationViewController;
        serverSignIn.navigationTitle = selectedFileName;
        serverSignIn.sectionIdentifier = @"SavedRecording";
    } else if ([segue.identifier isEqualToString:@"SettingsIdentifier"]) {
        self.navigationItem.title = @"Done";
    } else if([segue.identifier isEqualToString:@"addRecordingIdentifer"]){
        NewRecordingViewController *newRecordingVc;
        newRecordingVc = segue.destinationViewController;
        newRecordingVc.sectionIdentifier = @"newRecording";
    }

}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([identifier isEqualToString:@"SelectedRecordingIdentifier"]) {
        return !self.recordingsTableView.editing;
    }


    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}
-(IBAction)prepareForUnwind:(UIStoryboardSegue*)segue
{
    if([segue.identifier isEqualToString:@"unwindToMain"])
    {
        NSLog(@"UNWIND TO MAIN");
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.title=@"AVA";
    }
    
}

#pragma mark - CustomCell delegate methods

-(void)uploadClickedForSelectedCell:(NSInteger)cellIndex
{
    _data = (AudioData *)[fileArray objectAtIndex:cellIndex];
    selectedFileName = [_data.fileName stringByDeletingPathExtension];
    
    // Check whether already uploaded
    if(!_data.uploadStatus)
    {
        [self performSegueWithIdentifier:@"SavedToSignInIdentifier" sender:self];
    }
    else
    {
        UIAlertView *fileUploadAlertView = [[UIAlertView alloc]initWithTitle:MSG_ALREADY_UPLOADED message:nil  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [fileUploadAlertView show];

    }
        
}

-(void)deleteClickedForSelectedCell:(NSInteger)cellIndex updated:(BOOL)uploaded
{
    // Delete selected file 
    _data = (AudioData *)[fileArray objectAtIndex:cellIndex];
    fileToDelete = [_data.fileName stringByDeletingPathExtension];
    
       selectedCellIndex = cellIndex;
    //check to see if recording has been uploaded and if so, delete. If not, give the alert to notify the user that the file has not been uploaded.
    if (_data.uploadStatus) {
        if(![docData deleteRecordingFileWithName:[NSString stringWithFormat:@"%@.m4a",fileToDelete]])
        {
            NSLog(@" Error while deleting file in documents folder");
            return;
        }
        
        if(lastSelectedCellIndex == selectedCellIndex)
            lastSelectedCellIndex = -1; // remove the selection of cell
        else if(lastSelectedCellIndex > selectedCellIndex)
            lastSelectedCellIndex = lastSelectedCellIndex -1;
        
        
        // remove file from file array
        [fileArray removeObjectAtIndex:selectedCellIndex];
        
        // Delete file details from database
        [dbManager deleteFileFromDatabase:[fileToDelete stringByAppendingPathExtension:@"m4a"]];
        // reload the table after deletion
        
        NSArray *indexPaths = @[[NSIndexPath indexPathForRow:selectedCellIndex inSection:0]];
        
        if (fileArray.count > 0) {
            [self.recordingsTableView deleteRowsAtIndexPaths:indexPaths
                                            withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.recordingsTableView reloadData];
        }
        if(fileArray.count == 0)
            _listLabel.hidden = NO;
        
        
    


    }else{
        UIAlertView *fileDeleteAlertView = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:MSG_DELETE_FILE,_data.name] message:nil  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [fileDeleteAlertView show];
        

    }
}


#pragma mark - Button Actions

- (IBAction)addButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"addRecordingIdentifer" sender:self];
}
- (IBAction)lockButtonTapped:(UIButton *)sender
{
    [self enterPasscode];
//    NSString *passwordString = [[UserDefaults sharedUserDefaults]unlockPassword];
//    // check whether locked with password
//	if(passwordString.length != 0)
//    {
//        [self performSegueWithIdentifier:@"SavedIdentifier" sender:self];
//    }
//    else
//    {
//        UIAlertView *passwordAlertView = [[UIAlertView alloc]initWithTitle:nil message:MSG_SET_PASSWORD_ALERT  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//        [passwordAlertView show];
//    }
    

}

- (IBAction)deleteAndSettingsButtonTapped:(UIBarButtonItem*)sender{
    if ([sender.title isEqualToString:BUTTON_SETTINGS]) {

        [self performSegueWithIdentifier:@"SettingsIdentifier" sender:self];
        return;
    }


    // delete all files in the list
    if(fileArray.count > 0)
    {
        UIAlertView *deleteAllAlertView;
        if ([sender.title isEqualToString:BUTTON_DELETE])
            deleteAllAlertView = [[UIAlertView alloc] initWithTitle:MSG_DELETE_SELECTED message:nil  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:BUTTON_DELETE, nil];
        else
            deleteAllAlertView = [[UIAlertView alloc] initWithTitle:MSG_DELETE_ALL message:nil  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:BUTTON_DELETE, nil];

        [deleteAllAlertView show];
    }
    else
    {
        UIAlertView *noRecordAlertView = [[UIAlertView alloc]initWithTitle:@"No recordings" message:nil  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [noRecordAlertView show];
    }
 
}



- (IBAction)doneButtonTapped:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UIAlertView delegate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if([alertView.title isEqualToString:[NSString stringWithFormat:MSG_DELETE_FILE,_data.name]])
    {
        if(buttonIndex == INDEX_ONE)
        {
            [docData deleteRecordingFileWithName:[NSString stringWithFormat:@"%@.m4a", fileToDelete]];
            
            if(![docData deleteRecordingFileWithName:[NSString stringWithFormat:@"%@.m4a",fileToDelete]])
            {
                NSLog(@" Error while deleting file in documents folder");
                return;
            }
            
            if(lastSelectedCellIndex == selectedCellIndex)
                lastSelectedCellIndex = -1; // remove the selection of cell
            else if(lastSelectedCellIndex > selectedCellIndex)
                lastSelectedCellIndex = lastSelectedCellIndex -1;
            

            // remove file from file array
            [fileArray removeObjectAtIndex:selectedCellIndex];
            
            // Delete file details from database
            [dbManager deleteFileFromDatabase:[fileToDelete stringByAppendingPathExtension:@"m4a"]];
            // reload the table after deletion

            NSArray *indexPaths = @[[NSIndexPath indexPathForRow:selectedCellIndex inSection:0]];

            if (fileArray.count > 0) {
                [self.recordingsTableView deleteRowsAtIndexPaths:indexPaths
                                                withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [self.recordingsTableView reloadData];
            }
            if(fileArray.count == 0)
                _listLabel.hidden = NO;

            
        }
    }
    else if ([alertView.title isEqualToString:MSG_DELETE_ALL])
    {
        if(buttonIndex == INDEX_ONE)
        {
            UIAlertView *fileDeleteAlertView = [[UIAlertView alloc] initWithTitle:MSG_DELETE_PERMANENTLY message:nil  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:BUTTON_DELETE, nil];
            [fileDeleteAlertView show];
        }
    }
    else if ([alertView.title isEqualToString:MSG_DELETE_SELECTED])
    {
        if(buttonIndex == INDEX_ONE)
        {
            NSMutableArray *indexPaths = [self.recordingsTableView.indexPathsForSelectedRows mutableCopy];
            NSMutableIndexSet *indexesToRemove = [NSMutableIndexSet indexSet];
            for (NSIndexPath *indexPath in self.recordingsTableView.indexPathsForSelectedRows) {


                AudioData *data = (AudioData *) [fileArray objectAtIndex:(NSUInteger) indexPath.row];
                NSString *fileToDelete1 = [data.fileName stringByDeletingPathExtension];

                if(![docData deleteRecordingFileWithName:[NSString stringWithFormat:@"%@.m4a", fileToDelete1]])
                {
                    NSLog(@" Error while deleting file in documents folder");
                    [indexPaths removeObject:indexPath];
                }
                else {
                    [indexesToRemove addIndex:(NSUInteger) indexPath.row];
                }

                // Delete file details from database
                [dbManager deleteFileFromDatabase:[fileToDelete1 stringByAppendingPathExtension:@"m4a"]];
            }


            // remove file from file array
            [fileArray removeObjectsAtIndexes:indexesToRemove];

            if (fileArray.count > 0)
                [self.recordingsTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            else
                [self.recordingsTableView reloadData];

            [self.recordingsTableView setEditing:NO animated:YES];
        }
    }
    else if ([alertView.title isEqualToString:MSG_DELETE_PERMANENTLY])
    {
        if(buttonIndex == INDEX_ONE)
        {
            // Delete all files from documents folder
            [docData deleteAllFiles];
            
            // Delete all files from database
            [dbManager deleteAllFilesFromDatabase];
            
            // Delete from array
            [fileArray removeAllObjects];
            [self.recordingsTableView reloadData];
            _listLabel.hidden = NO;

            [self.recordingsTableView setEditing:NO animated:YES];
        }
    }
    else if ([alertView.title isEqualToString:MSG_ALREADY_UPLOADED])
    {
        if(buttonIndex == INDEX_ONE)
        {
            // If user wants to upload the already uploaded file , move to SignIn page
            [self performSegueWithIdentifier:@"SavedToSignInIdentifier" sender:self];
        }
    }
}

@end






