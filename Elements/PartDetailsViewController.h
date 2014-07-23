//
//  PartDetailsViewController.h
//  Elements
//
//  Created by David Langley on 1/5/14.
//  Copyright (c) 2014 Langley Assets, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "HomeViewController.h"

@class RecordsManagerViewController;

@interface PartDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>
{
//    UIPickerView *pricePicker;
    NSArray *salesArray;
    NSArray *purchArray;
    NSArray *availArray;
    NSArray *marketArray;
    NSString *today;
    HomeViewController *homeViewController;
    BOOL userLongPressDetected;
    NSMutableArray *datesArray;
    NSMutableDictionary *datedRows;
}

@property (strong, nonatomic) IBOutlet UITextField *qtyTextField;
@property (strong, nonatomic) IBOutlet UILabel *descrLabel;
@property (strong, nonatomic) IBOutlet UITextField *priceTextField;
//@property (strong, nonatomic) IBOutlet UIButton *priceButton;
@property (strong, nonatomic) IBOutlet UISegmentedControl *categorySegmentedControl;
@property (strong, nonatomic) IBOutlet UITableView *resultsTableView;

@property (strong, nonatomic) NSIndexPath *resultsIndexPath;
@property (strong, nonatomic) NSMutableDictionary *partDictionary;

//- (IBAction)didSelectPrice:(id)sender;
- (IBAction)didChangeSegmentedControl:(id)sender;

@end
