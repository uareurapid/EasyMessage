//
//  SettingsViewController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/19/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize sendOptions,preferedServiceOptions;
@synthesize selectPreferredService,selectSendOption;

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
    selectSendOption = 0;//send both
    selectPreferredService = 0; //email is preferred, because is cheaper
    
    NSString *selectedSendSaved = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PREF_SEND_OPTION_KEY];
    NSString *selectedPrefServiceSaved = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PREF_SERVICE_KEY];
    
    if(selectedSendSaved!=nil) {
        if([selectedSendSaved isEqualToString:OPTION_SEND_EMAIL_ONLY]) {
            selectSendOption = 1;
        }
        if([selectedSendSaved isEqualToString:OPTION_SEND_SMS_ONLY]) {
            selectSendOption = 2;
        }
    }
    
    if(selectedPrefServiceSaved!=nil) {
        if([selectedPrefServiceSaved isEqualToString:OPTION_PREF_SERVICE_SMS]) {
            selectPreferredService = 1;
        }
        if([selectedPrefServiceSaved isEqualToString:OPTION_PREF_SERVICE_ALL]) {
            selectPreferredService = 2;
        }
    }
    
 

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//save user preferrences
-(void) viewWillDisappear:(BOOL)animated {
    [self saveSettings];
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



-(void) saveSettings {
    
    //the default send option
    
    switch (selectSendOption) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setObject:OPTION_ALWAYS_SEND_BOTH forKey:SETTINGS_PREF_SEND_OPTION_KEY];
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults] setObject:OPTION_SEND_EMAIL_ONLY forKey:SETTINGS_PREF_SEND_OPTION_KEY];
            break;
        default: //case 2
            [[NSUserDefaults standardUserDefaults] setObject:OPTION_SEND_SMS_ONLY forKey:SETTINGS_PREF_SEND_OPTION_KEY];
            break;
    }
    
    //now the preferred service
    
    if (selectPreferredService == 0) {
   
        [[NSUserDefaults standardUserDefaults] setObject:OPTION_PREF_SERVICE_EMAIL forKey:SETTINGS_PREF_SERVICE_KEY];
    }
    else if(selectPreferredService==1) {
        [[NSUserDefaults standardUserDefaults] setObject:OPTION_PREF_SERVICE_SMS forKey:SETTINGS_PREF_SERVICE_KEY]; 
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:OPTION_PREF_SERVICE_ALL forKey:SETTINGS_PREF_SERVICE_KEY];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if(section==0) {
        return sendOptions.count;
    }
    return preferedServiceOptions.count;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0) {
        return @"Send Options";
    }
    return @"Preferred Service";
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if(section==0) {
        return @"Choose the messaging service(s) to use";
    }
    else {
        return @"Choose the the preferred messaging service (in case the contact has  both entries)";
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
        cell.textLabel.text = [sendOptions objectAtIndex:row];
        cell.accessoryView.accessibilityLabel = @"hi";
        
        if(row == selectSendOption) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else {
        cell.textLabel.text = [preferedServiceOptions objectAtIndex:row];
        if(row == selectPreferredService) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
    }
    else {
        selectPreferredService = row;
    }
   // [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.tableView reloadData];
    
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
