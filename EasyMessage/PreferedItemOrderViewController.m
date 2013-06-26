//
//  PreferedItemOrderViewController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/26/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "PreferedItemOrderViewController.h"

@interface PreferedItemOrderViewController ()

@end

@implementation PreferedItemOrderViewController

@synthesize preferedEmailOptions,preferedPhoneOptions,previousController;
@synthesize selectedEmailOption,selectedPhoneOption;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil previousController: (UIViewController *) previous{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        preferedEmailOptions = [[NSMutableArray alloc] initWithObjects:ITEM_EMAIL_NONE, ITEM_EMAIL_HOME, ITEM_EMAIL_WORK, ITEM_EMAIL_OTHER, nil];
        preferedPhoneOptions = [[NSMutableArray alloc] initWithObjects:ITEM_PHONE_NONE,ITEM_PHONE_MOBILE, ITEM_PHONE_IPHONE, ITEM_PHONE_HOME, ITEM_PHONE_WORK, ITEM_PHONE_MAIN, nil];
        previousController = previous;
        
        selectedPhoneOption = ITEM_PHONE_NONE_ID;
        selectedEmailOption = ITEM_EMAIL_NONE_ID;
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(goBackAfterSelection:)];
        self.navigationItem.rightBarButtonItem = doneButton;
        self.title = @"Advanced Options";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //by default we just grab the first email and phone
    selectedPhoneOption = ITEM_PHONE_NONE_ID;
    selectedEmailOption = ITEM_EMAIL_NONE_ID;
    
    //check if there are any saved settings
    NSString *selectedEmail = [[NSUserDefaults standardUserDefaults] objectForKey:ADVANCED_OPTION_PREFERRED_EMAIL_KEY];
    NSString *selectedPhone = [[NSUserDefaults standardUserDefaults] objectForKey:ADVANCED_OPTION_PREFERRED_PHONE_KEY];
    
    if(selectedEmail!=nil) {
        if([selectedEmail isEqualToString:ITEM_EMAIL_HOME]) {
            selectedEmailOption = ITEM_EMAIL_HOME_ID;
        }
        else if([selectedEmail isEqualToString:ITEM_EMAIL_WORK]) {
            selectedEmailOption = ITEM_EMAIL_WORK_ID;
        }
        else if([selectedEmail isEqualToString:ITEM_EMAIL_OTHER]) {
            selectedEmailOption = ITEM_EMAIL_OTHER_ID;
        }
        
    }
    
    if(selectedPhone!=nil) {
        if([selectedPhone isEqualToString:ITEM_PHONE_WORK]) {
            selectedPhoneOption = ITEM_PHONE_WORK_ID;
        }
        else if([selectedPhone isEqualToString:ITEM_PHONE_HOME]) {
            selectedPhoneOption = ITEM_PHONE_HOME_ID;
        }
        else if([selectedPhone isEqualToString:ITEM_PHONE_IPHONE]) {
            selectedPhoneOption = ITEM_PHONE_IPHONE_ID;
        }
        else if([selectedPhone isEqualToString:ITEM_PHONE_MAIN]) {
            selectedPhoneOption = ITEM_PHONE_MAIN_ID;
        }
        else if([selectedPhone isEqualToString:ITEM_PHONE_MOBILE]) {
            selectedPhoneOption = ITEM_PHONE_MOBILE_ID;
        }
        
    }
    
    
}

//save user preferrences
-(void) viewWillDisappear:(BOOL)animated {
    [self saveSettings];
}

-(void) saveSettings {
    
    //the default mail option
    NSString *msg;
    
    switch (selectedEmailOption) {
        case ITEM_EMAIL_HOME_ID:
            [[NSUserDefaults standardUserDefaults] setObject:ITEM_EMAIL_HOME forKey:ADVANCED_OPTION_PREFERRED_EMAIL_KEY];
            break;
        case ITEM_EMAIL_NONE_ID:
            [[NSUserDefaults standardUserDefaults] setObject:ITEM_EMAIL_NONE forKey:ADVANCED_OPTION_PREFERRED_EMAIL_KEY];
            break;
        case ITEM_EMAIL_WORK_ID:
            [[NSUserDefaults standardUserDefaults] setObject:ITEM_EMAIL_WORK forKey:ADVANCED_OPTION_PREFERRED_EMAIL_KEY];
            break;
        case ITEM_EMAIL_OTHER_ID:
            [[NSUserDefaults standardUserDefaults] setObject:ITEM_EMAIL_OTHER forKey:ADVANCED_OPTION_PREFERRED_EMAIL_KEY];
            break;
            
        default: 
            [[NSUserDefaults standardUserDefaults] setObject:ITEM_EMAIL_NONE forKey:ADVANCED_OPTION_PREFERRED_EMAIL_KEY];
            break;
    }
    
    //now the preferred phone
    switch (selectedPhoneOption) {
        case ITEM_PHONE_NONE_ID:
            [[NSUserDefaults standardUserDefaults] setObject:ITEM_PHONE_NONE forKey:ADVANCED_OPTION_PREFERRED_PHONE_KEY];
            break;
        case ITEM_PHONE_MOBILE_ID:
            [[NSUserDefaults standardUserDefaults] setObject:ITEM_PHONE_MOBILE forKey:ADVANCED_OPTION_PREFERRED_PHONE_KEY];
            break;
        case ITEM_PHONE_MAIN_ID:
            [[NSUserDefaults standardUserDefaults] setObject:ITEM_PHONE_MAIN forKey:ADVANCED_OPTION_PREFERRED_PHONE_KEY];
            break;
        case ITEM_PHONE_IPHONE_ID:
            [[NSUserDefaults standardUserDefaults] setObject:ITEM_PHONE_IPHONE forKey:ADVANCED_OPTION_PREFERRED_PHONE_KEY];
            break;
        case ITEM_PHONE_HOME_ID:
            [[NSUserDefaults standardUserDefaults] setObject:ITEM_PHONE_HOME forKey:ADVANCED_OPTION_PREFERRED_PHONE_KEY];
            break;
        case ITEM_PHONE_WORK_ID:
            [[NSUserDefaults standardUserDefaults] setObject:ITEM_PHONE_WORK forKey:ADVANCED_OPTION_PREFERRED_PHONE_KEY];
            break;
            
        default:
            [[NSUserDefaults standardUserDefaults] setObject:ITEM_PHONE_NONE forKey:ADVANCED_OPTION_PREFERRED_PHONE_KEY];
            break;
    }
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //if(showToast) {
    //    [[[[iToast makeText:msg]
    //       setGravity:iToastGravityBottom] setDuration:2000] show];
    //}
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    if(section==0) {
        //email one
        return preferedEmailOptions.count;
    }
    return preferedPhoneOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    //section 0 is email options
    if(section==0) {
        cell.textLabel.text = [preferedEmailOptions objectAtIndex:row];
        if(row==selectedEmailOption) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else {
        cell.textLabel.text = [preferedPhoneOptions objectAtIndex:row];
        if(row==selectedPhoneOption) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    // Configure the cell...
    
    
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

   if(section==0) {
       selectedEmailOption = row;
   }
   else {
       selectedPhoneOption = row;
   }

   [self.tableView reloadData];
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0) {
        return @"Preferred email address";
    }
    else {
        return @"Preferred phone number";
    }
    
}

//just go back
-(IBAction)goBackAfterSelection:(id)sender {
    [self.navigationController popToViewController:previousController animated:YES];
}

@end
