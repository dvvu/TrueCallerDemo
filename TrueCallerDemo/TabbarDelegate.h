//
//  TabbarDelegate.h
//  TrueCallerDemo
//
//  Created by Doan Van Vu on 7/27/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TabbarDelegate <NSObject>

- (void)reloadViewControllerDelegate:(BOOL)isUpdateTabelView;

@end
