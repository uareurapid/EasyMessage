//
//  IAPHelper.h
//  EasyMessage
//
//  Created by Paulo Cristo on 9/7/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;


// Add two new method declarations
- (void)buyProduct:(SKProduct *)product;
//buy the product
- (BOOL)productPurchased:(NSString *)productIdentifier;
//restore purchases on other devices
- (void)restoreCompletedTransactions;
@end
