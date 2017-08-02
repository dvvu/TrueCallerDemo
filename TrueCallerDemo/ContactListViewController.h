//
//  ContactListViewController.h
//  TrueCallerDemo
//
//  Created by Doan Van Vu on 8/1/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactEntity.h"

@interface ContactListViewController : UIViewController

#pragma mark - prepare Data
- (void)prepareData:(NSArray<ContactEntity*>*)contactEntityList;

@end
