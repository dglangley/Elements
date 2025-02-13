//
//  SettingsViewController.m
//
//  Created by David Langley on 12/25/13.
//  Copyright (c) 2013 LunaCera, LLC. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIImageView+WebCache.h"
#import "AccountsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize homeViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Settings";
    [appDelegate addKeyboardBarWithOptions:NO];

    remotes = [[NSMutableArray alloc] init];//initWithObjects:@"N",@"Y",@"Y",@"Y",@"N",@"N",nil];
    
    self.settingsTableView.dataSource = self;
    self.settingsTableView.delegate = self;
    
    UIButton *logoutButton = [[UIButton alloc] init];
    [logoutButton.titleLabel setFont:DEFAULT_FONT(18)];
    [logoutButton setFrame:CGRectMake(10, self.tabBarController.tabBar.frame.origin.y-100, self.view.frame.size.width-20, 36)];
    [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(willSignout) forControlEvents:UIControlEventTouchUpInside];
    [logoutButton setBackgroundColor:[appDelegate color3]];
    [logoutButton setTitle:@"Sign Out" forState:UIControlStateNormal];
    [self.view addSubview:logoutButton];
    
    UILabel *disclosureLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, self.tabBarController.tabBar.frame.origin.y-35, self.view.frame.size.width-10, 30)];
    disclosureLabel.text = @"LunaCera is not affiliated with featured exchange sites, and acts only as a browser for mobile rendering with your exclusive membership to each respective site. For exchange site membership questions, please contact the broker sites directly.";
    disclosureLabel.font = [UIFont systemFontOfSize:10];
    disclosureLabel.textColor = [UIColor grayColor];
    disclosureLabel.numberOfLines = 0;
    disclosureLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:disclosureLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *urlString = [NSString stringWithFormat:@"%s/remotes.php?json=1", URL_ROOT];
    [appDelegate goURL:urlString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"connectionObserver" object:nil];
}

- (void)refreshView:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionObserver" object:nil];
    
    [self.settingsTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [appDelegate.remoteKeys count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    //return [remotes count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"ACCOUNTS";
    //return [appDelegate.remoteDescrs objectForKey:[appDelegate.remoteKeys objectAtIndex:section]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"settingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    UILabel *nameLabel = [[UILabel alloc] init];
    UILabel *helperLabel = [[UILabel alloc] init];
    UIImageView *cellImage = [[UIImageView alloc] init];
    UIImageView *lockImage = [[UIImageView alloc] init];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        [nameLabel setTag:11];
        [nameLabel setFrame:CGRectMake(40, 5, 280, 20)];
        [nameLabel setTextColor:[UIColor blackColor]];
        [nameLabel setFont:[UIFont systemFontOfSize:13]];
        
        [cellImage setTag:12];
        [cellImage setFrame:CGRectMake(5, 9, 24, 24)];
        
        [lockImage setTag:13];
        [lockImage setFrame:CGRectMake(self.view.frame.size.width-50, 11, 18, 18)];
        
        [helperLabel setTag:14];
        [helperLabel setFrame:CGRectMake(40, 20, 280, 20)];
        [helperLabel setTextColor:[UIColor lightGrayColor]];
        [helperLabel setFont:[UIFont systemFontOfSize:8]];
    }
    else
    {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:11];
        cellImage = (UIImageView *)[cell.contentView viewWithTag:12];
        lockImage = (UIImageView *)[cell.contentView viewWithTag:13];
        helperLabel = (UILabel *)[cell.contentView viewWithTag:14];
    }
    
    NSString *remoteKey = [appDelegate.remoteKeys objectAtIndex:indexPath.row];
    [nameLabel setText:[appDelegate.remoteDescrs objectForKey:remoteKey]];
    [cell.contentView addSubview:nameLabel];
    
    cellImage.image = [UIImage imageNamed:remoteKey];
    //NSURL *imgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.powersourceonline.com/favicon.ico"]];
    //[cellImage setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"no-picture.png"]];
    [cell.contentView addSubview:cellImage];
    
    if (! [appDelegate.jsonResults objectForKey:@"remotes"]
        || [[[[appDelegate.jsonResults objectForKey:@"remotes"] objectForKey:remoteKey] objectForKey:@"setting"] isEqualToString:@"N"])
    {
        lockImage.image = [UIImage imageNamed:@"locked"];
        [helperLabel setText:@"Enter your login and password to activate"];
    }
    else
    {
        //NSLog(@"key %@:%@",remoteKey, [[appDelegate.jsonResults objectForKey:@"remotes"] objectForKey:remoteKey]);

        [lockImage removeFromSuperview];
        lockImage.image = [UIImage imageNamed:@"checked_user"];
        [helperLabel setText:@"Activated!"];
    }
    [cell.contentView addSubview:lockImage];
    [cell.contentView addSubview:helperLabel];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
    
    /*
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
     */
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"accountsSegue" sender:indexPath];
    //commented 12/4/14
    /*
    if (indexPath.row == 0 || self.isPremiumAccount)
    {
        [self performSegueWithIdentifier:@"accountsSegue" sender:indexPath];
    }
    else
    {
        [self performSegueWithIdentifier:@"premiumSubscriptionSegue" sender:indexPath];
    }
     */
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (void)willSignout
{
    NSString *urlString = [NSString stringWithFormat:@"%s/signout.php?json=1", URL_ROOT];
    [appDelegate goURL:urlString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSignout) name:@"connectionObserver" object:nil];
}

- (void)didSignout
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionObserver" object:nil];
    [appDelegate deleteCookies];
    
    [self.tabBarController setSelectedIndex:0];
    [homeViewController.view setNeedsDisplay];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"accountsSegue"])
    {
        if (self.isPremiumAccount)
        {
            // something here for premium subscription slide-up
            return;
        }
        AccountsViewController *avc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.settingsTableView indexPathForSelectedRow];
        avc.brokerKey = [appDelegate.remoteKeys objectAtIndex:indexPath.row];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
