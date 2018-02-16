//
//  CustomMessagesController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 9/6/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "CustomMessagesController.h"
#import "EasyMessageIAPHelper.h"
#import "MessageDataModel.h"
#import "CoreDataUtils.h"

@interface CustomMessagesController ()

@end

@implementation CustomMessagesController

@synthesize messagesList,selectedMessage, selectedMessageIndex, rootViewController;
//lock,unlock;
//,headerView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil rootViewController: (PCViewController *) rootViewControllerArg {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil ];
    if(self) {
        self.tabBarItem.image = [UIImage imageNamed:@"33-cabinet"];
        self.title = NSLocalizedString(@"archive",@"Archive");
        
        //self.addNewMessage = YES;
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add.png"]
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(selectFinished:)];
        //unlock = [UIImage imageNamed:@"Unlock32"];
        //lock = [UIImage imageNamed:@"Lock32"];
        
        UIBarButtonItem *deleteButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete.png"] style:UIBarButtonItemStyleDone target:self action:@selector(deleteMessageClicked:)];
      
        [doneButton setEnabled:YES];
        [deleteButtonItem setEnabled:NO];
        
        self.navigationItem.rightBarButtonItem = doneButton;
        self.navigationItem.leftBarButtonItem = deleteButtonItem;
        self.navigationController.toolbarHidden = NO;
        
        selectedMessageIndex = -1;
        selectedMessage = nil;
        self.rootViewController = rootViewControllerArg;
        
        //[self prepareCustomHeaderView];
        
    }
    return  self;
}
/**
-(void)prepareCustomHeaderView {
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.tableView.frame.size.width,38)];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10,0, self.tableView.frame.size.width-40,38)];
    [label setText: NSLocalizedString(@"select_custom_message",@"select a message") ];
 
    [headerView addSubview:label];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(label.frame.size.width + 2,0, 32,32)];

    [headerView addSubview:imageView];
    [headerView setAlpha:0.9];
    imageView ad
    
    if ([[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_COMMON_MESSAGES]) {
        imageView.image=unlock;
    }
    else {
        imageView.image=lock;
    }

}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width,38)];
    
                                                                  
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5,0, tableView.frame.size.width-40,40)];
    [label setText: NSLocalizedString(@"select_custom_message",@"select a message") ];
                                                                  
    
    [headerView addSubview:label];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(label.frame.size.width + 2,0, 32,32)];
    
    [headerView addSubview:imageView];
    //[headerView setAlpha:0];
    
    if ([[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_COMMON_MESSAGES]) {
        imageView.image=unlock;
    }
    else {
        imageView.image=lock;
    }
    headerView.backgroundColor = [UIColor colorWithRed:0.0 green:0.7 blue:0.8 alpha:0.75];
    
    UIImageView *imageView = (UIImageView *)[headerView.subviews objectAtIndex:headerView.subviews.count -1];
    
    if ([[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_COMMON_MESSAGES]) {
        
        imageView.image=unlock;
    }
    else {
        imageView.image=lock;
    }
    
    return headerView;
    
}*/

//the header height
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 38;
}

-(void)viewWillAppear:(BOOL)animated {
    //if ([[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_COMMON_MESSAGES]) {
        [self.navigationItem.leftBarButtonItem setEnabled:[self getSelectedMessageIfAny]!=nil];
        [self.navigationItem.rightBarButtonItem setEnabled: YES];
        [self.tableView setAllowsSelection:YES];
    
    self.addNewMessage = ([self getSelectedMessageIfAny]==nil);
    //}
    //else {
    //    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    //    [self.navigationItem.rightBarButtonItem setEnabled: NO];
    //    [self.tableView setAllowsSelection:NO];
    //}
    [self addRecordsFromDatabase];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
     
}

-(IBAction)deleteMessageClicked:(id)sender {
    
    
    NSString *msg = [self getSelectedMessageIfAny];
    if(msg!=nil) {
        
        [messagesList removeObject:msg];
        
        BOOL deleted = [CoreDataUtils deleteMessageDataModelByMsg:msg];
        if(deleted) {
            
            //clear stuff
            selectedMessage = nil;
            selectedMessageIndex = -1;
            self.rootViewController.body.text = @"";
            
            [self.tableView reloadData];
            [self.navigationItem.leftBarButtonItem setEnabled:NO];
            
            [[[[iToast makeText:NSLocalizedString(@"deleted", @"deleted")]
               setGravity:iToastGravityBottom] setDuration:2000] show];

        }
    }
}

//returns the selected message
-(NSString * ) getSelectedMessageIfAny {
    if(selectedMessageIndex>-1 && selectedMessage!=nil && selectedMessageIndex < messagesList.count) {
        return [messagesList objectAtIndex:selectedMessageIndex];
    }
    else {
     return nil;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedMessageIndex = -1;
    selectedMessage = nil;
    
    messagesList = [[ NSMutableArray alloc]initWithObjects:NSLocalizedString(@"custom_msg_christmas",@"Merry Christmas"),
                    NSLocalizedString(@"custom_msg_birthday",@"Happy Birthday"),
                    NSLocalizedString(@"custom_msg_whereareyou",@"Where are you?"),
                    NSLocalizedString(@"custom_msg_whataredoing",@"What are you doing?"),
                    NSLocalizedString(@"custom_msg_callback",@"Call back. Please"),
                    NSLocalizedString(@"custom_msg_busy",@"Busy now. Call later please"),
                    NSLocalizedString(@"custom_msg_meeting",@"Sorry, i have a meeting now"),
                    NSLocalizedString(@"custom_msg_callsoon",@"Call you soon"),
                    NSLocalizedString(@"custom_msg_noworry",@"Don´t worry. I´m fine"),
                    NSLocalizedString(@"custom_msg_wayhome",@"On my way home now"),
                    NSLocalizedString(@"custom_msg_arrivesoon",@"I´ll Arrive soon"),nil];
    
    [self addRecordsFromDatabase];

    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) addRecordsFromDatabase {
    
    NSMutableArray *databaseRecords = [CoreDataUtils fetchMessageRecordsFromDatabase];
    
    BOOL add = NO;
    for(MessageDataModel *model in databaseRecords) {
        if(![messagesList containsObject:model.msg]) {
           [messagesList addObject:model.msg];
            add = YES;
        }
        
    }
    if(add) {
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) createNewMessage {
   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage" message:NSLocalizedString(@"message_label",@"message_label") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel",@"cancel") otherButtonTitles:NSLocalizedString(@"save",@"save"),nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
}
//the delegate for the new Group
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex==1) { //0 - cancel, 1 - save
      //TODO save message on database!
        
        NSString *message = [alertView textFieldAtIndex:0].text;
        NSLog(@"message is %@",message);
        if(message.length==0) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage" message:NSLocalizedString(@"alert_message_body_empty",@"alert_message_body_empty") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else {
            //check if exists already
            BOOL exists = false;
            NSLog(@"checking if exists");
            for(NSString *msg in messagesList) {
                NSLog(@"model msg: %@",msg);
                if([msg isEqualToString:message]) {
                    exists = true;
                }
                
            }
            if(!exists) {
                NSLog(@"not exists adding: %@",message);
                NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
                MessageDataModel *messageModel = (MessageDataModel *)[NSEntityDescription insertNewObjectForEntityForName:@"MessageDataModel" inManagedObjectContext:managedObjectContext];
                messageModel.msg = message;
                
                //BOOL OK = NO;
                NSError *error;
                if(![managedObjectContext save:&error]){
                    NSLog(@"Unable to save object, error is: %@",error.description);
                }
                else {
                    //add to list and reload table
                    [messagesList addObject:message];
                    [self.tableView reloadData];
                    //show a success toast
                    [[[[iToast makeText:NSLocalizedString(@"added", @"added")]
                       setGravity:iToastGravityBottom] setDuration:2000] show];
                }
            }
            else {
                //group name already exists
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage" message:NSLocalizedString(@"message_already_exists",@"message_already_exists") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
            
        }
        
        
        
    }
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
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)row];
        
        if(row == selectedMessageIndex) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger row =  indexPath.row;
    
    if(row==selectedMessageIndex) {
        selectedMessageIndex = -1;
        selectedMessage = nil;
        //Nothing selected
        
        [self.navigationItem.rightBarButtonItem setEnabled:YES];//no save
        [self.navigationItem.rightBarButtonItem setTitle:@"Add"];//no save
        self.addNewMessage = YES;
        [self.navigationItem.leftBarButtonItem setEnabled:NO];//no delete
        //NOTE if the item is not purchased selection is not even possible
    }
    else {
        selectedMessageIndex = row;
        selectedMessage = [messagesList objectAtIndex:selectedMessageIndex];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];//can save
        self.addNewMessage = NO;
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"done_button", nil)];//can save
        
        [self.navigationItem.leftBarButtonItem setEnabled:YES];//can delete
        
        if(selectedMessageIndex <= 10) {
           [self.navigationItem.leftBarButtonItem setEnabled:NO];//no delete of built in
        }
        else {
            [self.navigationItem.leftBarButtonItem setEnabled:YES];//no delete
        }
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.addNewMessage){
            [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"add.png"]];
        }
        else{
            [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"done.png"]];
        }
    });
    
    
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
    if(section==0 && selectedMessageIndex!=-1) {
        
        return [NSString stringWithFormat: @"%@ '%@'",NSLocalizedString(@"selected_message",@"Selected message"),
                [messagesList objectAtIndex:selectedMessageIndex]];
    }
    return @"";
}

//done with the message selection
-(IBAction)selectFinished:(id)sender {
    //go back to compose
    
    if(self.addNewMessage) {
        [self createNewMessage];
    }
    else {
        if(selectedMessageIndex!=-1 && selectedMessage!=nil) {
            self.rootViewController.body.text = selectedMessage;
        }
        
        [self.tabBarController setSelectedIndex:0];
    }
    
    
}

@end
