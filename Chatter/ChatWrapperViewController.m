//
//  ChatMessagesNavigationController.m
//  chatter
//
//  Created by mattneary on 6/15/13.
//  Copyright (c) 2013 mattneary. All rights reserved.
//

#import "ChatWrapperViewController.h"
#import "ChatMessagesViewController.h"

@implementation ChatWrapperViewController

- (IBAction)done {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.delegate dismissViewControllerAnimated:YES completion:nil];
    self.delegate.threadView = nil;
}
- (IBAction)sendMessage {    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://chatter.swell.io/message/%@/%@", self.account[@"id_str"], self.userId]]];
    [req setHTTPMethod:@"POST"];
    req.HTTPBody = [messageNew.text dataUsingEncoding:NSStringEncodingConversionAllowLossy];
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:req delegate:self];
    [conn start];
    
    [self.delegate.threads[self.account[@"id_str"]] addObject:@{@"account":self.username, @"payload":messageNew.text}];
    
    ChatMessagesViewController *cmvc = self.cmvc;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [cmvc.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.delegate.tableView reloadData];
    [cmvc.tableView reloadData];
    
    messageNew.text = @"";
    [cmvc.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[cmvc.chats count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
- (void)scrollViewForKeyboard:(NSNotification*)aNotification up: (BOOL)up{
    NSDictionary* userInfo = [aNotification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardFrame];
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [messageBar setFrame:CGRectMake(messageBar.frame.origin.x, messageBar.frame.origin.y + (keyboardFrame.size.height * (up?-1:1)), messageBar.frame.size.width, messageBar.frame.size.height)];
    [container setFrame:CGRectMake(container.frame.origin.x, container.frame.origin.y, container.frame.size.width, container.frame.size.height + (keyboardFrame.size.height * (up?-1:1)))];
    [UIView commitAnimations];
}
- (void)keyboardWillShow:(NSNotification*)aNotification {
    [self scrollViewForKeyboard:aNotification up:YES];
}
- (void)keyboardWillHide:(NSNotification*)aNotification {
    [self scrollViewForKeyboard:aNotification up:NO];
}
- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)scrollToBottom: (UITableView *)tableView {
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[((ChatMessagesViewController *)self.cmvc).chats count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [[segue identifier] isEqualToString:@"messagesEmbed"] ) {
        ChatMessagesViewController *target = segue.destinationViewController;
        target.delegate = self;
        target.threadListController = self.delegate;
        target.account = self.account;
        target.currentUser = self.currentUser;
        [target configure];
        
        self.cmvc = target;
        
        [messageNew performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:.1];
        ChatMessagesViewController *cmvc = self.cmvc;
        if( [cmvc.chats count] ) {
            [self performSelector:@selector(scrollToBottom:) withObject:cmvc.tableView afterDelay:.12];
        }
    }
}

@end
