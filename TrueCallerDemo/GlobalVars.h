//
//  GlobalVars.h
//  TrueCallerDemo
//
//  Created by Doan Van Vu on 7/24/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GlobalVars : NSObject

#pragma mark - singleton
+ (GlobalVars *)sharedInstance;

@property (nonatomic, strong) NSArray* contactEntityList;
@property (nonatomic) BOOL isAccessContacts;

- (void)getContactBook;

@end
