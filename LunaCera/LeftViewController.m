//
//  LeftViewController.m
//
//  Created by David Langley on 1/20/14.
//  Copyright (c) 2014 LunaCera, LLC. All rights reserved.
//

#import "LeftViewController.h"
#import "HomeViewController.h"

@interface LeftViewController ()

@end

@implementation LeftViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    sectionNames = [[NSArray alloc] initWithObjects:@"PURCHASES",@"SALES",@"COMPANIES", nil];
    sectionArrays = [[NSMutableArray alloc] initWithObjects:[[NSArray alloc] init], [[NSArray alloc] init], [[NSArray alloc] init], nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    NSString *urlString = [NSString stringWithFormat:@"%s/accounts.php", URL_ROOT];
    NSLog(@"accounts url %@",urlString);
    [appDelegate goURL:urlString];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAccounts) name:@"connectionObserver" object:nil];
}

- (void)loadAccounts
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionObserver" object:nil];

    if (! [appDelegate.jsonResults objectForKey:@"accounts"]) return;

    NSDictionary *accounts = [appDelegate.jsonResults objectForKey:@"accounts"];

    [sectionArrays replaceObjectAtIndex:0 withObject:[accounts objectForKey:@"purchases"]];
    [sectionArrays replaceObjectAtIndex:1 withObject:[accounts objectForKey:@"sales"]];
    [sectionArrays replaceObjectAtIndex:2 withObject:[accounts objectForKey:@"companies"]];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)];
    [self.accountsTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    //[self.accountsTableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"accountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    NSDictionary *list = [[sectionArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    //NSLog(@"row %@",list);

    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
    NSString *rowLabel = @"";
    if ([list objectForKey:@"order_number"])
    {
        rowLabel = [rowLabel stringByAppendingString:[NSString stringWithFormat:@"%@ ",[list objectForKey:@"order_number"]]];
    }
    rowLabel = [rowLabel stringByAppendingString:[list objectForKey:@"name"]];
    cell.textLabel.text = rowLabel;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //homeViewController = [self.navigationController.viewControllers objectAtIndex:0];
    /*
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HomeViewController *homeViewController = (HomeViewController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"HomeViewController"];
     */

    NSDictionary *textData;
    NSArray *splitter;
    switch (indexPath.section) {
        case 0:
        case 1:
            splitter = [cell.textLabel.text componentsSeparatedByString:@" "];
            //[self.navigationController pushViewController:homeViewController animated:YES];
            textData = [[NSDictionary alloc] initWithObjectsAndKeys:[splitter objectAtIndex:0], @"entry", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSearchBar" object:self userInfo:textData];
            break;
        case 2:
        default:
            textData = [[NSDictionary alloc] initWithObjectsAndKeys:cell.textLabel.text, @"entry", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSearchBar" object:self userInfo:textData];
            break;
    }
    
    [self.revealController resignPresentationModeEntirely:YES animated:YES completion:^(BOOL finished){
     //[self.revealController showViewController:self.revealController.leftViewController];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    //NSLog(@"section %d count %d",section, [[sectionArrays objectAtIndex:section] count]);
    return [[sectionArrays objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionNames objectAtIndex:section];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
