//
//  ContactCellObject.m
//  NimbusExample
//
//  Created by Doan Van Vu on 7/5/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ContactTableViewCell.h"
#import "ContactCache.h"

@implementation ContactCellObject

- (Class)cellClass {
    
    return [ContactTableViewCell class];
}

- (void)getImageCacheForCell: (UITableViewCell *)cell {
    
    __weak ContactTableViewCell* contactTableViewCell = (ContactTableViewCell *)cell;
    
    [[ContactCache sharedInstance] getImageForKey:_identifier completionWith:^(UIImage* image) {
        
        if (image) {
            
            if ([_identifier isEqualToString:contactTableViewCell.identifier]) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    contactTableViewCell.profileImageView.image = image;
                });
            }
        }
    }];
}

@end
