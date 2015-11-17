//
//  AddContactViewController.m
//  EasyMessage
//
//  Created by PC Dreams on 14/11/15.
//  Copyright © 2015 Paulo Cristo. All rights reserved.
//

#import "AddContactViewController.h"
#import "ContactDataModel.h"
#import "Contact.h"
#import "PCAppDelegate.h"
#import "iToast.h"

@interface AddContactViewController ()

@end

//TODO README how to center this http://stackoverflow.com/questions/26471661/auto-layout-xcode-6-centering-ui-elements

@implementation AddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)btnCancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}
- (IBAction)addContactClicked:(id)sender {
    
    if([self checkIfContactExists:self.lblName.text]==NO) {
        
        //name OK, save it!
        Contact *contact = [[Contact alloc] init];
        contact.name = self.lblName.text;
        contact.phone = self.lblPhone.text;
        contact.email = self.lblEmail.text;
        contact.lastName = self.lblLastName.text;
        
        NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        ContactDataModel *contactModel = [self prepareModelFromContact:managedObjectContext :contact ];
        
        BOOL OK = NO;
        NSError *error;
        
        if(![managedObjectContext save:&error]){
            NSLog(@"Unable to save object, error is: %@",error.description);
            //This is a serious error saying the record
            //could not be saved. Advise the user to
            //try again or restart the application.
        }
        else {
            OK = YES;
            [[[[iToast makeText:NSLocalizedString(@"group_created",@"group_created")]
               setGravity:iToastGravityBottom] setDuration:2000] show];
        }
        
        if(OK) {
            //add to the list
            [self.contactsList addObject:contact];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
        
        
        
        
    }
    else {
        //group name already exists
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"invalid_name",@"invalid_name") message:NSLocalizedString(@"group_already_exists",@"group_already_exists") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    
    
    
    
    
}

-(ContactDataModel *) prepareModelFromContact: (NSManagedObjectContext *) managedObjectContext: (Contact *)contact {
    
    ContactDataModel *contactModel = (ContactDataModel *)[NSEntityDescription insertNewObjectForEntityForName:@"ContactDataModel" inManagedObjectContext:managedObjectContext];
    contactModel.name = contact.name;
    contactModel.phone = contact.phone;
    contactModel.email = contact.email;
    contactModel.lastname = contact.lastName;
    contactModel.group = nil;
    
    return contactModel;
}


-(BOOL) checkIfContactExists: (NSString *) name {
    
    
    /*for(id contact in contactsList) {
        if([contact isKindOfClass:Group.class]) {
            Group *gr = (Group *)contact;
            if([gr.name isEqualToString:name]) {
                return YES;
            }
        }
    }*/
    return NO;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
