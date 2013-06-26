//
//  SettingsViewController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/19/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "SettingsViewController.h"
#import "iToast.h"
#import "PreferedItemOrderViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize sendOptions,preferedServiceOptions;
@synthesize selectPreferredService,selectSendOption;
@synthesize furtherOptionsController;
@synthesize showToast;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    sendOptions = [[NSMutableArray alloc] initWithObjects:OPTION_ALWAYS_SEND_BOTH, OPTION_SEND_EMAIL_ONLY, OPTION_SEND_SMS_ONLY,nil];
    preferedServiceOptions = [[NSMutableArray alloc] initWithObjects:OPTION_PREF_SERVICE_EMAIL,OPTION_PREF_SERVICE_SMS,OPTION_PREF_SERVICE_ALL, nil];
    
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
    
    //UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
     //                                                              style:UIBarButtonItemStyleDone target:self action:@selector(goBackAfterSelection:)];
    //self.navigationItem.rightBarButtonItem = doneButton;
    
    furtherOptionsController = [[PreferedItemOrderViewController alloc] initWithNibName:@"PreferedItemOrderViewController" bundle:nil previousController:self];

    showToast = YES;
    
    
    
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil  {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.title = @"Settings";
        self.tabBarItem.image = [UIImage imageNamed:@"gear"];
    }
    
    return self;
}

//save user preferrences
-(void) viewWillDisappear:(BOOL)animated {
    [self saveSettings];
}

-(void) viewWillAppear:(BOOL)animated {
    if(showToast==NO) {
        showToast=YES;
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
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
    return 3;
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
            msg = @"Will send both SMS and email!";
            break;
        case OPTION_SEND_EMAIL_ONLY_ID:
            [[NSUserDefaults standardUserDefaults] setObject:OPTION_SEND_EMAIL_ONLY forKey:SETTINGS_PREF_SEND_OPTION_KEY];
            msg = @"Will send email only!";
            break;
        default: //case 2 -> OPTION_SEND_SMS_ONLY_ID
            [[NSUserDefaults standardUserDefaults] setObject:OPTION_SEND_SMS_ONLY forKey:SETTINGS_PREF_SEND_OPTION_KEY];
            msg = @"Will send SMS only!";
            break;
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
    
    if(showToast) {
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:2000] show];
    }
    
    
    
    
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
    else {
        return 1; //just one for the prefered item options
    }
    
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0) {
        return @"Message - Send Options";
    }
    else if(section==1) {
       return @"Preferred Service"; 
    }
    else {
       return @"Advanced Options";
    }
    
}

//-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    /*if(section==0) {
        return @"Choose the messaging service(s) to use";
    }
    else if(section==1) {
        return @"Choose the preferred service (in case the contact has both)";
    }
    else {
        return @"";
        //@"Since a single contact can have several email addresses and/or several phone numbers you can choose one as default (or let us choose one)";
    }*/
    
//}

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
        cell.textLabel.text = [sendOptions objectAtIndex:row];
        //cell.accessoryView.accessibilityLabel = @"hi";
        
        if(row == selectSendOption) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if (section==1 ) {
        cell.textLabel.text = [preferedServiceOptions objectAtIndex:row];
        if(row == selectPreferredService) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else {//section 2
        cell.textLabel.text = OPTION_PREFERED_EMAIL_PHONE_ITEMS;
        if(row == 0) {
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
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
        [self.tableView reloadData];
    }
    else if(section==1) {
        selectPreferredService = row;
        [self.tableView reloadData];
    }
    else {
        //present the other table
        showToast = NO;
        [self.navigationController pushViewController:furtherOptionsController animated:YES];
    }
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
