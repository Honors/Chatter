//
//  ChatMasterViewController.m
//  Chatter
//
//  Created by mattneary on 6/12/13.
//  Copyright (c) 2013 mattneary. All rights reserved.
//

#import "ChatMasterViewController.h"
#import "ChatLoginViewController.h"
#import "ChatMessagesViewController.h"
#import "ChatContactsViewController.h"
#import <Social/Social.h>

@interface ChatMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation ChatMasterViewController

- (void)refresh: (NSString *)author {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if( self.threadView && ![((ChatWrapperViewController *)self.threadView).userId isEqualToString:author] ) {
        self.unreadThreads[author] = @"NO";
    } else {
        self.unreadThreads[author] = @"YES";
    }
    if( ![self hasThreadForUser:author] ) {
        [_objects insertObject:self.contacts[author] atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView reloadData];
    if( self.threadView != nil && ((ChatWrapperViewController *)self.threadView).cmvc != nil ) {
        ChatMessagesViewController *cmvc = ((ChatWrapperViewController *)self.threadView).cmvc;
        [cmvc.tableView reloadData];
        [cmvc.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[cmvc.chats count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
- (void)awakeFromNib
{
    [super awakeFromNib];
}
- (void)choseContact: (NSDictionary *)contact {
    [self dismissViewControllerAnimated:YES completion:nil];
    [_objects insertObject:contact atIndex:0];    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    [self performSegueWithIdentifier:@"openThread" sender:self];
}
- (BOOL)hasThreadForUser: (NSString *)id_str {
    for( NSDictionary *account in _objects ) {
        if( [account[@"id_str"] isEqualToString:id_str] ) return YES;
    }
    return NO;
}
- (void)showContacts {
    ChatContactsViewController *ccvc = [self.storyboard instantiateViewControllerWithIdentifier:@"contactsNav"];
    ccvc.followers = self.followers;
    ccvc.delegate = self;
    [self presentViewController:ccvc animated:YES completion:nil];
}
- (void)getAvatars {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentFolderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *avatarsPath = [documentFolderPath stringByAppendingPathComponent:@"/avatars"];
    NSError *error;
    if(![fileManager fileExistsAtPath:avatarsPath]) {
        [fileManager createDirectoryAtPath:avatarsPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    for( NSDictionary *follower in self.followers ) {
        NSString *imagePath = follower[@"profile_image_url"];
        
        NSString *savedPath = [documentFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"avatars/%@", [[imagePath pathComponents] lastObject]]];
        if( [fileManager fileExistsAtPath:savedPath] ) {
            // image ready...
        } else {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imagePath] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10.0];
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *respData, NSError *err){
                if (!err && respData) {
                    NSError *error;
                    [respData writeToFile:savedPath options:NSDataWritingAtomic error:&error];
                }
            }];
        }
    }
}
- (void)accountChosen {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.userId = [[self.account valueForKey:@"properties"] valueForKey:@"user_id"];
    self.username = self.account.username;
     SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                        requestMethod:SLRequestMethodGET
                                  URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/followers/list.json"]
                           parameters:@{@"screen_name":self.account.username}];
    
     [request setAccount:self.account];

     [request performRequestWithHandler:^(NSData *responseData,
                                          NSHTTPURLResponse *urlResponse,
                                          NSError *error) {
         if( urlResponse.statusCode == 200 ) {
             NSError *jsonError = nil;
             self.followers = [NSJSONSerialization JSONObjectWithData:responseData
                                                              options:0
                                                                error:&jsonError][@"users"];
             dispatch_sync(dispatch_get_main_queue(), ^{
                 [self getAvatars];
                 for( NSDictionary *contact in self.followers ) {
                     self.contacts[contact[@"id_str"]] = contact;
                     self.threads[contact[@"id_str"]] = [[NSMutableArray alloc] initWithCapacity:255];
                 }
                 _objects = [[NSMutableArray alloc] initWithCapacity:255];
                 
                 // TODO: Read _objects from disk, the list of open threads, in the form of id_str's
                 
                 [self.tableView reloadData];
             });
         }         
     }];
     /*
      TODO: IMPLEMENT:
     [self.accountStore renewCredentialsForAccount:[twitterAccounts firstObject] completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
         //...
     }];
      */                     
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ChatLoginViewController *clvc = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
    clvc.delegate = self;
    [self presentViewController:clvc animated:YES completion:nil];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showContacts)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.threads = [[NSMutableDictionary alloc] initWithCapacity:255];
    self.contacts = [[NSMutableDictionary alloc] initWithCapacity:255];
    self.unreadThreads = [[NSMutableDictionary alloc] initWithCapacity:255];
    
    // TODO: read in threads written to file
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
    [data appendData:d];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
        // Throw Error
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    
    data = [[NSMutableData alloc] initWithCapacity:255];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://chatter.swell.io/message/matt"]];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[@"testing" dataUsingEncoding:NSStringEncodingConversionAllowLossy]];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:req delegate:self];
    [connection start];        
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    NSDictionary *follower = _objects[indexPath.row];
    
    // TODO: move file read to a single external step
    NSString *imagePath = follower[@"profile_image_url"];
    NSString *documentFolderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *readPath = [documentFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"avatars/%@", [[imagePath pathComponents] lastObject]]];
    NSData *imageDataRead = [NSData dataWithContentsOfFile:readPath];
    UIImage *readImage = [UIImage imageWithData:imageDataRead];
    ((UIImageView *)[cell.contentView subviews][0]).image = readImage;
    
    CALayer * l = [((UIImageView *)[cell.contentView subviews][0]) layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    
    ((UILabel *)[cell.contentView subviews][1]).text = follower[@"name"];
    if( [self.threads[follower[@"id_str"]] count] ) {
        NSArray *thread = self.threads[follower[@"id_str"]];
        ((UILabel *)[cell.contentView subviews][2]).text = thread[[thread count]-1][@"payload"];
    } else {
        ((UILabel *)[cell.contentView subviews][2]).text = @"";
    }
    
    if( [self.unreadThreads[follower[@"id_str"]] isEqualToString:@"YES"] ) {
        ((UIImageView *)[cell.contentView subviews][3]).hidden = NO;
    } else {
        ((UIImageView *)[cell.contentView subviews][3]).hidden = YES;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 119;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"openThread"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ChatWrapperViewController *target = (ChatWrapperViewController *)[segue destinationViewController];
        target.account = self.followers[indexPath.row];
        target.delegate = self;
        target.title = target.account[@"name"];
        target.userId = self.userId;
        target.username = self.username;
        target.currentUser = self.currentUser;
        self.threadView = target;
        self.unreadThreads[target.account[@"id_str"]] = @"NO";
        [self.tableView reloadData];
    }
}

@end
