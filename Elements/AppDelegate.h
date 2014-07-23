//
//  AppDelegate.h
//  Elements
//
//  Created by David Langley on 12/25/13.
//  Copyright (c) 2013 Langley Assets, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"
#import "PKRevealController.h"

#define appDelegate ((AppDelegate*)[[UIApplication sharedApplication] delegate])

#define URL_ROOT "http://david.local"//beta.thewaitlessapp.com"//

@class LeftViewController;
@class HomeViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDelegate, PKRevealing>
{
    NSMutableData* _receivedData;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LoadingView *LoadingVC;
@property (strong, nonatomic) UINavigationController *navViewController;
@property (strong, nonatomic) UITabBarController *tabBarViewController;
@property (strong, nonatomic) NSDictionary *jsonResults;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIToolbar *keyboardToolbar;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong, readwrite) PKRevealController *revealController;
@property (strong, nonatomic) LeftViewController* leftViewController;
@property (strong, nonatomic) HomeViewController *HomeVC;
@property (strong, nonatomic) NSUserDefaults *LOCAL_DB;
@property (strong, nonatomic) NSDictionary *remoteDescrs;
@property (strong, nonatomic) NSArray *remoteKeys;


//for singleton class
//@property (strong, nonatomic) SingletonData *singleton;

- (void)fadeOutViewWithDelay: (UIView *)expiringView :(float)delayInSeconds;
- (void)goURL:(NSString *)queryString;
- (void)requestURL:(NSString *)queryString;
- (void)addKeyboardBarWithOptions:(BOOL)withNavigators;
- (NSString *)formatPartTitle:(NSString *)part :(NSString *)rel :(NSString *)heci;
- (NSString *)formatPartDescr:(NSString *)system :(NSString *)descr;
- (void)completeAlertView;
- (void)addUniqueObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object;
- (NSString *)stringByEncodingAmpersands:(NSString *)stringToEncode;
- (void)updateTabBarBadge;
- (NSString *)getCompany:(NSString *)cid;

@end
