//
//  HomeViewController.h
//  Elements
//
//  Created by David Langley on 12/25/13.
//  Copyright (c) 2013 Langley Assets, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
//#import "PartDetailsViewController.h"
@class PartDetailsViewController;

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
{
    BOOL forceLoadResults;
    NSMutableArray *masterResults;
    BOOL userLongPressDetected;
    int pg;
    CGPoint lastScrollOffset;
    BOOL isLoadingOffsetResults;
}

@property (strong, nonatomic) NSMutableArray *results;
@property (strong, nonatomic) IBOutlet UITableView *resultsTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISegmentedControl *resultsTypeSegmentedControl;
- (IBAction)didChangeSegmentedControl:(id)sender;

-(void)refreshTableView;
-(void)synchronizeResultsWithRowData:(NSMutableDictionary *)rowData;

@end
