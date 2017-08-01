//
//  CallManager.h
//  CallKitDemo
//
//  Created by Doan Van Vu on 7/19/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - delegate to notify cotroller -> UI
@protocol CallManagerDelegate <NSObject>

- (void)callDidAnswer;
- (void)callDidEnd;
- (void)callDidHold:(BOOL)isOnHold;
- (void)callDidFail;

@end

@interface CallManager : NSObject

#pragma mark - singleton
+ (CallManager *)sharedInstance;

#pragma mark - report new incoming call
- (void)reportIncomingCallForUUID:(NSUUID *)uuid phoneNumber:(NSString *)phoneNumber;

#pragma mark - start call
- (void)startCallWithPhoneNumber:(NSString *)phoneNumber;

#pragma mark - hold call
- (void)holdCall:(BOOL)hold;

#pragma mark - end call
- (void)endCall;

#pragma mark - CallManager delegate
@property (nonatomic, weak) id<CallManagerDelegate>delegate;

@end
