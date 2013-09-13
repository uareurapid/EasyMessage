//
//  CoreDataUtils.h
//  EasyMessage
//
//  Created by Paulo Cristo on 9/11/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupDataModel.h"
#import "PCAppDelegate.h"

@interface CoreDataUtils : NSObject

+ (NSMutableArray *)fetchGroupRecordsFromDatabase;
+ (NSMutableArray *)fetchMessageRecordsFromDatabase;
@end
