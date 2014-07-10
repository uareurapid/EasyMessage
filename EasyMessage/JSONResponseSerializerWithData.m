//
//  JSONResponseSerializerWithData.m
//  EasyMessage
//
//  Created by Paulo Cristo on 26/03/14.
//  Copyright (c) 2014 Paulo Cristo. All rights reserved.
//

#import "JSONResponseSerializerWithData.h"

@implementation JSONResponseSerializerWithData


- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (*error != nil) {
            NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
            NSError *jsonError;
            
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"DATA IS %@",responseString);
            
            // parse to json
            id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            // store the value in userInfo
            if(json==nil)
                NSLog(@"IS JSON NIL ");
            //userInfo[JSONResponseSerializerWithDataKey] = (jsonError == nil) ? json : nil;
            //NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
            //(*error) = newError;
        }
        return (nil);
    }
    return ([super responseObjectForResponse:response data:data error:error]);
}

@end
