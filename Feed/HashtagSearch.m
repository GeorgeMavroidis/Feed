//
//  HashtagSearch.m
//  Feed
//
//  Created by George on 2014-06-18.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "HashtagSearch.h"
#import "HashtagFunctions.h"
#import "HashtagDataClass.h"
#import "FeedMainViewController.h"
#import "InstagramCell.h"
#import "TwitterCell.h"
#import "FacebookCell.h"
#import "TumblrCell.h"
#import "DataClass.h"
#import "UIImageView+WebCache.h"
#import "STTwitter.h"
#import "CreationFunctions.h"
#import <FacebookSDK/FacebookSDK.h>
#import <TMAPIClient.h>
#import "InstagramCommentViewController.h"
#import "TwitterComposeScreenViewController.h"
#import "TumblrComposeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AsyncImageView.h"
#import "HashtagSearch.h"
#import "ProfileView.h"

@interface HashtagSearch (){
        NSString *searched;
    UISearchBar *searchBar;
    UIView *headerViewNew;
    UITableView *main_tableView;
    UIRefreshControl *refresh;
    UILabel *hashtag;
    UIView *urlWrapper, *closeView,*profile_view;
    UIWebView *t;
    HashtagDataClass *singleton_universal;
    NSMutableArray *local_universal_feed_array;
}

@end
@implementation HashtagSearch
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(id)initWithSearch:(NSString *)search{
    self = [super init];
    if (self) {
        searched = search;
        NSLog(searched);
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:NO];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    singleton_universal = [HashtagDataClass getInstance];
    DataClass *d_su = [DataClass getInstance];
    local_universal_feed_array = [[NSMutableArray alloc] init];
    
    singleton_universal.universal_feed = [[NSMutableDictionary alloc] init];
    singleton_universal.universal_feed_array = [[NSMutableArray alloc] init];
    
//    d_su.mainNavController = self.navigationController;
//    d_su.mainViewController = self;
    
    main_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-0) style:UITableViewStylePlain];
    
    main_tableView.scrollEnabled = YES;
    main_tableView.showsVerticalScrollIndicator = YES;
    main_tableView.userInteractionEnabled = YES;
    main_tableView.bounces = YES;
    // main_tableView.backgroundColor = [UIColor blackColor];
    
    main_tableView.delegate = self;
    main_tableView.dataSource = self;
    [self.view addSubview:main_tableView];
    singleton_universal.mainTableView = main_tableView;
    refresh = [[UIRefreshControl alloc] init];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [refresh addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [main_tableView addSubview:refresh];
    
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    headerViewNew = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 42)];
    [headerViewNew setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:headerViewNew];
    
    hashtag = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, screenWidth-80, 40)];
    hashtag.text = searched;
    hashtag.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
    [hashtag setTextAlignment:NSTextAlignmentCenter];
    
    [headerViewNew addSubview:hashtag];
    [self fetchFeeds];
    
    [HashtagFunctions sortUniversalFeedByTime:singleton_universal];
    
    local_universal_feed_array = singleton_universal.universal_feed_array;
    
    [main_tableView reloadData];
    

}
-(void)fetchFeeds{
    [HashtagFunctions fetchTwitterFeed:searched singleton:singleton_universal];
    
    [HashtagFunctions fetchInstagramFeed:searched singleton:singleton_universal];
    
    [HashtagFunctions fetchTumblrFeed:searched singleton:singleton_universal];
    
    [HashtagFunctions addInstagramFeed:singleton_universal];
//    [HashtagFunctions addTumblrFeed:singleton_universal];
    
    local_universal_feed_array = singleton_universal.universal_feed_array;
    [main_tableView reloadData];
}
- (void)refreshTable{
    [refresh beginRefreshing];
    
    //[CreationFunctions fetchInstagramFeed:singleton_universal];
    //[CreationFunctions fetchTwitterFeed:singleton_universal];
    //[CreationFunctions createUniversalFeed:singleton_universal];
    //[self getFeeds]; - this just adds to the bottom of the singleton feed - create new singleton - then switch maybe
    
    local_universal_feed_array = singleton_universal.universal_feed_array;
    [main_tableView reloadData];
    [main_tableView setNeedsDisplay];
    [refresh endRefreshing];
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
//    [main_tableView scrollRectToVisible:CGRectMake(0, main_tableView.contentSize.height - main_tableView.bounds.size.height, screenWidth, screenHeight-55) animated:NO];
    DataClass *singleton_universal =[DataClass getInstance];
    
    singleton_universal.mainTableView = main_tableView;
//    singleton_universal.mainNavController = self.navigationController;
    singleton_universal.mainViewController = self;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
//    [inputTextView resignFirstResponder];
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor clearColor]}];
    
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSString *type = [[singleton_universal.universal_feed_array objectAtIndex:indexPath.row] objectForKey:@"type"];
    NSString *type = [[local_universal_feed_array objectAtIndex:indexPath.row] objectForKeyedSubscript:@"type"];
    
    if([type isEqualToString:@"instagram"]){
        static NSString *cellIdentifier = @"InstagramCell";
        [tableView registerClass:[InstagramCell class] forCellReuseIdentifier:cellIdentifier];
        
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        // Similar to UITableViewCell, but
        InstagramCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[InstagramCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell = [CreationFunctions createInstagramCell:tableView cellForRowAtIndexPath:indexPath singleton:local_universal_feed_array];
//        instagram_media = cell.media_id;
        //[CreationFunctions fadeInLayer:cell.profile_picture_image_view.layer];
        //[CreationFunctions fadeInLayer:cell.main_picture_view.layer];
        
        return cell;
    }else if ([type isEqualToString:@"twitter"]){
        static NSString *cellIdentifier = @"TwitterCell";
        [tableView registerClass:[TwitterCell class] forCellReuseIdentifier:cellIdentifier];
        // Similar to UITableViewCell, but
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        TwitterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[TwitterCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:cellIdentifier];
        }
        cell = [CreationFunctions createTwitterCell:tableView cellForRowAtIndexPath:indexPath singleton:local_universal_feed_array];
        //[CreationFunctions fadeInLayer:cell.profile_picture_image_view.layer];
        return cell;
    }else if ([type isEqualToString:@"facebook"]){
        static NSString *cellIdentifier = @"FacebookCell";
        // Similar to UITableViewCell, but
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        FacebookCell *cell = [CreationFunctions createFacebookCell:tableView cellForRowAtIndexPath:indexPath singleton:local_universal_feed_array];
        if (cell == nil) {
            cell = [[FacebookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        //cell.textLabel.text = @"facebook test";
        return cell;
    }else if([type isEqualToString:@"tumblr"]){
        static NSString *cellIdentifier = @"TumblrCell";
        [tableView registerClass:[TumblrCell class] forCellReuseIdentifier:cellIdentifier];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        TumblrCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[TumblrCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell = [CreationFunctions createTumblrCell:tableView cellForRowAtIndexPath:indexPath singleton:local_universal_feed_array];
        //[CreationFunctions fadeInLayer:cell.contentView.layer];
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
    //    NSString *type = [[singleton_universal.universal_feed_array objectAtIndex:indexPath.row] objectForKey:@"type"];
    
    NSString *type = [[local_universal_feed_array objectAtIndex:indexPath.row] objectForKey:@"type"];
    //    return 100;
    if([type isEqualToString:@"instagram"]){
        return [CreationFunctions tableView:tableView heightForInstagram:indexPath singleton:local_universal_feed_array];
    }else if([type isEqualToString:@"facebook"]){
        return [CreationFunctions tableView:tableView heightForFacebook:indexPath singleton:local_universal_feed_array];
    }else if([type isEqualToString:@"tumblr"]){
        return [CreationFunctions tableView:tableView heightForTumblr:indexPath singleton:local_universal_feed_array];
    }else{
        return [CreationFunctions tableView:tableView heightForTwitter:indexPath singleton:local_universal_feed_array];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int main_count = [local_universal_feed_array count];
//    NSLog(@"main count %d", main_count);
    return main_count;
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGPoint scrollVelocity = [scrollView.panGestureRecognizer velocityInView:scrollView.superview];
    if (scrollVelocity.y > 0.0f){
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             CGRect new_frame = headerViewNew.frame;
                             new_frame.origin.y = 0;
                             headerViewNew.frame = new_frame;
                         }
                         completion:^(BOOL finished){
                         }];
        
    }
    else if (scrollVelocity.y < 0.0f){
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             CGRect new_frame = headerViewNew.frame;
                             new_frame.origin.y = -headerViewNew.frame.size.height;
                             headerViewNew.frame = new_frame;
                             
                             [searchBar resignFirstResponder];
                         }
                         completion:^(BOOL finished){
                         }];
        
    }
    
    CGPoint scrollVelo = [t.scrollView.panGestureRecognizer velocityInView:t.scrollView.superview];
    if (scrollVelo.y > 0.0f){
        //        NSLog(@"going down");
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             CGRect new_frame = closeView.frame;
                             new_frame.origin.y = 0;
                             closeView.frame = new_frame;
                         }
                         completion:^(BOOL finished){
                             //                             NSLog(@"Done!");
                         }];
        
    }
    else if (scrollVelo.y < 0.0f){
        //        NSLog(@"going up");
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             CGRect new_frame = closeView.frame;
                             new_frame.origin.y = -closeView.frame.size.height;
                             
                             closeView.frame = new_frame;
                             
                             [searchBar resignFirstResponder];
                         }
                         completion:^(BOOL finished){
                             //                             NSLog(@"Done!");
                         }];
        
    }
    
    
    
    
}
@end
