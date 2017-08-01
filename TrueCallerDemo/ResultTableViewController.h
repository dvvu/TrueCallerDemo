//
//  ResultTableViewController.h
//  NimbusExample
//
//  Created by Doan Van Vu on 6/26/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactEntity.h"

@interface ResultTableViewController : UITableViewController

- (void)repareData:(NSArray<ContactEntity*>*)listContactBook;

@end
