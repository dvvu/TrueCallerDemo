//
//  CallManager.m
//  CallKitDemo
//
//  Created by Doan Van Vu on 7/19/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "CallManager.h"
#import <CallKit/CallKit.h>
#import <CallKit/CXError.h>
#import "AppDelegate.h"

@interface CallManager () <CXProviderDelegate>

@property (nonatomic, strong) CXCallController* callController;
@property (nonatomic, strong) CXProvider* provider;
@property (nonatomic, strong) NSUUID* uuid;

@end

@implementation CallManager

#pragma mark - singleton

+ (CallManager *)sharedInstance {
    
    static CallManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^ {
        
        sharedInstance = [[CallManager alloc] init];
        [sharedInstance provider];
    });
    
    return sharedInstance;
}

#pragma mark - init

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _callController = [[CXCallController alloc] init];
    }
    
    return self;
}

#pragma mark - report incommingcall

- (void)reportIncomingCallForUUID:(NSUUID *)uuid phoneNumber:(NSString *)phoneNumber {
    
    CXCallUpdate* update = [[CXCallUpdate alloc] init];
    update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:phoneNumber];
    update.hasVideo = YES;
    
    __weak CallManager* weakSelf = self;
    
    [_provider reportNewIncomingCallWithUUID:uuid update:update completion:^(NSError * _Nullable error) {
        
        if (!error) {
            
            weakSelf.uuid = uuid;
        } else {
            
            if (_delegate && [_delegate respondsToSelector:@selector(callDidFail)]) {
                
                [_delegate callDidFail];
            }
        }
    }];
}

#pragma mark - start call

- (void)startCallWithPhoneNumber:(NSString *)phoneNumber {
    
    _uuid = [NSUUID new];
    CXHandle* handle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:phoneNumber];
    CXStartCallAction* startCallAction = [[CXStartCallAction alloc] initWithCallUUID:_uuid handle:handle];
    CXTransaction* transaction = [[CXTransaction alloc] init];
    [startCallAction setVideo:YES];
    
    [transaction addAction:startCallAction];
    [self requestTransaction:transaction];
}

#pragma mark - end call

- (void)endCall {
    
    CXEndCallAction* endCallAction = [[CXEndCallAction alloc] initWithCallUUID:_uuid];
    CXTransaction* transaction = [[CXTransaction alloc] init];
    
    [transaction addAction:endCallAction];
    [self requestTransaction:transaction];
}

#pragma mark - hold

- (void)holdCall:(BOOL)hold {
    
    CXSetHeldCallAction* holdCallAction = [[CXSetHeldCallAction alloc] initWithCallUUID:_uuid onHold:hold];
    CXTransaction* transaction = [[CXTransaction alloc] init];
    
    [transaction addAction:holdCallAction];
    [self requestTransaction:transaction];
}

#pragma mark - request Transaction

- (void)requestTransaction:(CXTransaction *)transaction {
    
    [_callController requestTransaction:transaction completion:^(NSError * _Nullable error) {
        
        if (error) {
            
            NSLog(@"%@", error.localizedDescription);
            
            if (_delegate && [_delegate respondsToSelector:@selector(callDidFail)]) {
                
                [_delegate callDidFail];
            }
        }
    }];
}

#pragma mark - Getters

- (CXProvider *)provider {
    
    if (!_provider) {
        
        CXProviderConfiguration* configuration = [[CXProviderConfiguration alloc] initWithLocalizedName:@"CallKitDemo"];
        configuration.supportsVideo = YES;
        configuration.maximumCallsPerCallGroup = 1;
        configuration.supportedHandleTypes = [NSSet setWithObject:@(CXHandleTypePhoneNumber)];
        configuration.ringtoneSound = @"Ringtone.mp3";

        _provider = [[CXProvider alloc] initWithConfiguration:configuration];
        [_provider setDelegate:self queue:nil];
    }
    return _provider;
}

#pragma mark - CXProviderDelegate

- (void)providerDidReset:(CXProvider *)provider {
    
    NSLog(@"stop audio...");
    //endCall
}


- (void)providerDidBegin:(CXProvider *)provider {
    
    // Called when the provider has been fully created and is ready to send actions and receive updates
}


- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action {
    
    // If provider:executeTransaction:error: returned NO, each perform*CallAction method is called sequentially for each action in the transaction
    // configure audio session
    // start network call
    [_provider reportOutgoingCallWithUUID:action.callUUID startedConnectingAtDate:nil];
    [_provider reportOutgoingCallWithUUID:action.callUUID connectedAtDate:nil];
    
    if (_delegate && [_delegate respondsToSelector:@selector(callDidAnswer)]) {
        
        [_delegate callDidAnswer];
    }
    
    NSLog(@"audio...");
    
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
    
    // configure audio session
    // answer network call
    if (_delegate && [_delegate respondsToSelector:@selector(callDidAnswer)]) {
        
        [_delegate callDidAnswer];
    }
    
    NSLog(@"audio...");
    
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
    
    // stop audio
    // end network call
    _uuid = nil;
    
    if (_delegate && [_delegate respondsToSelector:@selector(callDidEnd)]) {
        
        [_delegate callDidEnd];
    }
    
    NSLog(@"stop audio...");
    
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action {
    
    if (action.isOnHold) {
        NSLog(@"start audio...");
    } else {
        NSLog(@"stop audio...");
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(callDidHold:)]) {
        
        [_delegate callDidHold:action.isOnHold];
    }
    
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action {
    
}

- (void)provider:(CXProvider *)provider performSetGroupCallAction:(CXSetGroupCallAction *)action {
    
}

- (void)provider:(CXProvider *)provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action {
    
}

- (void)provider:(CXProvider *)provider timedOutPerformingAction:(CXAction *)action {
    
    // Called when an action was not performed in time and has been inherently failed. Depending on the action, this timeout may also force the call to end. An action that has already timed out should not be fulfilled or failed by the provider delegate
    // React to the action timeout if necessary, such as showing an error UI.
}


- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {
    
    // Called when the provider's audio session activation state changes.
    // Start call audio media, now that the audio session has been activated after having its priority boosted.
    NSLog(@"start audio...");

}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession {

     // Restart any non-call related audio now that the app's audio session has been  de-activated after having its priority restored to normal.
}

@end

