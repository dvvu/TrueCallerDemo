//
//  CallViewController.h
//  CallKitDemo
//
//  Created by Doan Van Vu on 7/19/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "CallViewController.h"
#import "CallManager.h"
#import "AppDelegate.h"

@interface CallViewController () <CallManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel* infoLabel;
@property (weak, nonatomic) IBOutlet UILabel* timeLabel;
@property (weak, nonatomic) IBOutlet UILabel* callerLabel;
@property (weak, nonatomic) IBOutlet UIButton* holdButton;
@property (weak, nonatomic) IBOutlet UIButton* endButton;

@property (nonatomic, strong) NSDateComponentsFormatter* timeFormatter;
@property (nonatomic, strong) NSTimer* callDurationTimer;

@property (nonatomic, assign) NSTimeInterval callDuration;
@property (nonatomic, assign) BOOL isOnHold;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTask;

@end

@implementation CallViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _callerLabel.text = _phoneNumber;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (_phoneNumber) {
        
        [CallManager sharedInstance].delegate = self;
        
        if (_isIncoming) {
            
             //Since the app may be suspended while waiting for the delayed action to begin,
             //start a background task.
            [self beginBackgroundUpdateTask];
          
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                [self performCall:^{
                    
                    [self endBackgroundUpdateTask];
                }];
            });

        } else {
            
            [[CallManager sharedInstance] startCallWithPhoneNumber:_phoneNumber];
        }
    }
}

- (void) beginBackgroundUpdateTask {
    
    _backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        [self endBackgroundUpdateTask];
    }];
}

- (void) endBackgroundUpdateTask {
    
    [[UIApplication sharedApplication] endBackgroundTask: _backgroundUpdateTask];
    _backgroundUpdateTask = UIBackgroundTaskInvalid;
}

#pragma mark - Getters

- (NSDateComponentsFormatter *)timeFormatter {
    
    if (!_timeFormatter) {
        
        _timeFormatter = [[NSDateComponentsFormatter alloc] init];
        _timeFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
        _timeFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
        _timeFormatter.allowedUnits = NSCalendarUnitMinute | NSCalendarUnitSecond;
    }
    return _timeFormatter;
}

#pragma mark - Actions

- (IBAction)endButtonTapped:(id)sender {
    
    [[CallManager sharedInstance] endCall];
}

- (IBAction)holdButtonTapped:(UIButton  *)sender {
    
    _isOnHold = !_isOnHold;
    [_holdButton setTitle:(_isOnHold ? @"   RESUME   " : @"   HOLD   ") forState:UIControlStateNormal];
    [[CallManager sharedInstance] holdCall:_isOnHold];
}

#pragma mark - CallManagerDelegate

- (void)callDidAnswer {
    
    _timeLabel.hidden = NO;
    _holdButton.hidden = NO;
    _endButton.hidden = NO;
    _infoLabel.text = @"Active";
    [self startTimer];
}

- (void)callDidEnd {
    
    [_callDurationTimer invalidate];
    _callDurationTimer = nil;
    _holdButton.hidden = YES;
    _endButton.hidden = YES;
    _infoLabel.text = @"Ended";
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:1.f];
}

- (void)callDidHold:(BOOL)isOnHold {
    
    if (isOnHold) {
        
        [_callDurationTimer invalidate];
        _callDurationTimer = nil;
        [_holdButton setTitle:@"   RESUME   " forState:UIControlStateNormal];
        _infoLabel.text = @"On Hold";
    } else {
        
        [self startTimer];
        [_holdButton setTitle:@"   HOLD   " forState:UIControlStateNormal];
        _infoLabel.text = @"Active";
    }
}

- (void)callDidFail {
    
    [_callDurationTimer invalidate];
    _callDurationTimer = nil;
    _infoLabel.text = @"Failed";
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:1.f];
}

#pragma mark - Utilities

- (void)performCall:(void(^)())completion {
    
    [[CallManager sharedInstance] reportIncomingCallForUUID:_uuid phoneNumber:_phoneNumber];
}

- (void)dismiss {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)startTimer {
    
    __weak CallViewController* weakSelf = self;
    
    _callDurationTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        weakSelf.timeLabel.text = [weakSelf.timeFormatter stringFromTimeInterval:weakSelf.callDuration++];
    }];
}

@end


