//
//  Audio.h
//  CallKitDemo
//
//  Created by Doan Van Vu on 7/19/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface Audio : NSObject

#pragma mark - start audio
- (void)startAudio;

#pragma mark - stop audio
- (void)stopAudio;

@end
