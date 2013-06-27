//
//  ChatContactsViewController.m
//  chatter
//
//  Created by mattneary on 6/15/13.
//  Copyright (c) 2013 mattneary. All rights reserved.
//

#import "ChatContactsViewController.h"

@implementation ChatContactsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.followers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *imagePath = self.followers[indexPath.row][@"profile_image_url"];
    NSString *documentFolderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *readPath = [documentFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"avatars/%@", [[imagePath pathComponents] lastObject]]];
    NSData *imageDataRead = [NSData dataWithContentsOfFile:readPath];
    UIImage *readImage = [UIImage imageWithData:imageDataRead];
    ((UIImageView *)[cell.contentView subviews][0]).image = readImage;
    
    CALayer * l = [((UIImageView *)[cell.contentView subviews][0]) layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    
    ((UILabel *)[cell.contentView subviews][1]).text = self.followers[indexPath.row][@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate choseContact:self.followers[indexPath.row]];
}

- (IBAction)cancel {
    [self.delegate dismissViewControllerAnimated:YES completion:nil];
}

@end
