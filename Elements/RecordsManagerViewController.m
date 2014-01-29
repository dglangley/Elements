//
//  RecordsManagerViewController.m
//  Elements
//
//  Created by David Langley on 1/5/14.
//  Copyright (c) 2014 Langley Assets, LLC. All rights reserved.
//

#import "RecordsManagerViewController.h"

@interface RecordsManagerViewController ()

@end

@implementation RecordsManagerViewController

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
    
    //NSLog(@"array %@",self.recordArray);
    [appDelegate addKeyboardBarWithOptions:NO];
    
    homeViewController = [self.navigationController.viewControllers objectAtIndex:0];

    if ([[self.recordArray objectAtIndex:6] isEqualToString:@"0"])//sale
    {
        self.title = @"Sales Order";
    }
    else if ([[self.recordArray objectAtIndex:6] isEqualToString:@"1"])//purchase
    {
        self.title = @"Purchase Order";
    }
    else
    //else if ([[self.recordArray objectAtIndex:7] isEqualToString:@""])
    {
        self.title = @"Availability";
    }
    NSString *descr = [[self.recordArray objectAtIndex:9] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (descr == nil) descr = @"";
    self.titleLabel.text = descr;
    
    // initialize
    self.companyArray = [[NSMutableArray alloc] init];
    
    self.companyPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 180)];
    self.companyPicker.delegate = self;
    self.companyPicker.dataSource = self;
    self.companyPicker.showsSelectionIndicator = YES;
    
    // -30 is Y-pos to move starting position up so there's not white buffer space
    dateTimePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 162.0f)];
    [dateTimePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [dateTimePicker setTimeZone:[NSTimeZone localTimeZone]];
    [dateTimePicker addTarget:self action:@selector(dateTimeDidChange:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *queryString = [NSString stringWithFormat:@"%s/drop/companies.php",URL_ROOT];
    NSLog(@"companies url %@",queryString);
    [appDelegate goURL:queryString];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"connectionObserver" object:nil];
    //[appDelegate addUniqueObserver:self selector:@selector(refreshView:) name:@"connectionObserver" object:nil];
}

- (void)refreshView:(NSNotification *) notification
{
    if (! [appDelegate.jsonResults objectForKey:@"results"]) return;
    
    [self.companyArray removeAllObjects];
    
    companyData = [appDelegate.jsonResults objectForKey:@"results"];
    //NSLog(@"company %d",[companyData count]);
    
    NSMutableDictionary *eachCompany = [[NSMutableDictionary alloc] init];
    UITextField *companyTextField = (UITextField *)[self.cell0 viewWithTag:1];
    
    [self.companyArray addObject:@"- New Company -"];
    NSInteger i = 0;
    for (id key in companyData) {
        eachCompany = (NSMutableDictionary *)key;
        //NSLog(@"key %@",eachCompany);
        [self.companyArray addObject:[eachCompany objectForKey:@"name"]];
        if ([[eachCompany objectForKey:@"name"] isEqualToString:companyTextField.text])
        {
            [self.companyPicker selectRow:i+1 inComponent:0 animated:YES];
        }
        i++;
    }
    [self.companyArray addObject:@"- New Company -"];

    
    [self.companyPicker reloadAllComponents];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionObserver" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    NSString *cellId = [NSString stringWithFormat:@"cell%d",indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
     */
    UITableViewCell *cell;
    switch (indexPath.row) {
        case 0:
            cell = self.cell0;
            break;
        case 1:
            cell = self.cell1;
            break;
        case 2:
            cell = self.cell2;
            break;
        case 3:
            cell = self.cell3;
            break;
        case 4:
            cell = self.cell4;
            break;
        case 5:
            cell = self.cell5;
            break;
        default:
            cell = self.cell5;
            break;
    }
    UITextField *cellTextField = (UITextField *)[cell.contentView viewWithTag:indexPath.row+1];

    cellTextField.text = [self.recordArray objectAtIndex:indexPath.row];
    //NSLog(@"text %@",cellTextField.text);

    //cellTextField.contentMode = UIViewContentModeScaleAspectFit;
    //cellTextField.adjustsFontSizeToFitWidth = YES;
    
    cellTextField.delegate = self;
    if (indexPath.row == 0)
    {
        /*
        [UIView beginAnimations: nil context: NULL];
        [UIView setAnimationDuration: 0.25];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
        [self.companyPicker setFrame:CGRectMake(0, 0, self.view.frame.size.width, 180)];
        [UIView commitAnimations];
         */
        
        //UITextField *companyTextField = (UITextField *)[self.cell0 viewWithTag:1];
        //[companyTextField setInputView:self.companyPicker];
        [cellTextField setInputView:self.companyPicker];
    }
    else if (indexPath.row == 4)
    {
        NSDate *recordDate;
        NSString *dateStr;
        if (cellTextField.text == nil || [cellTextField.text isEqualToString:@""])
        {
            dateStr = [[appDelegate dateFormatter] stringFromDate:[NSDate date]];
            cellTextField.text = dateStr;
        }
        else
        {
            dateStr = cellTextField.text;
        }
        [appDelegate.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        recordDate = [[appDelegate dateFormatter] dateFromString:dateStr];
        //NSLog(@"date %@",recordDate);

        [dateTimePicker setDate:recordDate];
        [cellTextField setInputView:dateTimePicker];
    }
    [cellTextField setInputAccessoryView:appDelegate.keyboardToolbar];

    [cell addSubview:cellTextField];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)saveRecord:(id)sender
{
    NSString *company = [[(UITextField *)[self.cell0 viewWithTag:1] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (company == nil) company = @"";
    company = [appDelegate stringByEncodingAmpersands:company];
    NSString *orderNum = [[(UITextField *)[self.cell1 viewWithTag:2] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (orderNum == nil) orderNum = @"";
    //orderNum = [orderNum stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *qty = [[(UITextField *)[self.cell2 viewWithTag:3] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (qty == nil) qty = @"";
    NSString *price = [[(UITextField *)[self.cell3 viewWithTag:4] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (price == nil) price = @"";
    NSString *date = [[(UITextField *)[self.cell4 viewWithTag:5] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (date == nil) date = @"";
    //date = [date stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *ref1 = [[(UITextField *)[self.cell5 viewWithTag:6] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (ref1 == nil) ref1 = @"";
    //ref1 = [ref1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *recordId = [[self.recordArray objectAtIndex:6] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (recordId == nil) recordId = @"";
    NSString *categoryId = [[self.recordArray objectAtIndex:7] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (categoryId == nil) categoryId = @"";
    NSString *partId = [[self.recordArray objectAtIndex:8] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (partId == nil) partId = @"";
    
    NSString *masterPartId = [[homeViewController.results objectAtIndex:self.resultsIndexPath.row] objectForKey:@"partid"];
    NSString *queryString = [NSString stringWithFormat:@"%s/drop/save_record.php?company=%@&qty=%@&ref1=%@&price=%@&datetime=%@&recordid=%@&categoryid=%@&order_number=%@&partid=%@&master_partid=%@",URL_ROOT,company,qty,ref1,price,date,recordId,categoryId,orderNum,partId,masterPartId];
    NSLog(@"records url %@",queryString);
    [appDelegate goURL:queryString];
    
    [appDelegate addUniqueObserver:self selector:@selector(userAlertView) name:@"connectionObserver" object:nil];
}

- (void)userAlertView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionObserver" object:nil];

    [self.view endEditing:YES];
    [appDelegate completeAlertView];
    if (! [appDelegate.jsonResults objectForKey:@"results"]) return;
    
    
    NSMutableDictionary *tempDataArray = [[[appDelegate.jsonResults objectForKey:@"results"] objectAtIndex:0] mutableCopy];
    //NSLog(@"new log %@",tempDataArray);

    // update data source, synchronize and reload results in prior views
    [homeViewController.results replaceObjectAtIndex:self.resultsIndexPath.row withObject:tempDataArray];
    [homeViewController synchronizeResultsWithRowData:tempDataArray];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateHomeResults" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDetailsResults" object:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)startEmail:(id)sender
{
    NSString *emailSubject = [self.titleLabel.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *emailBody = [[NSString stringWithFormat:@"Hi \n\nPlease quote me on this part:\n\n%@",self.titleLabel.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *emailURL = [NSString stringWithFormat:@"mailto:?subject=%@&body=%@",emailSubject, emailBody];
    //NSLog(@"email %@",emailURL);
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: emailURL]];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.companyArray objectAtIndex:row];
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    //NSLog(@"row %d",row);
    
    if ([self.companyArray count] == 0) return nil;
    NSString *rowItem = [self.companyArray objectAtIndex:row];
    
    // Create and init a new UILabel.
    // We must set our label's width equal to our picker's width.
    // We'll give the default height in each row.
    UILabel *lblRow = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView bounds].size.width, 58.0f)];
    
    // Center the text.
    [lblRow setTextAlignment:NSTextAlignmentCenter];
    
    // Change font size
    lblRow.font = [UIFont systemFontOfSize:14];
    //lblRow.textColor = [UIColor colorWithRed:(75/255.0) green:(145/255.0) blue:(235/255.0) alpha:1.0];
    
    // Add the text.
    [lblRow setText:rowItem];//[rowItem objectForKey:@"name"]];
    //NSLog(@"host %@",[rowItem objectForKey:@"name"]);
    
    // Clear the background color to avoid problems with the display.
    [lblRow setBackgroundColor:[UIColor clearColor]];
    
    // Return the label.
    return lblRow;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UITextField *companyTextField = (UITextField *)[self.cell0 viewWithTag:1];
    if ([[self.companyArray objectAtIndex:row] isEqualToString:@"- New Company -"])
    {
        [companyTextField resignFirstResponder];
        [companyTextField setInputView:nil];
        [companyTextField setText:@""];
        [companyTextField becomeFirstResponder];
    }
    else
    {
        companyTextField.text = [self.companyArray objectAtIndex:row];
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.companyArray count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (void)dateTimeDidChange:(id)sender
{
    UITextField *dateTimeTextField = (UITextField *)[self.cell4 viewWithTag:5];
    NSString *dateTimeStr = [[appDelegate dateFormatter] stringFromDate:dateTimePicker.date];
    dateTimeTextField.text = dateTimeStr;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField != (UITextField *)[self.cell0 viewWithTag:1]) return;

    //if (textField.inputAccessoryView != nil)
    //companyTextField.inputAccessoryView = nil;
    //companyTextField.inputView = self.companyPicker;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField != (UITextField *)[self.cell0 viewWithTag:1]) return;
    
    [textField setInputView:self.companyPicker];
}


@end
