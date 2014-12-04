//
//  LoadingView.m
//
//  Created by David Langley on 12/25/13.
//  Copyright (c) 2013 LunaCera, LLC. All rights reserved.
//


#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
//    self = [super initWithFrame:frame];
    
//    if (self) {
        if ([self viewWithTag:151] && [self viewWithTag:151].hidden == NO)
        {
            [[self viewWithTag:151] removeFromSuperview];
            //return nil;
        }
        
        // Create label to hold activity loading items
        self.loadingBackgroundView = [[UIView alloc] initWithFrame:CGRectMake((self.bounds.size.width/4), (self.bounds.size.height/3), (self.frame.size.width/2), (self.frame.size.height/3))];
        self.loadingBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.loadingBackgroundView.clipsToBounds = YES;
        self.loadingBackgroundView.layer.cornerRadius = 10;
        self.loadingBackgroundView.tag = 151;
      
        // Create "Loading" Label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((self.bounds.size.width/2)-(self.loadingBackgroundView.bounds.size.width/4),
        (self.bounds.size.height/2)+(self.loadingBackgroundView.bounds.size.height/10),94,25)];
    
    
        // Setup "Loading" label
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = @"Loading…";
        label.font = [label.font fontWithSize:20];

        // Create spinner style and location
        UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.frame = CGRectMake((self.bounds.size.width/2), (self.bounds.size.height/2)-(self.loadingBackgroundView.bounds.size.height/4), 0, 0);

        // Combine all activity loading items together
        [self addSubview: self.loadingBackgroundView];
        [spinner startAnimating];
        [self addSubview: spinner];
        [self addSubview: label];
//    }
    //LoadingView *lv = [[LoadingView alloc] init];
    //[lv addSubview:self];
    return self;
}
@end
