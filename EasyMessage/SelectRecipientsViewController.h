//
//  SelectRecipientsViewController.h
//  EasyMessage
//
//  Created by Paulo Cristo on 6/19/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@interface SelectRecipientsViewController : UITableViewController

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contacts: (NSMutableArray *) contacts;

@property (strong,nonatomic) NSMutableArray *contactsList;

@property (strong,nonatomic) NSMutableArray *selectedContactsList;
@end
