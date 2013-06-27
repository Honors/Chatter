//
//  ChatMessagesNavigationController.h
//  chatter
//
//  Created by mattneary on 6/15/13.
//  Copyright (c) 2013 mattneary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMasterViewController.h"

@interface ChatWrapperViewController : UIViewController <NSURLConnectionDelegate> {
    IBOutlet UIView *container;
    IBOutlet UIToolbar *messageBar;
    IBOutlet UITextField *messageNew;
}
@property ChatMasterViewController *delegate;
@property NSDictionary *account;
@property NSDictionary *currentUser;
@property NSString *userId;
@property NSString *username;
@property id cmvc;
- (IBAction)sendMessage;
@end
