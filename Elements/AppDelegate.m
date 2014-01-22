//
//  AppDelegate.m
//  Elements
//
//  Created by David Langley on 12/25/13.
//  Copyright (c) 2013 Langley Assets, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "LeftViewController.h"
#import "HomeViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation AppDelegate

@synthesize LoadingVC;
@synthesize HomeVC;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //self.tabBarViewController = (UITabBarController *)self.window.rootViewController;
    self.tabBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"tabBarViewController"];
    self.navViewController = (UINavigationController *)self.tabBarViewController.navigationController;
    [self.navViewController.navigationBar setContentMode:UIViewContentModeScaleAspectFit];
	self.leftViewController = [storyboard instantiateViewControllerWithIdentifier:@"leftViewController"];
    self.leftViewController.view.backgroundColor = [UIColor grayColor];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
    }
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeZone:[NSTimeZone localTimeZone]];//systemTimeZone?
    [self.dateFormatter setLocale:[NSLocale currentLocale]];
    [self.dateFormatter setDateFormat:@"EEEE MMMM d, yyyy"];
    [self.dateFormatter setFormatterBehavior:NSDateFormatterBehaviorDefault];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    
    //initialise the refresh controller
    self.refreshControl = [[UIRefreshControl alloc] init];
    //set the title for pull request
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"pull to refresh"];
    //    [self.refreshControl setFrame:CGRectMake(-100, -200, self.contentTableView.frame.size.width, 20)];
   
    //UIViewController *sideViewController = [[LeftViewController alloc] init];
    self.revealController = [PKRevealController
                             revealControllerWithFrontViewController:self.tabBarViewController
                             leftViewController:[self leftSideViewController]
                             rightViewController:nil];
    self.revealController.delegate = self;
    self.window.rootViewController = self.revealController;
    
    // disables the pan gesture which slides out side menu because it
    // interferes with swipe gesture for editing cells
    [self.revealController setRecognizesPanningOnFrontView:YES];
    // enable swipe gesture on nav bar
    [self.navViewController.navigationBar addGestureRecognizer:self.revealController.revealPanGestureRecognizer];
    
    return YES;
}

- (UIViewController *)leftSideViewController
{
    UIViewController *leftSideViewController = [[UIViewController alloc] init];
    leftSideViewController = self.leftViewController;
    leftSideViewController.view.backgroundColor = [UIColor grayColor];
    
    return leftSideViewController;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)loadingViewWillAppear
{
    self.activityIndicatorView.center = self.tabBarViewController.view.center;
    [self.tabBarViewController.view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
    
    self.tabBarViewController.view.userInteractionEnabled = NO;
    self.navViewController.view.userInteractionEnabled = NO;
    return;
    
    // Show Loading View
    LoadingVC.loadingView = [[LoadingView alloc] initWithFrame:self.window.bounds];
    [LoadingVC.loadingView addSubview:LoadingVC.loadingBackgroundView];
    [self.window addSubview:LoadingVC.loadingView];
}

- (void)loadingViewWillHide
{
    [self.activityIndicatorView stopAnimating];

    //[LoadingVC.loadingView removeFromSuperview];
    self.tabBarViewController.view.userInteractionEnabled = YES;
    self.navViewController.view.userInteractionEnabled = YES;
}

- (NSString *)formatPartTitle:(NSString *)part :(NSString *)rel :(NSString *)heci
{
    NSString *TitlePart = part;
    NSString *TitleRel = @"";
    NSString *TitleHeci = @"";
    
    if (rel != nil && ! [rel isKindOfClass:[NSNull class]] && ! [rel isEqualToString:@""])
    {
        TitleRel = [NSString stringWithFormat: @" %@",rel];
    }
    if (heci != nil && ! [heci isKindOfClass:[NSNull class]] && ! [heci isEqualToString:@""])
    {
        TitleHeci = [NSString stringWithFormat: @"  %@",heci];
    }
    NSString *titleString = [NSString stringWithFormat:@"%@%@%@",TitlePart, TitleRel, TitleHeci];
    
    return titleString;
}

- (NSString *)formatPartDescr:(NSString *)system :(NSString *)description
{
    NSString *sys = @"";
    NSString *descr = @"";
    
    if (system != nil && ! [system isKindOfClass:[NSNull class]] && ! [system isEqualToString:@""])
    {
        sys = [NSString stringWithFormat: @"%@",system];
    }
    if (description != nil && ! [description isKindOfClass:[NSNull class]] && ! [description isEqualToString:@""])
    {
        if ([sys isEqualToString:@""])
        {
            descr = description;
        }
        else
        {
            descr = [NSString stringWithFormat: @" %@",description];
        }
    }
    NSString *descrString = [NSString stringWithFormat:@"%@%@",sys, descr];
    
    return descrString;
}


- (void)addKeyboardToolbar
{
    [self addKeyboardBarWithOptions:YES];
}

- (void)addKeyboardBarWithOptions:(BOOL)withNavigators
{
    self.keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.window.bounds.size.width, 36)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [flexibleSpace setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:14], NSFontAttributeName,nil] forState:UIControlStateNormal];
    
    UIBarButtonItem *previousButton;
    UIBarButtonItem *nextButton;
    if (withNavigators == YES)
    {
        previousButton = [[UIBarButtonItem alloc] initWithTitle:@"Prev" style:UIBarButtonItemStyleBordered target:self action:@selector(prevField:)];
        [previousButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:14], NSFontAttributeName,nil] forState:UIControlStateNormal];
        
        nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextField:)];
        [nextButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:14], NSFontAttributeName,nil] forState:UIControlStateNormal];
        
    }
    else
    {
        previousButton = flexibleSpace;
        nextButton = flexibleSpace;
    }
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard:)];
    
    [self.keyboardToolbar setItems:[[NSArray alloc] initWithObjects:previousButton, nextButton, flexibleSpace, doneButton, nil]];
}

- (void)resignKeyboard:(id)sender
{
    [appDelegate resignFirstResponder];
    [self.tabBarViewController resignFirstResponder];
    [self.tabBarViewController.view endEditing:YES];
}

- (void)prevField:(id)sender
{
    [appDelegate.tabBarViewController.view nextResponder];
}

- (void)nextField:(id)sender
{
    [appDelegate.tabBarViewController.view nextResponder];
}

- (void)addUniqueObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:object];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:name object:object];
}


#pragma mark - NSUrlConnectionDelegate Methods

- (void)goURL:(NSString *)rawUrlString
{
    //NSLog(@"url %@", queryString);
    NSString *queryString = [rawUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"encoded url %@",queryString);
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest
                                     requestWithURL:[NSURL URLWithString:queryString]
                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:12.0];

    [appDelegate loadingViewWillAppear];
    
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (con) {
        _receivedData = [NSMutableData data];
    } else {
        // Something bad happened
    }
}

- (void)goJson:(NSDictionary *)jsonDict
{
    // update global data handler
    //NSLog(@"json %@",jsonDict);
    //NSLog(@"json %d %d",[self.jsonResults count], [jsonDict count]);
    //NSError *error = nil;

    self.jsonResults = jsonDict;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionObserver" object:nil];

    //[jsonResults valueForKey:@"hosts"]
}

// Connection did received a response
-(void)connection:(NSConnection*)conn didReceiveResponse:(NSURLResponse *)response
{
    if (_receivedData == NULL) {
        _receivedData = [[NSMutableData alloc] init];
    }
    [_receivedData setLength:0];
    //NSLog(@"didReceiveResponse: responseData length:(%d)", _receivedData.length);
}

// Connection did receive data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
}

// Connection failed
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection Failed with Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    // Remove loading view
    [self loadingViewWillHide];
    [self showAlertConnectionFailed];
}

// Connection finish loading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self loadingViewWillHide];
    NSError *error = nil;
    
    NSString *receivedDataString = [[NSString alloc] initWithData:_receivedData encoding: NSASCIIStringEncoding];
    
    NSData *readyData = [receivedDataString dataUsingEncoding:NSASCIIStringEncoding];
    
    // Parse that data object using NSJSONSerialization without options.
    NSDictionary *jsonDict = [[NSDictionary alloc] init];
    
    // options was: kNilOptions
    jsonDict = [NSJSONSerialization JSONObjectWithData:readyData options:NSJSONReadingMutableContainers error:&error];
    [self goJson:jsonDict];
}

// Display alert if server connection failed
- (void)showAlertConnectionFailed
{
    UIAlertView *alertGranted = [[UIAlertView alloc] initWithTitle:@"Network Failure" message:@"There's a problem connecting. Check your connection and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alertGranted show];
}

// Display server response to the user
- (void)showAlertResponse:(NSString *)response
{
}

- (void)completeAlertView
{
    // Create label to hold activity loading items
    UIView *completeView;
    completeView = [[UIView alloc] initWithFrame:CGRectMake((self.window.bounds.size.width/6), (self.window.bounds.size.height/3), (self.window.frame.size.width/1.5), (self.window.frame.size.height/5))];
    completeView.backgroundColor = [UIColor colorWithRed:0.0f green:122/255 blue:1.0f alpha:0.75];
    completeView.clipsToBounds = YES;
    completeView.layer.cornerRadius = 10;
    
    // Create "Loading" Label
    NSInteger viewWidth = (completeView.bounds.size.width);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((viewWidth/6),(completeView.bounds.size.height/4),(viewWidth-(viewWidth/3)),50)];
    
    // Setup "Loading" label
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    NSString *responseText = @"Complete!";
    if ([self.jsonResults objectForKey:@"response"])
    {
        responseText = [appDelegate.jsonResults objectForKey:@"response"];
    }
    label.text = responseText;
    label.font = [UIFont boldSystemFontOfSize:18];
    label.textAlignment = NSTextAlignmentCenter;
    
    // Combine all activity loading items together
    [completeView addSubview:label];
    [self.window addSubview: completeView];
    
    [self fadeOutView:completeView];
}

-(void)fadeOutView: (UIView *)expiringView
{
    [UIView animateWithDuration:0.4
                          delay:1.2  /* starts the animation after 1.2 seconds */
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         expiringView.alpha = 0.0;
                         //myLabel2.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [expiringView removeFromSuperview];
                         //[myLabel2 removeFromSuperview];
                     }];
}

@end
