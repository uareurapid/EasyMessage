//
//  UIPlaceHolderTextView.h
//  EasyMessage
//
//  Created by Paulo Cristo on 6/21/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

//@property unsigned int textLength;
-(void)textChanged:(NSNotification*)notification;

@end
