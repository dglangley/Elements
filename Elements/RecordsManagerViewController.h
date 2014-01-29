//
//  RecordsManagerViewController.h
//  Elements
//
//  Created by David Langley on 1/5/14.
//  Copyright (c) 2014 Langley Assets, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "HomeViewController.h"

@interface RecordsManagerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
{
    NSDictionary *companyData;
    UIDatePicker *dateTimePicker;
    HomeViewController *homeViewController;
}

@property (strong, nonatomic) IBOutlet UITableView *recordsTableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell0;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell1;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell2;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell3;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell4;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell5;

//@property (nonatomic, assign) NSInteger recordCategoryId;
@property (strong, nonatomic) UIPickerView *companyPicker;
@property (strong, nonatomic) NSArray *recordArray;
@property (strong, nonatomic) NSMutableArray *companyArray;
@property (strong, nonatomic) NSIndexPath *resultsIndexPath;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *emailButton;

- (IBAction)saveRecord:(id)sender;
- (IBAction)startEmail:(id)sender;

@end
