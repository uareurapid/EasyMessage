//
//  ContactDataModel.h
//  EasyMessage
//
//  Created by Paulo Cristo on 9/11/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GroupDataModel;

@interface ContactDataModel : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) UNKNOWN_TYPE phone;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSSet *belongsTo;
@end

@interface ContactDataModel (CoreDataGeneratedAccessors)

- (void)addBelongsToObject:(GroupDataModel *)value;
- (void)removeBelongsToObject:(GroupDataModel *)value;
- (void)addBelongsTo:(NSSet *)values;
- (void)removeBelongsTo:(NSSet *)values;

@end
