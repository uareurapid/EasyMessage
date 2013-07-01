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

    
    if(name && otherContact.name && [name isEqualToString:otherContact.name]) {
        return YES;
    }
    else if(lastName && otherContact.lastName && [lastName isEqualToString:otherContact.lastName]) {
       return YES;
    }
    else if(email && otherContact.email && [email isEqualToString:otherContact.email]) {
        return YES;
    }
    else if(phone && otherContact.phone && [phone isEqualToString:otherContact.phone]) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
