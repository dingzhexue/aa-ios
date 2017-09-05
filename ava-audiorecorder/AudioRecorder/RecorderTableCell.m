//
//  RecorderTableCell.m
//  AudioRecorder
//
//  Copyright (c) 2013 People Designs Inc. All rights reserved.
//  
//

#import "RecorderTableCell.h"

@implementation RecorderTableCell

@synthesize fileName;
@synthesize recordDate;
@synthesize lengthOfRecord;
@synthesize uploaded;
@synthesize delegate;
@synthesize deleteButton;
@synthesize uploadButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        UIView *cellSelectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
//        cellSelectedBackgroundView.backgroundColor = [UIColor colorWithRed:246.0 green:250.0 blue:246.0 alpha:1.0];
//        self.selectedBackgroundView = cellSelectedBackgroundView;
    }
    return self;
}


- (IBAction)uploadClicked:(UIButton *)sender
{
    [delegate uploadClickedForSelectedCell:[self getIndexPath].row];
}

- (IBAction)deleteClicked:(UIButton *)sender
{
    [delegate deleteClickedForSelectedCell:[self getIndexPath].row];
}

- (NSIndexPath *)getIndexPath {
    NSIndexPath *cellIndexPath;

    // iOS7 added an additional parent wrapper view, so we need parent of parent to get the table view
    if(NSClassFromString(@"UITableViewWrapperView")) {
        cellIndexPath = [(UITableView *) self.superview.superview indexPathForCell:self];
    } else {
        cellIndexPath = [(UITableView *) self.superview indexPathForCell:self];
    }
    return cellIndexPath;
}
@end
