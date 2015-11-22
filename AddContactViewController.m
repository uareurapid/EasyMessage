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
    [self.btnAddContact setTitle:NSLocalizedString(@"create_contact",@"create_contact") forState:UIControlStateNormal];
    [self.btnCancel setTitle:NSLocalizedString(@"cancel",@"cancel") forState:UIControlStateNormal];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableViewBackground.png"]];
    
    self.txtPhone.delegate = self;
    self.txtName.delegate=self;
    self.txtLastName.delegate=self;
    self.txtEmail.delegate=self;
    
    [self.labelEmail setText: [NSString stringWithFormat:@"%@:", NSLocalizedString(@"contact_email",@"contact_email")] ];
    [self.labelPhone setText: [NSString stringWithFormat:@"%@:",NSLocalizedString(@"phone_label",@"phone_label")] ];
    [self.labelName setText: [NSString stringWithFormat:@"%@:(*)",NSLocalizedString(@"contact_name",@"contact_name")] ];
    [self.labelLastname setText: [NSString stringWithFormat:@"%@:",NSLocalizedString(@"contact_last_name",@"contact_last_name")] ];
    
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //if(textField == subject) {
        [textField resignFirstResponder];
    //    return YES;
    //}
    
    return YES;
}

- (IBAction)addContactClicked:(id)sender {
    
    if(self.txtName.text.length==0 || (self.txtEmail.text.length==0 && self.txtPhone.text.length==0) ) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage" message:NSLocalizedString(@"contact_fields_required",@"contact_fields_required") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }//TODO msg, need either phone or email
    
    else {
        
        BOOL emailValid = YES;
        if(self.txtEmail.text.length > 0 ) {
            //check if email valid
            if(![self NSStringIsValidEmail: self.txtEmail.text]) {
                emailValid = NO;
                //not valid
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage" message:NSLocalizedString(@"invalid_email",@"invalid_email") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
       
        if(emailValid) {
            if([self checkIfContactExists:self.txtName.text]==NO) {
                
                //name OK, save it!
                Contact *contact = [[Contact alloc] init];
                contact.name = self.txtName.text;
                contact.phone = self.txtPhone.text.length==0 ? @"" : self.txtPhone.text;
                contact.email = self.txtEmail.text.length==0 ? @"" : self.txtEmail.text;
                contact.lastName = self.txtLastName.text.length==0? @"": self.txtLastName.text;
                
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
                    [[[[iToast makeText:NSLocalizedString(@"added",@"added")]
                       setGravity:iToastGravityBottom] setDuration:2000] show];
                }
                
                if(OK) {
                    //add to the list
                    [self.contactsList addObject:contact];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                }
                
                
            }
            else {
                //TODO contact already exists
                //group name already exists
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage" message:NSLocalizedString(@"contact_already_exists",@"contact_already_exists") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
        }
        
        
        
        
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

    for(Contact * contact in self.contactsList) {
        if([contact.name isEqualToString:name]){
            
            return YES;
        }
    }
    return NO;
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
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
