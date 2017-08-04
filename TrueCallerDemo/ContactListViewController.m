//
//  ContactListViewController.m
//  TrueCallerDemo
//
//  Created by Doan Van Vu on 8/1/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ContactListViewController.h"
#import "ResultTableViewController.h"
#import "ContactCellObject.h"
#import "ContactTableViewCell.h"
#import "NimbusModels.h"
#import "ContactBook.h"
#import "NimbusCore.h"
#import "Constants.h"
#import "ContactCache.h"
#import "Masonry.h"

@interface ContactListViewController () <NITableViewModelDelegate, UISearchResultsUpdating, UITableViewDelegate, ABPersonViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UIView* searchBarView;

@property (nonatomic, strong) ResultTableViewController* searchResultTableViewController;
@property (nonatomic, strong) NSArray<ContactEntity*>* contactEntityList;
@property (nonatomic, strong) UISearchController* searchController;
@property (nonatomic, strong) NIMutableTableViewModel* model;
@property (nonatomic) dispatch_queue_t contactQueue;

@end

@implementation ContactListViewController 

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Contacts";
    [self setupTableMode];
    [self setupData];
}

- (void)prepareData:(NSArray<ContactEntity*>*)contactEntityList {
    
    _contactEntityList = contactEntityList;
    
    [self setupTableMode];
    [self setupData];
}

#pragma mark - config TableMode

- (void)setupTableMode {
    
    _contactQueue = dispatch_queue_create("CONTACT_QUEUE", DISPATCH_QUEUE_SERIAL);
    [_tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:@"ContactTableViewCell"];
    _tableView.delegate = self;
    
    _model = [[NIMutableTableViewModel alloc] initWithDelegate:self];
    [_model setSectionIndexType:NITableViewModelSectionIndexDynamic showsSearch:NO showsSummary:NO];
}

#pragma mark - Create searchBar

- (void)createSearchController {
   
    _searchResultTableViewController = [[ResultTableViewController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:_searchResultTableViewController];
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchController.dimsBackgroundDuringPresentation = YES;
    [_searchController.searchBar sizeToFit];
    [_searchBarView addSubview:_searchController.searchBar];
    self.definesPresentationContext = YES;
}

#pragma mark - GetList Contact and add to models

- (void)setupData {
    
    int contacts = (int)_contactEntityList.count;
    
    if (contacts > 0) {
        
        dispatch_async(_contactQueue, ^ {
            
            NSString* groupNameContact = @"";
            
            // Run on background to get name group
            for (int i = 0; i < contacts; i++) {
                
                NSString* name = [_contactEntityList[i].name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
                    
                    [_model addSectionWithTitle:[groupNameContact substringWithRange:NSMakeRange(i,1)].uppercaseString];
                }
                
                ContactEntity* contactEntity = _contactEntityList[i];
                NSString* name = [_contactEntityList[i].name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString* firstChar = @"";
                
                if ([name length] > 0) {
                    
                    firstChar = [name substringToIndex:1];
                }
                
                NSRange range = [groupNameContact rangeOfString:firstChar];
                
                if (range.location != NSNotFound) {
                    
                    ContactCellObject* cellObject = [[ContactCellObject alloc] init];
                    cellObject.contactTitle = contactEntity.name;
                    cellObject.identifier = contactEntity.identifier;
                    cellObject.contactImage = contactEntity.profileImageDefault;
                    [_model addObject:cellObject toSection:range.location];
                }
            }
        
            [_model updateSectionIndex];
            _tableView.dataSource = _model;
            
            // Run on main Thread
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                [_tableView reloadData];
                [self createSearchController];
            });
        });
        
    }
}

#pragma mark - updateSearchResultViewController

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString* searchString = searchController.searchBar.text;
    
    if (searchString.length > 0) {
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchString];
        
        NSArray<ContactEntity*>* contactEntityList = [_contactEntityList filteredArrayUsingPredicate:predicate];
        
        if (contactEntityList) {
            
            [_searchResultTableViewController repareData:contactEntityList];
        }
    }
}

#pragma mark - selected

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactCellObject* cellObject = [_model objectAtIndexPath:indexPath];
    NSLog(@"%@", cellObject.contactTitle);
    
    [UIView animateWithDuration:0.2 animations: ^ {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    // Only test -> replace contact Detai later.
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef people = ABAddressBookCopyPeopleWithName(addressBook, (__bridge CFStringRef)cellObject.contactTitle);
    
    if ((people != nil) && (CFArrayGetCount(people) > 0)) {
        
        ABRecordRef person = CFArrayGetValueAtIndex(people, 0);
        ABPersonViewController* personViewController = [[ABPersonViewController alloc] init];
        
        personViewController.addressBook = addressBook;
        personViewController.personViewDelegate = self;
        personViewController.displayedPerson = person;
        personViewController.allowsEditing = YES;
        
        [self.navigationController pushViewController:personViewController animated:YES];
    }
    
    CFRelease(people);
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

#pragma mark - tableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    // Background color
    view.tintColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0];
    
    UITableViewHeaderFooterView* header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = [UIColor grayColor];
    header.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        [_searchController.searchBar sizeToFit];
    } completion:nil];
}

@end
