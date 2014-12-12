//
//  AppDelegate.m
//
//  Created by David Langley on 12/25/13.
//  Copyright (c) 2013 LunaCera, LLC. All rights reserved.
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
    
    self.color1 = [UIColor colorWithRed:78.0/255.0 green:184.0/255.0 blue:0.0 alpha:1.0];
    self.color2 = [UIColor colorWithRed:1.0/255.0 green:72.0/255.0 blue:135.0/255.0 alpha:1.0f];
    self.color3 = [UIColor colorWithRed:168.0/255.0 green:30.0/255.0 blue:0.0/255.0 alpha:1.0f];
    
    //self.tabBarViewController = (UITabBarController *)self.window.rootViewController;
    self.tabBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"tabBarViewController"];
    [self.tabBarViewController.tabBar setTintColor:self.color1];
    //[[UITabBar appearance] setTintColor:[UIColor redColor]];

    self.navViewController = (UINavigationController *)self.tabBarViewController.navigationController;
    [self.navViewController.navigationBar setContentMode:UIViewContentModeScaleAspectFit];

	self.leftViewController = [storyboard instantiateViewControllerWithIdentifier:@"leftViewController"];
    self.leftViewController.view.backgroundColor = [UIColor grayColor];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
    }

    
    self.LOCAL_DB = [NSUserDefaults standardUserDefaults];  //load NSUserDefaults
    if (! [self.LOCAL_DB objectForKey:@"companies"])
    {
        [self.LOCAL_DB setObject:[[NSMutableDictionary alloc] init] forKey:@"companies"];
        [self.LOCAL_DB synchronize];
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
    [self.revealController setRecognizesPanningOnFrontView:NO];//disabling for now, 12/12/14
    // enable swipe gesture on nav bar
    //[self.navViewController.navigationBar addGestureRecognizer:self.revealController.revealPanGestureRecognizer];
    
    self.remoteDescrs = [[NSDictionary alloc] initWithObjectsAndKeys:@"PowerSource",@"ps",@"BrokerBin",@"bb",@"Tel-Explorer",@"te", nil];
    self.remoteKeys = [[NSArray alloc] initWithObjects:@"ps",@"bb",@"te", nil];
    
    [self styleViews];
    
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
    
    // Check if push notifications are enabled
    [self checkPushNotifications];
    
    [self updateTabBarBadge];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)loadingViewWillAppear
{
    self.activityIndicatorView.center = self.tabBarViewController.view.center;
    self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.activityIndicatorView.color = [UIColor colorWithRed:0.0f green:133.0f/255.0f blue:1.0f alpha:1.0f];
    [self.tabBarViewController.view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
    
    //self.tabBarViewController.view.userInteractionEnabled = NO;
    //self.navViewController.view.userInteractionEnabled = NO;
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
    if ([TitlePart length] > 28) TitlePart = [NSString stringWithFormat:@"%@...",[TitlePart substringToIndex:27]];
    NSString *TitleRel = @"";
    NSString *TitleHeci = @"";
    
    if (rel != nil && ! [rel isKindOfClass:[NSNull class]] && ! [rel isEqualToString:@""])
    {
        TitleRel = [NSString stringWithFormat: @" %@",rel];
    }
    if (heci != nil && ! [heci isKindOfClass:[NSNull class]] && ! [heci isEqualToString:@""])
    {
        TitleHeci = [NSString stringWithFormat: @"%@",heci];
    }
    NSString *titleString = [NSString stringWithFormat:@"%@%@\n%@",TitlePart, TitleRel, TitleHeci];
    
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

- (void)styleViews
{
    [[UITextField appearance] setFont:DEFAULT_FONT(17)];
    [[UITextField appearance] setBackgroundColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.7]];
    [[UITextField appearance] setBorderStyle:UITextBorderStyleNone];
    // create padding on left and right of text field
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 20)];
    [[UITextField appearance] setLeftView:paddingView];
    [[UITextField appearance] setLeftViewMode:UITextFieldViewModeAlways];
    // somehow I need this set, but I can't use it in setRightViewMode or the view won't appear
    [[UITextField appearance] setRightView:paddingView];
    
    //[[UITextField appearance] setDelegate:self];
    
    [self addKeyboardBarWithOptions:NO];
    [[UITextField appearance] setInputAccessoryView:self.keyboardToolbar];

    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:DEFAULT_FONT(18), NSFontAttributeName, nil] forState:UIControlStateNormal];
}

- (BOOL)isLoggedin
{
    self.cookies = [[NSMutableDictionary alloc] init];
    self.cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in self.cookiesArray)
    {
        [self.cookies setValue:[cookie value] forKey:[cookie name]];
        
    }
    if (! [self.cookies objectForKey:@"userid"] || ! [self.cookies objectForKey:@"user_token"])
    {
        [self deleteCookies];
        return NO;
    }
    return YES;
}

- (void)deleteCookies
{
    // erase all cookies on signout
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    // this last method attempts to search for the view controller and resign
    // any responders in text fields that are NOT necessarily in the tab view controller
    [self findFirstResponder];
    
}

- (id)findFirstResponder
{
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in [[[UIApplication sharedApplication] keyWindow] subviews]) {
        [subView endEditing:YES];
        /*if ([subView isFirstResponder]) {
            return subView;
        }*/
    }
    return nil;
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

- (void)checkPushNotifications
{
    // Setup items for Push Notifications
    // Let the device know we want to receive push notifications
	//[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
    // (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    UIRemoteNotificationType notificationTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    
    //NSLog(@"Notifications %u",notificationTypes);
    if (notificationTypes == UIRemoteNotificationTypeNone)
    {
        // Setup storage for notification date check
        //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSDate *savedNotificationCheckDate = [self.LOCAL_DB objectForKey:@"notificationCheckDate"];
        NSDate *currentDate = [NSDate date];
        
        NSLog(@"APNs are not enabled, saved notification date is: %@", savedNotificationCheckDate);
        
        // Check which date expires first, savedNotifcationCheckDate or current date and
        // store the answer in earlierDate
        NSDate *earlierDate = [currentDate earlierDate:savedNotificationCheckDate];
        
        // If earlierDate is savedNotificationCheckDate, display alert as two weeks have passed
        if([earlierDate isEqualToDate:savedNotificationCheckDate])// || savedNotificationCheckDate == NULL)
        {
            UIAlertView *alertSuccessful = [[UIAlertView alloc] initWithTitle:@"Push Notifications" message:@"Please enable LunaCera notifications on your iPhone to receive important updates" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertSuccessful show];
            
            // Save new notificationDate to check back in two weeks
            NSDate *notificationDateTwoWeeks = [currentDate dateByAddingTimeInterval:60*60*24*14];
            [self.LOCAL_DB setObject:notificationDateTwoWeeks forKey:@"notificationCheckDate"];
            [self.LOCAL_DB synchronize];
        }
        else if (savedNotificationCheckDate == NULL)
        {
            NSLog(@"Registering for APNs...");
            // Setup items for Push Notifications
            // Let the device know we want to receive push notifications
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        }
    }
    else
    {
        // Let the device know we want to receive push notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    // create instance of singleton class
    //self.singleton = [SingletonData getInstance];
    
    //NSLog(@"APNs Device Token before: %@", deviceToken);
    
    // Save Device Token without <> and spaces
    NSString *token = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Store device token in user defaults
    [self.LOCAL_DB setObject:[NSString stringWithFormat:@"%@", token] forKey:@"userDeviceToken"];
    
    // Set device token for app session
    //[self.singleton setDeviceToken:token];
    
    NSLog(@"APNs Device Token: %@", token);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self updateTabBarBadge];

    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"LunaCera" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alertView show];
    } else {
        //Do stuff that you would do if the application was not active
    }
}

- (void)updateTabBarBadge
{
    //NSLog(@"badges: %ld...", (long)[UIApplication sharedApplication].applicationIconBadgeNumber);
    UITabBarItem *tbi = (UITabBarItem*) [[[self.tabBarViewController tabBar] items] objectAtIndex:0];

    // set badge icon on tab bar if there's a notification
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0)
    {
        [tbi setBadgeValue:[NSString stringWithFormat:@"%ld",(long)[UIApplication sharedApplication].applicationIconBadgeNumber]];
    }
    else
    {
        [tbi setBadgeValue:nil];
    }
}


#pragma mark - NSUrlConnectionDelegate Methods

- (void)goURL:(NSString *)rawUrlString
{
    //NSLog(@"url %@", rawUrlString);
    NSString *queryString = [rawUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"encoded url %@",queryString);
    
    [self requestURL:queryString];
}

- (void)requestURL:(NSString *)queryString
{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest
                                     requestWithURL:[NSURL URLWithString:queryString]
                                     cachePolicy:NSURLRequestReloadIgnoringCacheData
                                     timeoutInterval:20.0];

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
    
    // show error to user if produced from server
    if ([self.jsonResults objectForKey:@"code"] && [self.jsonResults objectForKey:@"message"])
    {
        if ([[self.jsonResults objectForKey:@"code"] intValue]>0)
        {
            //NSLog(@"code %@",[self.jsonResults objectForKey:@"code"]);
            [self showAlertResponse:[self.jsonResults objectForKey:@"message"]];
        }
    }

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
    //NSLog(@"ready %@",receivedDataString);

    NSData *readyData = [receivedDataString dataUsingEncoding:NSASCIIStringEncoding];
    
    //NSLog(@"ready %@",readyData);
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
    UIAlertView *alertName = [[UIAlertView alloc] initWithTitle:@"Not cool..." message:response delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    // Set alert tag to make alertview unique
    alertName.tag = 800;
    [alertName show];
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
    label.adjustsFontSizeToFitWidth = YES;
    label.font = [UIFont boldSystemFontOfSize:18];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    
    // Combine all activity loading items together
    [completeView addSubview:label];
    [self.window addSubview: completeView];
    
    [self fadeOutView:completeView];
}


-(void)fadeOutView: (UIView *)expiringView
{
    [self fadeOutViewWithDelay:expiringView :1.2f];
}

-(void)fadeOutViewWithDelay: (UIView *)expiringView :(float)delayInSeconds
{
    [UIView animateWithDuration:0.4
                          delay:delayInSeconds  /* starts the animation after 1.2 seconds */
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

- (NSString *)stringByEncodingAmpersands:(NSString *)stringToEncode
{
    NSString *encodedString = [stringToEncode stringByReplacingOccurrencesOfString: @"&" withString: @"%26"];
    return encodedString;
}

- (NSString *)getCompany:(NSString *)cid
{
    NSDictionary *companies = [self.LOCAL_DB objectForKey:@"companies"];
    NSString *companyName = @"";
    
    if (! [companies objectForKey:cid] || [[companies valueForKey:cid] isEqualToString:@""])
    {
        /*
        NSString *urlString = [NSString stringWithFormat:@"%s/companies.php?cid=%@", URL_ROOT, cid];
        NSLog(@"companies url %@",urlString);
        [appDelegate goURL:urlString];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCompany) name:@"connectionObserver" object:nil];
        [[self.LOCAL_DB objectForKey:@"companies"] setObject:@"" forKey:cid];
        [self.LOCAL_DB synchronize];
         */
        companyName = @"Unknown";
    }
    else
    {
        companyName = [companies objectForKey:cid];
    }

    return companyName;
}

/*
- (void)saveCompany
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionObserver" object:nil];

    //NSLog(@"saving");
    NSDictionary *company = [[self.jsonResults objectForKey:@"results"] objectAtIndex:0];
    //if (! company || ! [company objectForKey:@"name"]) return;
    
    [[self.LOCAL_DB objectForKey:@"companies"] setObject:[company objectForKey:@"name"] forKey:[company objectForKey:@"id"]];
    [self.LOCAL_DB synchronize];
    //NSLog(@"c %@",company);
    
    //[self getCompany:[company objectForKey:@"id"]];
}
 */

@end
