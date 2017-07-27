//
//  ContactBook.h
//  NimBusExampleContact
//
//  Created by Lee Hoa on 6/16/17.
//  Copyright © 2017 Lee Hoa. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/ABAddressBook.h>
#import <Foundation/Foundation.h>

@interface ContactBook : NSObject

#pragma mark - singleton
+ (instancetype)sharedInstance;

#pragma mark - get permission
- (void)getPermissionContacts:(void(^)(NSError* error))completion;

#pragma mark - get contact
- (void)getContacts:(void (^)(NSMutableArray* contactlist,NSError* error))completion;

@end
