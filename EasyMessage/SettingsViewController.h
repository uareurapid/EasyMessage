//
//  SettingsViewController.h
//  EasyMessage
//
//  Created by Paulo Cristo on 6/19/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define OPTION_ALWAYS_SEND_BOTH   @"Always send both"
#define OPTION_SEND_EMAIL_ONLY    @"Send email only"
#define OPTION_SEND_SMS_ONLY      @"Send SMS only"

#define OPTION_ALWAYS_SEND_BOTH_ID   0
#define OPTION_SEND_EMAIL_ONLY_ID    1
#define OPTION_SEND_SMS_ONLY_ID      2

#define OPTION_PREF_SERVICE_ALL    @"Use both services"
#define OPTION_PREF_SERVICE_EMAIL  @"Email service"
#define OPTION_PREF_SERVICE_SMS    @"SMS service"

#define OPTION_PREF_SERVICE_ALL_ID    0
#define OPTION_PREF_SERVICE_EMAIL_ID  1
#define OPTION_PREF_SERVICE_SMS_ID    2


#define OPTION_PREFERED_EMAIL_PHONE_ITEMS    @"Preferred email/phone"
#define OPTION_PREFERED_EMAIL_PHONE_ITEMS_ID    0


//save on device
#define SETTINGS_PREF_SEND_OPTION_KEY    @"pref_send_option_key"
#define SETTINGS_PREF_SERVICE_KEY        @"pref_service_key"

@class PreferedItemOrderViewController;

@interface SettingsViewController : UITableViewController

@property(strong,nonatomic)NSMutableArray *sendOptions;
@property(strong,nonatomic)NSMutableArray *preferedServiceOptions;

@property (assign,nonatomic) NSInteger selectSendOption;
@property (assign,nonatomic) NSInteger selectPreferredService;

@property BOOL showToast;

@property (strong,nonatomic) PreferedItemOrderViewController *furtherOptionsController;

@end
