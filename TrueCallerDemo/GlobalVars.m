//
//  GlobalVars.m
//  TrueCallerDemo
//
//  Created by Doan Van Vu on 7/24/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "GlobalVars.h"
#import "ContactBook.h"
#import "Constants.h"


@interface GlobalVars ()

@property (nonatomic, strong) ContactBook* contactBook;

@end

@implementation GlobalVars

+ (GlobalVars *)sharedInstance {
    
    static dispatch_once_t onceToken;
    static GlobalVars* instance = nil;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[GlobalVars alloc] init];
    });
    
    return instance;
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        _contactEntityList = [[NSArray alloc] init];
        _isAccessContacts = false;
        _contactBook = [ContactBook sharedInstance];
    }
    
    return self;
}

#pragma mark - Show Contacts

- (void)getContactBook {
    
    [_contactBook getPermissionContacts:^(NSError* error) {
        
        if((error.code == ContactAuthorizationStatusDenied) || (error.code == ContactAuthorizationStatusRestricted)) {
            
            [[[UIAlertView alloc] initWithTitle:@"This app requires access to your contacts to function properly." message: @"Please! Go to setting!" delegate:self cancelButtonTitle:@"CLOSE" otherButtonTitles:@"GO TO SETTING", nil] show];
        } else {
            
            [_contactBook getContacts:^(NSMutableArray* contactEntityList, NSError* error) {
                
                if(error.code == ContactLoadingFailError) {
                    
                    [[[UIAlertView alloc] initWithTitle:@"This Contact is empty." message: @"Please! Check your contacts and try again!" delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles: nil, nil] show];
                } else {
                    
                    _isAccessContacts = YES;
                    _contactEntityList = [NSArray arrayWithArray:contactEntityList];
                    
                }
            }];
        }
    }];
}

@end
