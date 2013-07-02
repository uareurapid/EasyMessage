//
//  SelectRecipientsViewController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/19/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "SelectRecipientsViewController.h"
#import "PCViewController.h"

const NSString *MY_ALPHABET = @"ABCDEFGIJKLMNOPQRSTUVWXYZ";

@interface SelectRecipientsViewController ()

@end

@implementation SelectRecipientsViewController

@synthesize contactsList,selectedContactsList,rootViewController;
@synthesize initialSelectedContacts,contactsByLastNameInitial;
@synthesize sortedKeys;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contacts: (NSMutableArray *) contacts{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.contactsList = [[NSMutableArray alloc] initWithArray:contacts];
        self.selectedContactsList = [[NSMutableArray alloc] init];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                           style:UIBarButtonItemStyleDone target:self action:@selector(goBackAfterSelection:)];
        self.navigationItem.rightBarButtonItem = doneButton;
        
    }
    return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil rootViewController: (PCViewController*) viewController{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.contactsList = [[NSMutableArray alloc] init];
        self.selectedContactsList = [[NSMutableArray alloc] init];
        self.rootViewController = viewController;
        
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Select all"
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(selectAllContacts:)];
        self.navigationItem.leftBarButtonItem = doneButton;
        
 
        NSArray* toolbarItems = [NSArray arrayWithObjects:
                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                               target:self
                                                                               action:@selector(goBackAfterSelection:)],nil];
        
        //***************************************************************************************
        //[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
        //                                              target:self
        //                                              action:@selector(goBackAfterSelection:)],
        //[toolbarItems makeObjectsPerformSelector:@selector(release)];
        //***************************************************************************************
        
        self.toolbarItems = toolbarItems;
        self.navigationController.toolbarHidden = NO;
        self.tabBarItem.image = [UIImage imageNamed:@"phone-book"];
        self.title = @"Recipients";
        
    }
    return self;
}


-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contacts: (NSMutableArray *) contacts rootViewController: (PCViewController*) viewController{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.contactsList = [[NSMutableArray alloc] initWithArray:contacts];
        self.selectedContactsList = [[NSMutableArray alloc] init];
        self.rootViewController = viewController;
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(goBackAfterSelection:)];
        self.navigationItem.rightBarButtonItem = doneButton;
        self.title = @"Recipients";
        
    }
    return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contacts: (NSMutableArray *) contacts
         selectedOnes: (NSMutableArray *) selectedRecipients rootViewController: (PCViewController*) viewController {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.contactsList = [[NSMutableArray alloc] initWithArray:contacts];
        self.selectedContactsList = [[NSMutableArray alloc] initWithArray:selectedRecipients];
        self.rootViewController = viewController;
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(goBackAfterSelection:)];
        self.navigationItem.rightBarButtonItem = doneButton;
        self.title = @"Recipients";
    }
    return self;
}


-(IBAction)refreshPhonebook:(id)sender {
    contactsByLastNameInitial = [self loadInitialNamesDictionary];
    [self.tableView reloadData];
}

//will group the contacts by last name initial
- (NSMutableDictionary *) loadInitialNamesDictionary {
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    self.sortedKeys = [[NSMutableArray alloc] init];
    
    
    for(Contact *contact in contactsList) {
        
        NSString *initial;
        if(contact.lastName!=nil) {
           initial = [[contact.lastName substringToIndex:1] uppercaseString];
        }
        else if(contact.name!=nil) {
           initial = [[contact.name substringToIndex:1] uppercaseString];
        }
        else if(contact.email!=nil) {
            initial = [[contact.email substringToIndex:1] uppercaseString];
        }
        else if(contact.phone!=nil) {
            initial = [[contact.phone substringToIndex:1] uppercaseString];
        }
        
        id listForThatInitial = [dic objectForKey:initial];
        if(listForThatInitial == nil) {
            //doesnt exist yet, create the array
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:contact, nil];
            [dic setObject:array forKey:initial];
            [sortedKeys addObject:initial];
        }
        else {
            //already exists cast it
            NSMutableArray *array = (NSMutableArray *) listForThatInitial;
            [array addObject:contact];
        }
           
        
        
    }

    return dic;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshPhonebook:nil];
    self.tableView.sectionHeaderHeight = 2.0;
    self.tableView.sectionFooterHeight = 2.0;

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

#pragma  search bar delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    //searchBar.hidden = YES;
}

//- (void)textFieldDidEndEditing:(UITextField *)textField {
    //UITextField *searchField = [searchBar valueForKey:@"_searchField"];
    
    //if(searchField.text.length<3)//minimum 3 chars
//}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    UITextField *searchField = [searchBar valueForKey:@"_searchField"];
    
    if(searchField.text.length>3) {
        //try to find a match
        for(Contact *c in contactsList) {
            NSString * name = c.name;
            if([name rangeOfString:searchField.text].location!= NSNotFound ) {
                searchField.text = name;
                return;
            }
        }
    }
        
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    //s[searchBar resignFirstResponder];
    //move the keyboard out of the way
    
    
    
    [searchBar resignFirstResponder];
    //[self checkIfNavigateToSection:searchBar];
}

-(void) checkIfNavigateToSection: (UISearchBar *) searchBar {
    UITextField *searchField = [searchBar valueForKey:@"_searchField"];
    NSString *contactFullName = searchField.text;
    NSInteger section = -1;
    NSInteger row = -1;
    
    if(contactFullName!=nil) {
        
        for(Contact *contact in contactsList) {
            NSString * name = contact.name;
            if([name isEqualToString:contactFullName]) {
                //We found the contact we want
                NSString *initial; //get the key on dictionary
                if(contact.lastName!=nil) {
                    
                    initial = [[contact.lastName substringToIndex:1] uppercaseString];
                }
                else if(contact.name!=nil) {
                    initial = [[contact.name substringToIndex:1] uppercaseString];
                }
                
                
                if(initial!=nil) {
                    
                    
                    int i = 0;
                    for(id key in contactsByLastNameInitial.keyEnumerator) {
                        NSString *keyString = (NSString*)key;
                        if([keyString isEqualToString:initial]) {
                            section = i;
                            break;
                            //we have the section already, exit;
                        }
                        i++;
                    }
                    
                    
                    
                    NSMutableArray *cList = [contactsByLastNameInitial objectForKey:initial];
                    
                    int x = 0;
                    for(Contact *theContact in cList) {
                        if([theContact.name isEqualToString: contactFullName]) {
                            row = x;
                            break;
                            //and now we have the row too
                        }
                        x++;
                    }
                    
                }//end if initial!=nil
            }//end if name is equal fullName
        }//end outer foor loop
    }//end if
    
    
   // [theTable reloadData];
    if(row>-1 && section>-1) {
        NSLog(@"will scroll to section %d and row %d",section,row);
       NSIndexPath *scrollToPath = [NSIndexPath indexPathForRow:row inSection:section];
       [self.tableView scrollToRowAtIndexPath:scrollToPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    
    
    
    
}

//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
  //  return YES;
//}
//-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //GET THE TEXT
    //UITextField *searchField = [searchBar valueForKey:@"_searchField"];
    
    //if(searchField.text.length<3)//minimum 3 chars
//}

#pragma navigation stuff
-(IBAction)goBackAfterSelection:(id)sender {
    //[rootViewController.selectedRecipientsList addObjectsFromArray:selectedContactsList];
    [self.tabBarController setSelectedIndex:0];// popToRootViewControllerAnimated:YES];
}

-(IBAction)selectAllContacts:(id)sender {
    
    for (NSInteger s = 0; s < self.tableView.numberOfSections; s++) {
        for (NSInteger r = 0; r < [self.tableView numberOfRowsInSection:s]; r++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:s];
            
            
            NSInteger section = indexPath.section;
            //NSInteger row = indexPath.row;
            
            
            NSString *key = [sortedKeys objectAtIndex:section];
            
            NSMutableArray *array = (NSMutableArray *) [contactsByLastNameInitial objectForKey:key];
            for(Contact *contact in array) {
                if(![selectedContactsList containsObject:contact]) {
                    [selectedContactsList addObject:contact];
                }
            }
 
        }
    }
    [self.tableView reloadData];

}

-(void) viewWillAppear:(BOOL)animated {
    
    initialSelectedContacts = selectedContactsList.count;
}

-(void) viewWillDisappear:(BOOL)animated {
    //if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
    //}
   
    [rootViewController.selectedRecipientsList removeAllObjects];
    [rootViewController.selectedRecipientsList addObjectsFromArray:selectedContactsList];
    
    if(selectedContactsList.count>0 && initialSelectedContacts!=selectedContactsList.count) {
        
        NSString *msg = [NSString stringWithFormat:@"Selected %d recipients!",selectedContactsList.count];
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:2000] show];
    }
    
    
   
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return contactsByLastNameInitial.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //NSMutableArray *array = contactsByLastNameInitial ob
    //int count = contactsByLastNameInitial.count;
    
    NSString *key = [sortedKeys objectAtIndex:section];
    NSMutableArray *array = (NSMutableArray *) [contactsByLastNameInitial objectForKey:key];
    return array.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
   
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    
    NSString *key = [sortedKeys objectAtIndex:section];
    
    NSMutableArray *array = (NSMutableArray *) [contactsByLastNameInitial objectForKey:key];
    
    
    Contact *contact = [array objectAtIndex:row];
    if(contact.name!=nil) {
      cell.textLabel.text = contact.name;  
    }
    else if(contact.lastName!=nil) {
        cell.textLabel.text = contact.lastName;
    }
    else if(contact.email!=nil) {
        cell.textLabel.text = contact.email;
    }
    else if(contact.phone!=nil) {
        cell.textLabel.text = contact.phone;
    }
    
    
    BOOL hasPhone = contact.phone!=nil;
    BOOL hasEmail = contact.email!=nil;
    
    if(hasEmail && hasPhone) {
        cell.detailTextLabel.text = @"Email + Phone";
    }
    else if(hasEmail) {
        cell.detailTextLabel.text = @"Email";
    }
    else {
        //only phone
        cell.detailTextLabel.text = @"Phone";
    }
    
   // if(contact.photo!=nil) {
     //   cell.imageView.image = contact.photo;
    //}
    
    if([selectedContactsList containsObject:contact]) {
       // NSLog(@"already contains: %@",contact.name);
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
   
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    
    NSString *key = [sortedKeys objectAtIndex:section];
    NSMutableArray *array = (NSMutableArray *) [contactsByLastNameInitial objectForKey:key];
   

   Contact *contact = [array objectAtIndex:row];
    
   if(![selectedContactsList containsObject:contact]) {
           [selectedContactsList addObject:contact];
   }
   else {
     //already contains, remove it
     [selectedContactsList removeObject:contact];
   }
    
   [self.tableView reloadData];

}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    
   
    NSString *key = [sortedKeys objectAtIndex:section];
    if(section==0) {
        return [ NSString stringWithFormat: @"Choose your recipients:%@%@",@"\r\n",key ];
    }
    return key;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0)
    {
        return UITableViewAutomaticDimension;
    }
    return 16;
}
/**
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        return 40;
    }
    return UITableViewAutomaticDimension;
}*/

-(NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section == contactsByLastNameInitial.count-1) { //if is the last section
        return [NSString stringWithFormat: @"Selected %d recipients",selectedContactsList.count];
    }
    return @"";//
}

@end
