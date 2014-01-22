//
//  HomeViewController.m
//  Elements
//
//  Created by David Langley on 12/25/13.
//  Copyright (c) 2013 Langley Assets, LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "PartDetailsViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

//@synthesize searchBar;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if (URL_ROOT == "http://david.local")
    {
        [self.navigationController.navigationBar setBackgroundColor:[UIColor redColor]];
    }
    self.navigationItem.title = @"Elements";
    
    /*
    UIImage *listButtonImage = [UIImage imageNamed:@"listButtonBlue.png"];
    UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [listButton setFrame:CGRectMake(80, 80, listButtonImage.size.width, listButtonImage.size.height)];
    [listButton setBackgroundImage:listButtonImage forState:UIControlStateNormal];
    [listButton addTarget:self.revealController action:@selector(showLeftViewController) forControlEvents:UIControlEventTouchUpInside];
    self.leftNavButton = [[UIBarButtonItem alloc] initWithCustomView:listButton];
    [self.navigationItem setLeftBarButtonItem:self.leftNavButton];
     */

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
    }
    
    self.resultsTypeSegmentedControl.selectedSegmentIndex = 0;
    
    [appDelegate addKeyboardBarWithOptions:NO];
    self.searchBar.inputAccessoryView = appDelegate.keyboardToolbar;

    //call the refresh function
    [appDelegate.refreshControl addTarget:self action:@selector(refreshTableView)
                  forControlEvents:UIControlEventValueChanged];
    [self.resultsTableView addSubview:appDelegate.refreshControl];
    
    // initialize
    masterResults = [[NSMutableArray alloc] init];
    
    forceLoadResults = YES;
    [self loadResults];

    // set observer for updates from the next view so our data source can be updated automatically
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(simpleRefreshSection) name:@"updateHomeResults" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSearchBar:) name:@"updateSearchBar" object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    
    //[jsonResults valueForKey:@"hosts"]
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([self.searchBar.text isEqualToString:@""])
    {
        // confirm live results if depressed
        if (self.resultsTypeSegmentedControl.selectedSegmentIndex == 1)
        {
            [self confirmLiveResults];
        }
        else
        {
            forceLoadResults = NO;
            [self didLoadResultsWithPartId:@""];
        }
    }
    else
    {
        [self loadResults];
    }
    [self.view resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    return;//for now, no methods auto-load results below
    /*
    if (! [searchText isEqualToString:@""]) return;
    
    [self loadResults];
     */
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    //self.resultsTableView.allowsSelection = NO;
    //self.resultsTableView.scrollEnabled = NO;
    
    UITextField *searchBarTextField = nil;
    for (UIView *view in self.searchBar.subviews)
    {
        for (UIView *subview in view.subviews)
        {
            if ([subview isKindOfClass:[UITextField class]]) {
                searchBarTextField = (UITextField *)subview;
                break;
            }
        }
    }
    

    if (searchBarTextField == nil) return;
    
    searchBarTextField.enablesReturnKeyAutomatically = NO;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO];
}

- (void)loadResults
{
    forceLoadResults = YES;
    [self didLoadResultsWithPartId:@""];
}

- (void)didLoadResultsWithPartId : (NSString *)partId
{
    //[self.results removeAllObjects];
    if ([self.searchBar.text isEqualToString:@""] && [partId isEqualToString:@""])
    {
        //NSLog(@"%d %d %hhd", self.resultsTypeSegmentedControl.selectedSegmentIndex, [masterResults count], forceLoadResults);
        if (self.resultsTypeSegmentedControl.selectedSegmentIndex == 0
            && [masterResults count] > 0 && forceLoadResults == NO)
        {
            //NSLog(@"count %d, %d", [masterResults count], [self.results count]);
            self.results = masterResults;//[masterResults mutableCopy];
            [self simpleRefreshSection];

            return;
        }
        else if (self.resultsTypeSegmentedControl.selectedSegmentIndex == 1)
        {
            // probably want to prompt for something here
            return;
        }
    }
        
    NSString *searchString = [[NSString stringWithFormat:@"%@", self.searchBar.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *urlString = [NSString stringWithFormat:@"%s/drop/search.php?search=%@&partid=%@&results_type=%ld", URL_ROOT, searchString, partId, (long)self.resultsTypeSegmentedControl.selectedSegmentIndex];
    NSLog(@"home url %@",urlString);
    [appDelegate goURL:urlString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"connectionObserver" object:nil];
    //[appDelegate addUniqueObserver:self selector:@selector(refreshView:) name:@"connectionObserver" object:nil];
}

- (void)simpleRefreshSection
{
    // to make this more than one section, change the 0,1 to x,y
    // where x is the first section you want to change and y is
    // the number of sections proceeding from that initial section
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
    [self.resultsTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)refreshView:(NSNotification *) notification
{
    if (forceLoadResults == YES)
    {
        if (! [appDelegate.jsonResults objectForKey:@"results"]) return;
        
        self.results = [appDelegate.jsonResults objectForKey:@"results"];
        if ([masterResults count] == 0 && [self.searchBar.text isEqualToString:@""]
            && self.resultsTypeSegmentedControl.selectedSegmentIndex == 0)
        {
            masterResults = self.results;
        }
    }
    forceLoadResults = NO;
    
    [self simpleRefreshSection];
    
    if (! [self.searchBar.text isEqualToString:@""])
        [self.searchBar resignFirstResponder];//close keyboard and resign focus from search bar
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionObserver" object:nil];
}


- (IBAction)didChangeSegmentedControl:(id)sender
{
    if (self.resultsTypeSegmentedControl.selectedSegmentIndex == 0)
    {
        forceLoadResults = NO;
        [self didLoadResultsWithPartId:@""];
    }
    else
    {
        [self confirmLiveResults];
    }
    
    //[self loadResults];
}

-(void)refreshTableView
{
    [self loadResults];
    
    //set the title while refreshing
    appDelegate.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"checking for updates..."];
    //set the date and time of refreshing
    //[appDelegate.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [appDelegate.dateFormatter setDateFormat:@"MMM d, h:mm a"];

    NSString *lastupdated = [NSString stringWithFormat:@"Last updated %@",[appDelegate.dateFormatter stringFromDate:[NSDate date]]];
    appDelegate.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastupdated];
    
    [appDelegate.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    //end the refreshing
    [appDelegate.refreshControl endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"count %lu",(unsigned long)[self.results count]);
    return [self.results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"resultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    UILabel *qtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(3,16,18,20)];
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(25,2,220,30)];
    UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(25,28,240,20)];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-70,45,65,10)];
    UILabel *srcLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-170,40,95,20)];
    UISwitch *ignitorSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-50,15,40,10)];
    UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(25,46,200,20)];
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-70,4,62,14)];

    NSMutableDictionary *rowData = [self.results objectAtIndex:indexPath.row];

    // if this is single-search resulting data, attempt to update master results if it overlaps
    if (! [self.searchBar.text isEqualToString:@""])
    {
        [self synchronizeResultsWithRowData:rowData];
    }
    
    BOOL igniteOn = NO;
    if ([[rowData objectForKey:@"ignitor"] isEqualToString:@"1"]) igniteOn = YES;
    //NSLog(@"row %@",rowData);
    //NSLog(@"ignitor %@ %hhd",[rowData objectForKey:@"ignitor"], igniteOn);

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        
        qtyLabel.tag = 21;
        qtyLabel.font = [UIFont systemFontOfSize:16];
        qtyLabel.adjustsFontSizeToFitWidth = YES;
        qtyLabel.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:qtyLabel];

        topLabel.tag = 22;
        topLabel.font = [UIFont systemFontOfSize:12];
        topLabel.numberOfLines = 0;
        topLabel.adjustsFontSizeToFitWidth = YES;
        topLabel.contentMode = UIViewContentModeScaleAspectFit;
        topLabel.minimumScaleFactor = 0.5f;
        [cell.contentView addSubview:topLabel];

        bottomLabel.tag = 23;
        bottomLabel.font = [UIFont systemFontOfSize:10];
        bottomLabel.textColor = [UIColor grayColor];
        bottomLabel.numberOfLines = 0;
        bottomLabel.adjustsFontSizeToFitWidth = YES;
        bottomLabel.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:bottomLabel];

        dateLabel.tag = 24;
        dateLabel.font = [UIFont systemFontOfSize:8];
        dateLabel.textColor = [UIColor grayColor];
        dateLabel.adjustsFontSizeToFitWidth = YES;
        dateLabel.contentMode = UIViewContentModeScaleAspectFit;
        dateLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:dateLabel];

        srcLabel.tag = 25;
        srcLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:8];
        srcLabel.textColor = [UIColor grayColor];
        srcLabel.adjustsFontSizeToFitWidth = YES;
        srcLabel.contentMode = UIViewContentModeScaleAspectFit;
        srcLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:srcLabel];
        
        ignitorSwitch.tag = 26;//ignitorId;
        //[[ignitorSwitch superview] setTag:ignitorId];
        ignitorSwitch.transform = CGAffineTransformMakeScale(0.65, 0.65);
        //[ignitorSwitch addTarget:self action:@selector(initIgnitor:) forControlEvents:UIControlEventTouchDown];
        [ignitorSwitch addTarget:self action:@selector(toggleIgnitor:) forControlEvents:UIControlEventValueChanged];
        [ignitorSwitch setOn:igniteOn];
        [cell.contentView addSubview:ignitorSwitch];
        
        companyLabel.tag = 27;
        companyLabel.font = [UIFont systemFontOfSize:12];
        companyLabel.textColor = [UIColor colorWithRed:143.0/255.0 green:94.0/255.0 blue:23.0/255.0 alpha:1.0f];
        companyLabel.adjustsFontSizeToFitWidth = YES;
        companyLabel.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:companyLabel];
        
        priceLabel.tag = 28;
        priceLabel.font = [UIFont systemFontOfSize:12];
        priceLabel.textColor = [UIColor blackColor];
        priceLabel.adjustsFontSizeToFitWidth = YES;
        priceLabel.contentMode = UIViewContentModeScaleAspectFit;
        priceLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:priceLabel];
    }
    else
    {
        qtyLabel = (UILabel *)[cell.contentView viewWithTag:21];
        topLabel = (UILabel *)[cell.contentView viewWithTag:22];
        bottomLabel = (UILabel *)[cell.contentView viewWithTag:23];
        dateLabel = (UILabel *)[cell.contentView viewWithTag:24];
        srcLabel = (UILabel *)[cell.contentView viewWithTag:25];
        ignitorSwitch = (UISwitch *)[cell.contentView viewWithTag:26];
        [ignitorSwitch setOn:igniteOn];
        companyLabel = (UILabel *)[cell.contentView viewWithTag:27];
        priceLabel = (UILabel *)[cell.contentView viewWithTag:28];
    }

    NSString *qty = @"";
    if ([rowData objectForKey:@"qty"] != nil
        && ! [[rowData objectForKey:@"qty"] isKindOfClass:[NSNull class]]
        && ! [[rowData objectForKey:@"qty"] isEqualToString:@""])
    {
        qty = [NSString stringWithFormat: @" %@",[rowData objectForKey:@"qty"]];
    }
    qtyLabel.text = qty;

    NSString *labelString = [appDelegate formatPartTitle:[rowData objectForKey:@"part"] :[rowData objectForKey:@"rel"] :[rowData objectForKey:@"heci"]];
    topLabel.text = labelString;
    
    NSString *descr = [appDelegate formatPartDescr:[rowData objectForKey:@"system"] :[rowData objectForKey:@"description"]];
    bottomLabel.text = descr;
    
    NSString *date = @"";
    NSDate *dateTime = [[NSDate alloc] init];

    if ([rowData objectForKey:@"datetime"] != nil
        && ! [[rowData objectForKey:@"datetime"] isKindOfClass:[NSNull class]]
        && ! [[rowData objectForKey:@"datetime"] isEqualToString:@""])
    {
        // this is the date being passed in
        [appDelegate.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        dateTime = [appDelegate.dateFormatter dateFromString:[rowData objectForKey:@"datetime"]];
        // this is the date/time we're formatting to
        [appDelegate.dateFormatter setDateFormat:@"MM/dd, h:mma"];
        
        date = [NSString stringWithFormat:@"%@",[appDelegate.dateFormatter stringFromDate:dateTime]];
    }
    dateLabel.text = date;
    
    NSString *src = @"";
    if ([rowData objectForKey:@"source"] != nil
        && ! [[rowData objectForKey:@"source"] isKindOfClass:[NSNull class]]
        && ! [[rowData objectForKey:@"source"] isEqualToString:@""])
    {
        src = [rowData objectForKey:@"source"];
    }
    srcLabel.text = src;
    
    NSString *companyName = @"";
    if ([rowData objectForKey:@"company"] != nil
        && ! [[rowData objectForKey:@"company"] isKindOfClass:[NSNull class]]
        && ! [[rowData objectForKey:@"company"] isEqualToString:@""])
    {
        companyName = [rowData objectForKey:@"company"];
    }
    companyLabel.text = companyName;
    
    NSString *price = @"";
    if ([rowData objectForKey:@"price"] != nil
        && ! [[rowData objectForKey:@"price"] isKindOfClass:[NSNull class]]
        && ! [[rowData objectForKey:@"price"] isEqualToString:@""])
    {
        price = [NSString stringWithFormat:@"$ %@",[rowData objectForKey:@"price"]];
    }
    priceLabel.text = price;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // when there's no company to list, the cell height can be smaller
    if ([[[self.results objectAtIndex:indexPath.row] objectForKey:@"company"] isEqualToString:@""])
    {
        return 54.0f;
    }
     
    return 72.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // get partid and send it in url to get all results based on that partid
    //NSString *partId = [[self.results objectAtIndex:indexPath.row] objectForKey:@"id"];
    
    // push to details controller
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PartDetailsViewController *partDetailsViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"PartDetailsViewController"];
    NSMutableDictionary *partDict = [self.results objectAtIndex:indexPath.row];
    //NSLog(@"row %d: %@",indexPath.row, partDict);
    
    partDetailsViewController.resultsIndexPath = indexPath;
    // assign dictionary to next view controller
    //NSLog(@"prep dict %@",partDict);
    [partDict setObject:[NSString stringWithFormat:@"%d",indexPath.row] forKey:@"indexPathRow"];
    partDetailsViewController.partDictionary = partDict;
    
    [self.navigationController pushViewController:partDetailsViewController animated:YES];
    //[self performSegueWithIdentifier:@"partDetailsSegue" sender:self];
}

- (void)toggleIgnitor:(id) sender
{
    // declare the switch by its type based on the sender element
    UISwitch *switchIsPressed = (UISwitch *)sender;
    // get the indexPath of the cell containing the switch
    NSIndexPath *indexPath = [self indexPathForCellContainingView:switchIsPressed];
    // look up the value of the item that is referenced by the switch - this
    // is from my datasource for the table view
    NSString *pId = [[self.results objectAtIndex:indexPath.row] objectForKey:@"id"];
    NSString *save_on = @"0";
    if ([sender isOn]) save_on = @"1";
    NSString *urlString = [NSString stringWithFormat:@"%s/drop/save_ignitors.php?partid=%@&save_to_on=%@", URL_ROOT, pId, save_on];
    NSLog(@"ignitor url %@",urlString);
    [appDelegate goURL:urlString];
}

- (NSIndexPath *)indexPathForCellContainingView:(UIView *)view {
    while (view != nil) {
        if ([view isKindOfClass:[UITableViewCell class]]) {
            return [self.resultsTableView indexPathForCell:(UITableViewCell *)view];
        } else {
            view = [view superview];
        }
    }
    
    return nil;
}

- (void)synchronizeResultsWithRowData:(NSMutableDictionary *)rowData
{
    int i = 0;
    NSMutableArray *tempMasterList = [[NSMutableArray alloc] initWithArray:masterResults];
    for (NSMutableDictionary *dict in tempMasterList)
    {
        NSString *pId = [dict objectForKey:@"id"];
        //NSLog(@"id %@ to id %@",pId, [rowData objectForKey:@"id"]);
        if ([pId isEqualToString:[rowData objectForKey:@"id"]])
        {
            [masterResults replaceObjectAtIndex:i withObject:rowData];
        }
        i++;
    }
}

- (void)confirmLiveResults
{
    UIAlertView *userAlert = [[UIAlertView alloc] initWithTitle:@"Please confirm" message:@"Getting live results may be more than you bargained for.  Really?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Live!",nil];
    
    [userAlert show];
}

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex:(NSInteger) buttonIndex
{
    if (buttonIndex == 0)
    {
        self.resultsTypeSegmentedControl.selectedSegmentIndex = 0;
        // if no search string entered, default back to master results
        if ([self.searchBar.text isEqualToString:@""])
        {
            forceLoadResults = NO;
            [self didLoadResultsWithPartId:@""];
        }
        return;
    }
    
    [self loadResults];
}

- (void)updateSearchBar:(NSNotification *)notification
{
    //NSLog(@"not %@",notification.userInfo);
    self.searchBar.text = [notification.userInfo objectForKey:@"entry"];
    [self loadResults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
