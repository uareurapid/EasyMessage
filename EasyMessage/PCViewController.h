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
#import <AddressBook/AddressBook.h>

@class SelectRecipientsViewController;
@class IAPMasterViewController;
@class CustomMessagesController;

@interface PCViewController : UIViewController <MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,UITextFieldDelegate>
- (IBAction)sendMessage:(id)sender;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)switchSaveMessageValueChanged:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UILabel *labelMessage;
@property (strong, nonatomic) IBOutlet UILabel *labelSubject;
@property (strong, nonatomic) IBOutlet UILabel *labelOnlySocial;

@property (strong, nonatomic) IBOutlet UISwitch *saveMessageSwitch;

@property ABAddressBookRef addressBook;


-(IBAction)loadContactsList:(id)sender;
- (IBAction)showSettings:(id)sender;
- (IBAction)sendEmail:(id)sender;
-(IBAction)sendSMS:(id)sender;
-(IBAction)presentMediaPicker:(id) sender;
-(NSMutableArray *) getEmailAdresses;
-(NSMutableArray *) getPhoneNumbers;

void addressBookChanged(ABAddressBookRef reference,
                        CFDictionaryRef dictionary,
                        void *context);
-(void)setupAddressBook;

@property (strong, nonatomic) IBOutlet UITextField *subject;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *body;
@property (strong, nonatomic) IBOutlet UIImageView *lockImage;

@property (strong, nonatomic) UIImage *imageLock;
@property (strong, nonatomic) UIImage *imageUnlock;

@property (strong, nonatomic) IBOutlet UILabel *labelSaveArchive;
@property (strong, nonatomic) NSTimer *changeTimer;


@property(strong,nonatomic) SettingsViewController* settingsController;
@property(strong,nonatomic) SelectRecipientsViewController *recipientsController;
@property(strong,nonatomic) IAPMasterViewController *inAppPurchaseTableController;
@property (strong, nonatomic) CustomMessagesController *customMessagesController;


@property (strong,nonatomic) NSMutableArray *selectedRecipientsList;

@property BOOL emailSentOK;
@property BOOL smsSentOK;

@property BOOL facebookSentOK;
@property BOOL twitterSentOK;
@property BOOL sendToFacebook;
@property BOOL sendToTwitter;
@property BOOL saveMessage;


@end
