//
//  IncomingCallViewController.m
//  CallKitDemo
//
//  Created by Doan Van Vu on 7/19/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "IncomingCallViewController.h"
#import "CallViewController.h"

@interface IncomingCallViewController ()

@property (weak, nonatomic) IBOutlet UITextField* phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton* simulateCallButton;

@end


@implementation IncomingCallViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"Incoming Call";
}

#pragma mark - Actions

- (IBAction)phoneNumberValueChanged:(UITextField *)sender {
    
    NSString* phoneNumber = [sender.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _simulateCallButton.enabled = (phoneNumber.length);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowCall"]) {
        
        CallViewController* callViewController = [segue destinationViewController];
        callViewController.phoneNumber = _phoneNumberTextField.text;
        callViewController.isIncoming = YES;
        callViewController.uuid = [NSUUID new];
    }
}

@end
