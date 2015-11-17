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
#import "SocialNetworksViewController.h"
#import "IAPMasterViewController.h"
#import "CoreDataUtils.h"
#import "ContactDataModel.h"
#import "MessageDataModel.h"
#import "CustomMessagesController.h"
#import "LIALinkedInHttpClient.h"

//#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "AFURLResponseSerialization.h"
#import "AFHTTPRequestOperation.h"
#import "JSONResponseSerializerWithData.h"


@interface PCViewController ()

@end

@implementation PCViewController

@synthesize settingsController,subject,body,image;
@synthesize selectedRecipientsList,scrollView,recipientsController;
@synthesize smsSentOK,emailSentOK,sendButton;
@synthesize labelMessage,labelSubject,labelOnlySocial;
@synthesize sendToFacebook,sendToTwitter,sendToLinkedin,facebookSentOK,twitterSentOK;
@synthesize changeTimer,saveMessageSwitch,saveMessage,inAppPurchaseTableController;
@synthesize labelSaveArchive,lockImage;
@synthesize customMessagesController;
@synthesize imageName;
@synthesize storeController;
@synthesize popupView;
@synthesize showAds;
@synthesize  timeToShowPromoPopup;
@synthesize attachImageView;

@synthesize attachImage;
//google plus sdk
static NSString * const kClientId = @"122031362005-ibifir1r1aijhke7r3fe404usutpdnlq.apps.googleusercontent.com";

- (void)viewDidLoad
{
    //[super viewDidLoad];
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
    sendToLinkedin = NO;
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
    //imageLock = [UIImage imageNamed:@"Lock32"];
    //imageUnlock = [UIImage imageNamed:@"Unlock32"];
    
    selectedRecipientsList = [[NSMutableArray alloc]init];
    [scrollView flashScrollIndicators];
    [scrollView setContentSize:self.view.frame.size];
    
    //load the contacts list when the view loads
    [self setupAddressBook];
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableViewBackground.png"]];
    
    attachImage = [UIImage imageNamed:@"attach"];
    
    showAds = false;
    //shows / hides the banner, every 30 seconds interval
    //[NSTimer scheduledTimerWithTimeInterval: 30.0 target: self
    //                                                  selector: @selector(callBannerCheck:) userInfo: nil repeats: YES];
    
    self._client = [self client];
    
    
    //check popup times counter
    /**
    NSInteger times;
    if (![[NSUserDefaults standardUserDefaults] valueForKey:PROMO_SHOW_COUNTER]) {
        times = 0;
    }
    else {
        times = [[NSUserDefaults standardUserDefaults]  integerForKey:PROMO_SHOW_COUNTER ];
    }
    
    if(times==0) {
        timeToShowPromoPopup = true;//first time we open this
        times = times +1;
    }
    else {
        timeToShowPromoPopup = false;
        
        if(times == 5) {
            //if we loaded 5 times than reset the counter, to show next time
            times = 0;
        }
        //otherwise just increase the counter
        else {
           times = times +1;
        }
    }
  
    [[NSUserDefaults standardUserDefaults] setInteger:times forKey:PROMO_SHOW_COUNTER];
    
    */
    //to add attachments
    [self setupAttachViewTouch ];
    
    //the ads stuff
    //BOOL purchasedAdsFree = [[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_ADS_FREE];
    showAds = NO;//!purchasedAdsFree;
    //if(showAds) {
    //    [self createAdBannerView];
    //}
    
    [super viewDidLoad];
    
 
  
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
        
   
        
        //attach buttom
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"share",@"share")
                                                                         style:UIBarButtonItemStyleDone target:self action:@selector(shareClicked:)];
        self.navigationItem.leftBarButtonItem = shareButton;
        
    }
    return  self;
}

//setup touch on promo image
-(void) setupPromoViewTouch {

        popupView.imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPromoViewWithGesture:)];
        [popupView.imageView addGestureRecognizer:tapGesture];

}
- (void)didTapPromoViewWithGesture:(UITapGestureRecognizer *)tapGesture {
    
    [popupView.view removeFromSuperview];
    [self openAppStore];

    
}

//setup touch on promo image
-(void) setupAttachViewTouch {
    
    attachImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAttachViewWithGesture:)];
    [attachImageView addGestureRecognizer:tapGesture];
    
}
- (void)didTapAttachViewWithGesture:(UITapGestureRecognizer *)tapGesture {
    
    [self presentMediaPicker:nil];
    
}


//update at a given interval
/*
-(void) updateBannerView {
    
    if(self.showAds==false){
        
        [self.adView setHidden: true];
    }
    else {
        [self.adView setHidden:!self.adView.isHidden];
    }
}*/

//called every 30 seconds
/*
-(void) callBannerCheck:(NSTimer*) t
{
 
    if(self.adView!=nil) {
        
        [self updateBannerView];
        
    }
}*/



/**
 *Adjust banner view stuff
 *
- (void) adjustBannerView {
    CGRect contentViewFrame = self.view.bounds;
    CGRect adBannerFrame = self.adBannerView.frame;
    
    if([self.adBannerView isBannerLoaded])
    {
        CGSize bannerSize = [ADBannerView sizeFromBannerContentSizeIdentifier:self.adBannerView.currentContentSizeIdentifier];
        contentViewFrame.size.height = contentViewFrame.size.height - bannerSize.height;
        adBannerFrame.origin.y = contentViewFrame.size.height;
    }
    else
    {
        adBannerFrame.origin.y = contentViewFrame.size.height;
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.adBannerView.frame = adBannerFrame;
        self.view.frame = contentViewFrame;
    }];
}*/

//appear/disappear logic
-(void) viewWillAppear:(BOOL)animated {
    
    [self showHideSocialOnlyLabel];

    
    //subject is disabled for SMS only or social posts
    [self checkIfPostToSocial];
    if( (sendToFacebook || sendToTwitter || sendToLinkedin) && (selectedRecipientsList.count==0) ) {
        
        //[self.navigationItem.leftBarButtonItem setEnabled:true];
        if(selectedRecipientsList.count==0) {
           [subject setEnabled:false];
        }
        
    }
    else if(settingsController.selectSendOption == OPTION_SEND_SMS_ONLY_ID) {
        
          [subject setEnabled:false];
    }
    else {
          [subject setEnabled:true];
    }
    
    //always ON
    //[saveMessageSwitch setEnabled:purchasedCommonMessages];
    [saveMessageSwitch setEnabled:true];
    [self.navigationItem.rightBarButtonItem setEnabled: (subject.text.length > 0 || body.text.length>0) ];
    
    [self updateAttachButton];
    
   // if(timeToShowPromoPopup ) {
   //     [self setupPromoViewTouch];
        
   //     NSTimer *myTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
     //                                                       target:self
     //                                                     selector:@selector(showPopupView:)
     //                                                   userInfo:nil
     //                                                      repeats:NO];
    //}
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





/**
 * Checks if post to social is active
 */
- (void) checkIfPostToSocial {
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
    sendToLinkedin = [settingsController.socialOptionsController.selectedServiceOptions containsObject: OPTION_SENDTO_LINKEDIN_ONLY];
}

- (IBAction)sendMessage:(id)sender {
    
    
    [self checkIfPostToSocial];
    
    if(subject.text.length==0 && body.text.length==0) {
        
        [self showAlertBox: NSLocalizedString(@"alert_message_both_empty", @"Subject and message body cannot be empty!")];
         
    }
    else if(body.text.length==0) {
        
        [self showAlertBox: NSLocalizedString(@"alert_message_body_empty",@"The message body cannot be empty!")];

    }
    else if(selectedRecipientsList.count==0 ) {
        
        if(!sendToFacebook && !sendToTwitter && !sendToLinkedin) {
           [self showAlertBox: NSLocalizedString(@"alert_message_select_least_one",@"You need to select at least one recipient!")]; 
        }
        else {
            [self sendToSocialNetworks:body.text];
        
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
    
    //reset image attachment TODO not here
    /**
    image = nil;
    imageName = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"attach",@"attach");
    });**/
    
    
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
-(void)sendToSocialNetworks: (NSString*) message {
    
        if(sendToFacebook) {
            //NOTE: if twitter is also selected, it will show up/send on facebook result
            [self sendToFacebook:message];
        }
        else if(sendToTwitter) {
            //on dismiss we check if send to linkedin is selected
            [self sendToTwitter:message];
        }
        else if(!sendToFacebook && !sendToTwitter && sendToLinkedin) {
            //send to linkedin only
            //before send check if we need authorization
            [self authorizeAndSendToLinkedin: message];
            
        }
    
  
}
//auth and send
-(void) authorizeAndSendToLinkedin: (NSString *) message {
    NSString * token = [self accessToken];
    if(token!=nil && [self validToken]) {
        [self sendToLinkedin:message withToken:token];
    }
    else {
        //either is nill or invalid
        [self connectWithLinkedIn:message];
    }
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
            
            //load also the local contact models, from local database
            NSMutableArray *models = [self fetchLocalContactModelRecords];
            
            [recipientsController.contactsList addObjectsFromArray:models];
            
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
        
        //load also the local contact models, from local database
        NSMutableArray *models = [self fetchLocalContactModelRecords];
        
        [recipientsController.contactsList addObjectsFromArray:models];
        //[recipientsController.contactsList addObjectsFromArray:groupsFromAB];
        
        NSMutableArray *groupsFromDB = [self fetchGroupRecords];
        [recipientsController.contactsList addObjectsFromArray:groupsFromDB];
        
        [recipientsController.groupsList removeAllObjects];

        
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

//ContactModel from the local database, not ALAAssets
- (NSMutableArray*) fetchLocalContactModelRecords{
    
    NSMutableArray *records = [[NSMutableArray alloc] init];
    NSMutableArray *databaseRecords = [CoreDataUtils fetchContactModelRecordsFromDatabase];
    NSMutableArray* existingContacts = recipientsController.contactsList;
        
        for(ContactDataModel *contact in databaseRecords) {
            
            NSLog(@"checking name: %@ out of %ld",contact.name, databaseRecords.count);
            
            /*if(contact.group!=nil) {
                //skip this, is a group
                NSLog(@"skipping this as it ")
                continue;
            }*/
            
            NSString *name = contact.name;
            NSString *email = contact.email;
            NSString *phone =  contact.phone;
            
            BOOL exists = false;
            
            for(Contact *existing in existingContacts) {
                
                if(name!=nil && existing.name!=nil) {
                    if([name isEqualToString:existing.name]) {
                        exists = true;
                        break;
                    }
                }
                else if(email!=nil && existing.email!=nil) {
                    if([email isEqualToString:existing.email]) {
                        exists = true;
                        break;
                    }
                }
                else if(phone!=nil && existing.phone!=nil) {
                    if([existing.phone isEqualToString:existing.phone]) {
                        exists = true;
                        break;
                    }
                }
                
                /*if([name isEqualToString:existing.name] || (email!=nil && [email isEqualToString:existing.email] )
                   || (phone!=nil && [existing.phone isEqualToString:existing.phone]) ) {
                    exists = true;
                    break;
                }*/
            }
            if(!exists) {
                //avoid add repeating ones
                Contact *c = [[Contact alloc] init];
                c.name = contact.name;
                c.phone = contact.phone;
                c.email = contact.email;
                c.lastName = contact.lastname;
                
                [records addObject:c];
            }
            
            
            
            
        }
    
    return records;
    
}


//load the groups from the address book
-(NSMutableArray *)loadGroups: (ABAddressBookRef) addressBook {
    
    NSMutableArray *groupsArray = [[NSMutableArray alloc] init];
    
    CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(addressBook);
    CFIndex numGroups = CFArrayGetCount(groups);
    NSLog(@"Num groups is %ld",numGroups);
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
        
        //Get all the image info
        if(image!=nil && imageName!=nil) {
            
            //"image/jpeg" png
            NSData *imageData = [self getImageInfoData];
            BOOL isPNG = [self isImagePNG];
            
            [mc addAttachmentData:imageData mimeType: isPNG ? @"image/png" : @"image/jpeg" fileName:imageName];
        }
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    else if(settingsController.selectSendOption != OPTION_ALWAYS_SEND_BOTH_ID) {
        
        //means is OPTION_SEND_EMAIL_ONLY_ID
        //it means it´s selected only email... and we don´t have email adresses and we´re not sending SMS next either
        
        //but if we have social networks, we don´t care and will post to those only
        if(sendToFacebook || sendToTwitter) {
            
            [self sendToSocialNetworks: body.text];
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
    
    if(sendToFacebook || sendToTwitter || sendToLinkedin) {
        [self sendToSocialNetworks: body.text];
  
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
- (void)sendToFacebook:(NSString *)message {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [mySLComposerSheet setInitialText:message];
        
        if(image!=nil && imageName!=nil) {
            [mySLComposerSheet addImage:image];
        }
        
        if([self isEasyMessageShare:message]) {
            [mySLComposerSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/ca/app/easymessage/id668776671?mt=8"]];
        }
        
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
                [self sendToTwitter:message]; //will reset inside
            }
            else if(sendToLinkedin) {
                //before send check if we need authorization
                [self authorizeAndSendToLinkedin:message];
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
- (void)sendToTwitter:(NSString *)message {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [mySLComposerSheet setInitialText:message];
        
        if(image!=nil && imageName!=nil) {
            [mySLComposerSheet addImage:image];
        }
        
        
        if([self isEasyMessageShare:message]) {
            [mySLComposerSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/ca/app/easymessage/id668776671?mt=8"]];
        }
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        
            
            NSString *msg;
            BOOL clear = YES;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    msg = NSLocalizedString(@"twitter_post_canceled", @"twitter_post_canceled");
                    clear = NO;
                    
                    break;
                case SLComposeViewControllerResultDone:
                    //NSLog(@"Post to Twitter Sucessful");
                    msg = NSLocalizedString(@"twitter_post_ok", @"twitter_post_ok");
                    break;
                    
                default:
                    break;
            }
            
            
            //we need to dismiss manually for twitter
            [mySLComposerSheet dismissViewControllerAnimated:YES completion:^{
                
                //check if send to linkedin
                if(sendToLinkedin) {
                    
                    //before send check if we need authorization
                    [self authorizeAndSendToLinkedin:message];
                    
                }
                else {
                    [self resetSocialNetworks:clear];
                }
            
            
            }];
            
            if(msg!=nil) {
                [[[[iToast makeText:msg]
                   setGravity:iToastGravityBottom] setDuration:1000] show];
            }
            
            
            
        }];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
}

//post to linkedin
-(void) sendToLinkedin: (NSString* ) message withToken: (NSString*) token {
    
        
        //NSString *token = [self accessToken];
        //[self requestMeWithToken:token];
        
        NSMutableString *str = [[NSMutableString alloc] init];
        
        [str appendString:@"https://api.linkedin.com/v1/people/~/shares?oauth2_access_token="];
        [str appendString: token];
        NSString *postURL = [NSString stringWithString:str];
        
        //get the status message
        NSString *title = (subject.text!=nil && subject.text.length>0) ? subject.text : message;

    
        NSMutableString *thePost = [[NSMutableString alloc] init];
        [thePost appendString:@"<share>"];
        [thePost appendString: [NSString stringWithFormat: @"<comment>%@</comment>",message] ];
        [thePost appendString:@"<content>"];
        [thePost appendString: [NSString stringWithFormat: @"<title>%@</title>",title] ];
        [thePost appendString: [NSString stringWithFormat: @"<description>%@</description>",message] ];
        [thePost appendString:@"<submitted-url>https://itunes.apple.com/ca/app/easymessage/id668776671?mt=8</submitted-url>"];
        [thePost appendString:@"<submitted-image-url>http://pcdreams-software.com/images/ic_launcher.png</submitted-image-url>"];
        [thePost appendString:@"</content>"];
        [thePost appendString:@"<visibility>"];
        [thePost appendString:@"<code>anyone</code>"];
        [thePost appendString:@"</visibility>"];
        [thePost appendString:@"</share>"];
        
        
        // Create the request.
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postURL] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:20.0];
        // Specify that it will be a POST request
        [request setHTTPMethod: @"POST"];
        //with xml body
        [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        NSData *requestBodyData = [thePost dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:requestBodyData];
        
        // Create url connection and fire request
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        
        /**
         <?xml version="1.0" encoding="UTF-8"?>
         <share>
         <comment>Check out the LinkedIn Share API!</comment>
         <content>
         <title>LinkedIn Developers Documentation On Using the Share API</title>
         <description>Leverage the Share API to maximize engagement on user-generated content on LinkedIn</description>
         <submitted-url>https://developer.linkedin.com/documents/share-api</submitted-url>
         <submitted-image-url>http://m3.licdn.com/media/p/3/000/124/1a6/089a29a.png</submitted-image-url>
         </content>
         <visibility>
         <code>anyone</code>
         </visibility>
         </share>
         */

    
}

//if the message mentions EasyMessage then is a regular share
-(BOOL) isEasyMessageShare: (NSString *) message {
    return [message rangeOfString:@"EasyMessage"].location !=NSNotFound ;
}

-(IBAction)sendSMS:(id)sender {
    
 MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    
 if([MFMessageComposeViewController canSendText]) {
    
    NSMutableArray *recipients = [self getPhoneNumbers];

    if(recipients.count>0) {
        
        controller.body = body.text;
        controller.recipients = recipients;
        controller.messageComposeDelegate = self;
        
        if(image!=nil && imageName!=nil) {
            if( IS_OS_7_OR_LATER && [MFMessageComposeViewController canSendAttachments]) {
                NSData *imageData = [self getImageInfoData];
                BOOL isPNG = [self isImagePNG];
                [controller addAttachmentData:imageData typeIdentifier:isPNG ? @"image/png" : @"image/jpeg" filename:imageName];
            }
        }
        
        
        [self presentViewController:controller animated:YES completion:nil];
    }
    else {
        //means we have no available phones
        //since we´re not sending SMS, social networks will not be on that dismiss, so we need to check if send it now
      
        if(sendToTwitter || sendToFacebook) {
            [self sendToSocialNetworks: body.text];
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
    
    //update button UI
    image = nil;
    imageName = nil;
    
    [self updateAttachButton];
    
    
    
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
    
    //if i have something the idea is clear
    if(image==nil && imageName==nil) {
        
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:picker animated:YES completion:nil];
        
        
        
    }
    else {
        
        NSString *msg = [NSString stringWithFormat:@"%@ %@!",NSLocalizedString(@"removed",@"removed"),imageName];
        
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:3000] show];
        
        imageName = nil;
        image = nil;
        [self updateAttachButton];
        
    }
    
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissModalViewControllerAnimated:YES];
	image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    NSURL *imagePath = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    
    imageName = [imagePath lastPathComponent];
    NSString *msg = [NSString stringWithFormat:@"%@ %@!",NSLocalizedString(@"added",@"added"),imageName];

    
    [[[[iToast makeText:msg]
       setGravity:iToastGravityBottom] setDuration:3000] show];
    
    
    //update image...
    [self updateAttachButton];
    
}


#pragma rotation stuff
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
 
        //adjust the banner view to the current orientation
        //if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
        //    self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        //else
        //    self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    
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

//Get data
- (NSData *) getImageInfoData {
    
    NSData *imageData = nil;
    
    if ([self isImagePNG]) {
        imageData = UIImagePNGRepresentation(image);
    }
    else {
        imageData = UIImageJPEGRepresentation(image, 0.7); // 0.7 is JPG quality
    }

    return imageData;
    
}

//check is is PNG
-(BOOL) isImagePNG {
    bool isPNG = true;
    if ([imageName rangeOfString:@".png"].location != NSNotFound) {
        return isPNG;
    }
    else if([imageName rangeOfString:@".jpg"].location != NSNotFound
            || [imageName rangeOfString:@".jpeg"].location != NSNotFound) {
        isPNG = false;
    }
    else {
        isPNG = true;
    }
    return isPNG;
}

-(IBAction)shareClicked:(id)sender {
    //to get any selected ones
    [self checkIfPostToSocial];
    
    imageName = @"Icon-Small.png";
    image = [UIImage imageNamed:@"Icon-Small"];
    [self updateAttachButton];
    
    if(!sendToLinkedin && !sendToTwitter && !sendToFacebook) {
        
        
        //send at least to twitter
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            
           [self sendToTwitter:@"Checkout EasyMessage: SMS,Email & Social in one! "];
        }
        else if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {

            [self sendToFacebook:@"Checkout EasyMessage: SMS,Email & Social in one!"];
        }
        else {
          [self authorizeAndSendToLinkedin:@"Checkout EasyMessage: SMS,Email & Social in one!"];
        }
        
        
    }
    else {
        [self sendToSocialNetworks:@"Checkout EasyMessage: SMS,Email & Social in one!"];
    }
    
}

-(IBAction)showPopupView:(id)sender {
    
    
    popupView = [[PCPopupViewController alloc] initWithNibName:@"PCPopupViewController" bundle:nil];
    popupView.view.alpha=0.9;
    
    [self setupPromoViewTouch];
    
    [self.view addSubview:popupView.view];
    
    
}

-(IBAction)hideStoreView:(id)sender {
    [storeController dismissViewControllerAnimated:YES completion:nil];
}

//updates the button title
-(void) updateAttachButton {
    if(image==nil && imageName==nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            attachImageView.image = attachImage;
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            attachImageView.image = image;
        });
    }
}


//to connect with linkedin when no token is available
- (void)connectWithLinkedIn:(NSString *) message {
    [self.client getAuthorizationCode:^(NSString *code) {
        [self.client getAccessToken:code success:^(NSDictionary *accessTokenData) {
            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
            
            //[self requestMeWithToken:accessToken];
            
            [self sendToLinkedin:message withToken:accessToken];
            
        }                   failure:^(NSError *error) {
            
            
            NSLog(@"Quering accessToken failed %@", error);
        }];
    }                      cancel:^{
        NSLog(@"Authorization was cancelled by user");
    }                     failure:^(NSError *error) {
        NSLog(@"Authorization failed %@", error);
    }];
}

//get personal info from linkedin
- (void)requestMeWithToken:(NSString *)accessToken {

    [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSLog(@"current user %@", result);
    }        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to fetch current user %@", error);
    }];
}

- (LIALinkedInHttpClient *)client {
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.pcdreams-software.com/"
                                                                                    clientId:@"77l4jha5fww7gl"
                                                                                clientSecret:@"tJYyGefrcnz7FAyg"
                                                                                       state:@"DCEEFWF45453sdffef424"
                                                                               grantedAccess:@[@"r_basicprofile",@"w_share"]]; //@"w_messages"
    return [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
}

- (NSString *)accessToken {
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:LINKEDIN_TOKEN_KEY];
    return token;
    
}

//check if the token is valid
- (BOOL)validToken {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([[NSDate date] timeIntervalSince1970] >= ([userDefaults doubleForKey:LINKEDIN_CREATION_KEY] + [userDefaults doubleForKey:LINKEDIN_EXPIRATION_KEY])) {
        return NO;
    }
    else {
        return YES;
    }
}

/**
 
 Company:
 
 PC Dreams Software
 
 Application Name:
 
 EasyMessage
 
 API Key:
 
 77l4jha5fww7gl
 
 Secret Key:
 
 tJYyGefrcnz7FAyg
 
 OAuth User Token:
 
 6896ca8e-6e39-4109-8fe9-64691dcdb5c8
 
 OAuth User Secret:
 
 49df1d5b-c2ae-49f9-8179-20678dc36f69
 
 
-(void) doLinkedin {
 //Member Permission Scopes
 NSArray *permissions = @[@"r_network",@"r_fullprofile",@"rw_nus"];
 
 // Set up the request
 NSDictionary *options = @{ACLinkedInAppIdKey : @"API Key",ACLinkedInPermissionsKey: permissions};
 
 ACAccountStore *store = [[ACAccountStore alloc] init];
 ACAccountType *linkedInAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierLinkedIn];
 
 // Request access to LinkedIn account on device
 [store requestAccessToAccountsWithType:linkedInAccountType options:options completion:^(BOOL granted, NSError *error) {
 
 if(granted) {
     SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeLinkedIn
                                             requestMethod:SLRequestMethodGET
                                                       URL:[NSURL URLWithString:@"https://api.linkedin.com/v1/people/~"]
                                                    parameters:@{@"format" : @"json"}];
 
        request.account = store.accounts.lastObject;
 
        [request performRequestWithHandler:^(NSData *responseData,
                                             NSHTTPURLResponse *urlResponse,
                                             NSError *error) {
     
                if (responseData) {
 
                        //Handle Response
                }
     
 }];
 
 
 {"expires_in":5184000,"access_token":"AQXdSP_W41_UPs5ioT_t8HESyODB4FqbkJ8LrV_5mff4gPODzOYR"}
 The value of parameter expires_in is the number of seconds from now that this access_token will expire in (5184000 seconds is 60 days). 
 Please ensure to keep the user access tokens secure, as agreed upon in our APIs Terms of Use.https://api.linkedin.com/v1/people/~?oauth2_access_token=AQXdSP_W41_UPs5ioT_t8HESyODB4FqbkJ8LrV_5mff4gPODzOYR
 
 Step 4. Make the API calls
 You can now use this access_token to make API calls on behalf of this user by appending "oauth2_access_token=access_token" at the end of the API call that you wish to make.
 
 https://api.linkedin.com/v1/people/~?oauth2_access_token=AQXdSP_W41_UPs5ioT_t8HESyODB4FqbkJ8LrV_5mff4gPODzOYR
 
 post too
 http://api.linkedin.com/v1/people/~/shares
 
 <share>
 <comment>Check out the LinkedIn Share API!</comment>
 <content>
 <title>LinkedIn Developers Documentation On Using the Share API</title>
 <description>Leverage the Share API to maximize engagement on user-generated content on LinkedIn</description>
 <submitted-url>https://developer.linkedin.com/documents/share-api</submitted-url>
 <submitted-image-url>http://m3.licdn.com/media/p/3/000/124/1a6/089a29a.png</submitted-image-url>
 </content>
 <visibility>
 <code>anyone</code>
 </visibility>
 </share>
 
 <?xml version="1.0" encoding="UTF-8"?>
 <share>
 <comment>Check out the LinkedIn Share API!</comment>
 <content>
 <title>LinkedIn Developers Documentation On Using the Share API</title>
 <description>Leverage the Share API to maximize engagement on user-generated content on LinkedIn</description>
 <submitted-url>https://developer.linkedin.com/documents/share-api</submitted-url>
 <submitted-image-url>http://m3.licdn.com/media/p/3/000/124/1a6/089a29a.png</submitted-image-url>
 </content>
 <visibility>
 <code>anyone</code>
 </visibility>
 </share>
 
 // store credentials
 NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
 
 [userDefaults setObject:accessToken forKey:LINKEDIN_TOKEN_KEY];
 [userDefaults setDouble:expiration forKey:LINKEDIN_EXPIRATION_KEY];
 [userDefaults setDouble:[[NSDate date] timeIntervalSince1970] forKey:LINKEDIN_CREATION_KEY];
 [userDefaults synchronize];
 
 - (BOOL)validToken {
 NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
 
 if ([[NSDate date] timeIntervalSince1970] >= ([userDefaults doubleForKey:LINKEDIN_CREATION_KEY] + [userDefaults doubleForKey:LINKEDIN_EXPIRATION_KEY])) {
 return NO;
 }
 else {
 return YES;
 }
 }
 
 - (NSString *)accessToken {
 return [[NSUserDefaults standardUserDefaults] objectForKey:LINKEDIN_TOKEN_KEY];
 }
 
 current user {
 firstName = Paulo;
 headline = "Founder at advancedeventmanagement.com";
 lastName = Cristo;
 siteStandardProfileRequest =     {
 url = "http://www.linkedin.com/profile/view?id=14868785&authType=name&authToken=DhuV&trk=api*a3233463*s3306483*";
 };
 }
 
 }*/
#pragma LINKEDIN NSREQUEST STUFF
#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSString *responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    
    NSString *msg;
    if([responseString rangeOfString:@"<update-key>"].location!=NSNotFound) {
        //post ok
        msg = NSLocalizedString(@"linkedin_post_ok", @"linkedin_post_ok");
    }
    else {
        //error
        msg = NSLocalizedString(@"linkedin_post_canceled", @"linkedin_post_canceled");
    }
    
    [self resetSocialNetworks:true];
    
    
    [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:1000] show];
    
    //NSLog(@"RECEIVED DATA IS %@",responseString);
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"Failed with %@",error.localizedDescription);
}

#pragma OPEN APP STORE

-(void)openAppStore {

    NSString *appStoreID = @"837165900";
    if(storeController==nil) {
       storeController = [[SKStoreProductViewController alloc] init];
    }
    
    storeController.delegate = self;
    
    //[storeController.navigationItem.leftBarButtonItem setTarget:self];
    //[storeController.navigationItem.leftBarButtonItem setAction:@selector(hideStoreView:)];

    
    NSDictionary *productParameters = @{ SKStoreProductParameterITunesItemIdentifier : appStoreID };
    [storeController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
        //Handle response
        
        //NSLog(@"Do something here %d",result);
        if(result ) {
            [self presentViewController:storeController animated:YES completion:nil];
        }
    }];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    if (storeController!=nil){
        [storeController dismissViewControllerAnimated:YES completion:nil];
    }
}

//don´t think this is really necessary
- (void)dealloc {
    // ... your other -dealloc code ...
    //self.adView = nil;
}

//easymessage ADMOP
// iphone 8ad4ab8f6c3e4798bad4472517acf8a6
/**
 // MyViewController.h
 
 #import "MPAdView.h"
 
 @interface MyViewController : UIViewController <MPAdViewDelegate>
 
 @property (nonatomic, retain) MPAdView *adView;
 
 @end
 
 // MyViewController.m
 
 #import "MyViewController.h"
 
 @implementation MyViewController
 
 - (void)viewDidLoad {
 // ... your other -viewDidLoad code ...
 self.adView = [[[MPAdView alloc] initWithAdUnitId:@"8ad4ab8f6c3e4798bad4472517acf8a6"
 size:MOPUB_BANNER_SIZE] autorelease];
 self.adView.delegate = self;
 CGRect frame = self.adView.frame;
 CGSize size = [self.adView adContentViewSize];
 frame.origin.y = [[UIScreen mainScreen] applicationFrame].size.height - size.height;
 self.adView.frame = frame;
 [self.view addSubview:self.adView];
 [self.adView loadAd];
 [super viewDidLoad];
 }
 
 
 - (void)dealloc {
 // ... your other -dealloc code ...
 self.adView = nil;
 [super dealloc];
 }
 
 #pragma mark - <MPAdViewDelegate>
 - (UIViewController *)viewControllerForPresentingModalView {
 return self;
 }
 
 @end
 
 IPAD : f549ddd3a0944768a4f85f0cdd717faf
 
 initWithAdUnitId:@"f549ddd3a0944768a4f85f0cdd717faf"
 size:MOPUB_LEADERBOARD_SIZE] autorelease];
 
 NEEDED FRAMEWORKS:
 AdSupport.framework (*)
 AudioToolbox.framework
 AVFoundation.framework
 CoreGraphics.framework
 CoreLocation.framework
 CoreTelephony.framework
 iAd.framework
 MediaPlayer.framework
 MessageUI.framework
 MobileCoreServices.framework
 PassKit.framework (*)
 QuartzCore.framework
 Social.framework (*)
 StoreKit.framework (*)
 SystemConfiguration.framework
 Twitter.framework (*)
 (all files with arc)
 
 https://app.mopub.com/inventory/adunit/8ad4ab8f6c3e4798bad4472517acf8a6/generate/?status=success
 */


//FOR THE MOPUB
#pragma mark - <MPAdViewDelegate>
- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

//MOPUB only when the AD is received, we can adjust the size
// iAd's portrait banner size is 320x50, whereas AdMob's banner size is 320x48.
//In order to resize and position our adView accurately every time a new ad is retrieved,
//we can implement the -adViewDidLoadAd: delegate callback in our view controller
/*
- (void)adViewDidLoadAd:(MPAdView *)view
{
    CGSize size = [view adContentViewSize];
    CGFloat centeredX = (self.view.bounds.size.width - size.width) / 2;
    CGFloat bottomAlignedY = self.view.bounds.size.height - (2 * size.height);
    view.frame = CGRectMake(centeredX, bottomAlignedY, size.width, size.height);
}*/

/**
 *Create the banner view
 */
/*
- (void) createAdBannerView {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // The device is an iPad running iPhone 3.2 or later.
        // [for example, load appropriate iPad nib file]
        self.adView = [[MPAdView alloc] initWithAdUnitId:@"f549ddd3a0944768a4f85f0cdd717faf"
                                                    size:MOPUB_LEADERBOARD_SIZE];
    }
    else {
        // The device is an iPhone or iPod touch.
        // [for example, load appropriate iPhone nib file]
        self.adView = [[MPAdView alloc] initWithAdUnitId:@"8ad4ab8f6c3e4798bad4472517acf8a6"
                                                    size:MOPUB_BANNER_SIZE];
    }
    
    
    self.adView.delegate = self;
    CGRect frame = self.adView.frame;
    CGSize size = [self.adView adContentViewSize];
    frame.origin.y = [[UIScreen mainScreen] applicationFrame].size.height - (2 * size.height);
    self.adView.frame = frame;
    [self.view addSubview:self.adView];
    [self.adView loadAd];
    

}
*/
#pragma mark - ADBannerViewDelegate

/*
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    //user clicked on the banner
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
}*/
@end
