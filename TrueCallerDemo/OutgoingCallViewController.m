//
//  OutgoingCallViewController.m
//  CallKitDemo
//
//  Created by Doan Van Vu on 7/19/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "OutgoingCallViewController.h"
#import "CallViewController.h"


@interface OutgoingCallViewController ()

@property (weak, nonatomic) IBOutlet UIButton* dialButton;
@property (weak, nonatomic) IBOutlet UITextField* phoneNumberTextField;

@end

@implementation OutgoingCallViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"Dial Call";
}

#pragma mark - Actions

- (IBAction)phoneNumberValueChanged:(UITextField *)sender {
    
    NSString* phoneNumber = [sender.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _dialButton.enabled = (phoneNumber.length);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if ([[segue identifier] isEqualToString:@"ShowDial"]) {
        
        CallViewController* callViewController = [segue destinationViewController];
        callViewController.phoneNumber = _phoneNumberTextField.text;
    }
}

@end
