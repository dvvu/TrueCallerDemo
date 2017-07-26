//
//  ContactCache.h
//  NimbusExample
//
//  Created by Doan Van Vu on 6/29/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ContactCache : NSObject

#pragma mark - singleton
+ (instancetype)sharedInstance;

#pragma mark - set image to cache for key
- (void)setImageForKey:(UIImage *)image forKey:(NSString *)key;

#pragma mark - get image from cache with key
- (void)getImageForKey:(NSString *)key completionWith:(void(^)(UIImage* image))completion;

@end
