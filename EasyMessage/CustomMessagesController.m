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

@synthesize messagesList,selectedMessage, selectedMessageIndex, rootViewController,lock,unlock;

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
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"done_button",nil)
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(selectFinished:)];
        unlock = [UIImage imageNamed:@"Unlock32"];
        lock = [UIImage imageNamed:@"Lock32"];
        
        UIBarButtonItem *lockButtonItem = [[UIBarButtonItem alloc]initWithImage:lock style:UIBarButtonItemStyleBordered target:self action:@selector(unlockFeature:)];
      
        
        self.navigationItem.rightBarButtonItem = doneButton;
        self.navigationItem.leftBarButtonItem = lockButtonItem;
        self.navigationController.toolbarHidden = NO;
        
        selectedMessageIndex = -1;
        selectedMessage = nil;
        self.rootViewController = rootViewControllerArg;
        
    }
    return  self;
}



-(void)viewWillAppear:(BOOL)animated {
    if ([[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_COMMON_MESSAGES]) {
        self.navigationItem.leftBarButtonItem.image = unlock;
        [self.navigationItem.rightBarButtonItem setEnabled: YES];
        [self.tableView setAllowsSelection:YES];
    }
    else {
        self.navigationItem.leftBarButtonItem.image = lock;
        [self.navigationItem.rightBarButtonItem setEnabled: NO];
        [self.tableView setAllowsSelection:NO];
    }
    [self addRecordsFromDatabase];
     
}



//returns the selected message
-(NSString * ) getSelectedMessageIfAny {
    if(selectedMessageIndex>-1 && selectedMessage!=nil && selectedMessageIndex < messagesList.count) {
        return [messagesList objectAtIndex:selectedMessageIndex];
    }
    return @"";
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
        NSLog(@"row is %d and selected message is %@",row,selectedMessage);
        
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
    }
    else {
        selectedMessageIndex = row;
        selectedMessage = [messagesList objectAtIndex:selectedMessageIndex];
    }
    
    
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
        
        return [NSString stringWithFormat: @"%@ %d",NSLocalizedString(@"selected_message",@"Selected message"),selectedMessageIndex];
    }
    return @"";
}

//done with the message selection
-(IBAction)selectFinished:(id)sender {
    //go back to compose
    
    if(selectedMessageIndex!=-1 && selectedMessage!=nil) {
       self.rootViewController.body.text = selectedMessage;
    }
    
    [self.tabBarController setSelectedIndex:0];
}

@end
