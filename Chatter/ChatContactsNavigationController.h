//
//  ChatContactsNavigationController.h
//  chatter
//
//  Created by mattneary on 6/15/13.
//  Copyright (c) 2013 mattneary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMasterViewController.h"

@interface ChatContactsNavigationController : UINavigationController
@property ChatMasterViewController *delegate;
@property (strong) NSArray *followers;
@end
