//
//  PhoneViewController.h
//  TrueCallerDemo
//
//  Created by Doan Van Vu on 7/25/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ViewController.h"
#import "TabbarDelegate.h"
#import "ContactEntity.h"

@interface PhoneViewController : ViewController

#pragma mark - TabbarDelegate to notify TabbarController update Data
@property (nonatomic, strong) id<TabbarDelegate>delegate;

#pragma mark - prepare Data
- (void)prepareData:(NSArray<ContactEntity*>*)contactEntityList;

@end
