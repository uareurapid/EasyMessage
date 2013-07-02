//
//  Contact.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/19/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "Contact.h"

@implementation Contact

@synthesize phone,email,name,lastName,photo;

//we just consider the name
-(BOOL) isEqual:(id)object {
    if(!object || ![object isKindOfClass: [self class]]) {
        return NO;
    }
   
    if(object==self) {
        return YES;
    }
    
    Contact *otherContact = (Contact *)object;
    
    if([self isNameEqual:otherContact]) {
        
        //same name, what about last name?
        if([self isLastNameEqual:otherContact]) {
            //same last name
            //what about email?
            if([self isEmailEqual:otherContact]) {
                //same email
                //what about phone?
                if([self isPhoneEqual:otherContact]) {
                    return YES;
                }//phone is different
                else {
                    return NO;
                }
            }//email is different
            else {
                return NO;
            }
        }//last name is different
        else {
            return NO;
        }
    }
    
    //if one has null name, they are not the same for sure
    
    return NO;
}

#pragma auxiliar comparing methods

-(BOOL) isLastNameEqual: (Contact *) otherContact {
    if(lastName && otherContact.lastName) {
        if([lastName isEqualToString:otherContact.lastName]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL) isNameEqual: (Contact *) otherContact {
    if(name && otherContact.name) {
        
        if([name isEqualToString:otherContact.name]) {
            //ok name is equal, check lastname
            return YES;
        }
    }
    return NO;
}

-(BOOL) isPhoneEqual: (Contact *) otherContact {
    if(phone && otherContact.phone) {
        if([phone isEqualToString:otherContact.phone]) {
            return YES;
        }
    }
    
    
    return NO;
}

-(BOOL) isEmailEqual: (Contact *) otherContact {
    
    if(email && otherContact.email) { 
        if([email isEqualToString:otherContact.email]) {
            return YES;
        }
    }
    
    return NO;
}

@end
