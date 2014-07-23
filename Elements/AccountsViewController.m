//
//  AccountsViewController.m
//  Elements
//
//  Created by David Langley on 7/23/14.
//  Copyright (c) 2014 Langley Assets, LLC. All rights reserved.
//

#import "AccountsViewController.h"

@interface AccountsViewController ()

@end

@implementation AccountsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = self.remoteSegmentedControl;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self getRemoteSettings];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void)textFieldEditingDidEnd:(UITextField *)textField
{
    NSIndexPath *indexPath = [self indexPathForCellContainingView:textField];
    
    [self saveRemote:indexPath];
}
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


- (void)getRemoteSettings
{
    if (! [appDelegate.jsonResults objectForKey:@"remotes"]) return;
    
    remoteSettings = [appDelegate.jsonResults objectForKey:@"remotes"];
    
    if ([[[remoteSettings objectForKey:self.brokerKey] objectForKey:@"setting"] isEqualToString:@"Y"])
    {
        self.remoteSegmentedControl.selectedSegmentIndex = 1;
    }
    else
    {
        self.remoteSegmentedControl.selectedSegmentIndex = 0;
    }
    
    /*
    for (int i = 0; i < 6; i++)
    {
        // determine if we're replacing objects or adding
        if ([remotes count] > i)
        {
            [remotes replaceObjectAtIndex:i withObject:[remoteSettings objectForKey:[appDelegate.remoteKeys objectAtIndex:i]]];
        }
        else
        {
            [remotes insertObject:[remoteSettings objectForKey:[appDelegate.remoteKeys objectAtIndex:i]] atIndex:i];
        }
    }
    [self.settingsTableView reloadData];
     */
    //[self.settingsTableView reloadSections:0 withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)saveRemote
{
    NSMutableArray *creds = [[NSMutableArray alloc] initWithObjects:@"",@"", nil];//login and password objects
    
    NSString *remoteSetting = @"N";
    if (self.remoteSegmentedControl.selectedSegmentIndex == 1) remoteSetting = @"Y";
    
    NSString *urlString = [NSString stringWithFormat:@"%s/drop/remotes.php?remote=%@&remote_setting=%@&remote_login=%@&remote_password=%@", URL_ROOT, self.brokerKey, remoteSetting, [creds objectAtIndex:0], [creds objectAtIndex:1]];
    NSLog(@"save remote url %@",urlString);
    [appDelegate goURL:urlString];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"connectionObserver" object:nil];
}

- (IBAction)remoteSegmentedControlDidChange:(id)sender
{
    [self saveRemote];
}

@end
