//
//  ContactBook.m
//  NimBusExampleContact
//
//  Created by Lee Hoa on 6/16/17.
//  Copyright © 2017 Lee Hoa. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/ABAddressBook.h>
#import <Contacts/Contacts.h>
#import "ContactEntity.h"
#import "ContactCache.h"
#import "ContactBook.h"
#import "Constants.h"

@interface ContactBook()

@property (nonatomic)  BOOL isSupportiOS9;
@property (nonatomic) dispatch_queue_t loaderContactQueue;
@property (nonatomic) ABAddressBookRef addressBookRef;
@property (nonatomic) CNContactStore* contactStore;
@property (nonatomic, strong) ContactEntity* contactEntity;
@property (nonatomic, strong) NSMutableArray* contactEntityList;

@end

@implementation ContactBook

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    
    static ContactBook* sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[ContactBook alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - init

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _isSupportiOS9 = iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(9.0);
        _contactEntity = [ContactEntity new];
        _contactEntityList = [[NSMutableArray alloc] init];
        _loaderContactQueue = dispatch_queue_create("LOADER_CONTACT_QUEUE", DISPATCH_QUEUE_SERIAL);
      
        if (_isSupportiOS9) {
            
            _contactStore = [[CNContactStore alloc] init];
        } else {
            
            _addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        }
    }
    return  self;
}

#pragma mark - check Permission

- (void)getPermissionContacts:(void (^)(NSError *))completion {
    
    if (_isSupportiOS9) {
        
        [self getPermissionUseContacts:^(NSError* error) {
          
            if (error) {
                
                if (completion) {
                    
                    completion(error);
                }
            } else {
                
                if (completion) {
                    
                    completion(nil);
                }
            }
        }];
        
    } else {
        
        [self getPermissionUseAddressBook:^(NSError* error) {
            
            if (error) {
                
                if (completion) {
                    
                    completion(error);
                }
            } else {
                
                if (completion) {
                    
                    completion(nil);
                }
            }
        }];
    }
}

#pragma mark -get contact

- (void)getContacts:(void (^)(NSMutableArray *, NSError *))completion {
    
    dispatch_async(_loaderContactQueue,^{
   
        if (_isSupportiOS9) {
        
            [self getContactsWithCNContacts:^(NSMutableArray* contactEntityList, NSError* error) {
                
                if (error) {
                    
                    if (completion) {
                        
                        completion(nil, error);
                    }
                } else {
                    
                    if (completion) {
                        
                        completion(contactEntityList, nil);
                    }
                }
                
            }];
        } else {
        
            [self getContactsWithAddressBook:^(NSMutableArray* contactEntityList, NSError* error) {
               
                if (error) {
                    
                    if (completion) {
                        
                        completion(nil, error);
                    }
                    
                } else {
                    
                    if (completion) {
                        
                        completion(contactEntityList, nil);
                    }
                }
                
            }];
        }
   });
}

#pragma mark - get permisstionContacts

- (void)getPermissionUseAddressBook:(void (^)(NSError *))completion {
    
    ABAuthorizationStatus authorizationStatus =  ABAddressBookGetAuthorizationStatus();
    
    if (authorizationStatus == kABAuthorizationStatusNotDetermined) {
        
        ABAddressBookRequestAccessWithCompletion(_addressBookRef, ^(bool granted, CFErrorRef error) {
            
            if (granted) {
                
                // First time access has been granted, add the contact
                dispatch_async(dispatch_get_main_queue(), ^ {
                  
                    if (completion) {
                    
                        completion(nil);
                    }
                });
                
            } else {
                
                // Denied access
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    if (completion) {
                        
                        completion([NSError errorWithDomain:@"" code:ContactAuthorizationStatusDenied userInfo:nil]);
                    }
                });
            }
            
        });
    } else if (authorizationStatus == kABAuthorizationStatusAuthorized) {
        
        // The user has previously given access, add the contact
        if (completion) {
            
            completion(nil);
        }
    } else if(authorizationStatus == kABAuthorizationStatusDenied) {
        
        if (completion) {
            
            completion([NSError errorWithDomain:@"" code:ContactAuthorizationStatusDenied userInfo:nil]);
        }
    } else {
        
        // kABAuthorizationStatusRestricted
        // The user has previously denied access
        if (completion) {
            
            dispatch_async(dispatch_get_main_queue(), ^ {
            
                completion([NSError errorWithDomain:@"" code:ContactAuthorizationStatusRestricted userInfo:nil]);
            });
        }
    }
    
}

#pragma mark - get permisstion contacts 9.0 later

- (void)getPermissionUseContacts:(void (^)(NSError *))completion {
    
    CNAuthorizationStatus cNAuthorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    
    if (cNAuthorizationStatus == CNAuthorizationStatusAuthorized) {
        
        // The user has previously given access, add the contact
        if (completion) {
            
            completion(nil);
        }
    } else if (cNAuthorizationStatus == CNAuthorizationStatusNotDetermined) {
        
        [_contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError* _Nullable error) {
    
            if (granted) {
                
                // First time access has been granted, add the contact
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    if (completion) {
                        
                        completion(nil);
                    }
                });
                
            } else {
                
                // Denied access
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    if (completion) {
                        
                         completion([NSError errorWithDomain:@"" code:ContactAuthorizationStatusDenied userInfo:nil]);
                    }
                });
            }
        }];

    } else if (cNAuthorizationStatus == CNAuthorizationStatusDenied) {
        
        if (completion) {
            
            completion([NSError errorWithDomain:@"" code:ContactAuthorizationStatusDenied userInfo:nil]);
        }
    } else {
        
         // CNAuthorizationStatusRestricted
         // The user has previously denied access
        if (completion) {
            
            completion([NSError errorWithDomain:@"" code:ContactAuthorizationStatusRestricted userInfo:nil]);
        }
    }
    
}

#pragma mark - get CNcontacts 

- (void)getContactsWithCNContacts:(void (^)(NSMutableArray *,NSError *))completion {
    
    [_contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError* _Nullable error) {
        
        if (granted) {
            
            _contactEntityList = [[NSMutableArray alloc] init];
            // Feilds with fetching properties
            NSArray* feild = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
            CNContactFetchRequest* request = [[CNContactFetchRequest alloc] initWithKeysToFetch:feild];
            request.sortOrder = CNContactSortOrderGivenName;
            NSError* error;
            
            [_contactStore enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact* __nonnull contact, BOOL* __nonnull stop) {
                
                if (error) {
                    
                    if (completion) {
                        
                        completion(nil, [NSError errorWithDomain:@"" code:ContactLoadingFailError userInfo:nil]);
                    }
                } else {
                    
                    if(contact) {
                        
                        ContactEntity* contactEntity = [[ContactEntity alloc] initWithCNContacts:contact];
                        
                        [_contactEntityList addObject:contactEntity];
                      
                        // Get image
                        UIImage* image = [UIImage imageWithData:contact.imageData];
                        if (image) {
                            
                            [[ContactCache sharedInstance] setImageForKey:image forKey:contact.identifier];
                        }
                        
                    }
                }
                
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                if (completion) {
                    
                    completion(_contactEntityList, nil);
                }
            });
            
        }
    }];
    
}

#pragma mark - get ABAddressBookRef

- (void)getContactsWithAddressBook:(void (^)(NSMutableArray *,NSError *))completion {
    
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(_addressBookRef);
    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(people), people);
    
    CFArraySortValues(peopleMutable, CFRangeMake(0, CFArrayGetCount(peopleMutable)), (CFComparatorFunction) ABPersonComparePeopleByName, kABPersonSortByFirstName);
    
    CFRelease(people);
    
    if  (CFArrayGetCount(peopleMutable) == 0) {
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            if (completion) {
                
                completion(nil, [NSError errorWithDomain:@"" code:ContactLoadingFailError userInfo:nil]);
            }
        });
        
    } else {
        
        _contactEntityList = [[NSMutableArray alloc] init];
        
        for (CFIndex i = 0; i < CFArrayGetCount(peopleMutable); i++) {
            
            ABRecordRef contact = CFArrayGetValueAtIndex(peopleMutable, i);
            
            if (contact) {
                
                ContactEntity* contactEntity = [[ContactEntity alloc] initWithAddressBook:contact];
                [_contactEntityList addObject:contactEntity];
                NSString* recordId = [NSString stringWithFormat:@"%d",(ABRecordGetRecordID(contact))];
                
                // Get Image
                NSData* imgData = CFBridgingRelease((__bridge CFTypeRef)((__bridge NSData *)ABPersonCopyImageData(contact)));
                
                if (imgData) {

                    UIImage* image = [UIImage imageWithData:imgData];
                    [[ContactCache sharedInstance] setImageForKey:image forKey: recordId];
                }
            }
            
        }
        
        CFRelease(peopleMutable);
        
        // Run on main Thread
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            if (completion) {
                
                completion(_contactEntityList, nil);
            }
        });
    }
    
}

@end
