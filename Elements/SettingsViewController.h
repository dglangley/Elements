//
//  SettingsViewController.h
//  Elements
//
//  Created by David Langley on 12/25/13.
//  Copyright (c) 2013 Langley Assets, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *remotes;
}
@property (strong, nonatomic) IBOutlet UITableView *settingsTableView;

@end
