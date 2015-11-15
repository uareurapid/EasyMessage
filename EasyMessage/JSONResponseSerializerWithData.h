//
//  JSONResponseSerializerWithData.h
//  EasyMessage
//
//  Created by Paulo Cristo on 26/03/14.
//  Copyright (c) 2014 Paulo Cristo. All rights reserved.
//

#import "AFURLResponseSerialization.h"

/// NSError userInfo key that will contain response data
static NSString * const JSONResponseSerializerWithDataKey = @"JSONResponseSerializerWithDataKey";

@interface JSONResponseSerializerWithData : AFJSONResponseSerializer

@end
