//
//  PartDetailsViewController.m
//  Elements
//
//  Created by David Langley on 1/5/14.
//  Copyright (c) 2014 Langley Assets, LLC. All rights reserved.
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

    homeViewController = [self.navigationController.viewControllers objectAtIndex:0];
    
    // set the title using a cover label
    self.title = [appDelegate formatPartTitle:[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"part"] :[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"rel"] :[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"heci"]];
    UILabel* tlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, navBar.frame.size.width, navBar.frame.size.height)];
    tlabel.text = self.navigationItem.title;
    tlabel.adjustsFontSizeToFitWidth = YES;
    tlabel.numberOfLines = 0;
    self.navigationItem.titleView = tlabel;
    
    // load the add button
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [addButton addTarget:self action:@selector(pushToRecordsManager) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barRightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    [self.navigationItem setRightBarButtonItem:barRightButtonItem];

    [appDelegate addKeyboardBarWithOptions:NO];
    
    [appDelegate.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    today = [[appDelegate.dateFormatter stringFromDate:[NSDate date]] substringToIndex:10];
    
    NSString *partPrice = [[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"price"];
    if (partPrice == nil || [partPrice isKindOfClass:[NSNull class]] || [partPrice isEqualToString:@""])
    {
        partPrice = @"";
    }
    self.priceTextField.text = partPrice;
    self.priceTextField.delegate = self;
    [self.priceTextField setInputAccessoryView:appDelegate.keyboardToolbar];

    self.descrLabel.text = [appDelegate formatPartDescr:[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"system"] :[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"description"]];
    self.descrLabel.numberOfLines = 0;
    
    self.categorySegmentedControl.selectedSegmentIndex = 2;
    
    // set observer for updates from the next view so our data source can be updated automatically
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(simpleRefreshSection) name:@"updateDetailsResults" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"availability"] count] == 0)
    {
        if ([[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"sales"] count] > 0)
        {
            self.categorySegmentedControl.selectedSegmentIndex = 1;
            [self simpleRefreshSection];
        }
        else if ([[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"purchases"] count] > 0)
        {
            self.categorySegmentedControl.selectedSegmentIndex = 3;
            [self simpleRefreshSection];
        }
        else
        {
            self.categorySegmentedControl.selectedSegmentIndex = 0;
            [self simpleRefreshSection];
        }
    }
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.categorySegmentedControl.selectedSegmentIndex)
    {
        case 0:
            return [[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"demand"] count];
            break;
        case 1:
            return [[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"sales"] count];
            break;
        case 2:
            return [[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"availability"] count];
            break;
        case 3:
            return [[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"purchases"] count];
            break;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"s %d",self.categorySegmentedControl.selectedSegmentIndex);
    
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
    NSDictionary *rowData;
    
    switch (self.categorySegmentedControl.selectedSegmentIndex)
    {
        case 0:
            rowData = [[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"demand"] objectAtIndex:indexPath.row];
            break;
        case 1:
            rowData = [[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"sales"] objectAtIndex:indexPath.row];
            break;
        case 2:
            rowData = [[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"availability"] objectAtIndex:indexPath.row];
            break;
        case 3:
            rowData = [[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"purchases"] objectAtIndex:indexPath.row];
            break;
    }

    //NSLog(@"data %d %@ %@",indexPath.row, rowData);
    cellQty.text = [rowData objectForKey:@"qty"];
    //cellCompany.frame = CGRectMake(0, 0, 205, 21);
    cellCompany.text = [rowData objectForKey:@"company"];
    cellRef.text = @"";
    if ([rowData objectForKey:@"order_number"] != nil) cellRef.text = [rowData objectForKey:@"order_number"];
    cellPrice.text = @"";
    if ([rowData objectForKey:@"price"] != nil) cellPrice.text = [rowData objectForKey:@"price"];
    cellDate.text = [rowData objectForKey:@"fdate"];
    cellDescr.text = [rowData objectForKey:@"description"];
    
    // change alpha for cell of previous dates
    NSString *itemDate = [[NSString stringWithFormat:@"%@",[rowData objectForKey:@"datetime"]] substringToIndex:10];
    //NSLog(@"dates %@ %@",itemDate, today);
    
    float cellAlpha = 1.0f;
    if (! [itemDate isEqualToString:today] && self.categorySegmentedControl.selectedSegmentIndex == 2) cellAlpha = 0.5f;

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
    
    NSDictionary *rowData;

    switch (self.categorySegmentedControl.selectedSegmentIndex)
    {
        case 0:
            rowData = [[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"demand"] objectAtIndex:indexPath.row];
            break;
        case 1:
            rowData = [[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"sales"] objectAtIndex:indexPath.row];
            break;
        case 2:
            rowData = [[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"availability"] objectAtIndex:indexPath.row];
            break;
        case 3:
            rowData = [[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"purchases"] objectAtIndex:indexPath.row];
            break;
    }
    //NSLog(@"data %@",rowData);
    
    // send data to next view controller
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RecordsManagerViewController *recordsManagerViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RecordsManagerViewController"];
    
    NSString *company = [rowData objectForKey:@"company"];
    if (company == nil) company = @"";
    NSString *qty = [rowData objectForKey:@"qty"];
    if (qty == nil) qty = @"";
    NSString *ref1 = [rowData objectForKey:@"ref1"];
    if (ref1 == nil) ref1 = @"";
    NSString *price = [rowData objectForKey:@"price"];
    if (price == nil) price = @"";
    NSString *datetime = [rowData objectForKey:@"datetime"];
    if (datetime == nil) datetime = @"";
    
    NSString *recordId = [rowData objectForKey:@"id"];
    if (recordId == nil) recordId = @"";
    NSString *categoryId = [NSString stringWithFormat:@"%ld", (long)self.categorySegmentedControl.selectedSegmentIndex];
    if (categoryId == nil) categoryId = @"";
    NSString *orderNumber = [rowData objectForKey:@"order_number"];
    if (orderNumber == nil) orderNumber = @"";
    NSString *partId = [rowData objectForKey:@"partid"];
    if (partId == nil) partId = @"";
    NSString *descr = [rowData objectForKey:@"description"];
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

- (void)simpleRefreshSection
{
    // to make this more than one section, change the 0,1 to x,y
    // where x is the first section you want to change and y is
    // the number of sections proceeding from that initial section
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
    [self.resultsTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
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
        || [textField.text isEqualToString:[[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"price"]]) return;
    
    [[homeViewController.results objectAtIndex:self.resultsIndexPath.row] setValue:textField.text forKey:@"price"];
    
    NSMutableDictionary *tempDataArray = [[homeViewController.results objectAtIndex:self.resultsIndexPath.row] mutableCopy];
    [homeViewController.results replaceObjectAtIndex:self.resultsIndexPath.row withObject:tempDataArray];
    [homeViewController synchronizeResultsWithRowData:tempDataArray];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateHomeResults" object:nil];

    NSString *pId = [[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"partid"];
    NSString *price = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *queryString = [NSString stringWithFormat:@"%s/drop/save_part.php?partid=%@&price=%@",URL_ROOT, pId, price];
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
    NSString *pId = [[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"partid"];
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
