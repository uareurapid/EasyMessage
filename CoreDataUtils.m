//
//  CoreDataUtils.m
//  EasyMessage
//
//  Created by Paulo Cristo on 9/11/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "CoreDataUtils.h"

@implementation CoreDataUtils

+ (NSMutableArray *)fetchGroupRecordsFromDatabase {
    
    
    //NSMutableArray *locationEntitiesArray = [[NSMutableArray alloc] init];
    //add a clause
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(lastName like %@) AND (birthday > %@)", lastNameSearchString, birthdaySearchDate];
    //and then use: NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    
    NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    
    // Define our table/entity to use
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GroupDataModel" inManagedObjectContext:managedObjectContext];
    // Setup the fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    //this is equivalent to SELECT * FROM `LocationEntity`
    
    
    // Define how we will sort the records
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    //[sortDescriptor release];
    // Fetch the records and handle an error
    NSError *error;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    
    // Save our fetched data to an array
    return mutableFetchResults;
    

}

+ (NSMutableArray *)fetchMessageRecordsFromDatabase {
    NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    
    // Define our table/entity to use
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MessageDataModel" inManagedObjectContext:managedObjectContext];
    // Setup the fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    //this is equivalent to SELECT * FROM `LocationEntity`
    
    
    // Define how we will sort the records
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"msg" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    //[sortDescriptor release];
    // Fetch the records and handle an error
    NSError *error;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    
    // Save our fetched data to an array
    return mutableFetchResults;
}

+(ContactDataModel *) fetchContactDataModelByName: (NSString *) contactName {
    NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    
    // Define our table/entity to use
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ContactDataModel" inManagedObjectContext:managedObjectContext];
    // Setup the fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"name == %@",contactName];
    [request setPredicate:predicateID];
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    if(mutableFetchResults!=nil && mutableFetchResults.count>0) {
        return (ContactDataModel *)[mutableFetchResults objectAtIndex:0];
    }
    return nil;
}

+(GroupDataModel *) fetchGroupDataModelByName: (NSString *) groupName {
    NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    
    // Define our table/entity to use
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GroupDataModel" inManagedObjectContext:managedObjectContext];
    // Setup the fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"name == %@",groupName];
    [request setPredicate:predicateID];
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    if(mutableFetchResults!=nil && mutableFetchResults.count>0) {
        return (GroupDataModel *)[mutableFetchResults objectAtIndex:0];
    }
    return nil;
}

+(BOOL) deleteGroupDataModelByName: (NSString *) groupName {
    
    BOOL deleted = NO;
    @try {
        NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        
        // Define our table/entity to use
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"GroupDataModel" inManagedObjectContext:managedObjectContext];
        // Setup the fetch request
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        
        NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"name == %@",groupName];
        [request setPredicate:predicateID];
        
        NSError *error;
        NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        
        if(mutableFetchResults!=nil && mutableFetchResults.count>0) {
            GroupDataModel *toDelete = [mutableFetchResults objectAtIndex:0];
            [managedObjectContext deleteObject:toDelete];
            NSError *error;
            
            if(![managedObjectContext save:&error]){
                NSLog(@"Unable to save object, error is: %@",error.description);
                deleted = NO;
            }
            else {
                deleted = YES; 
            }
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"error deleting group on db %@",exception.description);
    }
    @finally {
        return deleted;
    }
    
}

//delete message
+(BOOL) deleteMessageDataModelByMsg: (NSString *) msg {
    
    BOOL deleted = NO;
    @try {
        NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        
        // Define our table/entity to use
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MessageDataModel" inManagedObjectContext:managedObjectContext];
        // Setup the fetch request
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        
        NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"msg == %@",msg];
        [request setPredicate:predicateID];
        
        NSError *error;
        NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        
        if(mutableFetchResults!=nil && mutableFetchResults.count>0) {
            MessageDataModel *toDelete = [mutableFetchResults objectAtIndex:0];
            [managedObjectContext deleteObject:toDelete];
            NSError *error;
            
            if(![managedObjectContext save:&error]){
                NSLog(@"Unable to save object, error is: %@",error.description);
                deleted = NO;
            }
            else {
                deleted = YES;
            }
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"error deleting message on db %@",exception.description);
    }
    @finally {
        return deleted;
    }
    
}

@end

