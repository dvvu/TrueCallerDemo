//
//  FriendsTableViewController.m
//  NimbusExample
//
//  Created by Doan Van Vu on 7/15/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "FriendContactCellObject.h"
#import "NimbusModels.h"
#import "ContactBook.h"
#import "NimbusCore.h"
#import "ContactEntity.h"
#import "Constants.h"

@interface FriendsTableViewController ()

@property (nonatomic) dispatch_queue_t contactQueue;
@property (nonatomic, strong) ContactBook* contactBook;
@property (nonatomic, strong) NSArray<ContactEntity*>* contactEntityList;
@property (nonatomic, strong) NIMutableTableViewModel* model;
@property (nonatomic, strong) UISearchController* searchController;

@end

@implementation FriendsTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        
        self.title = @"Friend";
        _contactQueue = dispatch_queue_create("SHOWER_CONTACT_QUEUE", DISPATCH_QUEUE_SERIAL);
        [self setupTableMode];
        [self getContactBook];
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

#pragma mark - config TableMode

- (void)setupTableMode {
    
    _model = [[NIMutableTableViewModel alloc] initWithDelegate:(id)[NICellFactory class]];
    [_model setSectionIndexType:NITableViewModelSectionIndexDynamic showsSearch:NO showsSummary:NO];
    
    self.tableView.dataSource = _model;
}


#pragma mark - GetList Contact and add to models

- (void)getContactBook {
    
    dispatch_async(_contactQueue, ^ {
        
        for (int i = 0; i < 100; i++) {
            
            FriendContactCellObject* cellObject = [[FriendContactCellObject alloc] init];
            cellObject.contactTitle = @"title item";
            cellObject.contactImage = [UIImage imageNamed:@"b"];
            [_model addObject:cellObject];
        }
        [_model updateSectionIndex];
        
        // Run on main Thread
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [self.tableView reloadData];
        });
    });
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

@end
