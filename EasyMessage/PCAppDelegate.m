//
//  PCAppDelegate.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/18/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "PCAppDelegate.h"

#import "PCViewController.h"
#import "SettingsViewController.h"
#import "SelectRecipientsViewController.h"
#import "CustomMessagesController.h"
#import "EasyMessageIAPHelper.h"
#import "IAPMasterViewController.h"


@implementation PCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[PCViewController alloc] initWithNibName:@"PCViewController" bundle:nil];
    
    self.settingsController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    self.viewController.settingsController = self.settingsController;
    
    self.recipientsController = [[SelectRecipientsViewController alloc] initWithNibName:@"SelectRecipientsViewController" bundle:nil rootViewController:self.viewController];
    
    self.customMessagesController = [[CustomMessagesController alloc] initWithNibName:@"CustomMessagesController" bundle:nil rootViewController:self.viewController ];
    
    self.inAppPurchasesController = [[IAPMasterViewController alloc] initWithNibName:@"IAPMasterViewController" bundle:nil ];
    
    
    
    self.viewController.recipientsController = self.recipientsController;
    
    
    UINavigationController *navControllerSettings = [[UINavigationController alloc] init];
    [navControllerSettings setViewControllers: [[NSArray alloc]  initWithObjects:self.settingsController, nil]];
    
    UINavigationController *navControllerRecipients = [[UINavigationController alloc] init];
    [navControllerRecipients setViewControllers: [[NSArray alloc]  initWithObjects:self.recipientsController, nil]];
    
    UINavigationController *customMessagesControllerNav = [[UINavigationController alloc] init];
    [customMessagesControllerNav setViewControllers: [[NSArray alloc]  initWithObjects:self.customMessagesController, nil]];
    
    UINavigationController *inAppPurchasesControllerNav = [[UINavigationController alloc] init];
    [inAppPurchasesControllerNav setViewControllers: [[NSArray alloc]  initWithObjects:self.inAppPurchasesController, nil]];
    
    
    UITabBarController *tabController = [[UITabBarController alloc] init];
    [tabController setViewControllers: [NSArray arrayWithObjects:self.viewController,navControllerRecipients,navControllerSettings,customMessagesControllerNav, inAppPurchasesControllerNav, nil] ];
   
    //[tabController setSelectedIndex:0];
    
    [EasyMessageIAPHelper sharedInstance];
    
    self.window.rootViewController = tabController;//navController;
    [self.window makeKeyAndVisible];
    
    
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
/*
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}*/

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

@end
