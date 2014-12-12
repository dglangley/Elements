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
    [self.navigationController.navigationBar setTintColor:appDelegate.color2];
    
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
    NSString *fieldHolder = @"";
    int textfieldTag = 0;
    
    if (indexPath.row == 0)
    {
        fieldHolder = @"Login";
        textfieldTag = 12;
    }
    else if (indexPath.row == 1)
    {
        fieldHolder = @"Password";
        textfieldTag = 13;
    }
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        [cellLabel setTag:11];
        [cellLabel setFrame:CGRectMake(10, 10, 80, 20)];
        [cellLabel setFont:DEFAULT_FONT(15)];
        [cellLabel setTextColor:[UIColor darkGrayColor]];
    }
    else
    {
        cellLabel = (UILabel *)[cell.contentView viewWithTag:11];
    }
    [cellLabel setText:fieldHolder];//this is the helper label, which mirrors the placeholder text

    [cellTextField setFrame:CGRectMake(100, 11, 210, 20)];
    [cellTextField setPlaceholder:[fieldHolder lowercaseString]];
    [cellTextField setFont:DEFAULT_FONT(15)];
    [cellTextField setInputAccessoryView:appDelegate.keyboardToolbar];
    [cellTextField setText:[[remoteSettings objectForKey:self.brokerKey] objectForKey:[fieldHolder lowercaseString]]];
    [cellTextField setTag:textfieldTag];
    [cellTextField setSecureTextEntry:NO];
    
    if ([fieldHolder isEqualToString:@"Password"]) [cellTextField setSecureTextEntry:YES];

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
    //NSMutableArray *creds = [[NSMutableArray alloc] initWithObjects:@"",@"", nil];//login and password objects
    
    NSString *remoteSetting = @"N";
    UITextField *loginField = (UITextField *)[self.view viewWithTag:12];
    UITextField *passwordField = (UITextField *)[self.view viewWithTag:13];
    NSString *remoteLogin = [appDelegate stringByEncodingAmpersands:[[[NSString stringWithFormat:@"%@", loginField.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *remotePassword = [appDelegate stringByEncodingAmpersands:[[NSString stringWithFormat:@"%@", passwordField.text]  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if (self.remoteSegmentedControl.selectedSegmentIndex == 1)
    {
        // must have login and password if the user is switching to on
        if ([remoteLogin isEqualToString:@""] || [remotePassword isEqualToString:@""])
        {
            self.remoteSegmentedControl.selectedSegmentIndex = 0;
            UIAlertView *alertSuccessful = [[UIAlertView alloc] initWithTitle:@"Did you forget?" message:@"Please enter your login and password to activate this module" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertSuccessful show];
            return;
        }
        remoteSetting = @"Y";
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%s/remotes.php?remote=%@&remote_setting=%@&remote_login=%@&remote_password=%@", URL_ROOT, self.brokerKey, remoteSetting, remoteLogin, remotePassword];
    NSLog(@"save remote url %@",urlString);
    [appDelegate goURL:urlString];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"connectionObserver" object:nil];
}

- (IBAction)remoteSegmentedControlDidChange:(id)sender
{
    [self saveRemote];
}

@end
