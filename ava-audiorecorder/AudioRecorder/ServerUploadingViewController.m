//
//  ServerUploadingViewController.m
//  AudioRecorder
//
//  
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import "ServerUploadingViewController.h"
#import "Constants.h"
#import "AudioRecorderAppDelegate.h"
#import "UserDefaults.h"
#import "ServerSession.h"
#import "DocumentsData.h"
#import "DatabaseManager.h"
#import "ServerSignInViewController.h"
#import "UploadProgressViewController.h"
#import "Passcode.h"

static NSUInteger lastIndexPath;
static NSIndexPath *selectedIndexPath;
static UserDefaults *userDefaults;

@interface ServerUploadingViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    NSArray *collectionIdArray;
    BOOL selectedCollection;
}
@property (retain, nonatomic)NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSURLSessionDataTask *connectTask;
@property (strong, nonatomic) IBOutlet UITextField *fileNameField;
@property (strong, nonatomic) IBOutlet UITableView *collectionTableView;
@property(nonatomic, strong) NSNumber *fileSize;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;

- (IBAction)changedUserPressed:(id)sender;


- (IBAction)closeButtonTapped:(id)sender;

- (IBAction)startUploadButtonTapped:(id)sender;
- (IBAction)lockButtonTapped:(id)sender;
- (void)reloadCollectionTable;

@end
int selectedCollectionId;
@implementation ServerUploadingViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        _collectionArray = [[NSMutableArray alloc]init];
  
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

#pragma mark - View Controller LifeCycle

-(void)viewWillAppear:(BOOL)animated
{
    
    
//    [userDefaults readUserDefaults];
//    if (userDefaults.selectedCollection !=nil) {
//        NSLog(@"SELECTED COLLECTION IS NOT NIL");
//        [_collectionTableView selectRowAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
//    }
//    NSLog(@"HAS SELECTED INDEX %@", userDefaults.selectedCollection);
//    if (selectedIndexPath !=nil) {
//
//        [self.collectionTableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
//    }
   // [_collectionTableView deselectRowAtIndexPath:[_collectionTableView indexPathForSelectedRow] animated:YES];
//    [_collectionTableView selectRowAtIndexPath:[_collectionTableView indexPathForSelectedRow] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self collectionRequestToServer];
    
    
    self.fileNameField.text = _nameString;
    //set the backBarButtonItem for the upload progress view controller
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    // Disable AutoCorrection in textfield
    _fileNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    //username assigned to label
    _userNameLabel.text = [[UserDefaults sharedUserDefaults]signInUserName];
    AudioRecorderAppDelegate *appDelegate=[AudioRecorderAppDelegate sharedDelegate];
    appDelegate.currentViewController=self;

    self.changeUserButton.layer.cornerRadius = 3.0;
    self.startUploadButton.layer.cornerRadius = 3.0;
    _startUploadButton.hidden = YES;
    
//    NSString *collectionId;
//    for(collectionId in collectionIdArray){
//        NSLog(@"ID: %@", collectionId);
//    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated
{
    
}
- (void)viewDidUnload {
    [self setFileNameField:nil];
    [self setCollectionTableView:nil];
    [super viewDidUnload];
}

#pragma mark - 
- (void)tapDetected:(UITapGestureRecognizer *)recognizer
{
    [self.fileNameField resignFirstResponder];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view.superview.superview isKindOfClass:[UITableViewCell class]]) {
        return NO;
    }
    else if ([touch.view.superview isKindOfClass:[UIToolbar class]])
        return NO;
    else if ([touch.view isKindOfClass:[UIButton class]])
        return NO;
    
    return YES;
}

-(void)saveEncryptedNameChange
{
    //NSData *dectryptedData = [self decryptedData];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *recordingsDirectory = [paths objectAtIndex:0];
    recordingsDirectory = [recordingsDirectory stringByAppendingPathComponent:@"Recordings"];
    NSString *oldFilePath = [recordingsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a", _nameString]];
    //_encryptionPassString = [[PDKeychain defaultKeychain]objectForKey:KEY_ENCRYPTION];
    //[[PDKeychain defaultKeychain]setObject:_encryptionPassString forKey:KEY_ENCRYPTION];
    //NSError *error;
    NSString *newFilePath = [recordingsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a", _fileNameField.text]];
    
    
    [[NSFileManager defaultManager]moveItemAtPath:oldFilePath toPath:newFilePath error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}
#pragma mark - UITextField delegate methods

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(_fileNameField.text.length == 0) // check for empty textfields
    {
        UIAlertView *emptyNameAlertView = [[UIAlertView alloc]initWithTitle:nil message:MSG_ENTER_SERVER_FILENAME delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [emptyNameAlertView show];
        self.fileNameField.text = _nameString;
        [textField becomeFirstResponder];

    }
 
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.fileNameField)
    {
		[self.fileNameField resignFirstResponder];
        if(_fileNameField.text.length == 0)
        {
            UIAlertView *emptyNameAlertView = [[UIAlertView alloc]initWithTitle:nil message:MSG_ENTER_SERVER_FILENAME delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [emptyNameAlertView show];
            self.fileNameField.text = _nameString;
            [textField becomeFirstResponder];


        }
      
    }
    
    return YES;
}

#pragma mark - 

- (void)collectionRequestToServer
{

    self.connectTask = [[ServerSession collectionSession] POST:URL_COLLECTION_REQUEST
                                                    parameters:nil
                                                       success:^(NSURLSessionDataTask *task, id collections) {
                                                           NSLog(@"Collection Response: %@", collections);

                                                           NSMutableArray *ids = [NSMutableArray array];
                                                           NSMutableArray *names = [NSMutableArray array];
                                                           for (NSArray *collection in collections) {
                                                               [ids addObject:[collection valueForKey:@"id"]];
                                                               [names addObject:[collection valueForKey:@"name"]];
                                                               
                                                           }

                                                           _collectionArray = collections;
                                                           collectionIdArray = ids;

                                                           // Reload collection table on response from server
                                                           [self reloadCollectionTable];
                                                           //get the saved row from the previously selected cell
                                                            lastIndexPath = [[NSUserDefaults standardUserDefaults]integerForKey:@"selectedRow"];
                                                           //create an indexPath from the previously selected row
                                                           selectedIndexPath = [NSIndexPath indexPathForRow:lastIndexPath inSection:0];
                                                           //select the previously selected row
                                                           [_collectionTableView selectRowAtIndexPath:selectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                                                           //notify the delegate that the tableview cell was selected.
                                                           [[_collectionTableView delegate]tableView:_collectionTableView didSelectRowAtIndexPath:selectedIndexPath];
                                                           //create new reference of cell with the last selected index path.
                                                           UITableViewCell *cell = [self.collectionTableView cellForRowAtIndexPath:selectedIndexPath];
                                                           [cell setSelected:YES animated:YES];
                                                           // Make custom accessoryview
                                                           UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_tick_btn.png"]];
                                                           imageView.frame = CGRectMake(0, 0, 20, 20);
                                                           //add accessory view to previously selected cell
                                                           cell.accessoryView = imageView;
                                                           //set start upload button to visible since a cell is automatically selected
                                                           _startUploadButton.hidden = NO;
//                                                           
                                                       }
                                                       failure:^(NSURLSessionDataTask *task, NSError *error) {
//                                                           [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
                                                           NSLog(@"Error retrieving collections");
                                                           NSLog(@"%@", [error localizedDescription]);
                                                           NSLog(@"%@", [error localizedFailureReason]);
                                                       }];

}


#pragma mark - Reload Table

-(void)reloadCollectionTable
{
    // Reload the collection table view
    [_collectionTableView reloadData];
    if([_collectionArray count] == 0)
    {
        UIAlertView *noCollectionAlertView = [[UIAlertView alloc]initWithTitle:nil message:MSG_NO_COLLECTION delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [noCollectionAlertView show];
    }
}

-(void)enterPasscode
{
    CustomPasscodeConfig *passCodeConfig = [[CustomPasscodeConfig alloc]init];
    
    
    passCodeConfig.navigationBarTitle = @"AVA Recorder";
    [Passcode setConfig:passCodeConfig];
    
    passCodeConfig.navigationBarBackgroundColor = [UIColor colorWithRed:0.32 green:0.75 blue:0.24 alpha:1.0];
    passCodeConfig.navigationBarTitleColor = [UIColor whiteColor];
    [Passcode showPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
        if (success && [Passcode isPasscodeSet]) {
            NSLog(@"PASSWORDS MATCH");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
}
#pragma mark - Button Actions

- (IBAction)startUploadButtonTapped:(UIButton *)sender
{
    if(_fileNameField.text.length!=0 && _collectionName.length!=0)
    {
       // [self saveEncryptedNameChange];
        [self performSegueWithIdentifier:@"uploadSegue" sender:self];
    }
    else if(_fileNameField.text.length == 0)
    {
        UIAlertView *emptyNameAlertView = [[UIAlertView alloc]initWithTitle:nil message:MSG_ENTER_SERVER_FILENAME delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [emptyNameAlertView show];
        [_fileNameField becomeFirstResponder];

    }
    else if(_collectionName.length == 0)
    {
        UIAlertView *noSelectionAlertView = [[UIAlertView alloc]initWithTitle:nil message:MSG_SELECT_COLLECTION delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [noSelectionAlertView show];
    }
}



- (IBAction)lockButtonTapped:(UIButton *)sender
{
    [self enterPasscode];

}


- (IBAction)changedUserPressed:(id)sender {
    [self performSegueWithIdentifier:@"changeUserSegue" sender:self];
}

- (IBAction)closeButtonTapped:(UIButton *)sender
{
    if(self.connectTask != nil) // If attempted request for collection, cancel request
    {
        NSLog(@"connectTask does not equal nil");
        [self.connectTask cancel]; // cancel request
        self.connectTask = nil;
    }
    if([self.sectionIdentifier isEqualToString:@"PlayBack"]) 
    {
        
        UIViewController *viewController=[self.navigationController.viewControllers objectAtIndex:1];

        [self.navigationController popToViewController:viewController animated:YES];
    }
    else if ([self.sectionIdentifier isEqualToString:@"SavedRecording"])
    {
        
        UIViewController *viewController=[self.navigationController.viewControllers objectAtIndex:1];
        [self.navigationController popToViewController:viewController animated:YES];
    }
    else if ([self.sectionIdentifier isEqualToString:@"NewRecording"])
    {
        
        UIViewController *viewController=[self.navigationController.viewControllers objectAtIndex:0];
        [self.navigationController popToViewController:viewController animated:YES];

    }else if([self.sectionIdentifier isEqualToString:@"SignIn"])
    {
        
        UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:0];
        [self.navigationController popToViewController:viewController animated:YES];
    }


}




#pragma mark - UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _collectionArray.count;
    
}
//this method sets the collection table separator to 15px from the left and right side of the table
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    if([cell respondsToSelector:@selector(setLayoutMargins:)]){
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
}
//this method handles the adjustment of the subviews for the tableview cell separators.
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if([self.collectionTableView respondsToSelector:@selector(setSeparatorInset:)]){
        //sets the inset of the cell seperator
        [self.collectionTableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
        
    }
    if([self.collectionTableView respondsToSelector:@selector(setLayoutMargins:)]){
        [self.collectionTableView setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *collectionTableCellIdentifier = @"CollectionTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:collectionTableCellIdentifier];
   [cell.textLabel setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 15)];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: collectionTableCellIdentifier];
    }
    //cell.textLabel.frame = CGRectMake(0, 0, 150, 30);
    //cell.textLabel.sizeToFit;
    
        cell.textLabel.text = [[_collectionArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        //if owner if upload only does not equal null
        if ([[_collectionArray objectAtIndex:indexPath.row] valueForKey:@"owner_if_upload_only"] != (id)[NSNull null])
        {
            cell.textLabel.text = [@"\u2757 " stringByAppendingString:cell.textLabel.text];
        }
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UserDefaults *getCollectionFromDefaults = [UserDefaults sharedUserDefaults];
    [getCollectionFromDefaults readUserDefaults];
    //if there is only one collection
        if(_collectionArray.count == 1)
        {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_tick_btn.png"]];
            imageView.frame = CGRectMake(0, 0, 20, 20);
            
            cell.accessoryView = imageView;
            _collectionId = [collectionIdArray objectAtIndex:indexPath.row];
            _collectionName = [[_collectionArray objectAtIndex:indexPath.row] valueForKey:@"name"];
   
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = nil;

        }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //reload collection table to handle deselection of last cell and selection of new one.
    [_collectionTableView reloadData];
//    if(selectedCollection)
//    {
//        UITableViewCell *cell = [self.collectionTableView cellForRowAtIndexPath:indexPath];
////        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastIndexPath inSection:0]];
//        cell = [self.collectionTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastIndexPath inSection:0]];
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.accessoryView = nil;
//        _startUploadButton.hidden = NO;
//        
//    }
    
    NSString *ownerIfUploadOnly = [[_collectionArray objectAtIndex:indexPath.row] valueForKey:@"owner_if_upload_only"];
    
    _collectionId = [collectionIdArray objectAtIndex:indexPath.row];
    _collectionName = [[_collectionArray objectAtIndex:indexPath.row] valueForKey:@"name"];
//    UserDefaults *defaults = [UserDefaults sharedUserDefaults];
//    [defaults setSelectedCollection:_collectionName];
//    [defaults saveUserDefaults];
    
    lastIndexPath = indexPath.row;
    self.selectedIndexPath = indexPath;
    
    if(ownerIfUploadOnly != (id)[NSNull null])
    {
        selectedCollection = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload-Only Collection"
                                                        message:[NSString stringWithFormat:@"This is an upload-only collection. Recordings you upload will not appear in your library and will be owned by %@.", ownerIfUploadOnly]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Continue", nil];
        [alert show];
    } else{
        //[_collectionTableView deselectRowAtIndexPath:indexPath animated:NO];
        UITableViewCell *cell = [self.collectionTableView cellForRowAtIndexPath:indexPath];
        [cell setSelected:YES animated:NO];
        // Make custom accessoryview
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_tick_btn.png"]];
        imageView.frame = CGRectMake(0, 0, 20, 20);
        cell.accessoryView = imageView;
        selectedCollection = YES;
        _startUploadButton.hidden = NO;
        lastIndexPath = [tableView indexPathForSelectedRow];
        _selectedIndexPath = [self.collectionTableView indexPathForSelectedRow];
        userDefaults.selectedCollection = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
        [userDefaults saveUserDefaults];
        [[NSUserDefaults standardUserDefaults]setInteger:indexPath.row forKey:@"selectedRow"];
        
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView firstOtherButtonIndex]) {
        UITableViewCell *cell = [_collectionTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastIndexPath inSection:0]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_tick_btn.png"]];
        imageView.frame = CGRectMake(0, 0, 20, 20);
        cell.accessoryView = imageView;
        selectedCollection = YES;
    } else {
        _collectionId = nil;
        _collectionName = nil;
        lastIndexPath = nil;
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"changeUserSegue"]) {
        NSString *name = _fileNameField.text;
        ServerSignInViewController *signIn = segue.destinationViewController;
        signIn.recordingName = name;
        signIn.fileName = _fileName;
    }else if([segue.identifier isEqualToString:@"uploadSegue"]){
        
        UploadProgressViewController *upload = segue.destinationViewController;
        upload.fileNameString = _fileNameField.text;
        upload.userName = _userNameLabel.text;
        upload.collectionName = _collectionName;
        upload.collectionId = _collectionId;
        upload.fileName = _fileName;
        UIBarButtonItem *uploadBackButton = [[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationItem setBackBarButtonItem:uploadBackButton];
        
    }
}


@end
