//
//  SettingsViewController.m
//  Elements
//
//  Created by David Langley on 12/25/13.
//  Copyright (c) 2013 Langley Assets, LLC. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = @"Settings";
    [appDelegate addKeyboardBarWithOptions:NO];

    brokerSites = [[NSArray alloc] initWithObjects:@"PowerSource",@"BrokerBin",@"Tel-Explorer", nil];
    remoteDescrs = [[NSDictionary alloc] initWithObjectsAndKeys:@"FirstPoint",@"fp",@"E&M",@"em",@"North Georgia",@"ngt",@"Tel-Explorer",@"te",@"PowerSource",@"ps",@"BrokerBin",@"bb", nil];
    remoteNames = [[NSArray alloc] initWithObjects:@"fp",@"em",@"ngt",@"te",@"ps",@"bb", nil];
    remotes = [[NSMutableArray alloc] init];//initWithObjects:@"N",@"Y",@"Y",@"Y",@"N",@"N",nil];
    
    self.settingsTableView.dataSource = self;
    self.settingsTableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *urlString = [NSString stringWithFormat:@"%s/drop/remotes.php", URL_ROOT];
    [appDelegate goURL:urlString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"connectionObserver" object:nil];
}

- (void)refreshView:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionObserver" object:nil];

    if (! [appDelegate.jsonResults objectForKey:@"remotes"]) return;

    NSDictionary *remoteDict = [appDelegate.jsonResults objectForKey:@"remotes"];
    //NSLog(@"dict %@",remoteDict);
    
    for (int i = 0; i < 6; i++)
    {
        // determine if we're replacing objects or adding
        if ([remotes count] > i)
        {
            [remotes replaceObjectAtIndex:i withObject:[remoteDict objectForKey:[remoteNames objectAtIndex:i]]];
        }
        else
        {
            [remotes insertObject:[remoteDict objectForKey:[remoteNames objectAtIndex:i]] atIndex:i];
        }
    }
    //NSLog(@"remote %@",remotes);
    [self.settingsTableView reloadData];
    //[self.settingsTableView reloadSections:0 withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
    /*
    if (section == 0)
    {
        return 6;
    }
    else
    {
        return 3;
    }
     */
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [remotes count];
    //return [brokerSites count]+1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [remoteDescrs objectForKey:[remoteNames objectAtIndex:section]];
    /*
    if (section == 0)
    {
        return @"REMOTES";
    }
    else
    {
        return [brokerSites objectAtIndex:section-1];
    }
     */
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId;
    UITableViewCell *cell;
    UITextField *cellTextField = [[UITextField alloc] initWithFrame:CGRectMake(14, 12, self.settingsTableView.frame.size.width-100, 20)];
    NSInteger cellTag = indexPath.row+1;

    if (indexPath.row == 0)
    {
        UISwitch *remoteSwitch;
        BOOL remoteOn;
        
        cellId = @"loginCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        //NSLog(@"remote %@",remotes);
        remoteSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-58,7,40,10)];
        if ([[[remotes objectAtIndex:indexPath.section] objectForKey:@"setting"] isEqualToString:@"Y"]) { remoteOn = YES; }
        else { remoteOn = NO; }
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
            
            cellTextField.tag = cellTag;
            remoteSwitch.tag = -1;
            remoteSwitch.transform = CGAffineTransformMakeScale(0.70, 0.70);
            [remoteSwitch setOn:remoteOn];
            [remoteSwitch addTarget:self action:@selector(didChangeRemoteToggle:) forControlEvents:UIControlEventValueChanged];
        }
        else
        {
            cellTextField = (UITextField *)[cell.contentView viewWithTag:cellTag];
            remoteSwitch = (UISwitch *)[cell.contentView viewWithTag:-1];
            [remoteSwitch setOn:remoteOn];
        }
        cellTextField.secureTextEntry = NO;
        cellTextField.text = [[remotes objectAtIndex:indexPath.section] objectForKey:@"login"];

        [cell.contentView addSubview:remoteSwitch];
    }
    else if (indexPath.row == 1)
    {
        cellId = @"passwordCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
            
            cellTextField.tag = cellTag;
        }
        else
        {
            cellTextField = (UITextField *)[cell.contentView viewWithTag:cellTag];
        }
        cellTextField.secureTextEntry = YES;
        cellTextField.text = [[remotes objectAtIndex:indexPath.section] objectForKey:@"password"];

    }
    cellTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    cellTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [cellTextField addTarget:self action:@selector(textFieldEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
    cellTextField.inputAccessoryView = appDelegate.keyboardToolbar;
    [cell.contentView addSubview:cellTextField];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didChangeRemoteToggle:(id) sender
{
    // declare the switch by its type based on the sender element
    UISwitch *switchIsPressed = (UISwitch *)sender;
    // get the indexPath of the cell containing the switch
    NSIndexPath *indexPath = [self indexPathForCellContainingView:switchIsPressed];

    [self saveRemote:indexPath];// :[sender isOn]];
}

- (void)textFieldEditingDidEnd:(UITextField *)textField
{
    NSIndexPath *indexPath = [self indexPathForCellContainingView:textField];

    [self saveRemote:indexPath];
}

- (void)saveRemote:(NSIndexPath *)indexPath
{
    NSMutableArray *creds = [[NSMutableArray alloc] initWithObjects:@"",@"", nil];//login and password objects
    
    // get remote login and password by iterating through cells in this section
    NSIndexPath *cellIndexPath;
    UITableViewCell *cell;
    UITextField *cellTextField;
    UISwitch *remoteSwitch;
    for (int row = 0; row < [self.settingsTableView numberOfRowsInSection:indexPath.section]; row++)
    {
        cellIndexPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
        cell = [self.settingsTableView cellForRowAtIndexPath:cellIndexPath];
        cellTextField = (UITextField *)[cell.contentView viewWithTag:row+1];
        [creds replaceObjectAtIndex:row withObject:cellTextField.text];
        
        if (row != 0) continue;
        
        // handle toggle switch
        remoteSwitch = (UISwitch *)[cell.contentView viewWithTag:-1];
    }

    NSString *remoteSetting = @"N";
    if ([remoteSwitch isOn]) remoteSetting = @"Y";
    
    // look up the value of the item that is referenced by the switch - this
    // is from my datasource for the table view
    NSString *remoteName = [remoteNames objectAtIndex:indexPath.section];
    
    NSString *urlString = [NSString stringWithFormat:@"%s/drop/remotes.php?remote=%@&remote_setting=%@&remote_login=%@&remote_password=%@", URL_ROOT, remoteName, remoteSetting, [creds objectAtIndex:0], [creds objectAtIndex:1]];
    NSLog(@"ignitor url %@",urlString);
    [appDelegate goURL:urlString];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"connectionObserver" object:nil];
}

- (NSIndexPath *)indexPathForCellContainingView:(UIView *)view
{
    while (view != nil) {
        //NSLog(@"log %@",view);
        if ([view isKindOfClass:[UITableViewCell class]]) {
            return [self.settingsTableView indexPathForCell:(UITableViewCell *)view];
        } else {
            view = [view superview];
        }
    }
    
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
