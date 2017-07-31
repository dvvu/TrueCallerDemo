//
//  ContactsViewController.m
//  NimbusExample
//
//  Created by Doan Van Vu on 6/20/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ResultTableViewController.h"
#import "ContactsViewController.h"
#import "ContactCellObject.h"
#import "ContactTableViewCell.h"
#import "NimbusModels.h"
#import "ContactBook.h"
#import "NimbusCore.h"
#import "Constants.h"
#import "ContactCache.h"
#import "GlobalVars.h"

@interface ContactsViewController () <NITableViewModelDelegate, UISearchResultsUpdating, ABPersonViewControllerDelegate>

@property (nonatomic, strong) ResultTableViewController* searchResultTableViewController;
@property (nonatomic, strong) UISearchController* searchController;
@property (nonatomic, strong) UIButton* checkPermissionButton;
@property (nonatomic, strong) NIMutableTableViewModel* model;
@property (nonatomic) dispatch_queue_t contactQueue;
@property (nonatomic) GlobalVars* globalVars;

@end

@implementation ContactsViewController

#pragma mark - singleton

+ (instancetype)sharedInstance {
    
    static ContactsViewController* sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^ {
        
        sharedInstance = [[ContactsViewController alloc] init];
    });
    
    return sharedInstance;
}

- (void)viewDidLoad {
   
    [super viewDidLoad];
    _globalVars =  [GlobalVars sharedInstance];
    self.title = @"Contacts";
}

- (void)prepareData {
    
    [self setupTableMode];
    [self setupData];
}

#pragma mark - config TableMode

- (void)setupTableMode {
    
    _model = [[NIMutableTableViewModel alloc] initWithDelegate:self];
    [_model setSectionIndexType:NITableViewModelSectionIndexDynamic showsSearch:NO showsSummary:NO];
    _contactQueue = dispatch_queue_create("SHOW_CONTACT_QUEUE", DISPATCH_QUEUE_SERIAL);
    [self.tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:@"ContactTableViewCell"];
    [self createSearchController];
}

#pragma mark - Create searchBar

- (void)createSearchController {
    
    _searchResultTableViewController = [[ResultTableViewController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:_searchResultTableViewController];
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchController.dimsBackgroundDuringPresentation = YES;
    [_searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = _searchController.searchBar;
}

#pragma mark - GetList Contact and add to models

- (void)setupData {
    
    dispatch_async(_contactQueue, ^ {
        
        int contacts = (int)_globalVars.contactEntityList.count;
        NSString* groupNameContact = @"";

        // Run on background to get name group
        for (int i = 0; i < contacts; i++) {
            
            NSString* name = [_globalVars.contactEntityList[i].name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString* firstChar = @"";
            
            if ([name length] > 0) {
                
                firstChar = [name substringToIndex:1];
            }
            
            if ([groupNameContact.uppercaseString rangeOfString:firstChar.uppercaseString].location == NSNotFound) {
                
                groupNameContact = [groupNameContact stringByAppendingString:firstChar];
            }
        }
        
        int characterGroupNameCount = (int)[groupNameContact length];
        
        // Run on background to get object
        for (int i = 0; i < contacts; i++) {
            
            if (i < characterGroupNameCount) {
 
                [_model addSectionWithTitle:[groupNameContact substringWithRange:NSMakeRange(i,1)]];
            }
            
            ContactEntity* contactEntity = _globalVars.contactEntityList[i];
            NSString* name = [_globalVars.contactEntityList[i].name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString* firstChar = @"";
            
            if ([name length] > 0) {
                
                firstChar = [name substringToIndex:1];
            }
        
            NSRange range = [groupNameContact rangeOfString:firstChar];
        
            if (range.location != NSNotFound) {
                
                ContactCellObject* cellObject = [[ContactCellObject alloc] init];
                cellObject.contactTitle = contactEntity.name;
                cellObject.phoneNumber = contactEntity.phone;
                cellObject.identifier = contactEntity.identifier;
                cellObject.contactImage = contactEntity.profileImageDefault;
                [_model addObject:cellObject toSection:range.location];
            }
        }
        
        [_model updateSectionIndex];
        self.tableView.dataSource = _model;
        
        // Run on main Thread
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [self.tableView reloadData];
        });
    });
}

#pragma mark - updateSearchResultViewController

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString* searchString = searchController.searchBar.text;
    
    if (searchString.length > 0) {

        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchString];
        _searchResultTableViewController.listContactBook = [_globalVars.contactEntityList filteredArrayUsingPredicate:predicate];
        [_searchResultTableViewController viewWillAppear:true];
    }
    
    if (!searchController.active) {
        
        // click Cancel button.
        NSLog(@"%f", self.tableView.frame.size.width);
        [self.view layoutIfNeeded];
    }
}


#pragma mark - selected

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    ContactCellObject* cellObject = [_model objectAtIndexPath:indexPath];
    NSLog(@"%@", cellObject.contactTitle);
    
    [UIView animateWithDuration:0.2 animations: ^ {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    // Fetch the address book
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef people = ABAddressBookCopyPeopleWithName(addressBook, (__bridge CFStringRef)cellObject.contactTitle);
    
    if ((people != nil) && (CFArrayGetCount(people) > 0)) {
        
        ABRecordRef person = CFArrayGetValueAtIndex(people, 0);
        ABPersonViewController* picker = [[ABPersonViewController alloc] init];
        picker.personViewDelegate = self;
        picker.displayedPerson = person;
        
        // Allow users to edit the person’s information
        picker.allowsEditing = YES;
        
        [self.navigationController pushViewController:picker animated:YES];
    }
}

#pragma mark - ABPersonview delegate

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    return TRUE;
}

#pragma mark - heigh for cell

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    CGFloat height = tableView.rowHeight;
    id object = [_model objectAtIndexPath:indexPath];
    id class = [object cellClass];
    
    if ([class respondsToSelector:@selector(heightForObject:atIndexPath:tableView:)]) {
        
        height = [class heightForObject:object atIndexPath:indexPath tableView:tableView];
    }
    
    return height;
}

#pragma mark - Nimbus tableViewDelegate

- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    
    ContactTableViewCell* contactTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"ContactTableViewCell" forIndexPath:indexPath];
   
    if (contactTableViewCell.model != object) {
    
        ContactCellObject* cellObject = (ContactCellObject *)object;
        contactTableViewCell.identifier = cellObject.identifier;
        contactTableViewCell.model = object;
        [cellObject getImageCacheForCell:contactTableViewCell];
    
        [contactTableViewCell shouldUpdateCellWithObject:object];
    }
  
    return contactTableViewCell;
}

@end

