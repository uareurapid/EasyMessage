//
//  PCViewController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/18/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "PCViewController.h"
#import <AddressBook/AddressBook.h>
#import "Contact.h"
#import "SelectRecipientsViewController.h"
#import <UIKit/UIKit.h>


@interface PCViewController ()

@end

@implementation PCViewController

@synthesize settingsController,subject,body,image;

- (void)viewDidLoad
{
    [super viewDidLoad];
    settingsController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"EasyMessage";
    //add the settings button
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(showSettings:)];
    self.navigationItem.rightBarButtonItem = settingsButton;
    subject.delegate = self;
    body.delegate = self;
    [body setPlaceholder:@"Message"];
    
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
        NSLog(@"HERE 1");
        [body resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    NSLog(@"HERE 2: %@",text);
    return YES;
}


//load the contacts from device
- (IBAction)sendMessage:(id)sender {
}

-(IBAction)loadContactsList:(id)sender {
    
    
    CFErrorRef * error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    NSMutableArray __block *contacts;
    // Request authorization to Address Book
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // First time access has been granted, add the contact
            contacts = [self loadContacts: addressBook];
            NSLog(@"size: %d",contacts.count);
            SelectRecipientsViewController *controller = [[SelectRecipientsViewController alloc] initWithNibName:@"SelectRecipientsViewController" bundle:nil contacts:contacts];
            [self.navigationController pushViewController:controller animated:YES];
        });
        
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
            contacts = [self loadContacts: addressBook];
            NSLog(@"size: %d",contacts.count);
            SelectRecipientsViewController *controller = [[SelectRecipientsViewController alloc] initWithNibName:@"SelectRecipientsViewController" bundle:nil contacts:contacts];
           [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        
    }
     
    
    
}

-(NSMutableArray *)loadContacts: (ABAddressBookRef) addressBook {
    
     NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    
    //ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize);
    for(int i = 0; i < numberOfPeople; i++){
        //NSData  *imgData = (__bridge_transfer NSData *) ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatThumbnail);
        Contact *contact = [[Contact alloc] init];
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
        //contact.person = person;
        
        NSLog(@"person is: %@",person);
        ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
        NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(multi, 0);
        NSLog(@"email is: %@", email);
        if(email!=nil) {
            contact.email = email;
        }
        
        ABMultiValueRef phoneMulti = ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSString *phone = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneMulti, 0);
        NSLog(@"phone is: %@", phone);
        if(phone!=nil) {
            contact.phone = phone;
        }
        
        //ABMultiValueRef nameMulti = ABRecordCopyValue(person, kABPersonCompositeNameFormatLastNameFirst);
        NSString *name = (__bridge NSString*)ABRecordCopyCompositeName(person);
        NSLog(@"name is: %@", name);
        if(name!=nil) {
            contact.name = name;
        }
        
        NSLog(@"adding one");
        [contacts addObject:contact];
        
        // More code here
    }
    return contacts;
}

- (IBAction)showSettings:(id)sender {
    [self.navigationController pushViewController:settingsController animated:YES];
}

- (IBAction)showEmail:(id)sender {
    // Email Subject
    NSString *emailTitle = subject.text;
    // Email Content
    NSString *messageBody = body.text;
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"cristo.paulo@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}
//delegate for the email controller
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            [self sendSMS:nil];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

//delegate for the sms controller
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result) {
		case MessageComposeResultCancelled:
			NSLog(@"Cancelled");
			break;
		case MessageComposeResultFailed:
            
            /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage"
                                                            message:@"Unknown Error!"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
			//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage"
              //                                              message:@"Unknown Error"
                //                                           delegate:self
                  //                                         cancelButtonTitle:@"OK"
                    //                              otherButtonTitles: nil];
			[alert show];
			[alert release];*/
			break;
		case MessageComposeResultSent:
            
			break;
		default:
			break;
	}
    
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)sendSMS:(id)sender {
    
MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
if([MFMessageComposeViewController canSendText])
{
    controller.body = body.text;
    controller.recipients = [NSArray arrayWithObjects:@"1(234)567-8910", nil];
    controller.messageComposeDelegate = self;
    [self presentModalViewController:controller animated:YES];
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
@end
