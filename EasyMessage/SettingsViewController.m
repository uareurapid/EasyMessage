//
//  SettingsViewController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/19/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "SettingsViewController.h"
#import "iToast.h"
#import "SocialNetworksViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize sendOptions,preferedServiceOptions,socialServicesOptions;
@synthesize selectPreferredService,selectSendOption;
@synthesize socialOptionsController;
@synthesize showToast;
@synthesize initiallySelectedPreferredService,initiallySelectedSendOption;
@synthesize isFacebookAvailable,isTwitterAvailable;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)resetSocialNetworks {
    if(socialOptionsController!=nil) {
        [socialOptionsController.selectedServiceOptions removeAllObjects];
        [socialOptionsController.tableView reloadData];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
  
    sendOptions = [[NSMutableArray alloc] initWithObjects:OPTION_ALWAYS_SEND_BOTH, OPTION_SEND_EMAIL_ONLY, OPTION_SEND_SMS_ONLY,nil];
    preferedServiceOptions = [[NSMutableArray alloc] initWithObjects:OPTION_PREF_SERVICE_EMAIL,OPTION_PREF_SERVICE_SMS,OPTION_PREF_SERVICE_ALL, nil];
    
    socialServicesOptions = [[NSMutableArray alloc] init];
    
    
    
    
    [self checkSocialServicesAvailability];
    
    //deafult values on startup
    selectSendOption = OPTION_ALWAYS_SEND_BOTH_ID;
    selectPreferredService = OPTION_PREF_SERVICE_ALL_ID;
    
    
    
    NSString *selectedSendSaved = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PREF_SEND_OPTION_KEY];
    NSString *selectedPrefServiceSaved = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PREF_SERVICE_KEY];
    
    if(selectedSendSaved!=nil) {
        if([selectedSendSaved isEqualToString:OPTION_SEND_EMAIL_ONLY]) {
            selectSendOption = OPTION_SEND_EMAIL_ONLY_ID;
        }
        if([selectedSendSaved isEqualToString:OPTION_SEND_SMS_ONLY]) {
            selectSendOption = OPTION_SEND_SMS_ONLY_ID;
        }
    }
    
    if(selectedPrefServiceSaved!=nil) {
        if([selectedPrefServiceSaved isEqualToString:OPTION_PREF_SERVICE_SMS]) {
            selectPreferredService = OPTION_PREF_SERVICE_SMS_ID;
        }
        if([selectedPrefServiceSaved isEqualToString:OPTION_PREF_SERVICE_EMAIL]) {
            selectPreferredService = OPTION_PREF_SERVICE_EMAIL_ID;
        }
    }
    
    NSMutableArray *services = [[NSMutableArray alloc] init];
    if(sendOptions.count>3) {
        if(isFacebookAvailable) {
            [services addObject:OPTION_SENDTO_FACEBOOK_ONLY];
        }
        if(isTwitterAvailable ) {
            [services addObject:OPTION_SENDTO_TWITTER_ONLY];
        }
    }
    
    
    socialOptionsController = [[SocialNetworksViewController alloc] initWithNibName:@"PreferedItemOrderViewController"
                                                                              bundle:nil previousController:self services:services];

    showToast = YES;
    
    
    
}

//check if the facebook and twitter services are available/configured
//and add/remove them accordingly
-(void) checkSocialServicesAvailability {
    //facebook
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        isFacebookAvailable=YES;

    }
    else {
        isFacebookAvailable = NO;
    }
    //twitter
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        isTwitterAvailable=YES;
    }
    else {
        isTwitterAvailable = NO;
    }
    
    if(isTwitterAvailable || isFacebookAvailable) {
        if(![sendOptions containsObject:OPTION_INCLUDE_SOCIAL_SERVICES]) {
        //add it
           [sendOptions addObject:OPTION_INCLUDE_SOCIAL_SERVICES]; 
        }
        
    }
    else if(!isTwitterAvailable && !isFacebookAvailable && [sendOptions containsObject:OPTION_INCLUDE_SOCIAL_SERVICES]) {
        //remove it
        [sendOptions removeObject:OPTION_INCLUDE_SOCIAL_SERVICES];
    }
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil  {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {

        self.tabBarItem.image = [UIImage imageNamed:@"gear"];
        self.title =  NSLocalizedString(@"settings",nil);
    }
    
    return self;
}


//save user preferrences
-(void) viewWillDisappear:(BOOL)animated {
    //remove the notification listener for account changes
    //[[NSNotificationCenter defaultCenter] removeObserver:ACAccountStoreDidChangeNotification];
    [self saveSettings];
}

-(void) viewWillAppear:(BOOL)animated {
    
    initiallySelectedSendOption = selectSendOption;
    initiallySelectedPreferredService = selectPreferredService;
    

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    //add a notification listener to detect account changes
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSocialServicesAvailability) name:ACAccountStoreDidChangeNotification object:nil];
    
    if(socialOptionsController!=nil) {
        if(socialOptionsController.selectedServiceOptions.count > 0) {
            //toast we will use social services
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    
    return 2;
}

-(IBAction)goBackAfterSelection:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void) saveSettings {
    
    //the default send option
    NSString *msg;

    switch (selectSendOption) {
        case OPTION_ALWAYS_SEND_BOTH_ID:
            [[NSUserDefaults standardUserDefaults] setObject:OPTION_ALWAYS_SEND_BOTH forKey:SETTINGS_PREF_SEND_OPTION_KEY];
            msg = NSLocalizedString(@"alert_message_settings_updated_both",@"Settings have been updated. Will send both SMS and email!");
            break;
        case OPTION_SEND_EMAIL_ONLY_ID:
            [[NSUserDefaults standardUserDefaults] setObject:OPTION_SEND_EMAIL_ONLY forKey:SETTINGS_PREF_SEND_OPTION_KEY];
            msg = NSLocalizedString(@"alert_message_settings_updated_email",@"Settings have been updated. Will send email only!");
            break;
        case OPTION_SEND_SMS_ONLY_ID: //case 2 -> OPTION_SEND_SMS_ONLY_ID
            [[NSUserDefaults standardUserDefaults] setObject:OPTION_SEND_SMS_ONLY forKey:SETTINGS_PREF_SEND_OPTION_KEY];
            msg = NSLocalizedString(@"alert_message_settings_updated_sms",@"Settings have been updated. Will send SMS only!");
            break;
            /*
        //twitter and facebook
        case OPTION_SENDTO_FACEBOOK_ONLY_ID:
            [[NSUserDefaults standardUserDefaults] setObject:OPTION_SENDTO_FACEBOOK_ONLY forKey:SETTINGS_PREF_SEND_OPTION_KEY];
            msg = NSLocalizedString(@"alert_message_settings_updated_email",@"Settings have been updated. Will send email only!");
            break;
        case OPTION_SENDTO_TWITTER_ONLY_ID:
            [[NSUserDefaults standardUserDefaults] setObject:OPTION_SENDTO_TWITTER_ONLY forKey:SETTINGS_PREF_SEND_OPTION_KEY];
            msg = NSLocalizedString(@"alert_message_settings_updated_email",@"Settings have been updated. Will send email only!");
            break;*/
            
        
    }
    
    //now the preferred service
    if(selectPreferredService == OPTION_PREF_SERVICE_ALL_ID) {
        [[NSUserDefaults standardUserDefaults] setObject:OPTION_PREF_SERVICE_ALL forKey:SETTINGS_PREF_SERVICE_KEY];
    }
    else if(selectPreferredService == OPTION_PREF_SERVICE_EMAIL_ID) {
   
        [[NSUserDefaults standardUserDefaults] setObject:OPTION_PREF_SERVICE_EMAIL forKey:SETTINGS_PREF_SERVICE_KEY];
    }
    else { //OPTION_PREF_SERVICE_SMS_ID
        [[NSUserDefaults standardUserDefaults] setObject:OPTION_PREF_SERVICE_SMS forKey:SETTINGS_PREF_SERVICE_KEY]; 
    }
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //if there were any changes
    if(initiallySelectedPreferredService != selectPreferredService || initiallySelectedSendOption!=selectSendOption) {
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:2000] show];
    }
    
    
    NSString *msg2;

    
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if(section==0) {
        return sendOptions.count;
    }
    else if(section==1) {
       return preferedServiceOptions.count; 
    }
   
    return 1; //just one for the prefered item options
    
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0) {
        return  NSLocalizedString(@"header_message_send_options",nil);
    }
    else if(section==1) {
      return NSLocalizedString(@"header_preferred_service",nil);
    }
    
    else {
       return @"Advanced Options";
    }
    
    
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    
    if(section==0) {
        return NSLocalizedString(@"footer_select_service", nil);
    }
    else if(section==1) {
        return NSLocalizedString(@"footer_preferred_service", nil);   
    }
    else {
        return @"Use social services";
    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if(section==0) {
        cell.textLabel.text =  [self labelForOptionIndex:row atSection:section];// [sendOptions objectAtIndex:row];
        
        if(row == selectSendOption) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if(row==0) {
            cell.imageView.image = [UIImage imageNamed:@"emblem_package"];
            //Author: VisualPharm, http://www.visualpharm.com/
        //License: CC Attribution No Derivatives

        }
        else if(row==1) {
             cell.imageView.image = [UIImage imageNamed:@"contact"];
            //VisualPharm (Ivan Boyko)
        }
        else if(row==2) {
            cell.imageView.image = [UIImage imageNamed:@"Sms-And-Mms-48"];
            //Author: CrazEriC, http://crazeric.deviantart.com/
        //License: CC Attribution
        }
        else if(row==3) {
            //these are free but anyway Zen Nikki - http://zen-nikki.deviantart.com/
            cell.imageView.image = [UIImage imageNamed:@"world3"];//About-me-icon
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        
        
        

        
    }
    else if(section==1){
        //if (section==1 ) {
        cell.textLabel.text = [self labelForOptionIndex:row atSection:section];//[preferedServiceOptions objectAtIndex:row];
        if(row == selectPreferredService) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        
        if(row==0) {
            cell.imageView.image = [UIImage imageNamed:@"contact"];
            //VisualPharm (Ivan Boyko)
        }
        else if(row==1) {
            cell.imageView.image = [UIImage imageNamed:@"Sms-And-Mms-48"];
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"emblem_package"];
        }
        
    }
 
    
    return cell;
}

-(NSString *) labelForOptionIndex: (NSInteger) rowIndex atSection: (NSInteger) section {
    
    
    if(section==0) {//send options
        switch (rowIndex) {
            case 0:
                //NSLog(@"returning %@", NSLocalizedString(@"option_send_both", @"send both email and sms"));
                return NSLocalizedString(@"option_send_both", @"send both email and sms");
            case 1:
                return NSLocalizedString(@"option_send_email_only", @"send email only");
            case 2:
                return NSLocalizedString(@"option_send_sms_only",@"send only sms");
                
            case 3:
                return NSLocalizedString(@"option_send_include_social_network",@"include social networks");
            default:
                return @"";
                      
  
        }
    }
    else if(section==1) {
        switch (rowIndex) {//preferred services
            case 0:
                return NSLocalizedString(@"preferred_email_service", @"prefer email");
            case 1:
                return NSLocalizedString(@"preferred_sms_service", @"prefer sms");
            default:
                return NSLocalizedString(@"preferred_use_both_services",@"use both");
        }
    }
  
    return @"";
    //section 0
    //OPTION_ALWAYS_SEND_BOTH, OPTION_SEND_EMAIL_ONLY, OPTION_SEND_SMS_ONLY
    //section 1
    //OPTION_PREF_SERVICE_EMAIL,OPTION_PREF_SERVICE_SMS,OPTION_PREF_SERVICE_ALL
    /*
    "option_send_both" = "Always send both";
    "option_send_email_only" = "Send email only";
    "option_send_sms_only" = "Send SMS only";
    "footer_select_service" = "Select the service to send the message";
    
    "preferred_email_service" = "Email service";
    "preferred_sms_service"= "SMS service";
    "preferred_use_both_services" = "Use both services";*/
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row =indexPath.row;

    
    if(section==0) {
        selectSendOption = row;
        if(row < 3) {
          [self.tableView reloadData];
        }
        else {
            showToast = NO;
            [self.navigationController pushViewController:socialOptionsController animated:YES];
        }
    }
    else if(section==1) {
        selectPreferredService = row;
        [self.tableView reloadData];
        
    }
    
    //else {
        //present the other table
    //    showToast = NO;
    //    [self.navigationController pushViewController:furtherOptionsController animated:YES];
    //}
   // [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    
    //[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    //[self.tableView selectRowAtIndexPath:indexPath animated:nil scrollPosition:nil];
    
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


@end
