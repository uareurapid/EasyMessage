//
//  Contact.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/19/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "Contact.h"

@implementation Contact

@synthesize phone,email,name;

//we just consider the name
-(BOOL) isEqual:(id)object {
    if(!object || ![object isKindOfClass: [self class]]) {
        return NO;
    }
    
    if(object==self) {
        return YES;
    }
    
    Contact *other = (Contact *)object;
    //NSString *otherName = other.name;
    //NSString *otherEmail = other.email;
    //NSString *otherPhone = other.phone;
    
    if([name isEqualToString:other.name]) {
       /* if(otherEmail!=nil && email!=nil) {
            if([otherEmail isEqual:email]) {
                return YES;
            }
            else {
                return NO;
            }
        }
        else {
            return NO;
        }*/
        
        return YES;
    }
    else {
       return NO;
    }
}

@end
