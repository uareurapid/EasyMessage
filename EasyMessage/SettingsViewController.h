//
//  SettingsViewController.h
//  EasyMessage
//
//  Created by Paulo Cristo on 6/19/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define OPTION_ALWAYS_SEND_BOTH   @"Always send both"
#define OPTION_SEND_SMS_ONLY      @"Send SMS only"
#define OPTION_SEND_EMAIL_ONLY    @"Send email only"

#define OPTION_PREF_SERVICE_EMAIL  @"Email service"
#define OPTION_PREF_SERVICE_SMS    @"SMS service"
#define OPTION_PREF_SERVICE_ALL    @"Use both services"


//save on device
#define SETTINGS_PREF_SEND_OPTION_KEY    @"pref_send_option_key"
#define SETTINGS_PREF_SERVICE_KEY        @"pref_service_key"


@interface SettingsViewController : UITableViewController

@property(strong,nonatomic)NSMutableArray *sendOptions;
@property(strong,nonatomic)NSMutableArray *preferedServiceOptions;

@property (assign,nonatomic) NSInteger selectSendOption;
@property (assign,nonatomic) NSInteger selectPreferredService;

@end
