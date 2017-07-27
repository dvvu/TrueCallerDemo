//
//  Constants.h
//  NimbusExample
//
//  Created by Doan Van Vu on 6/28/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#ifndef Constants_h
#define Constants_h


#define iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(version) [[[UIDevice currentDevice] systemVersion] floatValue] >= version

// 5M
#define MAX_CACHE_SIZE 5*1024*1024
#define MAX_ITEM_SIZE 1024*1024
#define KEYBOARD_HEADER_HEIGHT 35
#define DEVICE_WIDTH [[UIScreen mainScreen] bounds].size.width
#define DEVICE_HEIGHT [[UIScreen mainScreen] bounds].size.height

#endif /* Constants_h */


#pragma mark - contacts Authorizatio Status
typedef enum {
    
    ContactAuthorizationStatusDenied = 1,
    ContactAuthorizationStatusRestricted = 2,
} ContactAuthorizationStatus;


#pragma mark - contacts loading Error
typedef enum {
    
    ContactLoadingFailError = 3
} ErorrCode;

