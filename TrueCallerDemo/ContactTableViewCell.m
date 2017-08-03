//
//  ContactCellObject.h
//  NimbusExample
//
//  Created by Doan Van Vu on 7/5/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ContactTableViewCell.h"
#import "Masonry.h"
#define CELLHEIGHT 70

@interface ContactTableViewCell ()

@property (nonatomic)UIEdgeInsets padding;

@end

@implementation ContactTableViewCell

#pragma mark - init TableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
   
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
   
    if (self) {
        
        _padding = UIEdgeInsetsMake(10, 10, 10, 10);
        [self setupLayoutForCell];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
   
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        [self setupLayoutForCell];
    }
    
    return self;
}

#pragma mark - selected cell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    
}

#pragma mark - delegate oif NICell -> change when something is changed in cell

- (BOOL)shouldUpdateCellWithObject:(id<ContactModelProtocol>)object {

    _nameLabel.text = object.contactTitle;
    _profileImageView.image = object.contactImage;
    
    return YES;
}

- (void)setModel:(id<ContactModelProtocol>)model {
    
    _model = model;
}

#pragma mark - update layout

- (void)setupLayoutForCell {

    _nameLabel = [[UILabel alloc] init];
    _profileImageView = [[UIImageView alloc] init];
    [_nameLabel setFont:[UIFont systemFontOfSize:16]];
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_profileImageView];
    
    [_profileImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).with.offset(_padding.left);
        make.size.mas_equalTo(CGSizeMake(CELLHEIGHT * 0.7, CELLHEIGHT * 0.7));
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(_profileImageView).with.offset(_padding.left + CELLHEIGHT * 0.7);
        make.right.equalTo(self.contentView).with.offset(-_padding.right);
        make.height.lessThanOrEqualTo(self.contentView.mas_height);
    }];
}

+ (CGFloat)heightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    
    return CELLHEIGHT;
}

@end
