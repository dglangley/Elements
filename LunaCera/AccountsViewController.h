//
//  AccountsViewController.h
//
//  Created by David Langley on 7/23/14.
//  Copyright (c) 2014 LunaCera, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface AccountsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSDictionary *remoteSettings;
}

@property (strong, nonatomic) IBOutlet UITableView *accountsTableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *remoteSegmentedControl;
@property (strong, nonatomic) NSString *brokerKey;

- (IBAction)remoteSegmentedControlDidChange:(id)sender;

@end
