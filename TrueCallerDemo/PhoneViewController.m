//
//  PhoneViewController.m
//  TrueCallerDemo
//
//  Created by Doan Van Vu on 7/25/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "PhoneViewController.h"
#import "ContactTableViewCell.h"
#import "ContactCellObject.h"
#import "ContactEntity.h"
#import "ContactCache.h"
#import "NimbusModels.h"
#import "NimbusCore.h"
#import "ContactBook.h"
#import "Constants.h"

#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

@interface PhoneViewController () <NITableViewModelDelegate, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, CNContactViewControllerDelegate>

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* keyboardHeaderView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* keyboardViewHeight;
@property (nonatomic, weak) IBOutlet UILabel* phoneLabel;
@property (nonatomic, weak) IBOutlet UIView* keyBoardView;
@property (nonatomic, weak) IBOutlet UIView* backgroundView;
@property (nonatomic, weak) IBOutlet UIButton* showKeyboardButton;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic) float keyboardHeaderHeight;
@property (nonatomic) NSArray* symbolsArray;

@property (nonatomic, strong) NSArray<ContactEntity*>* contactEntityList;
@property (nonatomic, strong) NSArray<ContactEntity*>* searchContactList;
@property (nonatomic) dispatch_queue_t resultSearchContactQueue;
@property (nonatomic, strong) NITableViewModel* model;
@property (nonatomic, strong) ContactBook* contactBook;
@property (nonatomic) UILabel* tableHeaderLabel;
@property (nonatomic) UIView* headerView;

@end

@implementation PhoneViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self prepareUI];
    [self showContactBook];
    [self showHideKeyBoardheaderView:_phoneLabel.text];
}

#pragma mark - showContactBook

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

#pragma mark - setupView

- (void)prepareUI {
    
    // setup keyboard height
    _keyboardHeaderHeight = KEYBOARD_HEADER_HEIGHT;
    _keyboardViewHeight.constant = self.view.frame.size.height * 0.5 - _keyboardHeaderHeight;
    _symbolsArray = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"*", @"#", nil];
    
    // setup headerView
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 25)];
    _headerView.layer.shadowColor = [UIColor blackColor].CGColor;
    [_headerView setBackgroundColor:[UIColor whiteColor]];
    _headerView.layer.masksToBounds = NO;
    _headerView.layer.shadowOffset = CGSizeMake(0, 0.1);
    _headerView.layer.shadowOpacity = 0.1;
    _tableHeaderLabel = [[UILabel alloc] init];
    _tableHeaderLabel.frame = CGRectMake(8, 0, DEVICE_WIDTH - 41, 25);
    [_headerView addSubview:_tableHeaderLabel];
    
    // setup clearButton
    UIButton* clearPhoneNumberButton = [UIButton buttonWithType:UIButtonTypeCustom];
    clearPhoneNumberButton.frame = CGRectMake(DEVICE_WIDTH - 33, 0, 25, 25);
    [clearPhoneNumberButton setImage:[UIImage imageNamed:@"ic_clearText"] forState:UIControlStateNormal];
    [clearPhoneNumberButton addTarget:self action:@selector(clearHeader:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:clearPhoneNumberButton];
    _tableView.tableHeaderView = _headerView;
    
    // setup tableView
    _contactBook = [ContactBook sharedInstance];
    [_tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:@"ContactTableViewCell"];
    _resultSearchContactQueue = dispatch_queue_create("RESULT_SEARCH_CONTACT_QUEUE", DISPATCH_QUEUE_SERIAL);
    
    _tableView.delegate = self;
}

#pragma mark - setupView

- (void)setupTableView {
    
    dispatch_async(_resultSearchContactQueue, ^ {
        
        [_tableView setHidden:NO];
        NSMutableArray* objects = [NSMutableArray array];
        
        for (ContactEntity* contactEntity in _searchContactList) {
            
            ContactCellObject* cellObject = [[ContactCellObject alloc] init];
            cellObject.contactTitle = contactEntity.name;
            cellObject.identifier = contactEntity.identifier;
            cellObject.phoneNumber = contactEntity.phone;
            cellObject.contactImage = contactEntity.profileImageDefault;
            [objects addObject:cellObject];
        }
        
        // add search celloOject
        ContactCellObject* cellObject = [[ContactCellObject alloc] init];
        cellObject.contactTitle = @"Tim kiem trong Truecaller";
        cellObject.contactImage = [UIImage imageNamed:@"search"];
        [objects addObject:cellObject];
        
        _model = [[NITableViewModel alloc] initWithListArray:objects delegate:self];
        _tableView.dataSource = _model;
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [_tableView reloadData];
        });
    });
}

#pragma mark - selected

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _searchContactList.count) {
        
        // search into directory Cell
        
    } else {
        
        // action click to call contact cell.
        ContactCellObject* cellObject = [_model objectAtIndexPath:indexPath];
        NSLog(@"%@", cellObject.phoneNumber);
        
        NSString* phoneNumber = [cellObject.phoneNumber objectAtIndex:0];
        
        if (phoneNumber) {
            
            [[[UIAlertView alloc] initWithTitle:@"Do you want to call?" message: phoneNumber delegate:self cancelButtonTitle:@"Call" otherButtonTitles:@"Close", nil] show];
        }
    }
    
    [UIView animateWithDuration:0.2 animations: ^ {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
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

#pragma mark - height for cell

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = tableView.rowHeight;
    id object = [_model objectAtIndexPath:indexPath];
    id class = [object cellClass];
    
    if ([class respondsToSelector:@selector(heightForObject:atIndexPath:tableView:)]) {
        
        height = [class heightForObject:object atIndexPath:indexPath tableView:tableView];
    }
    
    return height;
}

#pragma mark - searchText

- (void)searchText:(NSString *)searchText {
    
    if (searchText.length > 0) {
        
        NSMutableArray* mutableArray = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < _contactEntityList.count; i++) {

            NSArray* phone = [_contactEntityList objectAtIndex:i].phone;
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchText];
            
            if ([phone filteredArrayUsingPredicate:predicate].count > 0) {
                
                [mutableArray addObject:[_contactEntityList objectAtIndex:i]];
            }
        }
        
        _searchContactList = mutableArray;
        [self setupTableView];
    }
}

#pragma mark - scroll

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
    [self hideKeyboard];
}

#pragma mark - clear header

- (IBAction)clearHeader:(id)sender {
    
    _phoneLabel.text = @"";
    [self showHideKeyBoardheaderView:_phoneLabel.text];
}

#pragma mark - add contact

- (IBAction)addContact:(id)sender {
    
    CNMutableContact* contact = [[CNMutableContact alloc] init];
    CNLabeledValue* homePhone = [CNLabeledValue labeledValueWithLabel:CNLabelHome value:[CNPhoneNumber phoneNumberWithStringValue:_phoneLabel.text]];
    contact.phoneNumbers = @[homePhone];
    
    CNContactViewController* contactViewController = [CNContactViewController viewControllerForNewContact:contact];
    contactViewController.delegate = self;
    UINavigationController* navContactViewController = [[UINavigationController alloc] initWithRootViewController:contactViewController];
    contactViewController.title = @"Add Contact";
    [self presentViewController:navContactViewController animated:NO completion:nil];
}

- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    _contactBook = [ContactBook sharedInstance];
    [self showContactBook];
    [self setupTableView];
}

#pragma mark - call

- (IBAction)call:(id)sender {
    
    if ([_phoneLabel.text length] > 0) {
        
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:_phoneLabel.text]]];
    }
}

#pragma mark - alertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
   
    if (buttonIndex == 0) {
        
        NSString* phoneNumber = [alertView.message stringByReplacingOccurrencesOfString:@" " withString:@""];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:phoneNumber]]];
    }
}

#pragma mark - click into phone letter

- (IBAction)typeNumberOrSymbol:(UIButton *)sender {
    
    _phoneLabel.text = [_phoneLabel.text stringByAppendingString:[_symbolsArray objectAtIndex:sender.tag]];
    [self showHideKeyBoardheaderView:_phoneLabel.text];
    [self searchText:_phoneLabel.text];
}

#pragma mark - go back phoneNumber

- (IBAction)back:(id)sender {
    
    NSUInteger currentLength = [_phoneLabel.text length];
    
    if (currentLength > 0) {
        
        NSRange range = NSMakeRange(0, currentLength - 1);
        _phoneLabel.text = [_phoneLabel.text substringWithRange:range];
    }
    
    [self showHideKeyBoardheaderView:_phoneLabel.text];
    [self searchText:_phoneLabel.text];
}

#pragma mark - hide/show KeyBoard

- (void)showHideKeyBoardheaderView:(NSString *)text {
    
    if ([text isEqualToString:@""]) {
        
        // hide keyboardheaderView
        _keyboardHeaderView.constant = 0;
        
        if(_showKeyboardButton.isHidden) {
            
            _keyboardViewHeight.constant = self.view.frame.size.height * 0.5 - _keyboardHeaderHeight;
        }
        
        [_tableView setHidden:YES];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            [self.view layoutIfNeeded];
        }];
    } else {
        
        // show keyboardheaderView
        _keyboardHeaderView.constant = _keyboardHeaderHeight;
        _keyboardViewHeight.constant = self.view.frame.size.height * 0.5;
        [_tableView setHidden:NO];
        _tableHeaderLabel.text = [[@"Ket qua tim kiem cho '" stringByAppendingString:text] stringByAppendingString:@"'"];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - show KeyBoard

- (IBAction)showKeyboard:(id)sender {
    
    // hide keyboard
    if ([_phoneLabel.text length] > 0) {
        
        _keyboardViewHeight.constant = self.view.frame.size.height * 0.5;
    } else {
        
        _keyboardViewHeight.constant = self.view.frame.size.height *0.5 - _keyboardHeaderHeight;
    }
    
    [_showKeyboardButton setHidden:YES];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - hide KeyBoard

- (IBAction)hideKeyboard:(id)sender {
    
    [self hideKeyboard];
}

#pragma mark - hide KeyBoard

- (void)hideKeyboard {
    
    // hide keyboard
    _keyboardViewHeight.constant = 0;
    [_showKeyboardButton setHidden:NO];
    
    [UIView animateWithDuration:0.3f animations:^ {
        
        [self.view layoutIfNeeded];
    }];
}

@end
