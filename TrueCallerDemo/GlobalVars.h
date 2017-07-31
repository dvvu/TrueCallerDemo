//
//  GlobalVars.h
//  TrueCallerDemo
//
//  Created by Doan Van Vu on 7/24/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ContactEntity.h"

@interface GlobalVars : NSObject

#pragma mark - singleton
+ (GlobalVars *)sharedInstance;

#pragma mark - global variable contactEntityList
@property (nonatomic, strong) NSArray<ContactEntity*>* contactEntityList;

@end
