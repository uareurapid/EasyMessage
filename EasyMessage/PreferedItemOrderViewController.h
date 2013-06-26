//
//  PreferedItemOrderViewController.h
//  EasyMessage
//
//  Created by Paulo Cristo on 6/26/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ITEM_PHONE_NONE  @"NONE (no preference)"
#define ITEM_PHONE_MOBILE @"mobile"
#define ITEM_PHONE_IPHONE @"iphone"
#define ITEM_PHONE_HOME   @"home"
#define ITEM_PHONE_WORK   @"work"
#define ITEM_PHONE_MAIN  @"main"

#define ITEM_PHONE_NONE_ID   0
#define ITEM_PHONE_MOBILE_ID 1
#define ITEM_PHONE_IPHONE_ID 2
#define ITEM_PHONE_HOME_ID   3
#define ITEM_PHONE_WORK_ID   4
#define ITEM_PHONE_MAIN_ID   5

#define ITEM_EMAIL_NONE   @"NONE (no preference)"
#define ITEM_EMAIL_HOME   @"home"
#define ITEM_EMAIL_WORK   @"work"
#define ITEM_EMAIL_OTHER  @"other"

#define ITEM_EMAIL_NONE_ID  0
#define ITEM_EMAIL_HOME_ID  1
#define ITEM_EMAIL_WORK_ID  2
#define ITEM_EMAIL_OTHER_ID 3


#define ADVANCED_OPTION_PREFERRED_EMAIL_KEY   @"Preferred email address"
#define ADVANCED_OPTION_PREFERRED_PHONE_KEY   @"Preferred phone number"




@interface PreferedItemOrderViewController : UITableViewController

@property (strong,nonatomic) NSMutableArray *preferedEmailOptions;
@property (strong,nonatomic) NSMutableArray *preferedPhoneOptions;
@property (strong,nonatomic) UIViewController *previousController;

@property NSInteger selectedEmailOption;
@property NSInteger selectedPhoneOption;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil previousController: (UIViewController *) previous;

@end
