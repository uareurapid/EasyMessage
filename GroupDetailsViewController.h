//
//  GroupDetailsViewController.h
//  EasyMessage
//
//  Created by Paulo Cristo on 9/12/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@interface GroupDetailsViewController : UITableViewController

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil group: (Group*) groupToShow;
@end
