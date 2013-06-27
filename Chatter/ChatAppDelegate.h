//
//  ChatAppDelegate.h
//  Chatter
//
//  Created by mattneary on 6/12/13.
//  Copyright (c) 2013 mattneary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMasterViewController.h"

@interface ChatAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property ChatMasterViewController *cmvc;

@end
