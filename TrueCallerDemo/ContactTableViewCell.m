//
//  ContactCellObject.h
//  NimbusExample
//
//  Created by Doan Van Vu on 7/5/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ContactTableViewCell.h"

@implementation ContactTableViewCell

#pragma mark - init TableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
   
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
   
    if (self) {
        
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
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_profileImageView];
    
    // ProfileImage
    _profileImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Center Y
    [[_profileImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor] setActive:YES];
    
    // Height = 0.9 parent View
    [_profileImageView addConstraint:[NSLayoutConstraint
                                  constraintWithItem:_profileImageView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                  multiplier:1.0
                                  constant:self.contentView.frame.size.height * 0.9]];
    // Ratio = 1
    [_profileImageView addConstraint:[NSLayoutConstraint
                                  constraintWithItem:_profileImageView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:_profileImageView
                                  attribute:NSLayoutAttributeWidth
                                  multiplier:1
                                  constant:0]];
    // Space to left = 8
    NSLayoutConstraint* leftProfileImageConstraint = [NSLayoutConstraint
                                                 constraintWithItem:_profileImageView
                                                 attribute:NSLayoutAttributeLeft
                                                 relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                                 attribute: NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                 constant:8];
    
    [self.contentView addConstraints:@[leftProfileImageConstraint]];
    
    // Name
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Center Y
    [[_nameLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor] setActive:YES];
    
    // Space to _profileImage left = 8
    NSLayoutConstraint* leftNameConstraint = [NSLayoutConstraint
                                                 constraintWithItem:_nameLabel
                                                 attribute:NSLayoutAttributeLeft
                                                 relatedBy:NSLayoutRelationEqual
                                                 toItem:_profileImageView
                                                 attribute: NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                 constant:self.contentView.frame.size.height * 0.9 + 8];
    // Space to right = 8
    NSLayoutConstraint* rightNameConstraint = [NSLayoutConstraint
                                              constraintWithItem:_nameLabel
                                              attribute:NSLayoutAttributeRight
                                              relatedBy:NSLayoutRelationEqual
                                              toItem:self.contentView
                                              attribute: NSLayoutAttributeRight
                                              multiplier:1.0
                                              constant:8];
    
    [self.contentView addConstraints:@[leftNameConstraint,rightNameConstraint]];
    
}

@end
