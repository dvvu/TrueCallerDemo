//
//  ContactViewController.h
//  TrueCallerDemo
//
//  Created by Doan Van Vu on 7/30/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactViewController : UIViewController

#pragma mark - prepare Data
- (void)prepareData:(NSArray<ContactEntity*>*)contactEntityList;

@end
