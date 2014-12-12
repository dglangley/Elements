//
//  PartDetailsViewController.m
//
//  Created by David Langley on 1/5/14.
//  Copyright (c) 2014 LunaCera, LLC. All rights reserved.
//

#import "PartDetailsViewController.h"
#import "RecordsManagerViewController.h"

@interface PartDetailsViewController ()

@end

@implementation PartDetailsViewController

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
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    [navBar setContentMode:UIViewContentModeScaleAspectFit];
    [navBar setContentScaleFactor:0.5f];
    [self.navigationController.navigationBar setTintColor:appDelegate.color2];

    homeViewController = [self.navigationController.viewControllers objectAtIndex:0];
    
    // set the title using a cover label
    self.title = [appDelegate formatPartTitle:[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"part"] :[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"rel"] :[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"heci"]];
    UILabel* tlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, navBar.frame.size.width, navBar.frame.size.height)];
    tlabel.text = self.navigationItem.title;
    tlabel.adjustsFontSizeToFitWidth = YES;
    tlabel.numberOfLines = 0;
    self.navigationItem.titleView = tlabel;
    
    // load the add button
    // commented 12/4/14
    /*
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [addButton addTarget:self action:@selector(pushToRecordsManager) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barRightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    [self.navigationItem setRightBarButtonItem:barRightButtonItem];
     */

    [appDelegate addKeyboardBarWithOptions:NO];
    
    [appDelegate.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    today = [[appDelegate.dateFormatter stringFromDate:[NSDate date]] substringToIndex:10];
    
    NSString *partPrice = [[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"price"];
    if (partPrice == nil || [partPrice isKindOfClass:[NSNull class]] || [partPrice isEqualToString:@""])
    {
        partPrice = @"";
    }
    self.priceTextField.text = partPrice;
    self.priceTextField.delegate = self;
    [self.priceTextField setInputAccessoryView:appDelegate.keyboardToolbar];
    // hidden and disabled for now, 12/4/14
    self.priceTextField.hidden = YES;
    self.priceTextField.enabled = NO;

    self.descrLabel.text = [appDelegate formatPartDescr:[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"sys"] :[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"descr"]];
    self.descrLabel.numberOfLines = 0;
    
    self.categorySegmentedControl.selectedSegmentIndex = 2;//default to availability
    // hide the segmented control bar and move the table view up, 12/4/14
    self.categorySegmentedControl.hidden = YES;
    CGRect tvFrame = self.resultsTableView.frame;
    [self.resultsTableView setFrame:CGRectMake(tvFrame.origin.x, tvFrame.origin.y-30, tvFrame.size.width, tvFrame.size.height+30)];

    // mark part as 'read' for discovery db
    NSString *queryString = [NSString stringWithFormat:@"%s/read_part.php?partid=%@",URL_ROOT, [[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"pid"]];
    NSLog(@"read url %@",queryString);
    [appDelegate goURL:queryString];
    
    [appDelegate addUniqueObserver:self selector:@selector(didMarkPartAsRead) name:@"connectionObserver" object:nil];
    
    // set observer for updates from the next view so our data source can be updated automatically
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(simpleRefreshSection) name:@"updateDetailsResults" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    marketArray = [[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"market"];
    [self simpleRefreshSection];
    
    /*
    if ([[marketArray objectAtIndex:2] count] == 0)//avail
    {
        if ([[marketArray objectAtIndex:1] count] > 0)
        {
            self.categorySegmentedControl.selectedSegmentIndex = 1;//sales
            [self simpleRefreshSection];
        }
        else if ([[marketArray objectAtIndex:3] count] > 0)
        {
            self.categorySegmentedControl.selectedSegmentIndex = 3;//purch
            [self simpleRefreshSection];
        }
        else
        {
            self.categorySegmentedControl.selectedSegmentIndex = 0;//demand
            [self simpleRefreshSection];
        }
    }
    else
    {
        [self simpleRefreshSection];
    }*/
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    userLongPressDetected = NO;
    
    // commented 12/4/14
    /*
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(userDidLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self.resultsTableView addGestureRecognizer:lpgr];
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (IBAction)didSelectPrice:(id)sender {
    pricePicker.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    pricePicker.delegate = self;
    pricePicker.showsSelectionIndicator = YES;
    
}
*/

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([datesArray count] > 0) return ([datesArray count]);
    return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    [appDelegate.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //[appDelegate.dateFormatter stringFromDate:[NSDate date]
    //NSLog(@"date %@",[NSString stringWithFormat:@"%@",[datesArray objectAtIndex:section]]);
    //NSLog(@"dates %@ = %d",datesArray, [[datedRows objectForKey:[datesArray objectAtIndex:section]] count]);

    NSString *titleStr = @"";
    if ([datesArray count] > 0)
    {
        /*
        NSDate *titleDate = [appDelegate.dateFormatter dateFromString:[NSString stringWithFormat:@"%@",[datesArray objectAtIndex:section]]];
        [appDelegate.dateFormatter setDateFormat:@"cccc, MMMM d"];
        titleStr = [appDelegate.dateFormatter stringFromDate:titleDate];
         */
        titleStr = [datesArray objectAtIndex:section];
    }

    return (titleStr);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"dates %@",datedRows);
    if ([datesArray count] == 0) return 0;
    
    if ([datesArray objectAtIndex:section] == nil || [datedRows objectForKey:[datesArray objectAtIndex:section]] == nil) return 0;

    return ([[datedRows objectForKey:[datesArray objectAtIndex:section]] count]);
    //return [[marketArray objectAtIndex:self.categorySegmentedControl.selectedSegmentIndex] count];
    /*
    switch (self.categorySegmentedControl.selectedSegmentIndex)
    {
        case 0:
            return [[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"demand"] count];
            break;
        case 1:
            return [[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"sales"] count];
            break;
        case 2:
            return [[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"availability"] count];
            break;
        case 3:
            return [[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"purchases"] count];
            break;
    }

    return 0;
     */
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"resultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];// forIndexPath:indexPath];
    UILabel *cellQty = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *cellCompany = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *cellRef = (UILabel *)[cell.contentView viewWithTag:3];
    UILabel *cellPrice = (UILabel *)[cell.contentView viewWithTag:4];
    UILabel *cellDate = (UILabel *)[cell.contentView viewWithTag:5];
    UILabel *cellDescr = (UILabel *)[cell.contentView viewWithTag:6];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        
        [cell addSubview:cellQty];
        [cell addSubview:cellCompany];
        [cell addSubview:cellRef];
        [cell addSubview:cellPrice];
        [cell addSubview:cellDate];
        [cell addSubview:cellDescr];
    }
    NSInteger rowNum = [[[datedRows objectForKey:[datesArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] integerValue];
    //NSLog(@"%ld: %@ to %ld = %@",(long)indexPath.row, [datesArray objectAtIndex:indexPath.section], (long)rowNum, [[datedRows objectForKey:[datesArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]);
    NSDictionary *rowData = [[marketArray objectAtIndex:self.categorySegmentedControl.selectedSegmentIndex] objectAtIndex:rowNum];
    
    //NSLog(@"s %@",rowData);

    /*
    switch (self.categorySegmentedControl.selectedSegmentIndex)
    {
        case 0:
            rowData = [[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"demand"] objectAtIndex:indexPath.row];
            break;
        case 1:
            rowData = [[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"sales"] objectAtIndex:indexPath.row];
            break;
        case 2:
            rowData = [[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"availability"] objectAtIndex:indexPath.row];
            break;
        case 3:
            rowData = [[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"purchases"] objectAtIndex:indexPath.row];
            break;
    }
     */

    //NSLog(@"data %d %@ %@",indexPath.row, rowData);
    cellQty.text = [rowData objectForKey:@"q"];
    //cellCompany.frame = CGRectMake(0, 0, 205, 21);
    //NSLog(@"cid %@",[rowData objectForKey:@"cid"]);
    cellCompany.text = [appDelegate getCompany:[rowData objectForKey:@"cid"]];
    cellRef.text = @"";
    if ([rowData objectForKey:@"order_number"] != nil) cellRef.text = [rowData objectForKey:@"order_number"];
    cellPrice.text = @"";
    if ([rowData objectForKey:@"p"] != nil) cellPrice.text = [rowData objectForKey:@"p"];
    cellDate.text = [rowData objectForKey:@"fdate"];
    cellDescr.text = [rowData objectForKey:@"descr"];
    
    // change alpha for cell of previous dates
    // changed "dt" to "fdate" 12/4/14
    //NSString *itemDate = [[NSString stringWithFormat:@"%@",[rowData objectForKey:@"dt"]] substringToIndex:10];
    NSString *itemDate = [rowData objectForKey:@"fdate"];

    //NSLog(@"dates %@ %@",itemDate, today);
    
    float cellAlpha = 1.0f;
    //if (! [itemDate isEqualToString:today] && self.categorySegmentedControl.selectedSegmentIndex == 2) cellAlpha = 0.5f;
    // changed "dt" to "fdate" 12/4/14
    if (! [itemDate isEqualToString:@"Today"] && self.categorySegmentedControl.selectedSegmentIndex == 2) cellAlpha = 0.5f;


    cellQty.alpha = cellAlpha;
    cellCompany.alpha = cellAlpha;
    cellRef.alpha = cellAlpha;
    cellPrice.alpha = cellAlpha;
    cellDate.alpha = cellAlpha;
    cellDescr.alpha = cellAlpha;
    
    /*
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:cellCompany
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:cellCompany.superview
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1.0
                                                                        constant:-110];
    [cellCompany.superview addConstraint:widthConstraint];
     */
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    return;
    // commented 12/4/14 when disabling segmented control bar
    /*
    NSDictionary *rowData;

    switch (self.categorySegmentedControl.selectedSegmentIndex)
    {
        case 0:
            rowData = [[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"demand"] objectAtIndex:indexPath.row];
            break;
        case 1:
            rowData = [[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"sales"] objectAtIndex:indexPath.row];
            break;
        case 2:
            rowData = [[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"availability"] objectAtIndex:indexPath.row];
            break;
        case 3:
            rowData = [[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"purchases"] objectAtIndex:indexPath.row];
            break;
    }
     */
    NSDictionary *rowData = [[marketArray objectAtIndex:self.categorySegmentedControl.selectedSegmentIndex] objectAtIndex:indexPath.row];
    //NSLog(@"data %@",rowData);
    
    // send data to next view controller
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RecordsManagerViewController *recordsManagerViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RecordsManagerViewController"];
    
    NSString *company = [appDelegate getCompany:[rowData objectForKey:@"cid"]];
    if (company == nil) company = @"";
    NSString *qty = [rowData objectForKey:@"q"];
    if (qty == nil) qty = @"";
    NSString *ref1 = [rowData objectForKey:@"ref1"];
    if (ref1 == nil) ref1 = @"";
    NSString *price = [rowData objectForKey:@"p"];
    if (price == nil) price = @"";
    // changed "dt" to fdate
    NSString *datetime = [rowData objectForKey:@"fdate"];
    if (datetime == nil) datetime = @"";
    
    NSString *recordId = [rowData objectForKey:@"id"];
    if (recordId == nil) recordId = @"";
    NSString *categoryId = [NSString stringWithFormat:@"%ld", (long)self.categorySegmentedControl.selectedSegmentIndex];
    if (categoryId == nil) categoryId = @"";
    NSString *orderNumber = [rowData objectForKey:@"order_number"];
    if (orderNumber == nil) orderNumber = @"";
    NSString *partId = [rowData objectForKey:@"pid"];
    if (partId == nil) partId = @"";
    NSString *descr = [rowData objectForKey:@"descr"];
    if (descr == nil) descr = @"";
    
    NSMutableArray *recordArray = [[NSMutableArray alloc] initWithObjects:company,orderNumber,qty,price,datetime,ref1, recordId,categoryId,partId,descr, nil];
    //NSLog(@"record %@",recordArray);
    
    recordsManagerViewController.recordArray = (NSArray *)recordArray;
    recordsManagerViewController.resultsIndexPath = self.resultsIndexPath;
    //recordsManagerViewController.recordCategoryId = self.categorySegmentedControl.selectedSegmentIndex;
    
    [self.navigationController pushViewController:recordsManagerViewController animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return  UITableViewCellEditingStyleInsert;
    //return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"hi");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0f;
}

//

- (void)userDidLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) return;
    
    userLongPressDetected = YES;
    CGPoint p = [gestureRecognizer locationInView:self.resultsTableView];
    
    NSIndexPath *indexPath = [self.resultsTableView indexPathForRowAtPoint:p];
    if (indexPath == nil) return;//long pressed on table but not on row
    
    NSDictionary *avail = [[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"availability"] objectAtIndex:indexPath.row];
    NSString *sourceUrl;
    //NSLog(@"company is %@",[[avail objectForKey:@"company"] substringToIndex:4]);
    if ([[[avail objectForKey:@"company"] substringToIndex:4] isEqualToString:@"eBay"])
    {
        sourceUrl = [NSString stringWithFormat:@"ebay://launch?itm=%@",[avail objectForKey:@"src"]];
    }
    else if ([[avail objectForKey:@"src"] isEqualToString:@"TE"])
    {
        UILabel *descrLabel = (UILabel *)[[self.resultsTableView cellForRowAtIndexPath:indexPath].contentView viewWithTag:6];
        NSString *descr = [descrLabel.text stringByReplacingOccurrencesOfString:@"  " withString:@" "];
        descr = [descr stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
        sourceUrl = [[NSString stringWithFormat:@"http://tel-explorer.com/Main_Page/Search/Multi_srch_go.php?submit=submit&multipart=%@",descr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    else
    {
        return;
    }
    NSLog(@"source url %@",sourceUrl);

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sourceUrl]];
    
    userLongPressDetected = NO;
    //[self loadResults];
}


- (void)simpleRefreshSection
{
    [self initDataSources];
    
    [self.resultsTableView reloadData];
    return;

    // to make this more than one section, change the 0,1 to x,y
    // where x is the first section you want to change and y is
    // the number of sections proceeding from that initial section
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
    [self.resultsTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)initDataSources
{
    //changed "dt" to fdate, and commented section altogether since array is sorted by server 12/4/14
    /*
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"fdate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject: sorter];
    [[marketArray objectAtIndex:self.categorySegmentedControl.selectedSegmentIndex] sortUsingDescriptors:sortDescriptors];
     */
    
    [datesArray removeAllObjects];
    [datedRows removeAllObjects];
    datesArray = [[NSMutableArray alloc] init];//reset every time
    datedRows = [[NSMutableDictionary alloc] init];//reset every time
    NSDictionary *eachRow;
    NSString *eachDate;
    for (int i = 0; i < [[marketArray objectAtIndex:self.categorySegmentedControl.selectedSegmentIndex] count]; i++)
    {
        eachRow = [[marketArray objectAtIndex:self.categorySegmentedControl.selectedSegmentIndex] objectAtIndex:i];
        //changed "dt" to fdate 12/4/14
        //eachDate = [[eachRow objectForKey:@"dt"] substringToIndex:10];
        eachDate = [eachRow objectForKey:@"fdate"];
        if ([datesArray count] == 0 || ([datesArray count] > 0 && ! [eachDate isEqualToString:[datesArray objectAtIndex:[datesArray count]-1]]))
        {
            [datesArray addObject:eachDate];
            [datedRows setObject:[[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%d",i], nil] forKey:eachDate];
        }
        else
        {
            [[datedRows objectForKey:eachDate] setObject:[NSString stringWithFormat:@"%d",i] atIndex:[[datedRows objectForKey:eachDate] count]];
        }
    }
}


- (void)didMarkPartAsRead
{
    if ([appDelegate.jsonResults objectForKey:@"code"] || [appDelegate.jsonResults objectForKey:@"code"]>0) return;
    
    if ([[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"rank"]
        && [[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"rank"] isEqualToString:@"3"])
    {
        [[homeViewController.results objectAtIndex:self.resultsIndexPath.section] setValue:@"2" forKey:@"rank"];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[UIApplication sharedApplication].applicationIconBadgeNumber-1];
    }
}

- (IBAction)didChangeSegmentedControl:(id)sender
{
    [self simpleRefreshSection];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //HomeViewController *homeViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    
    if (textField != self.priceTextField
        || [textField.text isEqualToString:[[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"price"]]) return;
    
    [[homeViewController.results objectAtIndex:self.resultsIndexPath.section] setValue:textField.text forKey:@"price"];
    
    NSMutableDictionary *tempDataArray = [[homeViewController.results objectAtIndex:self.resultsIndexPath.section] mutableCopy];
    [homeViewController.results replaceObjectAtIndex:self.resultsIndexPath.section withObject:tempDataArray];
    [homeViewController synchronizeResultsWithRowData:tempDataArray];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateHomeResults" object:nil];

    NSString *pId = [[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"pid"];
    NSString *price = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *queryString = [NSString stringWithFormat:@"%s/save_part.php?partid=%@&price=%@",URL_ROOT, pId, price];
    NSLog(@"save url %@",queryString);
    [appDelegate goURL:queryString];
    
    [appDelegate addUniqueObserver:self selector:@selector(userAlertView) name:@"connectionObserver" object:nil];
}

- (void)userAlertView
{
    [appDelegate completeAlertView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionObserver" object:nil];
}

- (void)pushToRecordsManager
{
    NSString *categoryId = [NSString stringWithFormat:@"%ld", (long)self.categorySegmentedControl.selectedSegmentIndex];
    if (categoryId == nil) categoryId = @"";
    
    // push to records controller
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RecordsManagerViewController *recordsManagerViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RecordsManagerViewController"];
    NSString *pId = [[homeViewController.results objectAtIndex:self.resultsIndexPath.section] objectForKey:@"pid"];
    NSMutableArray *recordArray = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", @"", @"", categoryId, pId, self.title, nil];
    recordsManagerViewController.resultsIndexPath = self.resultsIndexPath;
    recordsManagerViewController.recordArray = (NSArray *)recordArray;
    
    [self.navigationController pushViewController:recordsManagerViewController animated:YES];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 10;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

@end
