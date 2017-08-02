//
//  ResultTableViewController.m
//  NimbusExample
//
//  Created by Doan Van Vu on 6/26/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ResultTableViewController.h"
#import "ContactTableViewCell.h"
#import "ContactCellObject.h"
#import "ContactEntity.h"
#import "NimbusModels.h"
#import "ContactCache.h"
#import "ContactBook.h"
#import "NimbusCore.h"

@interface ResultTableViewController () <NITableViewModelDelegate>

@property (nonatomic) dispatch_queue_t resultSearchContactQueue;
@property (nonatomic, strong ) NITableViewModel* model;
@property (nonatomic, strong) NSArray<ContactEntity*>* listContactBook;

@end

@implementation ResultTableViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    // Dimiss keyboard when drag
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:@"ContactTableViewCell"];
}

- (void)repareData:(NSArray<ContactEntity*>*) listContactBook {
    
    _listContactBook = listContactBook;
    _resultSearchContactQueue = dispatch_queue_create("RESULT_SEARCH_CONTACT_QUEUE", DISPATCH_QUEUE_SERIAL);
    [self setupTableView];
}

#pragma mark - setupView

- (void)setupTableView {
    
    dispatch_async(_resultSearchContactQueue, ^ {
        
        if(_listContactBook) {
            
            NSMutableArray* objects = [NSMutableArray array];
            
            for (ContactEntity* contactEntity in _listContactBook) {
                
                ContactCellObject* cellObject = [[ContactCellObject alloc] init];
                cellObject.contactTitle = contactEntity.name;
                cellObject.identifier = contactEntity.identifier;
                cellObject.phoneNumber = contactEntity.phone;
                cellObject.contactImage = contactEntity.profileImageDefault;
                [objects addObject:cellObject];
            }
            
            _model = [[NITableViewModel alloc] initWithListArray:objects delegate:self];
            self.tableView.dataSource = _model;
            
            dispatch_async(dispatch_get_main_queue(), ^ {
            
                [self.tableView reloadData];
            });
        }
    });
}

#pragma mark - selected

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactCellObject* cellObject = [_model objectAtIndexPath:indexPath];
    NSLog(@"%@", cellObject.contactTitle);
    
    [UIView animateWithDuration:0.2 animations: ^ {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
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
