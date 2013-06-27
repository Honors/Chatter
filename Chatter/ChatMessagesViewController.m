//
//  ChatDetailViewController.m
//  Chatter
//
//  Created by mattneary on 6/12/13.
//  Copyright (c) 2013 mattneary. All rights reserved.
//

#import "ChatMessagesViewController.h"

@implementation ChatMessagesViewController

- (void)configure {
    self.title = self.account[@"name"];
    self.chats = self.threadListController.threads[self.account[@"id_str"]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *message = self.chats[indexPath.row];
    UITableViewCell *cell;
    NSString *imagePath;
    if( [message[@"author"] isEqualToString:self.account[@"id_str"]] ) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"from" forIndexPath:indexPath];
        imagePath = self.account[@"profile_image_url"];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"to" forIndexPath:indexPath];
        imagePath = self.currentUser[@"profile_image_url"];
    }
    
    NSString *documentFolderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *readPath = [documentFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"avatars/%@", [[imagePath pathComponents] lastObject]]];
    NSData *imageDataRead = [NSData dataWithContentsOfFile:readPath];
    UIImage *readImage = [UIImage imageWithData:imageDataRead];
    ((UIImageView *)[cell.contentView subviews][0]).image = readImage;
    
    CALayer * l = [((UIImageView *)[cell.contentView subviews][0]) layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    
    ((UILabel *)[cell.contentView subviews][1]).text = message[@"payload"];
    
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chats count];
}
- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *twitterAppLink = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?id=%@", self.chats[indexPath.row][@"author"]]];
    BOOL hasTwitter = [[UIApplication sharedApplication] canOpenURL:twitterAppLink];
    if( hasTwitter ) {
        [[UIApplication sharedApplication] openURL:twitterAppLink];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/account/redirect_by_id?id=%@", self.chats[indexPath.row][@"author"]]]];
    }
}

@end
