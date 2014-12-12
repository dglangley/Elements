//
//  SettingsViewController.h
//
//  Created by David Langley on 12/25/13.
//  Copyright (c) 2013 LunaCera, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "HomeViewController.h"

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *remotes;
}
@property (strong, nonatomic) IBOutlet UITableView *settingsTableView;
@property (nonatomic) BOOL isPremiumAccount;
@property (strong, nonatomic) HomeViewController *homeViewController;

@end
