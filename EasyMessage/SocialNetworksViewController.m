//
//  PreferedItemOrderViewController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/26/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "SocialNetworksViewController.h"

@interface SocialNetworksViewController ()

@end

@implementation SocialNetworksViewController

@synthesize sendOptions,selectedServiceOptions,previousController,isTwitterAvailable,isFacebookAvailable;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil previousController: (UIViewController *) previous services:(NSArray *) services{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        sendOptions = [[NSMutableArray alloc] initWithArray:services];
        selectedServiceOptions = [[NSMutableArray alloc] init];
        previousController = previous;
        isFacebookAvailable = [services containsObject:OPTION_SENDTO_FACEBOOK_ONLY];
        isTwitterAvailable = [services containsObject:OPTION_SENDTO_TWITTER_ONLY];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(goBackAfterSelection:)];
        self.navigationItem.rightBarButtonItem = doneButton;
        //self.title = @"Advanced Options";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
}



//save user preferrences
-(void) viewWillDisappear:(BOOL)animated {
    //[self saveSettings];
    
    if(selectedServiceOptions.count >0) {
        NSString *msg = NSLocalizedString(@"alert_message_include_social_networks",@"alert_message_include_social_networks");
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:2000] show];
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

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return sendOptions.count;
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
        
        cell = [self labelForOptionIndex:row cellView:cell];
        NSString *option = [sendOptions objectAtIndex:row];
        
        if( [selectedServiceOptions containsObject: option]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    
    
    
    return cell;
}

-(UITableViewCell *) labelForOptionIndex: (NSInteger) rowIndex cellView: (UITableViewCell *) cell  {
    
     if(isFacebookAvailable && !isTwitterAvailable) {
         cell.textLabel.text = NSLocalizedString(@"option_send_facebook_only",@"send only to facebook");
         cell.imageView.image = [UIImage imageNamed:@"facebook"];
         
     }
     else if(isTwitterAvailable && !isFacebookAvailable) {
         cell.textLabel.text = NSLocalizedString(@"option_send_twitter_only",@"send only to twitter");
         cell.imageView.image = [UIImage imageNamed:@"twitter"];
     }
     else {
    //both available
         if(rowIndex==0) {
            cell.textLabel.text = NSLocalizedString(@"option_send_facebook_only",@"send only to facebook");
            cell.imageView.image = [UIImage imageNamed:@"facebook"];
         }
         else {
            cell.textLabel.text = NSLocalizedString(@"option_send_twitter_only",@"send only to twitter");
            cell.imageView.image = [UIImage imageNamed:@"twitter"];
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
    
    NSInteger row = indexPath.row;

    NSString *optionSelected = [sendOptions objectAtIndex:row];
    if([selectedServiceOptions containsObject:optionSelected]) {
        [selectedServiceOptions removeObject:optionSelected];
    }
    else {
        [selectedServiceOptions addObject:optionSelected];
    }

   [self.tableView reloadData];
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0) {
        return NSLocalizedString(@"option_send_include_social_network", @"include social networks");
    }
    else {
        return @"";
    }
    
}

-(NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section==0) {
        return NSLocalizedString(@"footer_social_networks", @"settings not persisted between messages");
    }
    else {
        return @"";
    }
    
}

//just go back
-(IBAction)goBackAfterSelection:(id)sender {
    [self.navigationController popToViewController:previousController animated:YES];
}

@end
