//
//  PCViewController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/18/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "PCViewController.h"
#import "Contact.h"
#import "Group.h"
#import "SelectRecipientsViewController.h"
#import <UIKit/UIKit.h>
#import "SocialNetworksViewController.h"
#import "IAPMasterViewController.h"
#import "EasyMessageIAPHelper.h"
#import "CoreDataUtils.h"
#import "ContactDataModel.h"
#import "MessageDataModel.h"
#import "CustomMessagesController.h"

@interface PCViewController ()

@end

@implementation PCViewController

@synthesize settingsController,subject,body,image;
@synthesize selectedRecipientsList,scrollView,recipientsController;
@synthesize smsSentOK,emailSentOK,sendButton;
@synthesize labelMessage,labelSubject,labelOnlySocial;
@synthesize sendToFacebook,sendToTwitter,facebookSentOK,twitterSentOK;
@synthesize changeTimer,saveMessageSwitch,saveMessage,inAppPurchaseTableController;
@synthesize labelSaveArchive,lockImage;
@synthesize customMessagesController;
@synthesize imageLock,imageUnlock;


- (void)viewDidLoad
{
    [super viewDidLoad];
    //settingsController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"EasyMessage";//NSLocalizedString(@"compose",nil);
    labelSaveArchive.text = NSLocalizedString(@"archive_message", @"save in archive");
 
    
    smsSentOK = NO;
    emailSentOK = NO;
    facebookSentOK = NO;
    twitterSentOK = NO;
    sendToTwitter = NO;
    sendToFacebook = NO;
    saveMessage = NO;

    labelOnlySocial.text = NSLocalizedString(@"no_recipients_only_social","@only social post, no recipients selected");
    
    subject.delegate = self;
    body.delegate = self;
    [sendButton setTitle:NSLocalizedString(@"send_message",nil) forState:UIControlStateNormal];
    
    subject.placeholder = NSLocalizedString(@"placeholder_subject",nil);
    [body setPlaceholder: NSLocalizedString(@"placeholder_your_message", nil)];
    
    labelSubject.text = NSLocalizedString(@"subject_label",nil);
    labelMessage.text = NSLocalizedString(@"message_label",nil);
    
    //the table that shows the in app purchases
    inAppPurchaseTableController = [[IAPMasterViewController alloc] initWithNibName:@"IAPMasterViewController" bundle:nil];
    
    //set the images
    imageLock = [UIImage imageNamed:@"Lock32"];
    imageUnlock = [UIImage imageNamed:@"Unlock32"];
    
    selectedRecipientsList = [[NSMutableArray alloc]init];
    [scrollView flashScrollIndicators];
    [scrollView setContentSize:self.view.frame.size];
    
    //load the contacts list when the view loads
    [self setupAddressBook];
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableViewBackground.png"]];
 
  
}
//override
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.tabBarItem.image = [UIImage imageNamed:@"email"];
        self.tabBarItem.title = NSLocalizedString(@"compose",nil);
        
        UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"clear",@"clear")
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(clearClicked:)];
        self.navigationItem.rightBarButtonItem = clearButton;
        
    }
    return  self;
}

//appear/disappear logic
-(void) viewWillAppear:(BOOL)animated {
    
    [self showHideSocialOnlyLabel];
    BOOL purchasedCommonMessages = [[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_COMMON_MESSAGES];
    
    if(purchasedCommonMessages) {
        lockImage.image = imageUnlock;
    }
    else {
        lockImage.image = imageLock;
    }
    
    [saveMessageSwitch setEnabled:purchasedCommonMessages];
    [self.navigationItem.rightBarButtonItem setEnabled: (subject.text.length > 0 || body.text.length>0) ];
    
    
   
}

//clear stuff

-(IBAction)clearClicked:(id)sender
{
    [self clearInputFields];
}

-(void) showHideSocialOnlyLabel {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(selectedRecipientsList.count==0 && settingsController.socialOptionsController.selectedServiceOptions.count>0) {
            labelOnlySocial.hidden = NO;
        }
        else {
            labelOnlySocial.hidden = YES;
        }
        
    });
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//delegate for the subject uitextfield 
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == subject) {
        [subject resignFirstResponder];
        return YES;
    }

    return YES;
}

//text view delegate to enable/disable the clear button
-(void)textViewDidChange:(UITextView *)textView {
   

    BOOL isEnabled = [self.navigationItem.rightBarButtonItem isEnabled];
    NSInteger lengthBody = textView.text.length;
    
    if(lengthBody>=1 && !isEnabled) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    else if(lengthBody==0 && isEnabled) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    
}

//delegate for the body uitextview
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        [body resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}

/*
- (IBAction)sendMessage:(id)sender {
    [self sendToFacebook:nil];//http://www.visualpharm.com/
}*/


//- (IBAction)sendMessage:(id)sender {
    
//    [self presentViewController:inAppPurchaseTableController animated:YES completion:nil];
//}

- (IBAction)sendMessage:(id)sender {
    
    
    BOOL isFacebookAvailable = settingsController.socialOptionsController.isFacebookAvailable;
    BOOL isTwitterAvailable = settingsController.socialOptionsController.isTwitterAvailable;
    BOOL isFacebookSelected = NO;
    BOOL isTwitterSelected = NO;
    
    if(isFacebookAvailable) {
        isFacebookSelected = [settingsController.socialOptionsController.selectedServiceOptions containsObject: OPTION_SENDTO_FACEBOOK_ONLY];
    }
    if(isTwitterAvailable) {
        isTwitterSelected = [settingsController.socialOptionsController.selectedServiceOptions containsObject: OPTION_SENDTO_TWITTER_ONLY];
    }
    
    sendToFacebook = isFacebookSelected;
    sendToTwitter = isTwitterSelected;
    
    if(subject.text.length==0 && body.text.length==0) {
        
        [self showAlertBox: NSLocalizedString(@"alert_message_both_empty", @"Subject and message body cannot be empty!")];
         
    }
    else if(body.text.length==0) {
        
        [self showAlertBox: NSLocalizedString(@"alert_message_body_empty",@"The message body cannot be empty!")];

    }
    else if(selectedRecipientsList.count==0 ) {
        
        if(!sendToFacebook&& !sendToTwitter) {
           [self showAlertBox: NSLocalizedString(@"alert_message_select_least_one",@"You need to select at least one recipient!")]; 
        }
        else {
            [self sendToSocialNetworks];
        
        }
        //if we do not have recipients, neither are using social networks show message
        
    }
    else { //we have recipients
       
        /**
         #define OPTION_ALWAYS_SEND_BOTH   @"Always send both" 0
         #define OPTION_SEND_EMAIL_ONLY    @"Send email only" 1
         #define OPTION_SEND_SMS_ONLY      @"Send SMS only" 2
         
         #define OPTION_PREF_SERVICE_ALL    @"Use both services" 0
         #define OPTION_PREF_SERVICE_EMAIL  @"Email service" 1
         #define OPTION_PREF_SERVICE_SMS    @"SMS service" 2
         
         //further options
         #define ITEM_PHONE_MOBILE_ID 0
         #define ITEM_PHONE_IPHONE_ID 1
         #define ITEM_PHONE_HOME_ID   2
         #define ITEM_PHONE_WORK_ID   3
         #define ITEM_PHONE_MAIN_ID   4
         
         
         #define ITEM_EMAIL_HOME_ID  0
         #define ITEM_EMAIL_WORK_ID  1
         #define ITEM_EMAIL_OTHER_ID 2
         
         **/
       
        @try {
            if(settingsController.selectSendOption == OPTION_ALWAYS_SEND_BOTH_ID || settingsController.selectSendOption == OPTION_SEND_EMAIL_ONLY_ID) {
                
                emailSentOK = NO;
                
                [self sendEmail:nil];//will send sms on dismiss email
            }
            else if(settingsController.selectSendOption == OPTION_SEND_SMS_ONLY_ID) {
                
                smsSentOK = NO;
                [self sendSMS:nil];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Error sending message: %@", exception.description);
        }
        @finally {
            //clear facebook and twitter selection
            //if(isTwitterSelected || isFacebookSelected) {
            //    [self resetSocialNetworks];
            //}
        }

        
    }
    
       
}
//showAlertBox messageios
-(void) showAlertBox:(NSString *) msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

//send to social networks
-(void)sendToSocialNetworks {
    
    //NSLog(@"send to social networks");
    //@try {
        if(sendToFacebook) {
            //NOTE: if twitter is also selected, it will show up/send on facebook result
            [self sendToFacebook:nil];
        }
        else if(sendToTwitter) {
            [self sendToTwitter:nil];
        }
    //}
    //@catch (NSException *exception) {
    //    NSLog(@"Error sending to social networks: %@",exception.description);
    //}
    //@finally {
        //nothing here
    //}
    
    
}

//create the address book reference and register the callback
-(void)setupAddressBook {
    
    @try {
        [self loadContactsList:nil];
    }
    @catch (NSException *exception) {
        [self showAlertBox:[NSString stringWithFormat: NSLocalizedString(@"unable_load_contacts_error_%@", @"unable to read contacts from AB"),exception.description]];
    }
    @finally {
        //do nothing
    }
    
    
}

-(IBAction)loadContactsList:(id)sender {
    
    
    CFErrorRef * error = NULL;
    //ABAddressBookRef 
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    NSMutableArray __block *contacts;
    
    //register a callback to track adressbook changes
    ABAddressBookRegisterExternalChangeCallback(addressBook, addressBookChanged, (__bridge void *)(self));
    
    // Request authorization to Address Book
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // First time access has been granted, add the contact
            contacts = [self loadContacts: addressBook];
       
            [recipientsController.contactsList removeAllObjects];
            [recipientsController.contactsList addObjectsFromArray:contacts];
            
            
            
            [recipientsController.selectedContactsList removeAllObjects];
            [recipientsController.selectedContactsList addObjectsFromArray:selectedRecipientsList];
 
        });
        
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        contacts = [self loadContacts: addressBook];
        
        //load the groups from addressbook (if they have contacts)
        //NSMutableArray *groupsFromAB = [self loadGroups:addressBook];
        
        
        [recipientsController.contactsList removeAllObjects];
        [recipientsController.contactsList addObjectsFromArray:contacts];
        //[recipientsController.contactsList addObjectsFromArray:groupsFromAB];
        
        NSMutableArray *groupsFromDB = [self fetchGroupRecords];
        
        [recipientsController.contactsList addObjectsFromArray:groupsFromDB];
        
        [recipientsController.groupsList removeAllObjects];
        //[recipientsController.groupsList addObjectsFromArray:groupsFromAB];
        //[recipientsController.groupsList addObjectsFromArray:groupsFromDB];
        
        [recipientsController.selectedContactsList removeAllObjects];
        [recipientsController.selectedContactsList addObjectsFromArray:selectedRecipientsList];
        
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        
    }
    [recipientsController refreshPhonebook:nil];
 
    CFRelease(addressBook);
    
}

//get all the records from db
- (NSMutableArray*) fetchGroupRecords{
    
    NSMutableArray *records = [[NSMutableArray alloc] init];
    NSMutableArray *databaseRecords = [CoreDataUtils fetchGroupRecordsFromDatabase];

    for(GroupDataModel *model in databaseRecords) {
               
        //NSLog(@"Loaded group %@ which has %d contacts",model.name,model.contacts.count);
        
        Group *group = [[Group alloc] init];
        group.name = model.name;
        
        for(ContactDataModel *contact in model.contacts) {
            
            Contact *c = [[Contact alloc] init];
            c.name = contact.name;
            c.phone = contact.phone;
            c.email = contact.email;
            c.lastName = contact.lastname;
            
            [group.contactsList addObject:c];
            
        }
        [records addObject:group];

       
    }
    return records;
    
}


//load the groups from the address book
-(NSMutableArray *)loadGroups: (ABAddressBookRef) addressBook {
    
    NSMutableArray *groupsArray = [[NSMutableArray alloc] init];
    
    CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(addressBook);
    CFIndex numGroups = CFArrayGetCount(groups);
    NSLog(@"Num groups is %d",numGroups);
    for(CFIndex idx=0; idx<numGroups; ++idx) {
        
        ABRecordRef groupItem = CFArrayGetValueAtIndex(groups, idx);
        
        NSString *groupName = (__bridge_transfer NSString*)ABRecordCopyCompositeName(groupItem);
        NSLog(@"Loaded group named %@",groupName);
        
        //create the group object
        Group *group = [[Group alloc] init];
        group.email=@"mail@mail.com";
        group.name = groupName;
        group.lastName = groupName;
        group.person = nil;
        
        
        CFArrayRef members = ABGroupCopyArrayOfAllMembers(groupItem);
        if(members) {
            NSUInteger count = CFArrayGetCount(members);
            
            //if(count>0) {
                //only add if has contacts
                //add the group to the array
                [groupsArray addObject:group];
            //}
            
            for(NSUInteger idx=0; idx<count; ++idx) {
                ABRecordRef person = CFArrayGetValueAtIndex(members, idx);
                NSString *name = (__bridge NSString*)ABRecordCopyCompositeName(person);
                NSLog(@"group person: %@",name);
                // your code
            }
            CFRelease(members);
        }
        else {
            NSLog(@"No members in this group");
        }
    }
    
    return groupsArray;
}
//Load the contacts list from the address book
-(NSMutableArray *)loadContacts: (ABAddressBookRef) addressBook {
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    
       //*****
        
        NSArray *arrayOfPeople = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        for(int i = 0; i < arrayOfPeople.count; i++){
            
            
            
            Contact *contact = [[Contact alloc] init];
            ABRecordRef person = (__bridge ABRecordRef)[arrayOfPeople objectAtIndex:i];
            
            
            NSString *name = (__bridge NSString*)ABRecordCopyCompositeName(person);
            NSString *lastName =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            
            //save the reference
            contact.person=person;
            
            NSString *email;
            
            //NSString *theName = (__bridge NSString*)ABRecordCopyCompositeName(person);
            
            
            ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
            
#pragma GET EMAIL ADDRESS
            
            
            int count = ABMultiValueGetCount(multi);
            
            //do we have more than 1?
            if(count > 0) {
                email = [self getPreferredEmail: multi forLabel:kABHomeLabel count: count];
            }
            //else, we don´t have email
            
            //add it if we have it
            if(email!=nil) {
                contact.email = email;
            }
            
            
#pragma GET PHONE NUMBER
            
            NSString *phone;
            
            ABMultiValueRef phoneMulti = ABRecordCopyValue(person, kABPersonPhoneProperty);
            int countPhones = ABMultiValueGetCount(phoneMulti);
            
            if(countPhones>0) {
                phone = [self getPreferredPhone: phoneMulti forLabel:kABPersonPhoneMobileLabel count: countPhones];
                
            }
            
            //add the phone number
            if(phone!=nil) {
                contact.phone = phone;
            }
            
            
            //ABMultiValueRef nameMulti = ABRecordCopyValue(person, kABPersonCompositeNameFormatLastNameFirst);
            //NSString *name = (__bridge NSString*)ABRecordCopyCompositeName(person);
            //NSString *lastName =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            
            //i must have some sort of contact info
            if(phone!=nil || email!=nil) {
                
                if(name!=nil) {
                    contact.name = name;
                }
                if(lastName!=nil) {
                    contact.lastName = lastName;
                }
                
                //try to get the photo if available
                @try {
                    NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
                    if(imgData!=nil) {
                        UIImage  *img = [UIImage imageWithData:imgData];
                        contact.photo = img;
                    }
                    else {
                        UIImage  *img = [UIImage imageNamed:@"111-user"];
                        contact.photo = img;
                    }
                    
                }
                @catch (NSException *exception) {
                    NSLog(@"Unable to get contact photo, %@",[exception description]);
                }
                @finally {
                    ;
                }
                
                [contacts addObject:contact];
                
            }
            
            
        }//end for loop

       //****
    
        
   return contacts;
    
    
    
    
        
    
}

//get the preferred email address to use
-(NSString *) getPreferredEmail: (ABMultiValueRef) properties forLabel:(CFStringRef) labelConst count: (NSInteger) size {
    for (int k=0;k<size; k++)
    {
        NSString *mail = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(properties, k);
        CFStringRef labelValue  =  ABMultiValueCopyLabelAtIndex(properties, k);
        
        //NSLog(@"mail address: %@ with label %@: ",mail, labelValue);
        if (labelValue && CFStringCompare(labelValue, labelConst, 0) == 0) {
            //NSLog(@"found preferred email label %@  whose value is %@",labelConst,mail);
            return mail;
        }
        
    }
    return [self grabFirstEmailAddressInList:properties];
    
}

//just grab the first email address
-(NSString *) grabFirstEmailAddressInList:(ABMultiValueRef) properties {
    //if still here just grab the first one
    NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(properties, 0);
    return email;
}

//get the preferred phone number to use
-(NSString *) getPreferredPhone: (ABMultiValueRef) properties forLabel:(CFStringRef) labelConst count: (NSInteger) size {
    for (int k=0;k<size; k++)
    {
        NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(properties, k);
        CFStringRef labelValue  =  ABMultiValueCopyLabelAtIndex(properties, k);
        
        //NSLog(@"phone number: %@ with label %@: ",phone, labelValue);
        if (labelValue && CFStringCompare(labelValue, labelConst, 0) == 0) {
           // NSLog(@"found preferred phone label %@ whose value is %@",labelConst,phone);
            return phone;
        }
        
    }
    return [self grabFirstPhoneNumberInList:properties];
}

//just grab the first phone number
-(NSString *) grabFirstPhoneNumberInList:(ABMultiValueRef) properties {
    //if still here just grab the first one
    NSString *phone = (__bridge NSString *)ABMultiValueCopyValueAtIndex(properties, 0);
    return phone;
}



- (IBAction)showSettings:(id)sender {
    [self.navigationController pushViewController:settingsController animated:YES];
}

- (IBAction)sendEmail:(id)sender {
    // Email Subject
    NSString *emailTitle = subject.text;
    // Email Content
    NSString *messageBody = body.text;
    // To address
    NSMutableArray *toRecipents = [self getEmailAdresses];
    

    
    if(toRecipents.count>0) {
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    else if(settingsController.selectSendOption != OPTION_ALWAYS_SEND_BOTH_ID) {
        
        //means is OPTION_SEND_EMAIL_ONLY_ID
        //it means it´s selected only email... and we don´t have email adresses and we´re not sending SMS next either
        
        //but if we have social networks, we don´t care and will post to those only
        if(sendToFacebook || sendToTwitter) {
            
            [self sendToSocialNetworks];
        }
        else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"easymessage_send_email_title",@"EasyMessage: Send email")
                                                            message:NSLocalizedString(@"recipients_least_one_recipient", @"select valid recipient")
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
        }
        
        
        
    }
    
    //#BUGFIX this way was sending SMS 2 times! here and on checkIfSendBoth
    //else {
    //    [self sendSMS:nil];
    //}
    
    
    
}
//delegate for the email controller
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *msg;
    switch (result)
    
    {
        case MFMailComposeResultCancelled:
            msg = NSLocalizedString(@"message_mail_canceled",@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            msg = NSLocalizedString(@"message_mail_saved",@"Mail saved");
            break;
        case MFMailComposeResultSent:
            msg = NSLocalizedString(@"message_mail_sent",@"Mail sent");
            emailSentOK = YES;
            break;
        case MFMailComposeResultFailed:
            msg = [NSString stringWithFormat:NSLocalizedString(@"message_mail_sent_failure_%@", @"Mail sent failure"),[error localizedDescription]];
            break;
        default:
            break;
    }
    if(msg!=nil) {
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:2000] show];
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:^{[self checkIfSendBoth];}];
    
    
}
//This is called after send email , if option is send both, send the SMS
-(void) checkIfSendBoth {
    if(settingsController.selectSendOption == OPTION_ALWAYS_SEND_BOTH_ID ) {//OPTION_ALWAYS_SEND_BOTH
        [self sendSMS:nil];
    }
    else {

        [self doSocialNetworksIfSelected];
    }
}

//this is called only from sms or email
-(void) doSocialNetworksIfSelected{
    
    if(sendToFacebook || sendToTwitter) {
        [self sendToSocialNetworks];
  
    }
    else {
       [self clearFieldsAndRecipients];
    }
    
}



//delegate for the sms controller
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    
    NSString *msg;
	switch (result) {
		case MessageComposeResultCancelled:
            msg = NSLocalizedString(@"message_sms_canceled",@"Canceled");
			break;
		case MessageComposeResultFailed:
            msg = NSLocalizedString(@"message_sms_unable_compose",@"Unable to compose SMS");
			break;
		case MessageComposeResultSent:
            msg = NSLocalizedString(@"message_sms_sent",@"SMS sent");
            smsSentOK = YES;
			break;
		default:
			break;
	}
    if(msg!=nil) {
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:1000] show];
    }
    
	[self dismissViewControllerAnimated:YES completion:^{[self doSocialNetworksIfSelected];}];
}

//will send the message to facebook
- (IBAction)sendToFacebook:(id)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [mySLComposerSheet setInitialText:body.text];
        
        //[mySLComposerSheet addImage:[UIImage imageNamed:@"myImage.png"]];
        
        //[mySLComposerSheet addURL:[NSURL URLWithString:@"http://stackoverflow.com/questions/12503287/tutorial-for-slcomposeviewcontroller-sharing"]];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            NSString *msg;
            BOOL clear = YES;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    msg = NSLocalizedString(@"facebook_post_canceled", @"facebook_post_canceled");
                    clear = NO;
                    //NSLog(@"Post to Facebook Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    //NSLog(@"Post to Facebook Sucessful");
                    msg = NSLocalizedString(@"facebook_post_ok", @"facebook_post_ok");
                    
                    break;
                    
                default:
                    break;
            }
            
            if(msg!=nil) {
                [[[[iToast makeText:msg]
                   setGravity:iToastGravityBottom] setDuration:1000] show];
            }
            
            if(sendToTwitter) {
                [self sendToTwitter:nil]; //will reset inside
            }
            else {
                //reset now
                [self resetSocialNetworks:clear];
            }
        }];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
}

//reset the booleans after sending the message
-(void) resetSocialNetworks: (BOOL) clear {
    
    if(clear) {
        sendToFacebook = NO;
        sendToTwitter = NO;
        [settingsController resetSocialNetworks];
        
        if(body.text.length>0) {
            //we still haven´t cleared
            [self clearFieldsAndRecipients];
        }
    }
    
    
    //NSLog(@"resetting....");
}

//send the message also to twitter (facebook is always first if available)
- (IBAction)sendToTwitter:(id)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [mySLComposerSheet setInitialText:body.text];
        
        //[mySLComposerSheet addImage:[UIImage imageNamed:@"myImage.png"]];
        
        //[mySLComposerSheet addURL:[NSURL URLWithString:@"http://stackoverflow.com/questions/12503287/tutorial-for-slcomposeviewcontroller-sharing"]];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        
            
            NSString *msg;
            BOOL clear = YES;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    msg = NSLocalizedString(@"twitter_post_canceled", @"twitter_post_canceled");
                    clear = NO;
                    //NSLog(@"Post to Twitter Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    //NSLog(@"Post to Twitter Sucessful");
                    msg = NSLocalizedString(@"twitter_post_ok", @"twitter_post_ok");
                    break;
                    
                default:
                    break;
            }
            
            
            //we need to dismiss manually for twitter
            [mySLComposerSheet dismissViewControllerAnimated:YES completion:^{[self resetSocialNetworks:clear];}];
            
            if(msg!=nil) {
                [[[[iToast makeText:msg]
                   setGravity:iToastGravityBottom] setDuration:1000] show];
            }
            
        }];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
}


-(IBAction)sendSMS:(id)sender {
    
 MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    
 if([MFMessageComposeViewController canSendText]) {
    
    NSMutableArray *recipients = [self getPhoneNumbers];

    if(recipients.count>0) {
        
        controller.body = body.text;
        controller.recipients = recipients;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    else {
        //means we have no available phones
        //since we´re not sending SMS, social networks will not be on that dismiss, so we need to check if send it now
      
        if(sendToTwitter || sendToFacebook) {
            [self sendToSocialNetworks];
        }
        else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"easymessage_send_sms_title", @"EasyMessage: Send SMS")
                                                            message: NSLocalizedString(@"recipients_least_one_recipient",@"recipient not valid")
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    }
    
 }
 else {
   
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"easymessage_send_sms_title", @"EasyMessage: Send SMS")
                                                    message:NSLocalizedString(@"no_sms_device_settings",@"can´ send sms")
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
 }
    
    
}

//clear stuff, this is called after sending sms or email
-(void)clearFieldsAndRecipients {
    
    
    //NSLog(@"clearing stuff...");
    
    [selectedRecipientsList removeAllObjects];
    [recipientsController.selectedContactsList removeAllObjects];
    [recipientsController.tableView reloadData];
    
    
    if(saveMessage) {
        //TODO SAVE THE MESSAGE
        [self saveMessageInArchive];
    }
    
    [self clearInputFields];
    
    //the default action on beginning is also NOT save
    saveMessage = NO;
    [saveMessageSwitch setOn:NO];
    
    customMessagesController.selectedMessageIndex=-1;
    customMessagesController.selectedMessage = nil;
    
    
}
-(void) clearInputFields{
    subject.text = @"";
    body.text = @"";
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

//save the message in archive, core data
-(void)saveMessageInArchive {
    
    
    NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
  
    
    NSString *msg = body.text;
    //get all the records and see if we have already this one
    NSMutableArray *allRecords = [CoreDataUtils fetchMessageRecordsFromDatabase];
    [allRecords addObjectsFromArray:customMessagesController.messagesList];
    
    BOOL exists = NO;
    for(MessageDataModel *model in allRecords) {
        if([model.msg isEqualToString:msg]) {
            exists=YES;
            break;
        }
    }
    if(!exists) {
        MessageDataModel *message = (MessageDataModel *)[NSEntityDescription insertNewObjectForEntityForName:@"MessageDataModel" inManagedObjectContext:managedObjectContext];
        message.msg = body.text;

        //BOOL OK = NO;
        NSError *error;
        if(![managedObjectContext save:&error]){
            NSLog(@"Unable to save object, error is: %@",error.description);
        }
    }
    
    //else {
    //    OK = YES;
    //    [[[[iToast makeText:NSLocalizedString(@"group_created",@"group_created")]
    //       setGravity:iToastGravityBottom] setDuration:2000] show];
    //}
   
    
}

//get all emails
-(NSMutableArray *) getEmailAdresses {
    
    NSMutableArray *emails = [[NSMutableArray alloc] init];
    for(Contact *c in selectedRecipientsList) {
        
        if([c isKindOfClass:Group.class]) {
            
            Group *group = (Group *)c;
            for(Contact *other in group.contactsList) {
                NSString *emailAddress = [self extractEmailAddress:other];
                if(emailAddress!=nil) {
                    [emails addObject:emailAddress];
                }
            }  
         }
        else {
            NSString *emailAddress = [self extractEmailAddress:c];
            if(emailAddress!=nil) {
                [emails addObject:emailAddress];
            }
        }
        
        
        //first check is see if we have an email address
        /**if(c.email!=nil) {
            
            //if there is a preference other than ALL??
            if(settingsController.selectPreferredService!= OPTION_PREF_SERVICE_ALL_ID) {
                
                if(settingsController.selectPreferredService == OPTION_PREF_SERVICE_SMS_ID) {
                    //the preferred method is SMS
                    if(c.phone!=nil) {
                        
                        //OK, we have an SMS, but are we sending SMS?
                        if(settingsController.selectSendOption == OPTION_SEND_EMAIL_ONLY_ID) {
                            //we are just sending email, so we need to include it anyway
                            //NSLog(@"We prefere to use SMS service but we´re sending just email so %@ will be added to the addresses list",c.email);
                            [emails addObject:c.email];
                        }
                        //else {//means we are sending either BOTH or just SMS
                            //so we skip it, cause it will inlcuded in the SMS check
                        //}
                    
                    }
                    else {
                        //contact does not have phone number, so MUST be reached by email, even if not preferered
                        //NSLog(@"We prefere to use SMS service but we don´t have a phone number, just email, so %@ will be added to the addresses list",c.email);
                        [emails addObject:c.email];
                    }
                    
                }
                else {
                    //preference is email, so it´s ok to add it
                    //NSLog(@"We prefere to use email service and for that reason %@ will be added to the addresses list",c.email);
                    [emails addObject:c.email];
                }
                
            }
            else {
                //option is OPTION_PREF_SERVICE_ALL_ID , so it´s ok to add it
                //NSLog(@"We prefere to use both services, so %@ will be added to the addresses list",c.email);
                [emails addObject:c.email];
            }
            
            
            
            
        }*/
    }
    return emails;
}

-(NSString *) extractEmailAddress: (Contact *)c {
    
    
    
    //first check is see if we have an email address
    if(c.email!=nil) {
        
        //if there is a preference other than ALL??
        if(settingsController.selectPreferredService!= OPTION_PREF_SERVICE_ALL_ID) {
            
            if(settingsController.selectPreferredService == OPTION_PREF_SERVICE_SMS_ID) {
                //the preferred method is SMS
                if(c.phone!=nil) {
                    
                    //OK, we have an SMS, but are we sending SMS?
                    if(settingsController.selectSendOption == OPTION_SEND_EMAIL_ONLY_ID) {
                        //we are just sending email, so we need to include it anyway
                        //NSLog(@"We prefere to use SMS service but we´re sending just email so %@ will be added to the addresses list",c.email);
                        return c.email;
                    }
                    //else {//means we are sending either BOTH or just SMS
                    //so we skip it, cause it will inlcuded in the SMS check
                    //}
                    
                }
                else {
                    //contact does not have phone number, so MUST be reached by email, even if not preferered
                    //NSLog(@"We prefere to use SMS service but we don´t have a phone number, just email, so %@ will be added to the addresses list",c.email);
                    return c.email;
                }
                
            }
            else {
                //preference is email, so it´s ok to add it
                //NSLog(@"We prefere to use email service and for that reason %@ will be added to the addresses list",c.email);
                return c.email;
            }
            
        }
        else {
            //option is OPTION_PREF_SERVICE_ALL_ID , so it´s ok to add it
            //NSLog(@"We prefere to use both services, so %@ will be added to the addresses list",c.email);
            return c.email;
        }
    }
    
    return nil;
}

//get all phones
-(NSMutableArray *) getPhoneNumbers {
    
    NSMutableArray *phones = [[NSMutableArray alloc] init];
    for(Contact *c in selectedRecipientsList) {
        
        if([c isKindOfClass:Group.class]) {
            
            Group *group = (Group *)c;
            for(Contact *other in group.contactsList) {
                NSString *phoneNumber = [self extractPhoneNumber:other];
                if(phoneNumber!=nil) {
                    [phones addObject:phoneNumber];
                }
            }
        }
        else {
            NSString *phoneNumber = [self extractPhoneNumber:c];
            if(phoneNumber!=nil) {
                [phones addObject:phoneNumber];
            }
        }
    }
     /**if(c.phone!=nil) { //first thing we need is a phone number, otherwise we don´t even consider it
         
         //if there is a preference other than ALL??
         if(settingsController.selectPreferredService!= OPTION_PREF_SERVICE_ALL_ID) {
             
             if(settingsController.selectPreferredService == OPTION_PREF_SERVICE_EMAIL_ID) {
                 //if the prefereed service is email, and this one has it, we skip it
                 if(c.email!=nil) {
                     //ok the contact has email, and this is the preferred service
                     //but did we send the email already??
                     if(settingsController.selectSendOption == OPTION_SEND_SMS_ONLY_ID) {
                         //we have choosed just to send SMS, so definetely it was not reached by email before
                         //therefore, we need to add it
                         //NSLog(@"We want to send just SMS, so %@ will be added to the phones list",c.phone);
                         [phones addObject:c.phone]; 
                         
                     }
                     else if(emailSentOK==NO) {//means it was EMAIL AND SMS, OR JUST EMAIL, but failed
                         //NSLog(@"We wanted to send just email or both, but the email delivery has failed, so %@ will be added to the phones list",c.phone);
                         [phones addObject:c.phone];
                         
                     }
                     //else {
                         //do nothing, cause the email was already sent for sure, and with success
                         //skip it
                     //}
                 }
                 else {
                     //the contact does not have email, so it MUST be reached by SMS, despite the preference
                     //NSLog(@"We prefere to use email service, but we don´t have and address so %@ will be added to the phones list",c.phone);
                     [phones addObject:c.phone]; 
                 }
                 
             }
             else {//means settingsController.selectPreferredService == OPTION_PREF_SERVICE_SMS_ID
                 //if the prefereed service is SMS, we can add it
                 //NSLog(@"We prefere to use SMS service, so %@ will be added to the phones list",c.phone);
                 [phones addObject:c.phone]; 
             }
             
         }
         else {
            //preference is send both, so it´s ok to add it
            //NSLog(@"We prefere to use both services, so %@ will be added to the phones list",c.phone);
            [phones addObject:c.phone]; 
         }
         
         
        
     }
        
        
    }//end if phone!=nil
    */
    return phones;
}

-(NSString *) extractPhoneNumber: (Contact *)c {
    
    if(c.phone!=nil) { //first thing we need is a phone number, otherwise we don´t even consider it
        
        //if there is a preference other than ALL??
        if(settingsController.selectPreferredService!= OPTION_PREF_SERVICE_ALL_ID) {
            
            if(settingsController.selectPreferredService == OPTION_PREF_SERVICE_EMAIL_ID) {
                //if the prefereed service is email, and this one has it, we skip it
                if(c.email!=nil) {
                    //ok the contact has email, and this is the preferred service
                    //but did we send the email already??
                    if(settingsController.selectSendOption == OPTION_SEND_SMS_ONLY_ID) {
                        //we have choosed just to send SMS, so definetely it was not reached by email before
                        //therefore, we need to add it
                        //NSLog(@"We want to send just SMS, so %@ will be added to the phones list",c.phone);
                        //[phones addObject:c.phone];
                        return c.phone;
                        
                    }
                    else if(emailSentOK==NO) {//means it was EMAIL AND SMS, OR JUST EMAIL, but failed
                        //NSLog(@"We wanted to send just email or both, but the email delivery has failed, so %@ will be added to the phones list",c.phone);
                        //[phones addObject:c.phone];
                        return c.phone;
                        
                    }
                    //else {
                    //do nothing, cause the email was already sent for sure, and with success
                    //skip it
                    //}
                }
                else {
                    //the contact does not have email, so it MUST be reached by SMS, despite the preference
                    //NSLog(@"We prefere to use email service, but we don´t have and address so %@ will be added to the phones list",c.phone);
                    //[phones addObject:c.phone];
                    return c.phone;
                }
                
            }
            else {//means settingsController.selectPreferredService == OPTION_PREF_SERVICE_SMS_ID
                //if the prefereed service is SMS, we can add it
                //NSLog(@"We prefere to use SMS service, so %@ will be added to the phones list",c.phone);
                //[phones addObject:c.phone];
                return c.phone;
            }
            
        }
        else {
            //preference is send both, so it´s ok to add it
            //NSLog(@"We prefere to use both services, so %@ will be added to the phones list",c.phone);
            //[phones addObject:c.phone];
            return c.phone;
        }
        
    
  }//end if phone!=nil

 return nil;
}

//Callback to detect adressbook changes
//this sometimes get called multiple times, so we just log and do not show the alert message
//update we use a timer, to call after it ends only
void addressBookChanged(ABAddressBookRef reference,
                        CFDictionaryRef dictionary,
                        void *context)
{
    ABAddressBookRegisterExternalChangeCallback(reference,dictionary,context);
    
    PCViewController *_self = (__bridge PCViewController *)context;
    
    if(_self !=nil) {
    
        if(_self.changeTimer!=nil) {
            [_self.changeTimer invalidate];
        }
      _self.changeTimer = nil;
      _self.changeTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                        target:_self
                                                      selector:@selector(handleAdressBookExternalCallbackBackground)
                                                      userInfo:nil
                                                      repeats:NO];
    }
}


//this will be called when the timer ends, after an address book changed notification
-(void) handleAdressBookExternalCallbackBackground {
    
        
        [self showAlertBox: NSLocalizedString(@"address_book_changed_msg",@"address has changed")];
        //NSLog(@"address book has changed");
        [self.selectedRecipientsList removeAllObjects];
        [self loadContactsList:nil];
        //refresh is already done inside loadContactsList
        //[_self.recipientsController refreshPhonebook:nil];
        
    
}

/**
 MMS
 MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
 
 UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
 pasteboard.persistent = YES;
 pasteboard.image = [UIImage imageNamed:@"PDF_File.png"];
 
 NSString *phoneToCall = @"sms:";
 NSString *phoneToCallEncoded = [phoneToCalll stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
 NSURL *url = [[NSURL alloc] initWithString:phoneToCallEncoded];
 [[UIApplication sharedApplication] openURL:url];
 
 if([MFMessageComposeViewController canSendText]) {
 NSMutableString *emailBody = [[NSMutableString alloc] initWithString:@"Your Email Body"];
 picker.messageComposeDelegate = self;
 picker.recipients = [NSArray arrayWithObject:@"123456789"];
 [picker setBody:emailBody];// your recipient number or self for testing
 picker.body = emailBody;
 NSLog(@"Picker -- %@",picker.body);
 [self presentModalViewController:picker animated:YES];
 NSLog(@"SMS fired");
 }
 */





-(IBAction)presentMediaPicker:(id)sender {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    
	//f((UIButton *) sender == choosePhotoBtn) {
		picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	//} else {
	//	picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	//}
    
	[self presentModalViewController:picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissModalViewControllerAnimated:YES];
	image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    NSURL *imagePath = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    
    NSString *imageName = [imagePath lastPathComponent];
    NSString *msg = [NSString stringWithFormat:@"Attached image %@!",imageName];
    
    [[[[iToast makeText:msg]
       setGravity:iToastGravityBottom] setDuration:3000] show];
}


#pragma rotation stuff
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration
                     animations:^(void) {
                         //if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
                         //    self.scrollView.alpha = 0.0f;
                         //} else {
                             self.scrollView.alpha = 1.0f;
                             
                         //}
                     }];
}

- (IBAction)switchSaveMessageValueChanged:(id)sender {
    saveMessage = saveMessageSwitch.on ? YES : NO;
}
@end
