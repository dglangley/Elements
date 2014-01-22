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
    
    self.navigationItem.title = @"Login Settings";

    brokerSites = [[NSArray alloc] initWithObjects:@"PowerSource",@"BrokerBin",@"Tel-Explorer", nil];
    remoteNames = [[NSArray alloc] initWithObjects:@"fp",@"em",@"ngt",@"te",@"ps",@"bb", nil];
    remotes = [[NSMutableArray alloc] initWithObjects:@"N",@"Y",@"Y",@"Y",@"N",@"N",nil];
    
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
    
    for (int i = 0; i < 6; i++)
    {
        [remotes replaceObjectAtIndex:i withObject:[remoteDict objectForKey:[remoteNames objectAtIndex:i]]];
    }
    //NSLog(@"remote %@",remotes);
    [self.settingsTableView reloadData];
    //[self.settingsTableView reloadSections:0 withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 6;
    }
    else
    {
        return 3;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [brokerSites count]+1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"REMOTES";
    }
    else
    {
        return [brokerSites objectAtIndex:section-1];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId;
    UITableViewCell *cell;
    UILabel *remoteLabel;
    UISwitch *remoteSwitch;
    BOOL remoteOn;
    if (indexPath.section == 0)
    {
        cellId = @"remotesCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];

        remoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 12, 40, 20)];
        remoteSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-58,7,40,10)];
        if ([[remotes objectAtIndex:indexPath.row] isEqualToString:@"Y"])
        {
            remoteOn = YES;
        }
        else
        {
            remoteOn = NO;
        }
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
            
            remoteLabel.tag = 1;
            remoteSwitch.tag = 2;
            remoteSwitch.transform = CGAffineTransformMakeScale(0.70, 0.70);
            [remoteSwitch setOn:remoteOn];
            [remoteSwitch addTarget:self action:@selector(didChangeRemoteToggle:) forControlEvents:UIControlEventValueChanged];
        }
        else
        {
            remoteLabel = (UILabel *)[cell.contentView viewWithTag:1];
            remoteSwitch = (UISwitch *)[cell.contentView viewWithTag:2];
            [remoteSwitch setOn:remoteOn];
        }
        
        remoteLabel.text = [[remoteNames objectAtIndex:indexPath.row] uppercaseString];
        [cell.contentView addSubview:remoteLabel];
        [cell.contentView addSubview:remoteSwitch];
    }
    else
    {
        cellId = @"settingsCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];

    }
    
    return cell;
}

- (void)didChangeRemoteToggle:(id) sender
{
    // declare the switch by its type based on the sender element
    UISwitch *switchIsPressed = (UISwitch *)sender;
    // get the indexPath of the cell containing the switch
    NSIndexPath *indexPath = [self indexPathForCellContainingView:switchIsPressed];
    
    // look up the value of the item that is referenced by the switch - this
    // is from my datasource for the table view
    NSString *remoteName = [remoteNames objectAtIndex:indexPath.row];
    NSString *remoteSetting = @"N";
    if ([sender isOn]) remoteSetting = @"Y";
    NSString *urlString = [NSString stringWithFormat:@"%s/drop/remotes.php?remote=%@&remote_setting=%@", URL_ROOT, remoteName, remoteSetting];
    NSLog(@"ignitor url %@",urlString);
    [appDelegate goURL:urlString];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"connectionObserver" object:nil];
}

- (NSIndexPath *)indexPathForCellContainingView:(UIView *)view {
    while (view != nil) {
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
