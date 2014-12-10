//
//  PremiumViewController.m
//
//  Created by David Langley on 7/23/14.
//  Copyright (c) 2014 LunaCera, LLC. All rights reserved.
//

#import "PremiumViewController.h"

@interface PremiumViewController ()

@end

@implementation PremiumViewController

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
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [self initFormControls];
    [self didChangeSegmentedControl:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initFormControls
{
    // initialize controls
    registerView = [[UIView alloc] init];
    loginView = [[UIView alloc] init];
    registerFirstName = [[UITextField alloc] init];
    registerLastName = [[UITextField alloc] init];
    registerCompanyName = [[UITextField alloc] init];
    registerEmail1 = [[UITextField alloc] init];
    registerEmail2 = [[UITextField alloc] init];
    registerPassword1 = [[UITextField alloc] init];
    registerPassword2 = [[UITextField alloc] init];
    registerButton = [[UIButton alloc] init];
    loginEmail = [[UITextField alloc] init];
    
    // both segments are equal to index+1 (from segmented control)
    [loginView setTag:1];
    [registerView setTag:2];
    // set both views to be hidden (0 alpha) by default
    [loginView setAlpha:0.0f];
    [registerView setAlpha:0.0f];
    
    // set up frames for views
    float viewY = 100;
    [registerView setFrame:CGRectMake(0, viewY, self.view.frame.size.width, (self.view.frame.size.height-viewY)*2)];
    [self.view addSubview:registerView];
    [loginView setFrame:CGRectMake(0, viewY, self.view.frame.size.width, self.view.frame.size.height-viewY)];
    [self.view addSubview:loginView];
    
    // set up text fields within each view
    float textFieldWidth = self.view.frame.size.width-20;
    float textFieldHeight = 36;
    float textFieldY = 14;
    
    /***** REGISTER VIEW *****/
    [registerFirstName setFrame:CGRectMake(10, textFieldY, textFieldWidth, textFieldHeight)];
    [registerFirstName setPlaceholder:@"First name"];
    [registerFirstName setReturnKeyType:UIReturnKeyNext];
    [registerView addSubview:registerFirstName];
    
    [registerLastName setFrame:CGRectMake(10, textFieldY+textFieldHeight+1, textFieldWidth, textFieldHeight)];
    [registerLastName setPlaceholder:@"Last name"];
    [registerLastName setReturnKeyType:UIReturnKeyNext];
    [registerView addSubview:registerLastName];
    
    [registerCompanyName setFrame:CGRectMake(10, (textFieldY+textFieldHeight)*2, textFieldWidth, textFieldHeight)];
    [registerCompanyName setReturnKeyType:UIReturnKeyNext];
    [registerCompanyName setPlaceholder:@"Company name"];
    
    [registerView addSubview:registerCompanyName];
    [registerEmail1 setFrame:CGRectMake(10, (textFieldY+textFieldHeight)*3, textFieldWidth, textFieldHeight)];
    [registerEmail1 setPlaceholder:@"Email address"];
    [registerEmail1 setReturnKeyType:UIReturnKeyNext];
    [registerView addSubview:registerEmail1];
    
    [registerEmail2 setFrame:CGRectMake(10, ((textFieldY+textFieldHeight)*3)+textFieldHeight+1, textFieldWidth, textFieldHeight)];
    [registerEmail2 setPlaceholder:@"Verify your email"];
    [registerEmail2 setReturnKeyType:UIReturnKeyNext];
    [registerView addSubview:registerEmail2];
    
    [registerPassword1 setFrame:CGRectMake(10, ((textFieldY+textFieldHeight)*4)+textFieldHeight, textFieldWidth, textFieldHeight)];
    [registerPassword1 setPlaceholder:@"Password (minimum of 6 characters)"];
    [registerPassword1 setSecureTextEntry:YES];
    [registerPassword1 setReturnKeyType:UIReturnKeyNext];
    [registerView addSubview:registerPassword1];
    
    [registerPassword2 setFrame:CGRectMake(10, (((textFieldY+textFieldHeight)*4)+(textFieldHeight*2))+1, textFieldWidth, textFieldHeight)];
    [registerPassword2 setPlaceholder:@"Verify your password"];
    [registerPassword2 setSecureTextEntry:YES];
    [registerPassword2 setReturnKeyType:UIReturnKeyGo];
    [registerView addSubview:registerPassword2];
    
    [registerButton.titleLabel setFont:DEFAULT_FONT(20)];
    [registerButton setFrame:CGRectMake(10, ((textFieldY+textFieldHeight)*6)+textFieldHeight, textFieldWidth, textFieldHeight+4)];
    [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerButton setBackgroundColor:[appDelegate color1]];
    [registerButton setTitle:@"Register Me!" forState:UIControlStateNormal];
    [registerView addSubview:registerButton];
    
    /***** LOGIN VIEW *****/
    [loginEmail setFrame:CGRectMake(10, textFieldY, textFieldWidth, textFieldHeight)];
    [loginEmail setPlaceholder:@"Email address"];
    [loginView addSubview:loginEmail];
    
    // uniformly style all text fields
    [appDelegate styleViews];
}

- (IBAction)didChangeSegmentedControl:(id)sender {
    if (self.loginRegisterSegmentedControl.selectedSegmentIndex == 0)//login is selected
    {
        [UIView animateWithDuration:0.4 animations:^() {
            registerView.alpha = 0.0f;
            loginView.alpha = 1.0f;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^() {
            registerView.alpha = 1.0f;
            loginView.alpha = 0.0f;
        }];
    }
}

- (IBAction)cancelPremiumSegue:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
