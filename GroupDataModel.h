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
@property (nonatomic, retain) NSSet *contains;
@end

@interface GroupDataModel (CoreDataGeneratedAccessors)

- (void)addContainsObject:(NSManagedObject *)value;
- (void)removeContainsObject:(NSManagedObject *)value;
- (void)addContains:(NSSet *)values;
- (void)removeContains:(NSSet *)values;

@end
