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

@synthesize managedObjectContext,managedObjectModel,persistentStoreCoordinator;

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

#pragma CORE DATA instance methods

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store
 coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in
 application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self loadApplicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"easymessage.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should
         not use this function in a shipping application, although it may be useful during
         development. If it is not possible to recover from the error, display an alert panel that
         instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible
         * The schema for the persistent store is incompatible with current managed object
         model
         Check the error message to determine what the actual problem was.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator;
}

//load the application documents path
-(NSString*) loadApplicationDocumentsDirectory {
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    return documentPath;
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
