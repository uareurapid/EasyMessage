//
//  CustomMessagesController.h
//  EasyMessage
//
//  Created by Paulo Cristo on 9/6/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCViewController.h"

@interface CustomMessagesController : UITableViewController


@property (strong,nonatomic) NSMutableArray * messagesList;
@property NSInteger selectedMessage;//the index of the selected message

@property (strong,nonatomic) PCViewController *rootViewController;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil rootViewController: (PCViewController *) rootViewController;
@end
