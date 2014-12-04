//
//  HomeViewController.m
//
//  Created by David Langley on 12/25/13.
//  Copyright (c) 2013 LunaCera, LLC. All rights reserved.
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
    
    if (URL_ROOT == "http://lunacera.local")
    {
        [self.navigationController.navigationBar setBackgroundColor:[UIColor redColor]];
    }
    self.navigationItem.title = @"LunaCera";
    
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
    //disabled 12/4/14
    //[self.navigationController.navigationBar addGestureRecognizer:self.revealController.revealPanGestureRecognizer];
    
    [appDelegate.dateFormatter setDateFormat:@"MM-dd"];
    today = [appDelegate.dateFormatter stringFromDate:[NSDate date]];
    //NSLog(@"today %@",today);
    
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

    self.resultsTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.resultsTableView.bounds.size.width, 20.0f)];
    
    // disables the pan gesture which slides out side menu because it
    // interferes with swipe gesture for editing cells
    [self.revealController setRecognizesPanningOnFrontView:NO];
    // enable swipe gesture on nav bar
    //disabled 12/4/14
    //[self.navigationController.navigationBar addGestureRecognizer:self.revealController.revealPanGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
}

- (void)viewDidAppear:(BOOL)animated
{
    userLongPressDetected = NO;
    isLoadingOffsetResults = NO;

    // commented 12/4/14
    /*
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(userDidLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self.resultsTableView addGestureRecognizer:lpgr];
     */
    
    //[appDelegate updateTabBarBadge];
    
    //NSLog(@"badge %d",[UIApplication sharedApplication].applicationIconBadgeNumber);
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
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

        forceLoadResults = NO;
        [self didLoadResultsWithPartId:@""];
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
        if ([masterResults count] > 0 && forceLoadResults == NO)
        {
            self.results = masterResults;
            [self simpleRefreshSection];
            return;
        }
    }
    
    NSString *searchString = [appDelegate stringByEncodingAmpersands:[[[NSString stringWithFormat:@"%@", self.searchBar.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *urlString = [NSString stringWithFormat:@"%s/list.php?search=%@&partid=%@&pg=%d", URL_ROOT, searchString, partId, pg];
    NSLog(@"home url %@",urlString);
    [appDelegate requestURL:urlString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"connectionObserver" object:nil];
}

- (void)simpleRefreshSection
{
    // to make this more than one section, change the 0,1 to x,y
    // where x is the first section you want to change and y is
    // the number of sections proceeding from that initial section
    //NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
    
    //changed to reloaddata when I changed from many-rows-to-one-section to
    //one-row-to-many-sections
    //NSLog(@"results %@",self.results);

    [self.resultsTableView reloadData];
    //[self.resultsTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)refreshView:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionObserver" object:nil];

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
    
        NSLog(@"companies %@",[appDelegate.jsonResults objectForKey:@"companies"]);
        [appDelegate.LOCAL_DB setObject:[appDelegate.jsonResults objectForKey:@"companies"] forKey:@"companies"];
        [appDelegate.LOCAL_DB synchronize];
    
        // changed 2-4-14 because the master list wasn't getting updated when I really wanted it to
        //if ([masterResults count] == 0 && [self.searchBar.text isEqualToString:@""]
        //    && self.resultsTypeSegmentedControl.selectedSegmentIndex == 0)
        if ([self.searchBar.text isEqualToString:@""]) masterResults = self.results;
    }
    forceLoadResults = NO;

    NSLog(@"here:%@",[appDelegate jsonResults]);
    [self simpleRefreshSection];
    
    //close keyboard and resign focus from search bar
    if (! [self.searchBar.text isEqualToString:@""]) [self.searchBar resignFirstResponder];
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
    
    NSDictionary *rowData = [self.results objectAtIndex:indexPath.section];
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
    return 1;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    //NSLog(@"count %lu",(unsigned long)[self.results count]);
    return [self.results count];
}

-(void)zoomImage:(UIGestureRecognizer *)tapGesture
{
    UIView *gestureView = (UIView *)tapGesture.view;
    //NSLog(@"image frame %@",gestureView);
    gestureView.frame = self.view.frame;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"resultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    int bumperLeft = 60;//span of image that serves as a left bumper for other labels
    
    // shows current qty total
    UILabel *qtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-35,5,30,20)];
    // part/heci string
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(bumperLeft+10,3,self.view.bounds.size.width-(bumperLeft+60),30)];
    // item description
    UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(bumperLeft+10,35,self.view.bounds.size.width-(bumperLeft+70),24)];
    // date string, unformatted, outputted as directly from server
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(bumperLeft+10,85,50,10)];
    //UILabel *srcLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-170,40,95,20)];
    UIImageView *cellImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, bumperLeft, bumperLeft)];
    // Detecting touches on imageview
    UITapGestureRecognizer *imgTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(zoomImage:)];
    imgTapGesture.numberOfTapsRequired = 1;
    //[cellImage setUserInteractionEnabled:YES];
    //[cellImage addGestureRecognizer:imgTapGesture];

    /*
    UISwitch *ignitorSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-50,15,40,10)];
     */
    /*
    UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(90,65,160,20)];
     */
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,90,80,14)];
    //disabled, 12/4/14
    /*
    UILabel *marketFooter = [[UILabel alloc] initWithFrame:CGRectMake(0, 116, self.view.bounds.size.width, 36)];
    CGFloat buttonWidth = 80;
    CGFloat buttonHeight = marketFooter.frame.size.height;
    UIButton *demandButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    UIButton *salesButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth, 0, buttonWidth, buttonHeight)];
    UIButton *availButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth*2, 0, buttonWidth, buttonHeight)];
    UIButton *purchButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth*3, 0, buttonWidth, buttonHeight)];
     */

    NSInteger rowNumber = indexPath.section;
    NSMutableDictionary *rowData = [self.results objectAtIndex:rowNumber];

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
        qtyLabel.textAlignment = NSTextAlignmentRight;
        qtyLabel.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:qtyLabel];

        topLabel.tag = 22;
        topLabel.font = [UIFont systemFontOfSize:18];
        topLabel.numberOfLines = 0;
        topLabel.adjustsFontSizeToFitWidth = YES;
        topLabel.textAlignment = NSTextAlignmentLeft;
        topLabel.contentMode = UIViewContentModeScaleAspectFit;
        topLabel.minimumScaleFactor = 0.75f;
        [cell.contentView addSubview:topLabel];

        bottomLabel.tag = 23;
        bottomLabel.font = [UIFont systemFontOfSize:10];
        bottomLabel.textColor = [UIColor grayColor];
        bottomLabel.numberOfLines = 0;
        bottomLabel.adjustsFontSizeToFitWidth = YES;
        bottomLabel.textAlignment = NSTextAlignmentLeft;
        bottomLabel.contentMode = UIViewContentModeScaleAspectFit;
        bottomLabel.minimumScaleFactor = 0.75f;
        [cell.contentView addSubview:bottomLabel];

        dateLabel.tag = 24;
        dateLabel.font = [UIFont systemFontOfSize:8];
        dateLabel.textColor = [UIColor grayColor];
        dateLabel.adjustsFontSizeToFitWidth = YES;
        dateLabel.contentMode = UIViewContentModeScaleAspectFit;
        dateLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:dateLabel];
        
        priceLabel.tag = 28;
        priceLabel.font = [UIFont systemFontOfSize:14];
        priceLabel.textColor = [UIColor blackColor];
        priceLabel.adjustsFontSizeToFitWidth = YES;
        priceLabel.contentMode = UIViewContentModeScaleAspectFit;
        priceLabel.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:priceLabel];
        
        cellImage.tag = 29;
        [cell.contentView addSubview:cellImage];

        // footer row disabled, 12/4/14
        /*
        marketFooter.tag = 30;
        [marketFooter setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:0.3]];
        // build mask to cover border except for top edge
        CGFloat borderWidth = 0.5;
        [marketFooter.layer setBorderColor:[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0].CGColor];
        [marketFooter.layer setBorderWidth:borderWidth];
        UIView* mask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, marketFooter.frame.size.width, marketFooter.frame.size.height-borderWidth)];
        mask.backgroundColor = [UIColor blackColor];
        marketFooter.layer.mask = mask.layer;
        
        demandButton.tag = 31;
        [demandButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [demandButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [demandButton.titleLabel setNumberOfLines:0];
        [demandButton setBackgroundColor:[UIColor clearColor]];
        [demandButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [marketFooter addSubview:demandButton];
        
        salesButton.tag = 32;
        [salesButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [salesButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [salesButton.titleLabel setNumberOfLines:0];
        [salesButton setBackgroundColor:[UIColor clearColor]];
        [salesButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [marketFooter addSubview:salesButton];
        
        availButton.tag = 33;
        [availButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [availButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [availButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [availButton.titleLabel setNumberOfLines:0];
        [availButton setBackgroundColor:[UIColor clearColor]];
        [availButton setTitleColor:[UIColor colorWithRed:143.0/255.0 green:94.0/255.0 blue:23.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
        [marketFooter addSubview:availButton];
        
        purchButton.tag = 34;
        [purchButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [purchButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [purchButton.titleLabel setNumberOfLines:0];
        [purchButton setBackgroundColor:[UIColor clearColor]];
        [purchButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [marketFooter addSubview:purchButton];

        [cell.contentView addSubview:marketFooter];
        */
    }
    else
    {
        qtyLabel = (UILabel *)[cell.contentView viewWithTag:21];
        topLabel = (UILabel *)[cell.contentView viewWithTag:22];
        bottomLabel = (UILabel *)[cell.contentView viewWithTag:23];
        dateLabel = (UILabel *)[cell.contentView viewWithTag:24];
        priceLabel = (UILabel *)[cell.contentView viewWithTag:28];
        cellImage = (UIImageView *)[cell.contentView viewWithTag:29];
        //disabled, 12/4/14
        /*
        marketFooter = (UILabel *)[cell.contentView viewWithTag:30];
        demandButton = (UIButton *)[cell.contentView viewWithTag:31];
        salesButton = (UIButton *)[cell.contentView viewWithTag:32];
        availButton = (UIButton *)[cell.contentView viewWithTag:33];
        purchButton = (UIButton *)[cell.contentView viewWithTag:34];
         */
    }
    
    [cellImage setImage:[UIImage imageNamed:@"no-picture.png"]];
    //commented 12/4/14
    /*
    if (! [[rowData objectForKey:@"heci"] isEqualToString:@""])
    {
        NSURL *imgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.bell-enterprise.com/pictures/thumbs/%@.jpg",[[rowData objectForKey:@"heci"] substringToIndex:7]]];
        [cellImage sd_setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"no-picture.png"]];
    }
     */
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    qtyLabel.text = [rowData objectForKey:@"qty"];
    
    NSString *labelString = [appDelegate formatPartTitle:[rowData objectForKey:@"part"] :[rowData objectForKey:@"rel"] :[rowData objectForKey:@"heci"]];
    topLabel.text = labelString;
    if ([rowData objectForKey:@"rank"] && [[rowData objectForKey:@"rank"] isEqualToString:@"3"])
    {
        topLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    }
    else
    {
        topLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    
    NSString *descr = [appDelegate formatPartDescr:[rowData objectForKey:@"sys"] :[rowData objectForKey:@"descr"]];
    bottomLabel.text = descr;
    
    /*
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
        [appDelegate.dateFormatter setDateFormat:@"M/dd, h:mma"];
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
     */
    dateLabel.text = [rowData objectForKey:@"datetime"];
    
    NSString *qty = @"";
    if ([rowData objectForKey:@"qty"] != nil
        && ! [[rowData objectForKey:@"qty"] isKindOfClass:[NSNull class]]
        && ! [[rowData objectForKey:@"qty"] isEqualToString:@""])
    {
        qty = [NSString stringWithFormat: @"%@",[rowData objectForKey:@"qty"]];
    }
    
    // bottom row buttons and price options disabled, 12/4/14
    /*
    NSArray *market = [rowData objectForKey:@"market"];
    NSString *availStr = @"Availability";
    NSArray *avail = [market objectAtIndex:2];
    if ([avail count] > 0)
    {
        if ([qty isEqualToString:@""])
        {
            availStr = @"Availability";
        }
        else
        {
            availStr = [NSString stringWithFormat:@"(%@)\nAvailable",qty];
        }
    } else if (! [qty isEqualToString:@""]) {
        availStr = [NSString stringWithFormat:@"(%@)", qty];
    }
    [availButton setTitle:availStr forState:UIControlStateNormal];
    
    NSString *price = @"";
    if ([rowData objectForKey:@"price"] != nil
        && ! [[rowData objectForKey:@"price"] isKindOfClass:[NSNull class]]
        && ! [[rowData objectForKey:@"price"] isEqualToString:@""])
    {
        price = [NSString stringWithFormat:@"$ %@",[rowData objectForKey:@"price"]];
    }
    priceLabel.text = price;
    
    NSArray *sales = [market objectAtIndex:1];
    NSArray *purch = [market objectAtIndex:3];
    //NSLog(@"purch %@",purch);
    NSString *salesStr = @"Sales";
    NSString *purchStr = @"Purchases";
    if ([sales count] > 0)
    {
        NSString *sPost = @"";
        if ([sales count] != 1) sPost = @"s";
        if ([sales count] > 0)
        {
            salesStr = [NSString stringWithFormat:@"(%lu)\nSale%@", (unsigned long)[sales count], sPost];
        }
    }
    
    if ([purch count] > 0)
    {
        NSString *pPost = @"";
        if ([purch count] != 1) pPost = @"s";
        
        if ([purch count] > 0)
        {
            purchStr = [NSString stringWithFormat:@"(%lu)\nPurchase%@", (unsigned long)[purch count], pPost];
        }
    }
    
    [demandButton setTitle:@"Demand" forState:UIControlStateNormal];
    [salesButton setTitle:salesStr forState:UIControlStateNormal];
    [purchButton setTitle:purchStr forState:UIControlStateNormal];
     */
    
    cell.userInteractionEnabled = YES;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;//was 152.0f 12/4/14
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //NSLog(@"long %hhd",userLongPressDetected);
    if (userLongPressDetected == YES) return;

    // get partid and send it in url to get all results based on that partid
    //NSString *partId = [[self.results objectAtIndex:indexPath.row] objectForKey:@"pid"];
    
    // push to details controller
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PartDetailsViewController *partDetailsViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"PartDetailsViewController"];
    NSMutableDictionary *partDict = [self.results objectAtIndex:indexPath.section];
    //NSLog(@"row %d: %@",indexPath.row, partDict);
    
    partDetailsViewController.resultsIndexPath = indexPath;
    // assign dictionary to next view controller
    //NSLog(@"prep dict %@",partDict);
    [partDict setObject:[NSString stringWithFormat:@"%ld",(long)indexPath.section] forKey:@"indexPathRow"];
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
        NSString *pId = [[self.results objectAtIndex:indexPath.section] objectForKey:@"pid"];
        NSString *urlString = [NSString stringWithFormat:@"%s/save_ignitors.php?partid=%@&save_to_on=0", URL_ROOT, pId];
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
    NSString *pId = [[self.results objectAtIndex:indexPath.section] objectForKey:@"pid"];
    NSString *save_on = @"0";
    if ([sender isOn]) save_on = @"1";
    NSString *urlString = [NSString stringWithFormat:@"%s/save_ignitors.php?partid=%@&save_to_on=%@", URL_ROOT, pId, save_on];
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
        NSString *pId = [dict objectForKey:@"pid"];
        //NSLog(@"id %@ to id %@",pId, [rowData objectForKey:@"pid"]);
        if ([pId isEqualToString:[rowData objectForKey:@"pid"]])
        {
            [masterResults replaceObjectAtIndex:i withObject:rowData];
        }
        i++;
    }
}

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex:(NSInteger) buttonIndex
{
    if (buttonIndex == 0)
    {
        // if no search string entered, default back to master results
        if ([self.searchBar.text isEqualToString:@""])
        {
            [self loadResults];
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
