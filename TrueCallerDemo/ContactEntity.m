//
//  ContactEntity.m
//  NimbusExample
//
//  Created by Doan Van Vu on 6/28/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ContactEntity.h"
#import "Constants.h"

@interface ContactEntity()

@property (nonatomic, strong) NSString* textNameDefault;

@end

@implementation ContactEntity

#pragma mark - getCNContact

- (ContactEntity *)initWithCNContacts:(CNContact *)contact {
 
    self = [super init];
    
    if (self) {
        
        // Get Name
        NSString* firstName = @"";
        NSString* lastName = @"";
        _textNameDefault = @"";
        
        if (contact.givenName.length > 0) {
          
            firstName = contact.givenName;
            _textNameDefault = [_textNameDefault stringByAppendingString:[firstName substringToIndex:1]];
        }
        
        if (contact.familyName.length > 0) {
     
            lastName = contact.familyName;
            _textNameDefault = [_textNameDefault stringByAppendingString:[lastName substringToIndex:1]];
        }
        
        _name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
        // Get ID Contact
        _identifier = contact.identifier;
        
        // Get PhoneNumber
        _phone = [[NSMutableArray alloc] init];
        
        for (CNLabeledValue* cNLabeledValue in contact.phoneNumbers) {
            
            NSString* phoneNumber = [cNLabeledValue.value stringValue];
            
            if([self validatePhone:phoneNumber]) {
        
                NSString* phoneNumberFormatted = [phoneNumber stringByReplacingOccurrencesOfString:@"\u00a0" withString:@""];
                [_phone addObject:phoneNumberFormatted];
            }
            
        }
    
    }
    
    return self;
}

#pragma mark - getCNABRecordRef

- (ContactEntity *)initWithAddressBook:(ABRecordRef )contact {
    
    self = [super init];
 
    if (self) {
        
        // Get Name
        NSString* firstName = CFBridgingRelease(ABRecordCopyValue(contact, kABPersonFirstNameProperty));
        NSString* lastName = CFBridgingRelease(ABRecordCopyValue(contact, kABPersonLastNameProperty));
        _textNameDefault = @"";
        
        if (firstName.length > 0) {
            
            _textNameDefault = [_textNameDefault stringByAppendingString:[firstName substringToIndex:1]];
        } else {
            
            firstName = @"";
        }
        
        if (lastName.length > 0) {
          
            _textNameDefault = [_textNameDefault stringByAppendingString:[lastName substringToIndex:1]];
        } else {
            
            lastName = @"";
        }
        
        _name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
        // Get ID Record
        NSString* recordId = [NSString stringWithFormat:@"%d",(ABRecordGetRecordID(contact))];
        _identifier = recordId;
        
        ABMultiValueRef phoneNumbers = (__bridge ABMultiValueRef)(CFBridgingRelease(ABRecordCopyValue(contact, kABPersonPhoneProperty)));
        CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
        
        _phone = [[NSMutableArray alloc] init];
        
        for (CFIndex i = 0; i < numberOfPhoneNumbers; i++) {
            
            NSString* phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, i));
            
            if ([self validatePhone:phoneNumber]) {
             
                NSString* phoneNumberFormatted = [phoneNumber stringByReplacingOccurrencesOfString:@"\u00a0" withString:@""];
                [_phone addObject:phoneNumberFormatted];
            }
        }
    }
    
    return self;
}

#pragma mark - validate phoneNumber

- (BOOL)validatePhone:(NSString *)phoneNumber {
    
    NSString* phoneRegex = @"^[0-9-\\s]{6,14}$";
    NSPredicate* validatePhoneNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [validatePhoneNumber evaluateWithObject:phoneNumber];
}

#pragma mark - profileImageDefault

- (UIImage *)profileImageDefault {
    
    // Size image
    int imageWidth = 100;
    int imageHeight =  100;
    
    // Rect for image
    CGRect rect = CGRectMake(0,0,imageHeight,imageHeight);
    
    // setup text
    UIFont* font = [UIFont systemFontOfSize: 50];
    CGSize textSize = [_textNameDefault.uppercaseString sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:50]}];
    NSMutableAttributedString* nameAttString = [[NSMutableAttributedString alloc] initWithString:_textNameDefault.uppercaseString];
    NSRange range = NSMakeRange(0, [nameAttString length]);
    [nameAttString addAttribute:NSFontAttributeName value:font range:range];
    [nameAttString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range];
    
    // Create image
    CGSize imageSize = CGSizeMake(imageWidth, imageHeight);
    UIColor* fillColor = [UIColor lightGrayColor];
    
    // Begin ImageContext Options
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [fillColor setFill];
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();

    // Begin ImageContext
    UIGraphicsBeginImageContext(rect.size);
    
    //  Draw Circle image
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:imageWidth/2] addClip];
    [image drawInRect:rect];
    
    // Draw text
    [nameAttString drawInRect:CGRectIntegral(CGRectMake(imageWidth/2 - textSize.width/2, imageHeight/2 - textSize.height/2, imageWidth, imageHeight))];
    
    UIImage* profileImageDefault = UIGraphicsGetImageFromCurrentImageContext();
    
    // End ImageContext
    UIGraphicsEndImageContext();
    
    // End ImageContext Options
    UIGraphicsEndImageContext();
    
    return profileImageDefault;
}

@end
