//
//  ChatDetailViewController.h
//  Chatter
//
//  Created by mattneary on 6/12/13.
//  Copyright (c) 2013 mattneary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
