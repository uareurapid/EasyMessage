//
//  SelectRecipientsViewController.h
//  EasyMessage
//
//  Created by Paulo Cristo on 6/19/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import "Group.h"


@class PCViewController;



@interface SelectRecipientsViewController : UITableViewController <UISearchBarDelegate>

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contacts: (NSMutableArray *) contacts;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contacts: (NSMutableArray *) contacts rootViewController: (PCViewController*) viewController;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contacts: (NSMutableArray *) contacts
   selectedOnes: (NSMutableArray *) selectedRecipients rootViewController: (PCViewController*) viewController;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil rootViewController: (PCViewController*) viewController;

-(IBAction)refreshPhonebook:(id)sender;

-(void) deleteGroup:(Group *)group;

@property (strong,nonatomic) NSMutableArray *contactsList;
@property (strong,nonatomic) NSMutableArray *groupsList;

@property (strong,nonatomic) NSMutableArray *selectedContactsList;
@property (strong,nonatomic) NSMutableArray * databaseRecords;
@property (strong,nonatomic) PCViewController *rootViewController;

@property (strong,nonatomic) NSMutableDictionary *contactsByLastNameInitial;

@property (strong,nonatomic) NSMutableArray *sortedKeys;

@property ABRecordID groupId;

@property (strong, nonatomic) UIImage *imageLock;
@property (strong, nonatomic) UIImage *imageUnlock;


//will hold a list of contacts per each letter

@property NSInteger initialSelectedContacts;
@property BOOL groupLocked;
@end
