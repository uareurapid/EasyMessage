//
//  CustomMessagesController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 9/6/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "CustomMessagesController.h"

@interface CustomMessagesController ()

@end

@implementation CustomMessagesController

@synthesize messagesList,selectedMessage,rootViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil rootViewController: (PCViewController *) rootViewController {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil ];
    if(self) {
        self.tabBarItem.image = [UIImage imageNamed:@"33-cabinet"];
        self.title = NSLocalizedString(@"archive",@"Archive");
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"done_button",nil)
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(selectFinished:)];
        
      
        
        self.navigationItem.rightBarButtonItem = doneButton;
        self.navigationController.toolbarHidden = NO;
        
        NSArray* toolbarItems = [NSArray arrayWithObjects:
                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                               target:self
                                                                               action:@selector(goBackAfterSelection:)],nil];
        self.toolbarItems = toolbarItems;
        selectedMessage = -1;
        self.rootViewController = rootViewController;
        
    }
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedMessage = -1;
    messagesList = [[ NSMutableArray alloc]initWithObjects:@"Merry Christmas",@"Happy Birthday",
                    @"Where are you?",
                    @"What are you doing?",
                    @"Call back. Please",
                    @"Busy now. Call later, please",
                    @"Sorry, i have a meeting now",
                    @"Call you soon",
                    @"Don´t worry. i´m fine",
                    @"On my way home now",
                    @"Arrive soon",
                    @"Be there or be square!",
                    nil];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return messagesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    
    
    // Configure the cell...
    if(row < messagesList.count) {
        
        //paranoid check
        cell.textLabel.text = [messagesList objectAtIndex:row];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",row];
        NSLog(@"row is %d and selected message is %d",row,selectedMessage);
        
        if(row == selectedMessage) {
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
    
    NSInteger row =  indexPath.row;
    
    if(row==selectedMessage) {
        selectedMessage = -1;
    }
    else {
       selectedMessage = indexPath.row; 
    }
    
    
    
    NSLog(@"CALLED %d", selectedMessage);
    
    [self.tableView reloadData];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     
     */
}
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0) {
        return NSLocalizedString(@"select_custom_message",@"select a message");
    }
    return @"";
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section==0 && selectedMessage!=-1) {
        
        return [NSString stringWithFormat: @"%@ %d",NSLocalizedString(@"selected_message",@"Selected message"),selectedMessage];
    }
    return @"";
}

//done with the message selection
-(IBAction)selectFinished:(id)sender {
    //go back to compose
    [self.tabBarController setSelectedIndex:0];
}

@end
