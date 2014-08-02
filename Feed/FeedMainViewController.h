//
//  FeedMainViewController.h
//  Feed
//
//  Created by George on 2/25/2014.
//  Copyright (c) 2014 George. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface FeedMainViewController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UITextViewDelegate, UIWebViewDelegate, UIScrollViewDelegate, UISearchBarDelegate>
- (void)refreshTable;
-(void)update;
@property (nonatomic, strong) UITableView *main_tableView;

@end
