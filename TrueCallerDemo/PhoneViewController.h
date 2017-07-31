//
//  PhoneViewController.h
//  TrueCallerDemo
//
//  Created by Doan Van Vu on 7/25/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ViewController.h"
#import "TabbarDelegate.h"

@interface PhoneViewController : ViewController

@property (nonatomic, strong) id<TabbarDelegate> delegate;

- (void)prepareData;

@end
