//
//  ChatLoginViewController.h
//  chatter
//
//  Created by mattneary on 6/14/13.
//  Copyright (c) 2013 mattneary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import "ChatMasterViewController.h"

@interface ChatLoginViewController : UIViewController {
    IBOutlet UISegmentedControl *accountView;
    IBOutlet UIButton *loginButton;
    BOOL hadSingleAccount;
}

@property (strong, nonatomic) ChatMasterViewController *delegate;
@property (strong, nonatomic) ACAccountStore *accountStore;
@property NSArray *accounts;

- (void)renderAccounts;
- (void)getAccounts;
- (IBAction)login;

@end
