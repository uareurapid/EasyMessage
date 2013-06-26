//
//  PCAppDelegate.h
//  EasyMessage
//
//  Created by Paulo Cristo on 6/18/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCViewController;
@class SettingsViewController;
@class SelectRecipientsViewController;

@interface PCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) PCViewController *viewController;
@property (strong, nonatomic) SettingsViewController *settingsController;
@property (strong, nonatomic) SelectRecipientsViewController *recipientsController;

@end
