//
//  PremiumViewController.h
//
//  Created by David Langley on 7/23/14.
//  Copyright (c) 2014 LunaCera, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface PremiumViewController : UIViewController <UITextFieldDelegate>
{
    UIView *registerView, *loginView;
    UITextField *registerFirstName, *registerLastName, *registerCompanyName, *registerEmail1, *registerEmail2, *registerPassword1, *registerPassword2, *loginEmail, *loginPassword;
    UIButton *loginButton, *registerButton;
}

- (IBAction)cancelPremiumSegue:(id)sender;
- (IBAction)didChangeSegmentedControl:(id)sender;


@property (strong, nonatomic) IBOutlet UIScrollView *viewScrollView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *loginRegisterSegmentedControl;

@end
