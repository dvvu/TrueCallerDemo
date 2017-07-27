//
//  FriendContactCellObject.h
//  NimbusExample
//
//  Created by Doan Van Vu on 7/16/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "NICellCatalog.h"
#import "ContactCellObject.h"

@interface FriendContactCellObject : NITitleCellObject <ContactModelProtocol>

@property (nonatomic, copy) NSString* contactTitle;
@property (nonatomic) UIImage* contactImage;

@end
