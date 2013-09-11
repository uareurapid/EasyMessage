//
//  GroupDataModel.h
//  EasyMessage
//
//  Created by Paulo Cristo on 9/11/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GroupDataModel : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *contacts;
@end

@interface GroupDataModel (CoreDataGeneratedAccessors)

- (void)addContactsObject:(NSManagedObject *)value;
- (void)removeContactsObject:(NSManagedObject *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

@end
