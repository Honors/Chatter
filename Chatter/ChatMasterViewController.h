//
//  ChatMasterViewController.h
//  Chatter
//
//  Created by mattneary on 6/12/13.
//  Copyright (c) 2013 mattneary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <AudioToolbox/AudioServices.h>

@interface ChatMasterViewController : UITableViewController {
    NSMutableData *data;    
}
@property int accountIndex;
@property NSArray *followers;
@property ACAccount *account;
@property NSMutableDictionary *threads;
@property NSMutableDictionary *unreadThreads;
@property NSMutableDictionary *contacts;
@property NSMutableDictionary *currentUser;
@property NSString *userId;
@property NSString *username;
@property UIViewController *threadView;
- (void)accountChosen;
- (void)showContacts;
- (void)choseContact: (NSDictionary *)contact;
- (void)refresh: (NSString *)author;
@end
