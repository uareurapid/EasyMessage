//
//  AddContactViewController.h
//  EasyMessage
//
//  Created by PC Dreams on 14/11/15.
//  Copyright © 2015 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddContactViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *lblName;
@property (weak, nonatomic) IBOutlet UITextField *lblLastName;
@property (weak, nonatomic) IBOutlet UITextField *lblEmail;
@property (weak, nonatomic) IBOutlet UITextField *lblPhone;

//reference to recipients controller list
@property (strong,nonatomic) NSMutableArray *contactsList;

@end
