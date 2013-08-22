//
//  PreferedItemOrderViewController.h
//  EasyMessage
//
//  Created by Paulo Cristo on 6/26/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iToast.h"
#import "SettingsViewController.h"




@interface SocialNetworksViewController : UITableViewController

@property (strong,nonatomic) NSMutableArray *selectedServiceOptions;
@property (strong,nonatomic) NSMutableArray *sendOptions;
@property (strong,nonatomic) UIViewController *previousController;
@property BOOL isFacebookAvailable;
@property BOOL isTwitterAvailable;
@property (assign,nonatomic) NSInteger initiallySelectedNumOfSocialNetworks;
//@property (assign,nonatomic) NSInteger numSelectedSocialNetworks;


-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
   previousController: (UIViewController *) previous services:(NSArray *) services;

@end
