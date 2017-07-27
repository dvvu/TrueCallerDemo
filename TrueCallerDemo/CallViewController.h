//
//  CallViewController.h
//  CallKitDemo
//
//  Created by Doan Van Vu on 7/19/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallViewController : UIViewController

@property (nonatomic, strong) NSString* _Nonnull phoneNumber;
@property (nonnull, strong) NSUUID* uuid;
@property (nonatomic, assign) BOOL isIncoming;

@end
