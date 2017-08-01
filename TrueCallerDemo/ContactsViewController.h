//
//  ContactsViewController.h
//  NimbusExample
//
//  Created by Doan Van Vu on 6/20/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactEntity.h"

@interface ContactsViewController : UITableViewController

#pragma mark - singleton
+ (instancetype)sharedInstance;

#pragma mark - prepare Data
- (void)prepareData:(NSArray<ContactEntity*>*)contactEntityList;

@end
