//
//  AccountsViewController.m
//
//  Created by David Langley on 7/23/14.
//  Copyright (c) 2014 LunaCera, LLC. All rights reserved.
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
    [appDelegate addKeyboardBarWithOptions:NO];
    
    self.accountsTableView.dataSource = self;
    self.accountsTableView.delegate = self;
    
    /* Unselected background */
    /*
    UIImage *unselectedBackgroundImage = [[UIImage imageNamed:@"remoteGo"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [[UISegmentedControl appearance] setBackgroundImage:unselectedBackgroundImage
                                               forState:UIControlStateNormal
                                             barMetrics:UIBarMetricsDefault];
    */
    /* Selected background */
    /*
    UIImage *selectedBackgroundImage = [[UIImage imageNamed:@"remotePause"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [[UISegmentedControl appearance] setBackgroundImage:selectedBackgroundImage
                                               forState:UIControlStateSelected
                                             barMetrics:UIBarMetricsDefault];
     */
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"settingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    UILabel *cellLabel = [[UILabel alloc] init];
    UITextField *cellTextField = [[UITextField alloc] init];
    NSString *fieldHolder;
    
    if (indexPath.row == 0)
    {
        fieldHolder = @"Login";
    }
    else if (indexPath.row == 1)
    {
        fieldHolder = @"Password";
    }
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        [cellLabel setTag:11];
        [cellLabel setFrame:CGRectMake(10, 10, 80, 20)];
        [cellLabel setFont:[UIFont systemFontOfSize:14]];
        [cellLabel setTextColor:[UIColor darkGrayColor]];
        [cellTextField setTag:12];
        [cellTextField setFrame:CGRectMake(100, 11, 210, 20)];
        [cellTextField setPlaceholder:[fieldHolder lowercaseString]];
        [cellTextField setText:[[remoteSettings objectForKey:self.brokerKey] objectForKey:[fieldHolder lowercaseString]]];
        [cellTextField setFont:[UIFont systemFontOfSize:14]];
        cellTextField.inputAccessoryView = appDelegate.keyboardToolbar;
    }
    else
    {
        cellLabel = (UILabel *)[cell.contentView viewWithTag:11];
        cellTextField = (UITextField *)[cell.contentView viewWithTag:12];
    }
    cellLabel.text = fieldHolder;
    
    cellTextField.secureTextEntry = NO;
    if ([fieldHolder isEqualToString:@"Password"]) cellTextField.secureTextEntry = YES;

    [cell addSubview:cellLabel];
    [cell addSubview:cellTextField];
    
    return cell;
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
    
    NSString *urlString = [NSString stringWithFormat:@"%s/remotes.php?remote=%@&remote_setting=%@&remote_login=%@&remote_password=%@", URL_ROOT, self.brokerKey, remoteSetting, [creds objectAtIndex:0], [creds objectAtIndex:1]];
    NSLog(@"save remote url %@",urlString);
    [appDelegate goURL:urlString];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"connectionObserver" object:nil];
}

- (IBAction)remoteSegmentedControlDidChange:(id)sender
{
    [self saveRemote];
}

@end
