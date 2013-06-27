//
//  ChatLoginViewController.m
//  chatter
//
//  Created by mattneary on 6/14/13.
//  Copyright (c) 2013 mattneary. All rights reserved.
//

#import "ChatLoginViewController.h"
#import <Social/Social.h>

@implementation ChatLoginViewController

- (IBAction)login {
    self.delegate.account = self.accounts[hadSingleAccount?0:accountView.selectedSegmentIndex];
    [self.delegate accountChosen];
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"]
                                               parameters:@{@"screen_name":self.delegate.account.username}];
    
    [request setAccount:self.delegate.account];
    
    [request performRequestWithHandler:^(NSData *responseData,
                                         NSHTTPURLResponse *urlResponse,
                                         NSError *error) {
        if( urlResponse.statusCode == 200 ) {
            NSError *jsonError = nil;
            NSDictionary *info = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:0
                                                               error:&jsonError];
            self.delegate.currentUser = [NSMutableDictionary dictionaryWithDictionary:info];
            NSString *imagePath = info[@"profile_image_url"];
            NSString *documentFolderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *savedPath = [documentFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"avatars/%@", [[imagePath pathComponents] lastObject]]];
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imagePath] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10.0];
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *respData, NSError *err){
                    if (!err && respData) {
                        NSError *error;
                        [respData writeToFile:savedPath options:NSDataWritingAtomic error:&error];
                    }
                }];
            });
        }         
    }];
}
- (void)renderAccounts {
    loginButton.hidden = NO;
    if( ![self.accounts count] ) {
        [accountView setTitle:@"Error:" forSegmentAtIndex:0];
        [accountView setTitle:@"Twitter Not Setup." forSegmentAtIndex:1];
        loginButton.hidden = YES;
    } else if( [self.accounts count] == 1 ) {
        hadSingleAccount = YES;
        [accountView setTitle:@"Account:" forSegmentAtIndex:0];
        accountView.selectedSegmentIndex = 1;
        [accountView setTitle:((ACAccount *)self.accounts[0]).username forSegmentAtIndex:1];
    } else {
        int charLimit = 42/[self.accounts count];
        int index = 0;
        for( ACAccount *account in self.accounts ) {
            NSString *username = account.username;
            if( username.length > charLimit ) {
                username = [[username substringToIndex:charLimit-4] stringByAppendingString:@"..."];
            }
            [accountView setTitle:username forSegmentAtIndex:index];
            index++;
        }
        // TODO: give option of creating new account
    }
}
- (void)getAccounts {
    if( self.accountStore == nil ) {
        self.accountStore = [[ACAccountStore alloc] init];
    }
    ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
        if( granted ) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.accounts = [self.accountStore accountsWithAccountType:twitterType];
                [self renderAccounts];
            });
        }
    }];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self getAccounts];
    hadSingleAccount = NO;
}


@end
