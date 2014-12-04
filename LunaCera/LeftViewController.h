//
//  LeftViewController.h
//
//  Created by David Langley on 1/20/14.
//  Copyright (c) 2014 LunaCera, LLC. All rights reserved.
//

//#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
//#import "PartDetailsViewController.h"

@interface LeftViewController : UIViewController
{
    NSArray *sectionNames;
    NSMutableArray *sectionArrays;
}

@property (strong, nonatomic) IBOutlet UITableView *accountsTableView;


@end
