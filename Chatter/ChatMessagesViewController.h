//
//  ChatDetailViewController.h
//  Chatter
//
//  Created by mattneary on 6/12/13.
//  Copyright (c) 2013 mattneary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatWrapperViewController.h"
#import "ChatMasterViewController.h"

@interface ChatMessagesViewController : UITableViewController

@property ChatWrapperViewController *delegate;
@property NSDictionary *account;
@property NSDictionary *currentUser;
@property NSMutableArray *chats;
@property ChatMasterViewController *threadListController;
- (void)configure;
@end
