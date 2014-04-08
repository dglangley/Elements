//
//  HomeViewController.m
//  Elements
//
//  Created by David Langley on 12/25/13.
//  Copyright (c) 2013 Langley Assets, LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "PartDetailsViewController.h"
#import "UIImageView+WebCache.h"

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
    
    //disable panning across entire view, but enable for navbar alone
    [self.revealController setRecognizesPanningOnFrontView:NO];
    // enable swipe gesture on nav bar
    [self.navigationController.navigationBar addGestureRecognizer:self.revealController.revealPanGestureRecognizer];
    
    [appDelegate.dateFormatter setDateFormat:@"MM-dd"];
    today = [appDelegate.dateFormatter stringFromDate:[NSDate date]];
    //NSLog(@"today %@",today);
    
    self.resultsTypeSegmentedControl.selectedSegmentIndex = 0;
    
    [appDelegate addKeyboardBarWithOptions:NO];
    self.searchBar.inputAccessoryView = appDelegate.keyboardToolbar;
    pg = 0;// number that represents how many paged results
    isLoadingOffsetResults = NO;// don't load results while loading more

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
}

- (void)viewDidAppear:(BOOL)animated
{
    userLongPressDetected = NO;
    isLoadingOffsetResults = NO;

    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(userDidLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self.resultsTableView addGestureRecognizer:lpgr];
}

- (void)scrollViewDidScroll :(UIScrollView *)scrollView
{
    NSInteger currentOffset = scrollView.contentOffset.y;
    
    // offset at the bottom of the scrollview
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    //NSLog(@"offsets %d %f %f %f", currentOffset, lastScrollOffset.y, scrollView.contentSize.height, scrollView.frame.size.height);

    // load next page of results when scrolling reaches bottom of scrollview
    if (currentOffset > lastScrollOffset.y && currentOffset > 0
        && currentOffset > maximumOffset+150 && isLoadingOffsetResults == NO)
    {
        pg++;
        NSLog(@"pg %d",pg);
        [self loadResults];
        isLoadingOffsetResults = YES;
    }
    lastScrollOffset = scrollView.contentOffset;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    pg = 0;
    
    // remove previous-search label at bottom of view if it's there
    UILabel *searchLabel = (UILabel *)[self.view viewWithTag:11];
    if (searchLabel != nil)
    {
        //[appDelegate fadeOutViewWithDelay:searchLabel :0.4];
        //userLongPressDetected = NO;
    }

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
    pg = 0;// reset paged results because search entry changed
    return;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
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
    if ([self.searchBar.text isEqualToString:@""] && [partId isEqualToString:@""])
    {
        //NSLog(@"%d %d %hhd", self.resultsTypeSegmentedControl.selectedSegmentIndex, [masterResults count], forceLoadResults);
        if (self.resultsTypeSegmentedControl.selectedSegmentIndex == 0
            && [masterResults count] > 0 && forceLoadResults == NO)
        {
            self.results = masterResults;
            [self simpleRefreshSection];

            return;
        }
        else if (self.resultsTypeSegmentedControl.selectedSegmentIndex == 1)
        {
            // probably want to prompt for something here
            return;
        }
    }
    
    NSString *searchString = [appDelegate stringByEncodingAmpersands:[[[NSString stringWithFormat:@"%@", self.searchBar.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *urlString = [NSString stringWithFormat:@"%s/drop/search.php?search=%@&partid=%@&results_type=%ld&pg=%d", URL_ROOT, searchString, partId, (long)self.resultsTypeSegmentedControl.selectedSegmentIndex, pg];
    NSLog(@"home url %@",urlString);
    [appDelegate requestURL:urlString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"connectionObserver" object:nil];
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
        
        // if loading offsets, append to array
        if (isLoadingOffsetResults == YES)
        {
            isLoadingOffsetResults = NO;
            self.results = [[self.results arrayByAddingObjectsFromArray:[appDelegate.jsonResults objectForKey:@"results"]] mutableCopy];
        }
        else
        {
            self.results = [appDelegate.jsonResults objectForKey:@"results"];
        }
        
        // changed 2-4-14 because the master list wasn't getting updated when I really wanted it to
        //if ([masterResults count] == 0 && [self.searchBar.text isEqualToString:@""]
        //    && self.resultsTypeSegmentedControl.selectedSegmentIndex == 0)
        if ([self.searchBar.text isEqualToString:@""] && self.resultsTypeSegmentedControl.selectedSegmentIndex == 0)
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

- (void)userDidLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) return;

    userLongPressDetected = YES;
    CGPoint p = [gestureRecognizer locationInView:self.resultsTableView];
    
    NSIndexPath *indexPath = [self.resultsTableView indexPathForRowAtPoint:p];
    if (indexPath == nil) return;//long pressed on table but not on row
    
    if (! [self.searchBar.text isEqualToString:@""])
    {
        float labelHeight = 70.0f;
        UILabel *prevSearchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.tabBarController.tabBar.frame.origin.y-labelHeight, self.view.frame.size.width, labelHeight)];
        prevSearchLabel.text = self.searchBar.text;
        prevSearchLabel.textAlignment = NSTextAlignmentCenter;
        prevSearchLabel.textColor = [UIColor whiteColor];
        prevSearchLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        prevSearchLabel.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:94.0/255.0 blue:23.0/255.0 alpha:1.0];
        prevSearchLabel.userInteractionEnabled = YES;
        prevSearchLabel.tag = 11;
        
        [self.view addSubview:prevSearchLabel];
    }
    
    NSDictionary *rowData = [self.results objectAtIndex:indexPath.row];
    NSString *searchStr = [[rowData objectForKey:@"heci"] substringToIndex:7];
    if ([searchStr isEqualToString:@""] || searchStr == nil)
    {
        searchStr = [rowData objectForKey:@"part"];
    }
    
    userLongPressDetected = NO;
    self.searchBar.text = searchStr;
    [self loadResults];
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [touches anyObject];
    if (touch.view.tag != 11) return;
    
    UILabel *touchLabel = (UILabel *)touch.view;
    self.searchBar.text = touchLabel.text;
    
    // remove label at bottom of view if it's there
    [appDelegate fadeOutViewWithDelay:touchLabel :0.4];
    userLongPressDetected = NO;

    [self loadResults];
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
    
    UILabel *qtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(70,40,30,20)];
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,0,self.view.bounds.size.width-10,26)];
    UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,26,self.view.bounds.size.width-10,12)];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-80,46,50,10)];
    UILabel *srcLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-170,40,95,20)];
    /*
    UISwitch *ignitorSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-50,15,40,10)];
     */
    UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(100,40,160,20)];
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-70,100,65,14)];
    UILabel *historyLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 80, 160, 40)];

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
        qtyLabel.textColor = [UIColor colorWithRed:143.0/255.0 green:94.0/255.0 blue:23.0/255.0 alpha:1.0f];
        qtyLabel.adjustsFontSizeToFitWidth = YES;
        qtyLabel.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:qtyLabel];

        topLabel.tag = 22;
        topLabel.font = [UIFont systemFontOfSize:18];
        topLabel.numberOfLines = 0;
        topLabel.adjustsFontSizeToFitWidth = YES;
        topLabel.textAlignment = NSTextAlignmentCenter;
        topLabel.contentMode = UIViewContentModeScaleAspectFit;
        topLabel.minimumScaleFactor = 0.5f;
        [cell.contentView addSubview:topLabel];

        bottomLabel.tag = 23;
        bottomLabel.font = [UIFont systemFontOfSize:10];
        bottomLabel.textColor = [UIColor grayColor];
        bottomLabel.numberOfLines = 1;
        bottomLabel.adjustsFontSizeToFitWidth = YES;
        bottomLabel.textAlignment = NSTextAlignmentCenter;
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
        //[cell.contentView addSubview:srcLabel];
        
        /*
        ignitorSwitch.tag = 26;//ignitorId;
        //[[ignitorSwitch superview] setTag:ignitorId];
        ignitorSwitch.transform = CGAffineTransformMakeScale(0.65, 0.65);
        //[ignitorSwitch addTarget:self action:@selector(initIgnitor:) forControlEvents:UIControlEventTouchDown];
        [ignitorSwitch addTarget:self action:@selector(toggleIgnitor:) forControlEvents:UIControlEventValueChanged];
        [ignitorSwitch setOn:igniteOn];
        [cell.contentView addSubview:ignitorSwitch];
         */
        
        companyLabel.tag = 27;
        companyLabel.font = [UIFont systemFontOfSize:12];
        companyLabel.textColor = [UIColor colorWithRed:143.0/255.0 green:94.0/255.0 blue:23.0/255.0 alpha:1.0f];
        companyLabel.adjustsFontSizeToFitWidth = YES;
        //companyLabel.textAlignment = NSTextAlignmentRight;
        companyLabel.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:companyLabel];
        
        priceLabel.tag = 28;
        priceLabel.font = [UIFont systemFontOfSize:14];
        priceLabel.textColor = [UIColor blackColor];
        priceLabel.adjustsFontSizeToFitWidth = YES;
        priceLabel.contentMode = UIViewContentModeScaleAspectFit;
        priceLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:priceLabel];
        
        historyLabel.tag = 29;
        historyLabel.font = [UIFont systemFontOfSize:12];
        historyLabel.textColor = [UIColor grayColor];
        historyLabel.numberOfLines = 0;
        historyLabel.adjustsFontSizeToFitWidth = YES;
        //companyLabel.textAlignment = NSTextAlignmentRight;
        historyLabel.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:historyLabel];
    }
    else
    {
        qtyLabel = (UILabel *)[cell.contentView viewWithTag:21];
        topLabel = (UILabel *)[cell.contentView viewWithTag:22];
        bottomLabel = (UILabel *)[cell.contentView viewWithTag:23];
        dateLabel = (UILabel *)[cell.contentView viewWithTag:24];
        srcLabel = (UILabel *)[cell.contentView viewWithTag:25];
        /*
        ignitorSwitch = (UISwitch *)[cell.contentView viewWithTag:26];
        [ignitorSwitch setOn:igniteOn];
         */
        companyLabel = (UILabel *)[cell.contentView viewWithTag:27];
        priceLabel = (UILabel *)[cell.contentView viewWithTag:28];
        historyLabel = (UILabel *)[cell.contentView viewWithTag:29];
    }
    
    //cell.imageView = nil;
    if (! [[rowData objectForKey:@"heci"] isEqualToString:@""])
    {
        NSURL *imgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.bell-enterprise.com/pictures/thumbs/%@.jpg",[[rowData objectForKey:@"heci"] substringToIndex:7]]];
        [[cell.imageView layer] setMagnificationFilter:kCAFilterNearest];
        [cell.imageView setTransform:CGAffineTransformMakeScale(.55, .55)];
        [cell.imageView setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"no-picture.png"]];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

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
    if ([rowData objectForKey:@"rank"] && [[rowData objectForKey:@"rank"] isEqualToString:@"3"])
    {
        topLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    }
    else
    {
        topLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    
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
        //NSString *checkDate = [NSString stringWithFormat:@"%@",[appDelegate.dateFormatter dateFromString:[rowData objectForKey:@"datetime"]]];
        //if ([[checkDate substringToIndex:10] isEqualToString:today]) topLabel.font = [UIFont boldSystemFontOfSize:10.0f];
        
        dateTime = [appDelegate.dateFormatter dateFromString:[rowData objectForKey:@"datetime"]];
        // this is the date/time we're formatting to
        [appDelegate.dateFormatter setDateFormat:@"MM/dd, h:mma"];
        date = [[appDelegate.dateFormatter stringFromDate:dateTime] lowercaseString];
        
        [appDelegate.dateFormatter setDateFormat:@"MM-dd"];
        NSString *dateMMdd = [appDelegate.dateFormatter stringFromDate:dateTime];

        //NSLog(@"date %@ = %@",dateMMdd, today);
        if ([dateMMdd isEqualToString:today])
        {
            [appDelegate.dateFormatter setDateFormat:@"h:mma"];
            date = [[NSString stringWithFormat:@"today %@",[appDelegate.dateFormatter stringFromDate:dateTime]] lowercaseString];
        }
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
    
    NSArray *sales = [rowData objectForKey:@"sales"];
    NSArray *purch = [rowData objectForKey:@"purchases"];
    NSString *historyStr;
    if ([sales count] > 0 || [purch count] > 0)
    {
        NSString *sPost = @"";
        NSString *pPost = @"";
        if ([sales count] != 1) sPost = @"s";
        if ([purch count] != 1) pPost = @"s";
        
        if ([sales count] > 0 && [purch count] > 0)
        {
            historyStr = [NSString stringWithFormat:@"%d sale%@\n%d purchase%@", [sales count], sPost, [purch count], pPost];
        }
        else if ([sales count] > 0)
        {
            historyStr = [NSString stringWithFormat:@"%d sale%@", [sales count], sPost];
        }
        else
        {
            historyStr = [NSString stringWithFormat:@"%d purchase%@", [purch count], pPost];
        }
    }
    historyLabel.text = historyStr;
    
    cell.userInteractionEnabled = YES;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 128.0f;
    
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
    
    //NSLog(@"long %hhd",userLongPressDetected);
    if (userLongPressDetected == YES) return;

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
    [partDict setObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:@"indexPathRow"];
    partDetailsViewController.partDictionary = partDict;
    
    [self.navigationController pushViewController:partDetailsViewController animated:YES];
    //[self performSegueWithIdentifier:@"partDetailsSegue" sender:self];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // user is deleting item
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *pId = [[self.results objectAtIndex:indexPath.row] objectForKey:@"id"];
        NSString *urlString = [NSString stringWithFormat:@"%s/drop/save_ignitors.php?partid=%@&save_to_on=0", URL_ROOT, pId];
        NSLog(@"ignitor url %@",urlString);
        [appDelegate goURL:urlString];
    }
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
