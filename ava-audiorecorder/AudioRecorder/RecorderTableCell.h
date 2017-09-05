//
//  RecorderTableCell.h
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//
#import <UIKit/UIKit.h>

@protocol CustomCellDelegate <NSObject>

@optional

-(void)uploadClickedForSelectedCell:(NSInteger)cellIndex;
-(void)deleteClickedForSelectedCell:(NSInteger)cellIndex;

@end


@interface RecorderTableCell : UITableViewCell
{
    id<CustomCellDelegate>delegate;
}
@property (strong, nonatomic)id<CustomCellDelegate>delegate;
@property (strong, nonatomic) IBOutlet UILabel *fileName;
@property (strong, nonatomic) IBOutlet UILabel *recordDate;
@property (strong, nonatomic) IBOutlet UILabel *lengthOfRecord;
@property (strong, nonatomic) IBOutlet UILabel *uploaded;
@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

- (IBAction)uploadClicked:(id)sender;
- (IBAction)deleteClicked:(id)sender;

- (NSIndexPath *)getIndexPath;
@end
