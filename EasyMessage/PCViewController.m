//
//  PCViewController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/18/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "PCViewController.h"
#import "Contact.h"
#import "SelectRecipientsViewController.h"
#import <UIKit/UIKit.h>
#import "PreferedItemOrderViewController.h"


@interface PCViewController ()

@end

@implementation PCViewController

@synthesize settingsController,subject,body,image;
@synthesize selectedRecipientsList,scrollView,recipientsController;
@synthesize smsSentOK,emailSentOK,sendButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //settingsController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = NSLocalizedString(@"compose",nil);
    //add the settings button
    //UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
      //                                                                 style:UIBarButtonItemStyleDone target:self action:@selector(showSettings:)];
    //self.navigationItem.rightBarButtonItem = settingsButton;
    
    /*UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithTitle:@"Exit"
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(showSettings:)];
    self.navigationItem.leftBarButtonItem = exitButton;*/
    
    smsSentOK = NO;
    emailSentOK = NO;

    subject.delegate = self;
    body.delegate = self;
    sendButton.titleLabel.text = NSLocalizedString(@"send_message",nil);
    subject.placeholder = NSLocalizedString(@"placeholder_subject",nil);
    [body setPlaceholder: NSLocalizedString(@"placeholder_your_message", nil)];
    
    
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
        
    }
    return  self;
}

-(void) viewWillAppear:(BOOL)animated {
    
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


//load the contacts from device
- (IBAction)sendMessage:(id)sender {
    
    if(subject.text.length==0 && body.text.length==0) {
        
        [self showAlertBox: @"Subject and message body cannot be empty!"];
         
    }
    else if(body.text.length==0) {
        
        [self showAlertBox: @"The message body cannot be empty!"];

    }
    else if(selectedRecipientsList.count==0) {
        
        [self showAlertBox: @"You need to select at least one recipient!"];
    }
    else {
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
        if(settingsController.selectSendOption == OPTION_ALWAYS_SEND_BOTH_ID
           || settingsController.selectSendOption == OPTION_SEND_EMAIL_ONLY_ID) {
            
            emailSentOK = NO;
            [self sendEmail:nil];//will send sms on dismiss email
        }
        else if(settingsController.selectSendOption == OPTION_SEND_SMS_ONLY_ID) {
            
            smsSentOK = NO;
            [self sendSMS:nil];
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

//create the address book reference and register the callback
-(void)setupAddressBook {
    
    @try {
        [self loadContactsList:nil];
    }
    @catch (NSException *exception) {
        [self showAlertBox:[NSString stringWithFormat:@"Unable to load contacts from address book: %@",exception.description]];
    }
    @finally {
        //do nothing
    }
    
    
}

-(IBAction)loadContactsList:(id)sender {
    
    
    CFErrorRef * error = NULL;
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
        
        [recipientsController.contactsList removeAllObjects];
        [recipientsController.contactsList addObjectsFromArray:contacts];
        
        [recipientsController.selectedContactsList removeAllObjects];
        [recipientsController.selectedContactsList addObjectsFromArray:selectedRecipientsList];
        
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        
    }
     
    
    
}

-(NSMutableArray *)loadContacts: (ABAddressBookRef) addressBook {
    
     NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    
    ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
    //NSArray *thePeople = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByLastName);
    
    //CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByLastName);
    
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    
    //ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize);
    
    
    
    for(int i = 0; i < numberOfPeople; i++){
        //NSData  *imgData = (__bridge_transfer NSData *) ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatThumbnail);
        
        Contact *contact = [[Contact alloc] init];
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
        ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
        
        //FORGET THIS, WILL CONFUSE USERS MORE
        //NSInteger preferredEmailAddress = settingsController.furtherOptionsController.selectedEmailOption;
        //NSInteger preferredPhoneNumber = settingsController.furtherOptionsController.selectedPhoneOption;
        //NSLog(@"preferred email: %d preferred number: %d", preferredEmailAddress,preferredPhoneNumber);

#pragma GET EMAIL ADDRESS
        
        int count = ABMultiValueGetCount(multi);
        NSString *email;
        
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
        NSString *name = (__bridge NSString*)ABRecordCopyCompositeName(person);
        NSString *lastName =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
        
        
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
        //it means we don´t have email adresses and we´re not sending SMS next either
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage: Send email"
                                                        message:@"You need to select at least one valid recipient or adjust your settings!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
    else {
        [self sendSMS:nil];
    }
    
    
    
}
//delegate for the email controller
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *msg;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            msg = @"Mail cancelled";
            break;
        case MFMailComposeResultSaved:
            msg = @"Mail saved";
            break;
        case MFMailComposeResultSent:
            msg = @"Mail sent";
            emailSentOK = YES;
            break;
        case MFMailComposeResultFailed:
            msg = [NSString stringWithFormat:@"Mail sent failure: %@", [error localizedDescription] ];
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
        [self clearFieldsAndRecipients];
    }
}

//delegate for the sms controller
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSString *msg;
	switch (result) {
		case MessageComposeResultCancelled:
            msg = @"Cancelled";
			break;
		case MessageComposeResultFailed:
            msg = @"Unable to compose SMS";
			break;
		case MessageComposeResultSent:
            msg = @"SMS sent";
            smsSentOK = YES;
			break;
		default:
			break;
	}
    if(msg!=nil) {
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:1000] show];
    }
    
	[self dismissViewControllerAnimated:YES completion:^{[self clearFieldsAndRecipients];}];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage: Send SMS"
                                                        message:@"You need to select at least one valid recipient or adjust your settings!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
    
 }
 else {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage: Send SMS"
                                                    message:@"It´s not possible to send the SMS, please check your device settings!"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
 }
    
    
}

//clear stuff
-(void)clearFieldsAndRecipients {
    subject.text = @"";
    body.text = @"";
    [selectedRecipientsList removeAllObjects];
    [recipientsController.selectedContactsList removeAllObjects];
    [recipientsController.tableView reloadData];
}

//get all emails
-(NSMutableArray *) getEmailAdresses {
    
    NSMutableArray *emails = [[NSMutableArray alloc] init];
    for(Contact *c in selectedRecipientsList) {
        
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
                            NSLog(@"We prefere to use SMS service but we´re sending just email so %@ will be added to the addresses list",c.email);
                            [emails addObject:c.email];
                        }
                        //else {//means we are sending either BOTH or just SMS
                            //so we skip it, cause it will inlcuded in the SMS check
                        //}
                    
                    }
                    else {
                        //contact does not have phone number, so MUST be reached by email, even if not preferered
                        NSLog(@"We prefere to use SMS service but we don´t have a phone number, just email, so %@ will be added to the addresses list",c.email);
                        [emails addObject:c.email];
                    }
                    
                }
                else {
                    //preference is email, so it´s ok to add it
                    NSLog(@"We prefere to use email service and for that reason %@ will be added to the addresses list",c.email);
                    [emails addObject:c.email];
                }
                
            }
            else {
                //option is OPTION_PREF_SERVICE_ALL_ID , so it´s ok to add it
                NSLog(@"We prefere to use both services, so %@ will be added to the addresses list",c.email);
                [emails addObject:c.email];
            }
            
            
            
            
        }
    }
    return emails;
}

//get all phones
-(NSMutableArray *) getPhoneNumbers {
    
    NSMutableArray *phones = [[NSMutableArray alloc] init];
    for(Contact *c in selectedRecipientsList) {
        
        
            
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
                         NSLog(@"We want to send just SMS, so %@ will be added to the phones list",c.phone);
                         [phones addObject:c.phone]; 
                         
                     }
                     else if(emailSentOK==NO) {//means it was EMAIL AND SMS, OR JUST EMAIL, but failed
                         NSLog(@"We wanted to send just email or both, but the email delivery has failed, so %@ will be added to the phones list",c.phone);
                         [phones addObject:c.phone];
                         
                     }
                     //else {
                         //do nothing, cause the email was already sent for sure, and with success
                         //skip it
                     //}
                 }
                 else {
                     //the contact does not have email, so it MUST be reached by SMS, despite the preference
                     NSLog(@"We prefere to use email service, but we don´t have and address so %@ will be added to the phones list",c.phone);
                     [phones addObject:c.phone]; 
                 }
                 
             }
             else {//means settingsController.selectPreferredService == OPTION_PREF_SERVICE_SMS_ID
                 //if the prefereed service is SMS, we can add it
                 NSLog(@"We prefere to use SMS service, so %@ will be added to the phones list",c.phone);
                 [phones addObject:c.phone]; 
             }
             
         }
         else {
            //preference is send both, so it´s ok to add it
            NSLog(@"We prefere to use both services, so %@ will be added to the phones list",c.phone);
            [phones addObject:c.phone]; 
         }
         
         
        
     }
        
        
    }//end if phone!=nil
    
    return phones;
}

//Callback to detect adressbook changes
void addressBookChanged(ABAddressBookRef reference,
                        CFDictionaryRef dictionary,
                        void *context)
{
    ABAddressBookRegisterExternalChangeCallback(reference,dictionary,context);
    
    PCViewController *_self = (__bridge PCViewController *)context;
   
    if(_self!=nil) {
        
        [_self showAlertBox:@"Your Address book has changed! Refreshing data..."];
        [_self.selectedRecipientsList removeAllObjects];
        [_self loadContactsList:nil];
        [_self.recipientsController refreshPhonebook:nil];
      
    }
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

@end
