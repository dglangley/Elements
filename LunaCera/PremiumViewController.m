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
    
    [self.loginRegisterSegmentedControl setSelectedSegmentIndex:1];
    [self.loginRegisterSegmentedControl setTintColor:appDelegate.color2];
    [self.viewScrollView setBackgroundColor:[UIColor clearColor]];

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
    loginPassword = [[UITextField alloc] init];
    loginButton = [[UIButton alloc] init];
    
    // both segments are equal to index+1 (from segmented control)
    [loginView setTag:1];
    [registerView setTag:2];
    // set both views to be hidden (0 alpha) by default
    [loginView setAlpha:0.0f];
    [registerView setAlpha:0.0f];
    
    // set up frames for views
    float viewY = 80;
    [registerView setFrame:CGRectMake(0, viewY, self.view.frame.size.width, self.view.frame.size.height-viewY)];
    [self.viewScrollView addSubview:registerView];
    [loginView setFrame:CGRectMake(0, viewY, self.view.frame.size.width, self.view.frame.size.height-viewY)];
    [self.viewScrollView addSubview:loginView];
    
    // set up text fields within each view
    float textFieldWidth = self.view.frame.size.width-20;
    float textFieldHeight = 36;
    float textFieldY = 14;
    
    /***** REGISTER VIEW *****/
    [registerFirstName setFrame:CGRectMake(10, textFieldY, textFieldWidth, textFieldHeight)];
    [registerFirstName setPlaceholder:@"First name"];
    [registerFirstName setReturnKeyType:UIReturnKeyNext];
    [registerFirstName setKeyboardType:UIKeyboardTypeDefault];
    [registerFirstName setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [registerFirstName setDelegate:self];
    [registerView addSubview:registerFirstName];
    
    [registerLastName setFrame:CGRectMake(10, textFieldY+textFieldHeight+1, textFieldWidth, textFieldHeight)];
    [registerLastName setPlaceholder:@"Last name"];
    [registerLastName setReturnKeyType:UIReturnKeyNext];
    [registerLastName setKeyboardType:UIKeyboardTypeDefault];
    [registerLastName setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [registerLastName setDelegate:self];
    [registerView addSubview:registerLastName];
    
    [registerCompanyName setFrame:CGRectMake(10, (textFieldY+textFieldHeight)*2, textFieldWidth, textFieldHeight)];
    [registerCompanyName setReturnKeyType:UIReturnKeyNext];
    [registerCompanyName setPlaceholder:@"Company name"];
    [registerCompanyName setKeyboardType:UIKeyboardTypeDefault];
    [registerCompanyName setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [registerCompanyName setDelegate:self];
    [registerView addSubview:registerCompanyName];
    
    [registerEmail1 setFrame:CGRectMake(10, (textFieldY+textFieldHeight)*3, textFieldWidth, textFieldHeight)];
    [registerEmail1 setPlaceholder:@"Email address"];
    [registerEmail1 setReturnKeyType:UIReturnKeyNext];
    [registerEmail1 setKeyboardType:UIKeyboardTypeEmailAddress];
    [registerEmail1 setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [registerEmail1 setDelegate:self];
    [registerView addSubview:registerEmail1];
    
    [registerEmail2 setFrame:CGRectMake(10, ((textFieldY+textFieldHeight)*3)+textFieldHeight+1, textFieldWidth, textFieldHeight)];
    [registerEmail2 setPlaceholder:@"Verify your email"];
    [registerEmail2 setReturnKeyType:UIReturnKeyNext];
    [registerEmail2 setKeyboardType:UIKeyboardTypeEmailAddress];
    [registerEmail2 setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [registerEmail2 setDelegate:self];
    [registerView addSubview:registerEmail2];
    
    [registerPassword1 setFrame:CGRectMake(10, ((textFieldY+textFieldHeight)*4)+textFieldHeight, textFieldWidth, textFieldHeight)];
    [registerPassword1 setPlaceholder:@"Password (minimum of 6 characters)"];
    [registerPassword1 setSecureTextEntry:YES];
    [registerPassword1 setReturnKeyType:UIReturnKeyNext];
    [registerPassword1 setKeyboardType:UIKeyboardTypeDefault];
    [registerPassword1 setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [registerPassword1 setDelegate:self];
    [registerView addSubview:registerPassword1];
    
    [registerPassword2 setFrame:CGRectMake(10, (((textFieldY+textFieldHeight)*4)+(textFieldHeight*2))+1, textFieldWidth, textFieldHeight)];
    [registerPassword2 setPlaceholder:@"Verify your password"];
    [registerPassword2 setSecureTextEntry:YES];
    [registerPassword2 setReturnKeyType:UIReturnKeyGo];
    [registerPassword2 setKeyboardType:UIKeyboardTypeDefault];
    [registerPassword2 setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [registerPassword2 setDelegate:self];
    [registerView addSubview:registerPassword2];
    
    [registerButton.titleLabel setFont:DEFAULT_FONT(20)];
    [registerButton setFrame:CGRectMake(10, ((textFieldY+textFieldHeight)*6)+textFieldHeight, textFieldWidth, textFieldHeight+4)];
    [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerButton setBackgroundColor:[appDelegate color1]];
    [registerButton setTitle:@"Save and Continue" forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(willSubmitForm) forControlEvents:UIControlEventTouchUpInside];
    [registerView addSubview:registerButton];
    
    
    /***** LOGIN VIEW *****/
    [loginEmail setFrame:CGRectMake(10, textFieldY, textFieldWidth, textFieldHeight)];
    [loginEmail setPlaceholder:@"Email address"];
    [loginEmail setReturnKeyType:UIReturnKeyNext];
    [loginEmail setKeyboardType:UIKeyboardTypeEmailAddress];
    [loginEmail setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [loginEmail setDelegate:self];
    [loginView addSubview:loginEmail];
    
    [loginPassword setFrame:CGRectMake(10, (textFieldY*2)+textFieldHeight, textFieldWidth, textFieldHeight)];
    [loginPassword setPlaceholder:@"Password"];
    [loginPassword setSecureTextEntry:YES];
    [loginPassword setReturnKeyType:UIReturnKeyGo];
    [loginPassword setKeyboardType:UIKeyboardTypeDefault];
    [loginPassword setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [loginPassword setDelegate:self];
    [loginView addSubview:loginPassword];
    
    [loginButton.titleLabel setFont:DEFAULT_FONT(20)];
    [loginButton setFrame:CGRectMake(10, ((textFieldY+textFieldHeight)*2)+(textFieldY*2), textFieldWidth, textFieldHeight+4)];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(willSubmitForm) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setBackgroundColor:[appDelegate color1]];
    [loginButton setTitle:@"Sign In" forState:UIControlStateNormal];
    [loginView addSubview:loginButton];
    
    // uniformly style all text fields
    [appDelegate styleViews];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Tell the keyboard where to go on next / go button.
    if (textField == loginPassword || textField == registerPassword2)
    {
        [self willSubmitForm];
    }
    else if (textField == loginEmail)
    {
        [loginEmail resignFirstResponder];
        [loginPassword becomeFirstResponder];
    }
    else if (textField == registerFirstName)
    {
        [registerFirstName resignFirstResponder];
        [registerLastName becomeFirstResponder];
    }
    else if (textField == registerLastName)
    {
        [registerLastName resignFirstResponder];
        [registerCompanyName becomeFirstResponder];
    }
    else if (textField == registerCompanyName)
    {
        [registerCompanyName resignFirstResponder];
        [registerEmail1 becomeFirstResponder];
    }
    else if (textField == registerEmail1)
    {
        [registerEmail1 resignFirstResponder];
        [registerEmail2 becomeFirstResponder];
    }
    else if (textField == registerEmail2)
    {
        [registerEmail2 resignFirstResponder];
        [registerPassword1 becomeFirstResponder];
    }
    else if (textField == registerPassword1)
    {
        [registerPassword1 resignFirstResponder];
        [registerPassword2 becomeFirstResponder];
    }
    
    return YES;
}

- (void)willSubmitForm
{
    NSString *urlString, *email1, *email2, *password1, *password2, *name1, *name2, *company;
    if (self.loginRegisterSegmentedControl.selectedSegmentIndex == 0)
    {//submit login form
        email1 = [appDelegate stringByEncodingAmpersands:[[[NSString stringWithFormat:@"%@", loginEmail.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        password1 = [appDelegate stringByEncodingAmpersands:[[NSString stringWithFormat:@"%@", loginPassword.text]  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        urlString = [NSString stringWithFormat:@"%s/save_signin.php?signin_email=%@&signin_password=%@", URL_ROOT, email1, password1];
    }
    else
    {//submit registration form
        name1 = [appDelegate stringByEncodingAmpersands:[[[NSString stringWithFormat:@"%@", registerFirstName.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        name2 = [appDelegate stringByEncodingAmpersands:[[[NSString stringWithFormat:@"%@", registerLastName.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        company = [appDelegate stringByEncodingAmpersands:[[[NSString stringWithFormat:@"%@", registerCompanyName.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        email1 = [appDelegate stringByEncodingAmpersands:[[[NSString stringWithFormat:@"%@", registerEmail1.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        email2 = [appDelegate stringByEncodingAmpersands:[[[NSString stringWithFormat:@"%@", registerEmail2.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        password1 = [appDelegate stringByEncodingAmpersands:[[NSString stringWithFormat:@"%@", registerPassword1.text]  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        password2 = [appDelegate stringByEncodingAmpersands:[[NSString stringWithFormat:@"%@", registerPassword2.text]  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        urlString = [NSString stringWithFormat:@"%s/save_signin.php?register_firstname=%@&register_lastname=%@&register_company=%@&register_email=%@&register_email2=%@&register_password=%@&register_password2=%@", URL_ROOT, name1, name2, company, email1, email2, password1, password2];
    }

    NSLog(@"login/register url %@",urlString);
    [appDelegate requestURL:urlString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeFormRequest) name:@"connectionObserver" object:nil];
}

- (void)completeFormRequest
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionObserver" object:nil];
    
    [self cancelPremiumSegue:nil];
}

- (IBAction)didChangeSegmentedControl:(id)sender {
    if (self.loginRegisterSegmentedControl.selectedSegmentIndex == 0)
    {//login is selected
        [UIView animateWithDuration:0.4 animations:^() {
            [self.viewScrollView setContentSize:CGSizeMake(self.viewScrollView.frame.size.width, 460)];
            registerView.alpha = 0.0f;
            loginView.alpha = 1.0f;
            
            UITextField *subviewTextField;
            for (UIView *subView in [registerView subviews]) {
                if ([subView isKindOfClass:[UITextField class]]) {
                    subviewTextField = (UITextField *)subView;
                    [subviewTextField setEnabled:NO];
                }
            }
            for (UIView *subView in [loginView subviews]) {
                if ([subView isKindOfClass:[UITextField class]]) {
                    subviewTextField = (UITextField *)subView;
                    [subviewTextField setEnabled:YES];
                }
            }
            
            [loginEmail becomeFirstResponder];
        }];
    }
    else
    {//register is selected
        [UIView animateWithDuration:0.3 animations:^() {
            [self.viewScrollView setContentSize:CGSizeMake(self.viewScrollView.frame.size.width, 760)];
            registerView.alpha = 1.0f;
            loginView.alpha = 0.0f;
            
            UITextField *subviewTextField;
            for (UIView *subView in [registerView subviews]) {
                if ([subView isKindOfClass:[UITextField class]]) {
                    subviewTextField = (UITextField *)subView;
                    [subviewTextField setEnabled:YES];
                }
            }
            for (UIView *subView in [loginView subviews]) {
                if ([subView isKindOfClass:[UITextField class]]) {
                    subviewTextField = (UITextField *)subView;
                    [subviewTextField setEnabled:NO];
                }
            }
            
            [registerFirstName becomeFirstResponder];
        }];
    }
}

- (IBAction)cancelPremiumSegue:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
