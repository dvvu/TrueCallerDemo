//
//  TrueCallerDemoTabbarViewController.m
//  TrueCallerDemo
//
//  Created by Doan Van Vu on 7/27/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "TrueCallerDemoTabbarViewController.h"
#import "ContactListViewController.h"
#import "PhoneViewController.h"
#import "ContactEntity.h"
#import "ContactBook.h"
#import "Constants.h"
#import "TabbarDelegate.h"

@interface TrueCallerDemoTabbarViewController () <UITabBarControllerDelegate, UIAlertViewDelegate, TabbarDelegate>

@property (nonatomic, strong) ContactBook* contactBook;
@property (nonatomic, strong) UIView* backgroundView;
@property (nonatomic) BOOL isUpdateViewContoller;

@end

@implementation TrueCallerDemoTabbarViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.delegate = self;
    
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - self.tabBar.frame.size.height)];
    [_backgroundView setBackgroundColor:[UIColor lightGrayColor]];
    _contactBook = [ContactBook sharedInstance];
    [self.view addSubview:_backgroundView];
    
    if (iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(9.0)) {
        
        CNAuthorizationStatus cNAuthorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (cNAuthorizationStatus == CNAuthorizationStatusAuthorized) {
            
            [self getContactsBook];
        } else {
            
            [self setupCheckPermissionButton];
        }
    } else {
        
        ABAuthorizationStatus authorizationStatus =  ABAddressBookGetAuthorizationStatus();
        if (authorizationStatus == kABAuthorizationStatusAuthorized) {
        
            [self getContactsBook];
        } else {
            
            [self setupCheckPermissionButton];
        }
    }
}

#pragma mark - checkPermissionButton

- (void)setupCheckPermissionButton {
    
    UIGraphicsBeginImageContext(_backgroundView.frame.size);
    [[UIImage imageNamed:@"background"] drawInRect:_backgroundView.bounds];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _backgroundView.backgroundColor = [UIColor colorWithPatternImage:image];
    
    UIButton* checkPermissionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [checkPermissionButton setTitle:@"Allow access to contacts" forState:UIControlStateNormal];
    [checkPermissionButton setBackgroundColor:[UIColor blueColor]];
    [checkPermissionButton addTarget:self action:@selector(accessContacts:) forControlEvents:UIControlEventTouchUpInside];
    checkPermissionButton.frame = CGRectMake(20, _backgroundView.frame.size.height - 100, _backgroundView.frame.size.width - 40, 50);
    [_backgroundView addSubview:checkPermissionButton];
}

- (IBAction)accessContacts:(id)sender {

    [self checkPermisstion];
}

#pragma mark - checkPermission

- (void)checkPermisstion {
    
    [_contactBook getPermissionContacts:^(NSError* error) {
        
        if((error.code == ContactAuthorizationStatusDenied) || (error.code == ContactAuthorizationStatusRestricted)) {
            
            [[[UIAlertView alloc] initWithTitle:@"This app requires access to your contacts to function properly." message: @"Please! Go to setting!" delegate:self cancelButtonTitle:@"CLOSE" otherButtonTitles:@"GO TO SETTING", nil] show];
        } else {
            
            [self getContactsBook];
        }
    }];
}

#pragma mark - get ContactsBook

- (void)getContactsBook {
    
    [_contactBook getContacts:^(NSMutableArray* contactEntityList, NSError* error) {
        
        if(error.code == ContactLoadingFailError) {
            
            [[[UIAlertView alloc] initWithTitle:@"This Contact is empty." message: @"Please! Check your contacts and try again!" delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles: nil, nil] show];
        } else {
            
            [_backgroundView setHidden:YES];
            
            // if Exiting Data-> reload ViewController if need  
            for (UIViewController* viewController in self.viewControllers) {
                
                if ([viewController isKindOfClass:[UINavigationController class]]) {
                    
                    // ContactListViewController
                    UINavigationController* navContactViewController = (UINavigationController *)viewController;
                    
                    if ([navContactViewController.viewControllers[0] isKindOfClass:[ContactListViewController class]]) {
                        
                        ContactListViewController* contactListViewController = (ContactListViewController *)navContactViewController.viewControllers[0];
                        [contactListViewController prepareData:contactEntityList];
                    }
                } else {
                    
                    if ([viewController isKindOfClass:[PhoneViewController class]]) {
                        
                        // PhoneViewController
                        PhoneViewController* phoneViewController = (PhoneViewController *)viewController;
                        phoneViewController.delegate = self;
                        [phoneViewController prepareData:contactEntityList];;
                    }
                }
            }
        }
    }];
}

#pragma mark - tabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
  
    NSLog(@"%@", viewController.title);
}

#pragma mark - updateViewDelegate

-  (void)reloadViewControllerDelegate:(BOOL)isUpdateTabelView {
    
    [self getContactsBook];
}

#pragma mark - alertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        // goto setting screen
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
