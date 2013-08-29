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
//#import "SocialNetworksViewController.h"

@class SelectRecipientsViewController;

@interface PCViewController : UIViewController <MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,UITextFieldDelegate>
- (IBAction)sendMessage:(id)sender;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UILabel *labelMessage;
@property (strong, nonatomic) IBOutlet UILabel *labelSubject;
@property (strong, nonatomic) IBOutlet UILabel *labelOnlySocial;

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

@property (strong, nonatomic) NSTimer *changeTimer;


@property(strong,nonatomic) SettingsViewController* settingsController;
@property(strong,nonatomic) SelectRecipientsViewController *recipientsController;


@property (strong,nonatomic) NSMutableArray *selectedRecipientsList;

@property BOOL emailSentOK;
@property BOOL smsSentOK;

@property BOOL facebookSentOK;
@property BOOL twitterSentOK;
@property BOOL sendToFacebook;
@property BOOL sendToTwitter;


@end
