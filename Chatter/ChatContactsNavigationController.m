//
//  ChatContactsNavigationController.m
//  chatter
//
//  Created by mattneary on 6/15/13.
//  Copyright (c) 2013 mattneary. All rights reserved.
//

#import "ChatContactsNavigationController.h"
#import "ChatContactsViewController.h"

@interface ChatContactsNavigationController ()

@end

@implementation ChatContactsNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    ChatContactsViewController *ccvc = [self.storyboard instantiateViewControllerWithIdentifier:@"contacts"];
    ccvc.followers = self.followers;
    ccvc.delegate = self.delegate;
    [self pushViewController:ccvc animated:YES];
}

- (void)contactChosen: (NSDictionary *)contact {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate choseContact:contact];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
