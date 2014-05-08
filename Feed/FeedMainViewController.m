//
//  FeedMainViewController.m
//  Feed
//
//  Created by George on 2/25/2014.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "FeedMainViewController.h"
#import "InstagramCell.h"
#import "TwitterCell.h"
#import "FacebookCell.h"
#import "DataClass.h"
#import "UIImageView+WebCache.h"
#import "STTwitter.h"
#import "CreationFunctions.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FeedMainViewController (){
    DataClass *singleton_universal;
    UITableView *tableView;
    int height;
    UIRefreshControl *refresh;
}

@end

@implementation FeedMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    singleton_universal = [DataClass getInstance];
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Feed";
    // Do any additional setup after loading the view from its nib.
    
    singleton_universal.universal_feed = [[NSMutableDictionary alloc] init];
    singleton_universal.universal_feed_array = [[NSMutableArray alloc] init];
    [CreationFunctions fetchFacebookFeed:singleton_universal];
    
    //[CreationFunctions createUniversalFeed:singleton_universal];
    [CreationFunctions sortUniversalFeedByTime:singleton_universal];
    [NSThread detachNewThreadSelector:@selector(getFeeds) toTarget:self withObject:nil];
    
   
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    tableView.scrollEnabled = YES;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.userInteractionEnabled = YES;
    tableView.bounces = YES;
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    singleton_universal.mainTableView = tableView;
    refresh = [[UIRefreshControl alloc] init];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [refresh addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    
    [tableView addSubview:refresh];
    
    /*FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"Found: %i friends", friends.count);
        for (NSDictionary<FBGraphUser>* friend in friends) {
            NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
        }
    }];*/
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    UIView *tintView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 20)];
    tintView.backgroundColor = [UIColor colorWithRed:100/255.0 green:204/255.0 blue:215/255.0 alpha:1];
    [self.view addSubview:tintView];
    
    [self.navigationController setToolbarHidden:NO];
    //[self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:100/255.0 green:204/255.0 blue:215/255.0 alpha:1]];
    //[self.navigationController.navigationBar setBarTintColor:[UIColor clearColor]];
    //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}
- (void)refreshTable{
    [refresh beginRefreshing];
    
    //[CreationFunctions fetchInstagramFeed:singleton_universal];
    //[CreationFunctions fetchTwitterFeed:singleton_universal];
    //[CreationFunctions createUniversalFeed:singleton_universal];
    
    [tableView reloadData];
    [refresh endRefreshing];
    
    
}
-(void)getFeeds{
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    NSString *storePath = [documentsDirectory stringByAppendingPathComponent:@"instagram_auth.txt"];
    NSString* content = [NSString stringWithContentsOfFile:storePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    if([content isEqualToString:@"yes"]){
       [CreationFunctions fetchInstagramFeed:singleton_universal];
    }
    
    storePath = [documentsDirectory stringByAppendingPathComponent:@"twitter_auth.txt"];
    content = [NSString stringWithContentsOfFile:storePath
                                        encoding:NSUTF8StringEncoding
                                           error:NULL];
    if([content isEqualToString:@"yes"]){
        [CreationFunctions fetchTwitterFeed:singleton_universal];
    }
    storePath = [documentsDirectory
                               stringByAppendingPathComponent:@"facebook.txt"];
    NSString *check_facebook = [NSString stringWithContentsOfFile:storePath
                                                         encoding:NSUTF8StringEncoding
                                                            error:NULL];
    //check_facebook = @"no";
    if([check_facebook isEqualToString:@"yes"]){
        
        NSLog(@"out");
    }
    
    [CreationFunctions createUniversalFeed:singleton_universal];
    [CreationFunctions sortUniversalFeedByTime:singleton_universal];
    
    [tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int insta_count =[[singleton_universal.universal_feed objectForKey:@"instagram_entry"] count];
    int twitter_count =[[singleton_universal.universal_feed objectForKey:@"twitter_entry"] count];
    int facebook_count =[[singleton_universal.universal_feed objectForKey:@"facebook_entry"] count];
    int main_count = [singleton_universal.universal_feed_array count];
    //NSLog(@"main count %d", facebook_count);
    return main_count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *type = [[singleton_universal.universal_feed_array objectAtIndex:indexPath.row] objectForKey:@"type"];
    
    if([type isEqualToString:@"instagram"]){
        static NSString *cellIdentifier = @"InstagramCell";
        
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        // Similar to UITableViewCell, but
        InstagramCell *cell = [CreationFunctions createInstagramCell:tableView cellForRowAtIndexPath:indexPath singleton:singleton_universal];
        if (cell == nil) {
            cell = [[InstagramCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        return cell;
    }else if ([type isEqualToString:@"twitter"]){
        static NSString *cellIdentifier = @"TwitterCell";
        // Similar to UITableViewCell, but
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        TwitterCell *cell = [CreationFunctions createTwitterCell:tableView cellForRowAtIndexPath:indexPath singleton:singleton_universal];
        if (cell == nil) {
            cell = [[TwitterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        return cell;
    }else if ([type isEqualToString:@"facebook"]){
        static NSString *cellIdentifier = @"FacebookCell";
        // Similar to UITableViewCell, but
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        FacebookCell *cell = [CreationFunctions createFacebookCell:tableView cellForRowAtIndexPath:indexPath singleton:singleton_universal];
        if (cell == nil) {
            cell = [[FacebookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        //cell.textLabel.text = @"facebook test";
        return cell;
    }else{
        static NSString *cellIdentifier = @"FacebookCell";
        // Similar to UITableViewCell, but
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        //TwitterCell *cell = [CreationFunctions createTwitterCell:tableView cellForRowAtIndexPath:indexPath singleton:singleton_universal];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.text = @"test";
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *type = [[singleton_universal.universal_feed_array objectAtIndex:indexPath.row] objectForKey:@"type"];
    
    if([type isEqualToString:@"instagram"]){
        return [CreationFunctions tableView:tableView heightForInstagram:indexPath singleton:singleton_universal];
    }else if([type isEqualToString:@"facebook"]){
        return [CreationFunctions tableView:tableView heightForFacebook:indexPath singleton:singleton_universal];
    }else{
        return [CreationFunctions tableView:tableView heightForTwitter:indexPath singleton:singleton_universal];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //[tableView setContentOffset:CGPointMake(0, 58) animated:YES];
    NSArray *current_cells = [tableView visibleCells];    for(InstagramCell *cell in current_cells){
       /* //CGRect headerFrame =
        if(count == 0){
            // NSLog(@"%f", cell.header.frame.origin.y);
            CGFloat relativeY = tableView.contentOffset.y-cell.frame.origin.y;
            if(relativeY < cell.frame.size.height - cell.header.frame.size.height){
                CGRect frame = CGRectMake(0, relativeY, screenWidth, 50);
                // NSLog(@"%f", relativeY);
                cell.header.frame = frame;
                [tableView setNeedsDisplay];
            }
            count++;
        }else{
            CGRect frame = CGRectMake(0, 0, screenWidth, 50);
            // NSLog(@"%f", relativeY);
            cell.header.frame = frame;
            [tableView setNeedsDisplay];
        }
        if(tableView.contentOffset.y < 0){
            CGRect frame = CGRectMake(0, 10, screenWidth, 50);
            // NSLog(@"%f", relativeY);
            cell.header.frame = frame;
            [tableView setNeedsDisplay];
        }*/
    }
    

}

@end
