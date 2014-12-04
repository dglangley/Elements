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
    
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    //self.view.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelPremiumSegue:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
