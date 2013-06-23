//
//  PCViewController.h
//  EasyMessage
//
//  Created by Paulo Cristo on 6/18/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import <MessageUI/MessageUI.h> 
#import "UIPlaceHolderTextView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "iToast.h"

@interface PCViewController : UIViewController <MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UIImagePickerControllerDelegate>
- (IBAction)sendMessage:(id)sender;

-(IBAction)loadContactsList:(id)sender;
- (IBAction)showSettings:(id)sender;
- (IBAction)showEmail:(id)sender;
-(IBAction)sendSMS:(id)sender;
-(IBAction)presentMediaPicker:(id) sender;

@property (strong, nonatomic) IBOutlet UITextField *subject;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *body;


@property(strong,nonatomic) SettingsViewController* settingsController;


@end
