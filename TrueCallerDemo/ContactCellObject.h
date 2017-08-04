//
//  ContactCellObject.h
//  NimbusExample
//
//  Created by Doan Van Vu on 7/5/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "NICellCatalog.h"

@protocol ContactModelProtocol <NSObject>

@property (readonly, nonatomic, copy) NSString* contactTitle;
@property (readonly, nonatomic) NSMutableArray* phoneNumber;
@property (readonly, nonatomic) UIImage* contactImage;

@end

@interface ContactCellObject : NITitleCellObject <ContactModelProtocol>

@property (nonatomic, copy) NSString* contactTitle;
@property (nonatomic) NSMutableArray* phoneNumber;
@property (nonatomic, weak) NSString* identifier;
@property (nonatomic) UIImage* contactImage;

- (void)getImageCacheForCell: (UITableViewCell *)cell;

@end
