//
//  CallViewController.m
//  TrueCallerDemo
//
//  Created by Doan Van Vu on 7/25/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ResultTableViewController.h"
#import "ContactCellObject.h"
#import "ContactTableViewCell.h"
#import "CallViewController.h"
#import "ContactCache.h"
#import "NimbusModels.h"
#import "NimbusCore.h"
#import "ContactBook.h"
#import "Constants.h"


@interface CallViewController () <UISearchResultsUpdating, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIView* searBarView;
@property (weak, nonatomic) IBOutlet UIButton* showKeyboardButton;

@property (nonatomic, strong) NITableViewModel* model;
@property (nonatomic) UITapGestureRecognizer* tapRecognizer;

@property (nonatomic, strong) ContactBook* contactBook;
@property (nonatomic, strong) UIButton* checkPermissionButton;

@property (nonatomic, strong) NSArray<ContactEntity*>* contactEntityList;

@property (nonatomic) dispatch_queue_t resultSearchContactQueue;
@property (nonatomic) float keyboardHeight;

@property (nonatomic, strong) ResultTableViewController* searchResultTableViewController;
@property (nonatomic, strong) UISearchController* searchController;

@end

@implementation CallViewController

- (void)viewDidLoad {
   
    [super viewDidLoad];

    _contactBook = [ContactBook sharedInstance];
    _resultSearchContactQueue = dispatch_queue_create("RESULT_SEARCH_CONTACT_QUEUE", DISPATCH_QUEUE_SERIAL);
    
    switch ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts]) {
            
        case CNAuthorizationStatusNotDetermined: {
            
            _checkPermissionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            _checkPermissionButton.frame = CGRectMake(20, self.view.frame.size.height/2, 100, 25);
            [_checkPermissionButton setTitle:@"Allow access to contacts" forState:UIControlStateNormal];
            [_checkPermissionButton addTarget:self action:@selector(accessContacts:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_checkPermissionButton];
        }
            break;
            
        default:
            
            [self showContactBook];
            break;
    }
    [self createSearchController];
}

- (IBAction)accessContacts:(id)sender {
    
    [self showContactBook];
}

- (void)showContactBook {
    
    [_contactBook getPermissionContacts:^(NSError* error) {
        
        if((error.code == ContactAuthorizationStatusDenied) || (error.code == ContactAuthorizationStatusRestricted)) {
            
            [[[UIAlertView alloc] initWithTitle:@"This app requires access to your contacts to function properly." message: @"Please! Go to setting!" delegate:self cancelButtonTitle:@"CLOSE" otherButtonTitles:@"GO TO SETTING", nil] show];
        } else {
            
            [_contactBook getContacts:^(NSMutableArray* contactEntityList, NSError* error) {
                if(error.code == ContactLoadingFailError) {
                    
                    [[[UIAlertView alloc] initWithTitle:@"This Contact is empty." message: @"Please! Check your contacts and try again!" delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles: nil, nil] show];
                } else {
                    
                    _contactEntityList = [NSArray arrayWithArray:contactEntityList];
                }
            }];
        }
    }];
}

- (void)createSearchController {
    
    _searchResultTableViewController = [[ResultTableViewController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:_searchResultTableViewController];
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.searchBarStyle = UISearchBarStyleDefault;
    _searchController.dimsBackgroundDuringPresentation = NO;
    [_searchController.searchBar sizeToFit];
    _searchController.searchBar.showsCancelButton = NO;
    _searchController.searchBar.delegate = self;
    [_searBarView addSubview:_searchController.searchBar];
    
    UITextField* searchTextField = [((UITextField *)[_searchController.searchBar.subviews objectAtIndex:0]).subviews lastObject];
    searchTextField.layer.cornerRadius = 15.0f;
    searchTextField.textAlignment = NSTextAlignmentLeft;
    searchTextField.leftView = nil;
    searchTextField.placeholder = @"";
    searchTextField.rightViewMode = UITextFieldViewModeAlways;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    _keyboardHeight = -keyboardSize.height;
    [self moveFrameToVerticalPosition:_keyboardHeight/2 forDuration:0.3f];
//    [_showKeyboardButton setHidden:YES];
    [self.view layoutIfNeeded];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    [self moveFrameToVerticalPosition:0.0f forDuration:0.3f];
    [_showKeyboardButton setHidden:NO];
}

- (void)moveFrameToVerticalPosition:(float)position forDuration:(float)duration {
    
    CGRect frame = self.view.frame;
    frame.origin.y = position;
    
    [UIView animateWithDuration:duration animations:^{
        
        self.view.frame = frame;
    }];
}

- (IBAction)showKeyboard:(id)sender {
    
    [_searchController.searchBar becomeFirstResponder];
}

#pragma mark - updateSearchResultViewController

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString* searchString = searchController.searchBar.text;
    searchController.searchBar.showsCancelButton = NO;
    
    if (searchString.length > 0) {
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchString];
        _searchResultTableViewController.listContactBook = [_contactEntityList filteredArrayUsingPredicate:predicate];
        [_searchResultTableViewController viewWillAppear:true];
    }
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
      
        self.searchController.searchBar.showsCancelButton = NO;
    });
}

@end
