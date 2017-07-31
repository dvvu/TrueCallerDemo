//
//  TrueCallerDemoTabbarViewController.m
//  TrueCallerDemo
//
//  Created by Doan Van Vu on 7/27/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "TrueCallerDemoTabbarViewController.h"
#import "ContactsViewController.h"
#import "ContactEntity.h"
#import "ContactBook.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "GlobalVars.h"

@interface TrueCallerDemoTabbarViewController () <UITabBarControllerDelegate>

@property (nonatomic) BOOL isUpdateViewContoller;
@property (nonatomic, strong) UIView* backgroundView;
@property (nonatomic, strong) ContactBook* contactBook;
@property (nonatomic, strong) ContactsViewController* contactsViewController;
@end

@implementation TrueCallerDemoTabbarViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.delegate = self;
    
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - self.tabBar.frame.size.height)];
    [_backgroundView setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:_backgroundView];

    CNAuthorizationStatus cNAuthorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    
    if (cNAuthorizationStatus == CNAuthorizationStatusAuthorized) {
        
        _contactBook = [ContactBook sharedInstance];
        [self getContactBook];
    } else {
        
        _contactBook = [ContactBook sharedInstance];
        UIButton* checkPermissionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [checkPermissionButton setTitle:@"Allow access to contacts" forState:UIControlStateNormal];
        [checkPermissionButton setBackgroundColor:[UIColor blueColor]];
        [checkPermissionButton addTarget:self action:@selector(accessContacts:) forControlEvents:UIControlEventTouchUpInside];
        checkPermissionButton.frame = CGRectMake(20, _backgroundView.frame.size.height - 100, _backgroundView.frame.size.width - 40, 50);
        [_backgroundView addSubview:checkPermissionButton];
    }
}

- (IBAction)accessContacts:(id)sender {

    [self getContactBook];
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
                    
                    GlobalVars* globalVars = [GlobalVars sharedInstance];
                    globalVars.contactEntityList = [NSArray arrayWithArray:contactEntityList];
                    [_backgroundView setHidden:YES];
                }
            }];
        }
    }];
}

#pragma mark - tabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
  
    NSLog(@"controller class: %@", NSStringFromClass([viewController class]));
    NSLog(@"controller title: %@", viewController.title);
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController* contactViewController = (UINavigationController *)viewController;
        [contactViewController.viewControllers[0] viewDidLoad];
    }
}

@end
