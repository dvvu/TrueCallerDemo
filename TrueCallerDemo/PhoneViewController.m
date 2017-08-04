//
//  PhoneViewController.m
//  TrueCallerDemo
//
//  Created by Doan Van Vu on 7/25/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "PhoneViewController.h"
#import "AddressBookUI/AddressBookUI.h"
#import "AddressBook/AddressBook.h"
#import "ContactTableViewCell.h"
#import "ContactsUI/ContactsUI.h"
#import "Contacts/Contacts.h"
#import "ContactCellObject.h"
#import "ContactEntity.h"
#import "ContactCache.h"
#import "NimbusModels.h"
#import "NimbusCore.h"
#import "ContactBook.h"
#import "Constants.h"
#import "Masonry.h"

@interface PhoneViewController () <NITableViewModelDelegate, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, CNContactViewControllerDelegate, ABNewPersonViewControllerDelegate>

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* keyboardHeaderView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* keyboardViewHeight;
@property (nonatomic, weak) IBOutlet UIButton* showKeyboardButton;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UIView* backgroundView;
@property (nonatomic, weak) IBOutlet UIView* keyBoardView;
@property (nonatomic, weak) IBOutlet UILabel* phoneLabel;

@property (nonatomic, weak) IBOutlet UIButton* zeroKeyboardButton;
@property (nonatomic, weak) IBOutlet UIButton* fristKeyboardButton;
@property (nonatomic, weak) IBOutlet UIButton* secondKeyboardButton;
@property (nonatomic, weak) IBOutlet UIButton* thridKeyboardButton;
@property (nonatomic, weak) IBOutlet UIButton* fourthKeyboardButton;
@property (nonatomic, weak) IBOutlet UIButton* fifthKeyboardButton;
@property (nonatomic, weak) IBOutlet UIButton* sixthKeyboardButton;
@property (nonatomic, weak) IBOutlet UIButton* seventhKeyboardButton;
@property (nonatomic, weak) IBOutlet UIButton* eighthKeyboardButton;
@property (nonatomic, weak) IBOutlet UIButton* ninthKeyboardButton;
@property (nonatomic, weak) IBOutlet UIButton* starKeyboardButton;
@property (nonatomic, weak) IBOutlet UIButton* poundKeyboardButton;
@property (nonatomic, weak) IBOutlet UIButton* callKeyboardButton;
@property (nonatomic, weak) IBOutlet UIButton* closeKeyboardButton;

@property (nonatomic, strong) NSArray<ContactEntity*>* searchContactList;
@property (nonatomic, strong) NSArray<ContactEntity*>* contactEntityList;
@property (nonatomic) dispatch_queue_t resultSearchContactQueue;
@property (nonatomic, strong) NITableViewModel* model;
@property (nonatomic) float keyboardHeaderHeight;
@property (nonatomic) UILabel* tableHeaderLabel;
@property (nonatomic) NSArray* symbolsArray;
@property (nonatomic) UIView* headerView;

@end

@implementation PhoneViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupKeyboardButton];
}

- (void)prepareData:(NSArray<ContactEntity*>*)contactEntityList {
    
    _contactEntityList = contactEntityList;
    
    [self searchText:_phoneLabel.text];
    [self prepareUI];
    [self setupData];
}

#pragma mark - setupView

- (void)prepareUI {
    
    // setup tableView
    [_tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:@"ContactTableViewCell"];
    _resultSearchContactQueue = dispatch_queue_create("RESULT_SEARCH_CONTACT_QUEUE", DISPATCH_QUEUE_SERIAL);
    _tableView.delegate = self;
    
    // setup keyboard height
    _keyboardHeaderHeight = KEYBOARD_HEADER_HEIGHT;
    _keyboardViewHeight.constant = self.view.frame.size.height * 0.5 - _keyboardHeaderHeight;
    _symbolsArray = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"*", @"#", nil];
    
    // setup headerView
    _headerView = [UIView new];
    _headerView.layer.shadowColor = [UIColor blackColor].CGColor;
    _headerView.layer.masksToBounds = NO;
    _headerView.layer.shadowOffset = CGSizeMake(0, 0.1);
    _headerView.layer.shadowOpacity = 0.1;
    [_headerView setBackgroundColor:[UIColor whiteColor]];
    
    UIButton* clearPhoneNumberButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearPhoneNumberButton setImage:[UIImage imageNamed:@"ic_clearText"] forState:UIControlStateNormal];
    [clearPhoneNumberButton addTarget:self action:@selector(clearHeader:) forControlEvents:UIControlEventTouchUpInside];
   
    _tableHeaderLabel = [UILabel new];
    [_headerView addSubview:_tableHeaderLabel];
    [_headerView addSubview:clearPhoneNumberButton];
    _tableView.tableHeaderView = _headerView;
    
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.greaterThanOrEqualTo(_backgroundView).with.offset(0);
        make.left.equalTo(_backgroundView).with.offset(0);
        make.right.equalTo(_backgroundView).with.offset(0);
        make.height.equalTo(@25);
    }];
    
    [_tableHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.greaterThanOrEqualTo(_headerView).with.offset(0);
        make.left.equalTo(_headerView).with.offset(8);
        make.right.equalTo(clearPhoneNumberButton).offset(-12);
        make.height.equalTo(_headerView.mas_height);
    }];
    
    [clearPhoneNumberButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(_headerView);
        make.right.equalTo(_headerView).offset(-8);
        make.height.equalTo(@20);
        make.width.equalTo(@20);
    }];
}

#pragma mark - setupView

- (void)setupData {
    
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
           
            [self showHideKeyBoardheaderView:_phoneLabel.text];
            [_tableView reloadData];
        });
    });
}

#pragma mark - selected

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _searchContactList.count) {
        
        // search into directory Cell
        [[[UIAlertView alloc] initWithTitle:@"Waiting..." message: @"Searching your directory..." delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles: nil, nil] show];
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
        [self setupData];
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
    
    if (iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(9.0)) {
        
        CNMutableContact* contact = [[CNMutableContact alloc] init];
        CNLabeledValue* homePhone = [CNLabeledValue labeledValueWithLabel:CNLabelHome value:[CNPhoneNumber phoneNumberWithStringValue:_phoneLabel.text]];
        contact.phoneNumbers = @[homePhone];
        
        CNContactViewController* contactViewController = [CNContactViewController viewControllerForNewContact:contact];
        contactViewController.delegate = self;
        UINavigationController* navContactViewController = [[UINavigationController alloc] initWithRootViewController:contactViewController];
        contactViewController.title = @"Add Contact";
        [self presentViewController:navContactViewController animated:NO completion:nil];

    } else {
        
        // Creating new entry
        ABAddressBookRef addressBook = ABAddressBookCreate();
        ABRecordRef person = ABPersonCreate();
        
        // Adding phone numbers
        ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue,(__bridge CFTypeRef)(_phoneLabel.text), (CFStringRef)@"", NULL);
        ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, nil);
        CFRelease(phoneNumberMultiValue);
        
        // Adding person to the address book
        ABAddressBookAddRecord(addressBook, person, nil);
        CFRelease(addressBook);
        
        // Creating view controller for a new contact
        ABNewPersonViewController* newPersonViewController = [[ABNewPersonViewController alloc] init];
        [newPersonViewController setNewPersonViewDelegate:self];
        [newPersonViewController setDisplayedPerson:person];
        CFRelease(person);
        
        UINavigationController* navContactViewController = [[UINavigationController alloc] initWithRootViewController:newPersonViewController];
        newPersonViewController.title = @"Add Contact";
        [self presentViewController:navContactViewController animated:NO completion:nil];
    }
}

#pragma mark - addContact delegate ABAddressBook

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person {
    
    if (person) {
        
        // click done buttton
        [_delegate reloadViewControllerDelegate:YES];
    } else {
        
        // click cacel button
        [_delegate reloadViewControllerDelegate:NO];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - addContact delegate CNContact

- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact {
    
    if (contact) {
        
        // click done buttton
        [_delegate reloadViewControllerDelegate:YES];
    } else {
        
        // click cacel button
        [_delegate reloadViewControllerDelegate:NO];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
            
            _keyboardViewHeight.constant = self.view.frame.size.height * 0.55 - _keyboardHeaderHeight;
        }
        
        [_tableView setHidden:YES];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            [self.view layoutIfNeeded];
        }];
    } else {
        
        // show keyboardheaderView
        _keyboardHeaderView.constant = _keyboardHeaderHeight;
        _keyboardViewHeight.constant = self.view.frame.size.height * 0.55;
        [_tableView setHidden:NO];
        _tableHeaderLabel.text = [[@"Ket qua tim kiem cho '" stringByAppendingString:text] stringByAppendingString:@"'"];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - show KeyBoard

- (IBAction)showKeyboard:(id)sender {
    
    // show keyboard
    if ([_phoneLabel.text length] > 0) {
        
        _keyboardViewHeight.constant = self.view.frame.size.height * 0.55;
    } else {
        
        _keyboardViewHeight.constant = self.view.frame.size.height * 0.55 - _keyboardHeaderHeight;
    }
    
    [_showKeyboardButton setHidden:YES];
    
    [UIView animateWithDuration:0.3f animations:^ {
        
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

#pragma mark - setup KeyBoardButton

- (void)setupKeyboardButton {
    
    UIColor* keyboardClickColor = [UIColor colorWithRed:195/255.f green:1.f blue:191/255.f alpha:1.f];
    
    [self setTitleKeyBoardButton:_zeroKeyboardButton withMainText:@" 0" subText:@" +"];
    [self setTitleKeyBoardButton:_fristKeyboardButton withMainText:@"1" subText:@""];
    [self setTitleKeyBoardButton:_secondKeyboardButton withMainText:@"  2" subText:@" ABC"];
    [self setTitleKeyBoardButton:_thridKeyboardButton withMainText:@"3" subText:@" DEF"];
    [self setTitleKeyBoardButton:_fourthKeyboardButton withMainText:@"   4" subText:@" GHI"];
    [self setTitleKeyBoardButton:_fifthKeyboardButton withMainText:@"  5" subText:@" JKL"];
    [self setTitleKeyBoardButton:_sixthKeyboardButton withMainText:@"6" subText:@" MNO"];
    [self setTitleKeyBoardButton:_seventhKeyboardButton withMainText:@"    7" subText:@" PQRS"];
    [self setTitleKeyBoardButton:_eighthKeyboardButton withMainText:@"  8" subText:@" TUV"];
    [self setTitleKeyBoardButton:_ninthKeyboardButton withMainText:@" 9" subText:@" WXYZ"];
    [_starKeyboardButton setBackgroundImage:[self imageWithColor:keyboardClickColor] forState:UIControlStateHighlighted];
    [_poundKeyboardButton setBackgroundImage:[self imageWithColor:keyboardClickColor] forState:UIControlStateHighlighted];
    [_callKeyboardButton setBackgroundImage:[self imageWithColor:keyboardClickColor] forState:UIControlStateHighlighted];
    [_closeKeyboardButton setBackgroundImage:[self imageWithColor:keyboardClickColor] forState:UIControlStateHighlighted];
    
    _callKeyboardButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _closeKeyboardButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - set Title KeyBoardButton

- (void)setTitleKeyBoardButton:(UIButton*)button withMainText:(NSString *)mainText subText:(NSString *)subText {
    
    [button setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:195/255.f green:1.f blue:191/255.f alpha:1.f]] forState:UIControlStateHighlighted];
    NSMutableParagraphStyle* style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    
    UIFont* lineFristFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:30.0f];
    UIFont* lineSecondFont = [UIFont fontWithName:@"HelveticaNeue-Light"  size:10.0f];
   
    NSDictionary* customStringFrist = @{ NSFontAttributeName:lineFristFont,
                                         NSParagraphStyleAttributeName:style};
    
    NSDictionary* customStringSecond = @{ NSFontAttributeName:lineSecondFont,
                                          NSParagraphStyleAttributeName:style};
    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] init];
    
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:mainText attributes:customStringFrist]];
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:subText attributes:customStringSecond]];
    
    [button setAttributedTitle:attString forState:UIControlStateNormal];
    [[button titleLabel] setTextColor:[UIColor lightGrayColor]];
    [[button titleLabel] setLineBreakMode:NSLineBreakByWordWrapping];
}

#pragma mark - draw test

- (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        [self showHideKeyBoardheaderView:_phoneLabel.text];
    } completion:nil];
}

@end
