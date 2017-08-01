//
//  ContactCache.m
//  NimbusExample
//
//  Created by Doan Van Vu on 6/29/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ContactCache.h"
#import "Constants.h"

@interface ContactCache()

@property (nonatomic, strong) NSMutableArray<NSString*>* keyList;
@property (nonatomic) dispatch_queue_t cacheImageQueue;
@property (nonatomic, strong) NSCache* contactCache;
@property (nonatomic) NSUInteger maxCacheSize;
@property (nonatomic) NSUInteger totalPixel;

@end

@implementation ContactCache

#pragma mark - singleton

+ (instancetype)sharedInstance {
    
    static ContactCache* sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^ {
        
        sharedInstance = [[ContactCache alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - intit

- (instancetype)init {

    self = [super init];
    
    if (self) {
        
        _maxCacheSize = MAX_CACHE_SIZE;
        _keyList = [[NSMutableArray alloc]init];
        _contactCache = [[NSCache alloc] init];
        _cacheImageQueue = dispatch_queue_create("CACHE_IMAGE_QUEUE", DISPATCH_QUEUE_SERIAL);
        [_contactCache setName:@"ContactImage"];
    }
    return self;
}

#pragma mark - save to cache with image

- (void)setImageForKey:(UIImage *)image forKey:(NSString *)key {
    
    if (image && key) {
        
        dispatch_async(_cacheImageQueue, ^ {
               
            // Add key into keyList
            [_keyList addObject:key];
            
            // Get size of image
            UIImage* circleImage = [self makeRoundImage:image];
            CGFloat pixelImage = [self imageSize:circleImage];
            
            // Add size to check condition
            _totalPixel += pixelImage;
            
            NSLog(@"%lu",(unsigned long)_totalPixel);
            
            // size of image < valid memory?
            if (pixelImage < MAX_ITEM_SIZE) {
              
                int index = 0;
                while (_totalPixel > _maxCacheSize) {
                    
                    CGFloat size =  [self imageSize:[_contactCache objectForKey:[_keyList objectAtIndex:index]]];
                    [_contactCache removeObjectForKey:[_keyList objectAtIndex:index]];
                    _totalPixel -= size;
                    index++;
                }
                
                [_contactCache setObject:circleImage forKey:key];
                //[self writeToDirectory:[self makeRoundImage:image] forkey:key];
                
            } else if (pixelImage == _maxCacheSize) {
                
                [_contactCache removeAllObjects];
                [_contactCache setObject:circleImage forKey:key];
            }
        });
    }
}

#pragma mark - get to image from cache or dir

- (void)getImageForKey:(NSString *)key completionWith:(void(^)(UIImage* image))completion {
    
    dispatch_async(_cacheImageQueue, ^ {
        
        if (key) {
            
            if (completion) {
                
                UIImage* image = [self getImageFromCache:key];
                
                if (image) {
                    
                    // Cache
                    completion(image);
                } else {
                    
                   completion(nil);
                }
            }
        } else {
            
            if (completion) {
                
                completion(nil);
            }
        }
    });
}

#pragma mark - get image size

- (CGFloat)imageSize:(UIImage *)image {
    
    return image.size.height * image.size.width * [UIScreen mainScreen].scale;
}

#pragma mark - write image into cache

- (void)writeToCache:(UIImage *)image forkey:(NSString *)key {
    
    if (image && key) {
        
        [_contactCache setObject:image forKey:key];
    }
}

#pragma mark - get image from cache

- (UIImage *)getImageFromCache:(NSString *)key {
    
    if (key) {
        
        return [_contactCache objectForKey:key];
    }
    
    return nil;
}

#pragma mark - draw image circle

- (UIImage *)makeRoundImage:(UIImage *)image {
   
    // Resize image
    image = [self resizeImage:image];
    CGFloat imageWidth = image.size.width;
    CGRect rect = CGRectMake(0, 0, imageWidth, imageWidth);
    
    // Begin ImageContext
    UIGraphicsBeginImageContext(rect.size);
   
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:imageWidth/2] addClip];
    [image drawInRect:rect];
    UIImage* imageCircle = UIGraphicsGetImageFromCurrentImageContext();
    
    // End ImageContext
    UIGraphicsEndImageContext();
    
    return imageCircle;
}

#pragma mark - resize image

- (UIImage *)resizeImage:(UIImage *)image {
    
    CGAffineTransform scaleTransform;
    CGPoint origin;
    CGFloat edgeSquare = 100;
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    if (imageWidth > imageHeight) {
        
        CGFloat scaleRatio = edgeSquare / imageHeight;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        origin = CGPointMake(-(imageWidth - imageHeight) / 2, 0);
    } else {
        
        CGFloat scaleRatio = edgeSquare / imageWidth;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        origin = CGPointMake(0, -(imageHeight - imageWidth) / 2);
    }
    
    CGSize size = CGSizeMake(edgeSquare, edgeSquare);
    
    // Begin ImageContext
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    [image drawAtPoint:origin];
   
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
