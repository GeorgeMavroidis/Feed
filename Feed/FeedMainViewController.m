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
#import "FeedComposeViewController.h"
#import "MBProgressHUD.h"
#include<unistd.h>
#include<netdb.h>
#import "ConnectionFunctions.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
extern NSString *const kGAIScreenName;   // synonym for kGAIDescription

@interface FeedMainViewController (){
    DataClass *singleton_universal;
    int height;
    UIRefreshControl *refresh;
    UIView *headerView, *headerViewNew;
    NSString *instagram_media;
    UIView *urlWrapper, *closeView,*profile_view;
    UIWebView *t;
    UIImageView *headerImage, *profile_image;
    UIScrollView * profile_content_scroll;
    UIView *facebookContainer, *twitterContainer, *instagramContainer, *tumblrContainer;
    UIImageView *facebookIcon, *twitterIcon, *instagramIcon, *tumblrIcon;
    UIView *personalFeed;
    NSUserDefaults *defaults;
    UISearchBar *searchBar;
    IBOutlet UIPageControl *pageControl;
    NSMutableArray *local_universal_feed_array;
    FeedComposeViewController *compose;
    
}
@end
@implementation FeedMainViewController
@synthesize main_tableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    singleton_universal.mainTableView = main_tableView;
    singleton_universal.universal_feed_array = local_universal_feed_array;
    singleton_universal.mainNavController = self.navigationController;
    singleton_universal.mainViewController = self;
    
    self.title = @"Feed";
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    
    
    self.screenName = @"Main Home Page";
}
-(BOOL)isNetworkAvailable
{
    char *hostname;
    struct hostent *hostinfo;
    hostname = "google.com";
    hostinfo = gethostbyname (hostname);
    if (hostinfo == NULL){
        NSLog(@"-> no connection!\n");
        
        return NO;
    }
    else{
        NSLog(@"-> connection established!\n");
        return YES;
    }
    
    NSString *prof_img = [defaults valueForKey:@"profile_image"];
    prof_img = [prof_img stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    profile_image.layer.masksToBounds = YES;
    profile_image.imageURL = [NSURL URLWithString:prof_img];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    singleton_universal = [DataClass getInstance];
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Feed";
    // Do any additional setup after loading the view from its nib.
    defaults = [NSUserDefaults standardUserDefaults];
    
    singleton_universal.universal_feed = [[NSMutableDictionary alloc] init];
    singleton_universal.universal_feed_array = [[NSMutableArray alloc] init];
    local_universal_feed_array = [[NSMutableArray alloc] init];
    if(![self isNetworkAvailable]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Network Connection"
                                                        message:@"You must be connected to the internet to get a new Feed"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    DataClass *dc = [DataClass getInstance];
    NSData *data = [defaults objectForKey:@"stored_feed"];
    if (data != nil){
        NSArray *savedArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        local_universal_feed_array = [NSMutableArray arrayWithArray: savedArray];
    }else{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self getFeeds];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    }
    
    //[NSThread detachNewThreadSelector:@selector(getFeeds) toTarget:self withObject:nil];
    
   
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    main_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    [main_tableView setContentInset:UIEdgeInsetsMake(40,0,0,0)];
    [main_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    main_tableView.scrollEnabled = YES;
    main_tableView.showsVerticalScrollIndicator = YES;
    main_tableView.userInteractionEnabled = YES;
    main_tableView.bounces = YES;
   // main_tableView.backgroundColor = [UIColor blackColor];
    
    main_tableView.delegate = self;
    main_tableView.dataSource = self;
    [self.view addSubview:main_tableView];
    
    refresh = [[UIRefreshControl alloc] init];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [refresh addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    
    [main_tableView addSubview:refresh];
    
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
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(scrollToTop)];
    [tintView addGestureRecognizer:singleFingerTap];
    //tintView.backgroundColor = [UIColor colorWithRed:100/255.0 green:204/255.0 blue:215/255.0 alpha:1];
    tintView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tintView];
    
    //[self.navigationController setToolbarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    [self.navigationController setNavigationBarHidden:YES];
    //[self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:100/255.0 green:204/255.0 blue:215/255.0 alpha:1]];
    //[self.navigationController.navigationBar setBarTintColor:[UIColor clearColor]];
    //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
//    self.navigationController.navigationBar.translucent = YES;
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
//    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor redColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(create)];
    [self.navigationItem setRightBarButtonItem:addButton];
    
    UIBarButtonItem * settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"grey_profile_40.png"] landscapeImagePhone:[UIImage imageNamed:@"gear_a3a3a3_100.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setting)];
    [self.navigationItem setLeftBarButtonItem:settingsButton];
    
    UIButton *btn =  [[UIButton alloc] initWithFrame:CGRectMake(3, 1, 48, 43)];
    [btn setBackgroundImage:[UIImage imageNamed:@"grey_profile_sm.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(setting) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *compbtn =  [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-40, 7, 25, 25)];
    [compbtn setBackgroundImage:[UIImage imageNamed:@"penc.png"] forState:UIControlStateNormal];
    [compbtn addTarget:self action:@selector(create) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *searchbtn =  [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-80, 2, 35, 35)];
    [searchbtn setBackgroundImage:[UIImage imageNamed:@"magnify.png"] forState:UIControlStateNormal];
    [searchbtn addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    
    headerViewNew = [[UIView alloc] initWithFrame:CGRectMake(0, -40, screenWidth, 42)];
    headerViewNew = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 42)];
    [headerViewNew setBackgroundColor:[UIColor clearColor]];
//    [headerViewNew setAlpha:0.8];
    UIView *tm = [[UIView alloc] initWithFrame:CGRectMake(screenWidth-50,0, 50, 40)];

    [tm addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(create)] ];
    [tm setUserInteractionEnabled:YES];
    [headerViewNew addSubview:btn];
//    [headerViewNew addSubview:searchbtn];
    [headerViewNew addSubview:compbtn];
    
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 42)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    [headerViewNew addSubview:tm];
//    [self.view addSubview:headerView];
    
    
    
    UIScrollView *iconScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, headerView.frame.size.height)];
    CGRect new_frame = iconScrollView.frame;
    //new_frame.size.width = 500;
    iconScrollView.contentSize = new_frame.size;
    [iconScrollView setUserInteractionEnabled:YES];
    [iconScrollView setPagingEnabled:YES];
    [iconScrollView setBackgroundColor:[UIColor clearColor]];
    [headerView setUserInteractionEnabled:YES];
    [headerView addSubview:iconScrollView];
    
    
    UIImageView *facebook_square = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"facebook-square_000000_100.png"]];
    facebook_square.frame = CGRectMake(0, 0, 40, 40);
    [iconScrollView addSubview:facebook_square];
    
    UIImageView *twitter_square = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitter-square_000000_100.png"]];
    twitter_square.frame = CGRectMake(40, 0, 40, 40);
    [iconScrollView addSubview:twitter_square];
    
    UIImageView *tumblr_square = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tumblr-square_000000_100.png"]];
    tumblr_square.frame = CGRectMake(80, 0, 40, 40);
    [iconScrollView addSubview:tumblr_square];
    
    UIImageView *instagram_square = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instagram_000000_100.png"]];
    instagram_square.frame = CGRectMake(120, 0, 40, 40);
    [iconScrollView addSubview:instagram_square];
    //gear_a3a3a3_100
    UIImageView *settings = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pencil-square-o_000000_100.png"]];
    settings.frame = CGRectMake(screenWidth-44, 0, 40, 40);
    [iconScrollView addSubview:settings];
    
    profile_view = [[UIView alloc] initWithFrame:CGRectMake(30, 20, 0, 0)];
    [profile_view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:profile_view];
    
    profile_content_scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(30, 20, 0, 0)];
    [profile_view addSubview:profile_content_scroll];
    
    headerImage = [[UIImageView alloc] initWithFrame:CGRectMake(30, 20, 0, 0)];
    [headerImage setBackgroundColor:[UIColor blackColor]];
    [profile_content_scroll addSubview:headerImage];
    NSString *cov_img = [defaults valueForKey:@"cover_image"];
    headerImage.imageURL = [NSURL URLWithString:cov_img];
    [headerImage setContentMode:UIViewContentModeScaleAspectFill];
    
    
    profile_image = [[UIImageView alloc] initWithFrame:CGRectMake(30, 20, 30, 30)];
    [profile_image setBackgroundColor:[UIColor whiteColor]];
    profile_image.layer.cornerRadius = 100/2;
    NSString *prof_img = [defaults valueForKey:@"profile_image"];
    prof_img = [prof_img stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    profile_image.imageURL = [NSURL URLWithString:prof_img];
//    NSLog(@"%@", prof_img);
    profile_image.layer.masksToBounds = YES;
    profile_image.imageURL = [NSURL URLWithString:prof_img];
    
    UIView *whitecontainer = [[UIView alloc] initWithFrame:CGRectMake(0, 130, screenWidth, screenHeight)];
    [whitecontainer setBackgroundColor:[UIColor whiteColor]];
    [profile_content_scroll addSubview:whitecontainer];
    
    facebookContainer = [[UIView alloc] initWithFrame:CGRectMake(5, 130, 200, 50)];
    facebookIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    facebookIcon.image = [UIImage imageNamed:@"facebook_a6a6a6_100.png"];
    UISwitch *facebookSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(35, 2, 40, 30)];
    [facebookSwitch setOnTintColor:[UIColor blackColor]];
    [facebookContainer addSubview:facebookIcon];
    [facebookContainer addSubview:facebookSwitch];
    
    [facebookContainer setHidden:YES];
    [profile_content_scroll addSubview:facebookContainer];
    
    twitterContainer = [[UIView alloc] initWithFrame:CGRectMake(5, 170, 200, 50)];
    twitterIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    twitterIcon.image = [UIImage imageNamed:@"twitter_a6a6a6_100.png"];
    UISwitch *twitterSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(35, 2, 40, 30)];
    [twitterSwitch setOnTintColor:[UIColor blackColor]];
    [twitterContainer addSubview:twitterIcon];
    [twitterContainer addSubview:twitterSwitch];
    
    [twitterContainer setHidden:YES];
    [profile_content_scroll addSubview:twitterContainer];
    
    instagramContainer = [[UIView alloc] initWithFrame:CGRectMake(screenWidth-90, 130, 200, 50)];
    instagramIcon = [[UIImageView alloc] initWithFrame:CGRectMake(55, 0, 30, 30)];
    instagramIcon.image = [UIImage imageNamed:@"instagram_a6a6a6_100.png"];
    UISwitch *instagramSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 2, 40, 30)];
    [instagramSwitch setOnTintColor:[UIColor blackColor]];
    [instagramContainer addSubview:instagramIcon];
    [instagramContainer addSubview:instagramSwitch];
    
    [instagramContainer setHidden:YES];
    [profile_content_scroll addSubview:instagramContainer];
    
    tumblrContainer = [[UIView alloc] initWithFrame:CGRectMake(screenWidth-90, 170, 200, 50)];
    tumblrIcon = [[UIImageView alloc] initWithFrame:CGRectMake(55, 0, 30, 30)];
    tumblrIcon.image = [UIImage imageNamed:@"tumblr_a6a6a6_100.png"];
    UISwitch *tumblrSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 2, 40, 30)];
    [tumblrSwitch setOnTintColor:[UIColor blackColor]];
    [tumblrContainer addSubview:tumblrIcon];
    [tumblrContainer addSubview:tumblrSwitch];
    
    [tumblrContainer setHidden:YES];
    [profile_content_scroll addSubview:tumblrContainer];
    
    [facebookSwitch addTarget:self action:@selector(facebookSwitched:) forControlEvents:UIControlEventValueChanged];
    [twitterSwitch addTarget:self action:@selector(twitterSwitched:) forControlEvents:UIControlEventValueChanged];
    [tumblrSwitch addTarget:self action:@selector(tumblrSwitched:) forControlEvents:UIControlEventValueChanged];
    [instagramSwitch addTarget:self action:@selector(instagramSwitched:) forControlEvents:UIControlEventValueChanged];
    
    personalFeed = [[UIView alloc] initWithFrame:CGRectMake(0, 200, screenWidth, screenHeight*2)];
    personalFeed = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight*2)];
    [profile_content_scroll addSubview:personalFeed];
//    [personalFeed.layer setCornerRadius:30.0f];
    [personalFeed setBackgroundColor:[UIColor clearColor]];
    [personalFeed setHidden:YES];
    
    UIPanGestureRecognizer* pgr = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(personalPan:)];
//    [personalFeed addGestureRecognizer:pgr];
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(40, 0, screenWidth-80, 40)];
    [headerViewNew addSubview:searchBar];
    // transparency for UISearchBar
    searchBar.translucent = YES;
    searchBar.backgroundImage = [UIImage new];
    searchBar.scopeBarBackgroundImage = [UIImage new];
    searchBar.delegate = self;
    searchBar.barStyle = UISearchBarStyleDefault;
    
    searchBar.barTintColor = [UIColor colorWithRed: 25.0/255.0 green:181.0/255.0 blue:254.0/255.0 alpha:1.0];
    searchBar.tintColor = [UIColor colorWithRed: 25.0/255.0 green:181.0/255.0 blue:254.0/255.0 alpha:1.0];
    
    [[UITextField appearanceWhenContainedIn: [UISearchBar class], nil] setFont:[UIFont fontWithName:@"avenirNext-regular" size:16]];
    [[UITextField appearanceWhenContainedIn: [UISearchBar class], nil] setTextAlignment:NSTextAlignmentCenter];
    
    [headerViewNew addSubview:profile_image];
//    profile_image.frame = CGRectMake(screenWidth/2-50, 100, 100, 100);
    profile_image.frame = CGRectMake(10, 5, 30, 30);
    
    profile_image.layer.cornerRadius = 30/2;
//    [profile_image setHidden:YES];
    
    UITableView *personal_table_view = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, screenWidth, screenHeight)];
//    [personalFeed addSubview:personal_table_view];
    
    
    [self.view addSubview:headerViewNew];
    
    compose = [[FeedComposeViewController alloc] init];
    compose.view.frame = CGRectMake(0, screenHeight, screenWidth, screenHeight);
    //TumblrComposeViewController *compose = [[TumblrComposeViewController alloc] init];
    compose.view.alpha = 0.95;
    [singleton_universal.mainViewController addChildViewController:compose];
    
    [singleton_universal.mainViewController.view addSubview:compose.view];
    
   }
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self handleSearch:searchBar];
//    [searchBar resignFirstResponder];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
//    [self handleSearch:searchBar];
    
}


- (void)handleSearch:(UISearchBar *)searchBar {
//    NSLog(@"User searched for %@", searchBar.text);
    HashtagSearch *hashtag = [[HashtagSearch alloc] initWithSearch:searchBar.text];
    searchBar.text = @"";
    [self.navigationController pushViewController:hashtag animated:YES];
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
}


-(void)personalPan:(UIPanGestureRecognizer*)pgr{
    if (pgr.state == UIGestureRecognizerStateChanged) {
            CGPoint center = pgr.view.center;
            CGPoint translation = [pgr translationInView:pgr.view];
            center = CGPointMake(center.x,
                                 center.y + translation.y);
            pgr.view.center = center;
            [pgr setTranslation:CGPointZero inView:pgr.view];
            if(pgr.view.frame.origin.y < 130){
                CGRect frame = profile_image.frame;
                frame.origin.y += translation.y;
                profile_image.frame = frame;
            }
        
            
        
        
    }
    if(pgr.state == UIGestureRecognizerStateEnded){
        if(pgr.view.frame.origin.y > 130){
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options: UIViewAnimationCurveEaseOut
                             animations:^{
                        
                                 CGRect frame = profile_image.frame;
                                 frame.origin.y = 100;
                                 profile_image.frame = frame;
                                 
                                 frame = pgr.view.frame;
                                 frame.origin.y = 200;
                                 pgr.view.frame = frame;
                             }
                             completion:^(BOOL finished){
                                 
                                 //                             NSLog(@"Done!");
                             }];
        }
        if(pgr.view.frame.origin.y < 40){
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options: UIViewAnimationCurveEaseOut
                             animations:^{
                                 
                                 CGRect frame = profile_image.frame;
                                 frame.origin.y = 40;
                                 profile_image.frame = frame;
                                 
                                 frame = pgr.view.frame;
                                 frame.origin.y = 40;
                                 pgr.view.frame = frame;
                                 
                             }
                             completion:^(BOOL finished){
                                 
                                 //                             NSLog(@"Done!");
                             }];
        }
    }
}
- (IBAction)create{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    compose = [[FeedComposeViewController alloc] init];
    compose.view.frame = CGRectMake(0, screenHeight, screenWidth, screenHeight);
    //TumblrComposeViewController *compose = [[TumblrComposeViewController alloc] init];
    compose.view.alpha = 0.95;
    [self addChildViewController:compose];
    
    [self.view addSubview:compose.view];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         CGRect old_frame = compose.view.frame;
                         old_frame.origin.y = 0;
                         compose.view.frame = old_frame;
                     }
                     completion:^(BOOL finished){
                         //                         NSLog(@"Done!");
                     }];

}
-(IBAction)search{
    
}
- (IBAction)setting{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    ProfileView *tp = [[ProfileView alloc] initForSelf];
    [self.navigationController pushViewController:tp animated:YES];
    
//    if(profile_view.frame.size.width != 0){
//        [UIView animateWithDuration:0.25
//                              delay:0.0
//                            options: UIViewAnimationCurveEaseOut
//                         animations:^{
//                             CGRect new_frame = profile_view.frame;
//                             new_frame.origin.y = 23;
//                             new_frame.origin.x = 24;
//                             new_frame.size.height = 0;
//                             new_frame.size.width = 0;
//                             profile_view.frame = new_frame;
//                             
//                             profile_content_scroll.frame = CGRectMake(30, 20, 0, 0);
//                            
//                             headerImage.frame = CGRectMake(30, 20, 0, 0);
//                             profile_image.frame = CGRectMake(10, 5, 30, 30);
//                             profile_image.layer.cornerRadius = 30/2;
////                             [profile_image setHidden:YES];
//                             
//                             [facebookContainer setHidden:YES];
//                             [twitterContainer setHidden:YES];
//                             [tumblrContainer setHidden:YES];
//                             [instagramContainer setHidden:YES];
//                             [personalFeed setHidden:YES];
//                             
////                             main_tableView.frame = CGRectMake(0, -40, self.view.frame.size.width, self.view.frame.size.height+40);
//                             
//                         }
//                         completion:^(BOOL finished){
//                             
//                             //                             NSLog(@"Done!");
//                         }];
//    }else{
//        [UIView animateWithDuration:0.25
//                              delay:0.0
//                            options: UIViewAnimationCurveEaseOut
//                         animations:^{
//                             CGRect new_frame = profile_view.frame;
//                             new_frame.origin.y = 0;
//                             new_frame.origin.x = 0;
//                             new_frame.size.height = screenHeight-40;
//                             new_frame.size.width = screenWidth;
//                             profile_view.frame = new_frame;
//                             
//                             profile_image.frame = CGRectMake(10, 5, 30, 30);
//                             
//                             profile_content_scroll.frame = CGRectMake(0, 0, screenWidth, screenHeight);
//                             headerImage.frame = CGRectMake(0, 0, screenWidth, 120);
////                             profile_image.frame = CGRectMake(screenWidth/2-50, 100, 100, 100);
////                             profile_image.layer.cornerRadius = 100/2;
//                             [profile_image setHidden:NO];
//                             [facebookContainer setHidden:NO];
//                             [twitterContainer setHidden:NO];
//                             [tumblrContainer setHidden:NO];
//                             [instagramContainer setHidden:NO];
//                             [personalFeed setHidden:NO];
//                             
//                             
//                             ProfileView *tp = [[ProfileView alloc] initWithProfile:@"georgemavroidis" type:@"self"];
//                             [self addChildViewController:tp];
//                             tp.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
////                             [tp.main_tableView setContentInset:UIEdgeInsetsMake(40,0,0,0)];
//                             //    tp.view.frame = CGRectMake(0, 40, screenWidth, screenHeight+100);
//                             [personalFeed addSubview:tp.view];
//                             [headerImage setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//                            
//                         }
//                         completion:^(BOOL finished){
//                             //                             NSLog(@"Done!");
//                         }];
//    }
}
- (void)facebookSwitched:(id)sender
{
    BOOL state = [sender isOn];
    NSString *rez = state == YES ? @"YES" : @"NO";
    if([rez isEqualToString:@"YES"]){
        facebookIcon.image = [UIImage imageNamed:@"facebook_000000_100.png"];
    }else{
        facebookIcon.image = [UIImage imageNamed:@"facebook_a6a6a6_100.png"];
    }
}
- (void)twitterSwitched:(id)sender
{
    BOOL state = [sender isOn];
    NSString *rez = state == YES ? @"YES" : @"NO";
    if([rez isEqualToString:@"YES"]){
        twitterIcon.image = [UIImage imageNamed:@"twitter_000000_100.png"];
    }else{
        twitterIcon.image = [UIImage imageNamed:@"twitter_a6a6a6_100.png"];
    }
}
- (void)instagramSwitched:(id)sender
{
    BOOL state = [sender isOn];
    NSString *rez = state == YES ? @"YES" : @"NO";
    if([rez isEqualToString:@"YES"]){
        instagramIcon.image = [UIImage imageNamed:@"instagram_000000_100.png"];
    }else{
        instagramIcon.image = [UIImage imageNamed:@"instagram_a6a6a6_100.png"];
    }
}
- (void)tumblrSwitched:(id)sender
{
    BOOL state = [sender isOn];
    NSString *rez = state == YES ? @"YES" : @"NO";
    if([rez isEqualToString:@"YES"]){
        tumblrIcon.image = [UIImage imageNamed:@"tumblr_000000_100.png"];
    }else{
        tumblrIcon.image = [UIImage imageNamed:@"tumblr_a6a6a6_100.png"];
    }
}
-(void)scrollToTop{
    [main_tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}
- (void)refreshTable{
    if(![self isNetworkAvailable]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Network Connection"
                                                        message:@"You must be connected to the internet to get a new Feed"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [refresh beginRefreshing];
    
    [singleton_universal.universal_facebook_feed removeAllObjects];
    [singleton_universal.universal_feed_array removeAllObjects];
    [singleton_universal.universal_instagram_feed removeAllObjects];
    [singleton_universal.universal_tumblr_feed removeAllObjects];
    [singleton_universal.universal_twitter_feed removeAllObjects];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self getFeeds];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    local_universal_feed_array = singleton_universal.universal_feed_array;
    [main_tableView reloadData];
    [main_tableView setNeedsDisplay];
    [refresh endRefreshing];
    
    
}
-(void)update{
    DataClass *d = [DataClass getInstance];
    local_universal_feed_array = singleton_universal.universal_feed_array;
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithArray:local_universal_feed_array]]  forKey:@"stored_feed"];
//    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:(DataClass *)d]  forKey:@"stored_dataClass"];
    
//    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:(DataClass *)d  forKey:@"stored_data_class"];
    
}
-(void)getFeeds{
    
    if([self isNetworkAvailable]){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *instaCon = [defaults objectForKey:@"instagram_connect"];
        NSString *tumbCon = [defaults objectForKey:@"tumblr_connect"];
        NSString *twitCon = [defaults objectForKey:@"twitter_connect"];
        
        if([instaCon isEqualToString:@"yes"]){
            [CreationFunctions fetchInstagramFeed:singleton_universal];
        }
        if([twitCon isEqualToString:@"yes"]){
            [CreationFunctions fetchTwitterFeed:singleton_universal];
        }
        if([tumbCon isEqualToString:@"yes"]){
            [CreationFunctions fetchTumblrFeed:singleton_universal];
        }
        
        local_universal_feed_array  = singleton_universal.universal_feed_array;
        
        [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithArray:local_universal_feed_array]]  forKey:@"stored_feed"];
        [main_tableView reloadData];
    }else{
        
    }
    
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
   /* int insta_count =[[singleton_universal.universal_feed objectForKey:@"instagram_entry"] count];
    int twitter_count =[[singleton_universal.universal_feed objectForKey:@"twitter_entry"] count];
    int facebook_count =[[singleton_universal.universal_feed objectForKey:@"facebook_entry"] count];
    int tumblr_count =[[singleton_universal.universal_feed objectForKey:@"tumblr_entry"] count];*/
    int local_count = [local_universal_feed_array count];
//    int main_local_count = [[defaults objectForKey:@"main_lufa"] count];
//    NSLog(@"main %d", main_local_count);
    int main_count = [singleton_universal.universal_feed_array count];
    return local_count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *type = [[singleton_universal.universal_feed_array objectAtIndex:indexPath.row] objectForKey:@"type"];
    NSString *type = [[local_universal_feed_array objectAtIndex:indexPath.row] objectForKeyedSubscript:@"type"];
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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
        
        UITapGestureRecognizer *tapTwice = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(instagramDoubleTap:)];
        tapTwice.numberOfTapsRequired = 2;
        cell.main_picture_view.userInteractionEnabled = YES;
        [cell.main_picture_view addGestureRecognizer:tapTwice];
        
        UITapGestureRecognizer *delLike = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(instagramDelTap:)];
        delLike.numberOfTapsRequired = 1;
        cell.like.userInteractionEnabled = YES;
        [cell.like addGestureRecognizer:delLike];

        
        return cell;
    }else if ([type isEqualToString:@"twitter"]){
        static NSString *cellIdentifier = @"TwitterCell";
        [tableView registerClass:[TwitterCell class] forCellReuseIdentifier:cellIdentifier];
        // Similar to UITableViewCell, but
//        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
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
//        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        FacebookCell *cell = [CreationFunctions createFacebookCell:tableView cellForRowAtIndexPath:indexPath singleton:local_universal_feed_array];
        if (cell == nil) {
            cell = [[FacebookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        //cell.textLabel.text = @"facebook test";
        return cell;
    }else if([type isEqualToString:@"tumblr"]){
        static NSString *cellIdentifier = @"TumblrCell";
        [tableView registerClass:[TumblrCell class] forCellReuseIdentifier:cellIdentifier];
        // Similar to UITableViewCell, but
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        TumblrCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[TumblrCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell = [CreationFunctions createTumblrCell:tableView cellForRowAtIndexPath:indexPath singleton:local_universal_feed_array];
        
        UITapGestureRecognizer *tumblrLike = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(likeTumblr:)];
        cell.heart_view.userInteractionEnabled = YES;
        [cell.heart_view addGestureRecognizer:tumblrLike];
        
        UITapGestureRecognizer *tumblrDoubleLike = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(likeDoubleTumblr:)];
        tumblrDoubleLike.numberOfTapsRequired = 2;
        cell.userInteractionEnabled = YES;
        [cell addGestureRecognizer:tumblrDoubleLike];
        
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //[tableView setContentOffset:CGPointMake(0, 58) animated:YES];
    //NSArray *current_cells = [main_tableView visibleCells];
    //for(InstagramCell *cell in current_cells){
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
    //}
    
//    CGPoint scrollVelocity = [scrollView.panGestureRecognizer velocityInView:scrollView.superview];
//    if (scrollVelocity.y > 0.0f){
//        
//        CGRect new_frame = headerViewNew.frame;
//        if(new_frame.origin.y < 0){
//            new_frame.origin.y += 1;
//            headerViewNew.frame = new_frame;
//        }
//        
//        /*[UIView animateWithDuration:0.5
//                              delay:0.0
//                            options: UIViewAnimationCurveEaseOut
//                         animations:^{
//                             CGRect new_frame = headerViewNew.frame;
//                             new_frame.origin.y = 0;
//                             headerViewNew.frame = new_frame;
//                         }
//                         completion:^(BOOL finished){
//                         }];
//        */
//       
//    }
//    else if (scrollVelocity.y < 0.0f){
//        CGRect new_frame = headerViewNew.frame;
//        if(new_frame.origin.y > -headerViewNew.frame.size.height){
//            new_frame.origin.y -= 1;
//            headerViewNew.frame = new_frame;
//        }
//       /* [UIView animateWithDuration:0.5
//                              delay:0.0
//                            options: UIViewAnimationCurveEaseOut
//                         animations:^{
//                             CGRect new_frame = headerViewNew.frame;
//                             new_frame.origin.y = -headerViewNew.frame.size.height;
//                             headerViewNew.frame = new_frame;
//                             
//                             [searchBar resignFirstResponder];
//                         }
//                         completion:^(BOOL finished){
//                         }];
//        */
//    }
//
//        CGPoint scrollVelo = [t.scrollView.panGestureRecognizer velocityInView:t.scrollView.superview];
//        if (scrollVelo.y > 0.0f){
//            //        NSLog(@"going down");
//            [UIView animateWithDuration:0.5
//                                  delay:0.0
//                                options: UIViewAnimationCurveEaseOut
//                             animations:^{
//                                 CGRect new_frame = closeView.frame;
//                                 new_frame.origin.y = 0;
//                                 closeView.frame = new_frame;
//                             }
//                             completion:^(BOOL finished){
//                                 //                             NSLog(@"Done!");
//                             }];
//            
//        }
//        else if (scrollVelo.y < 0.0f){
//            //        NSLog(@"going up");
//            [UIView animateWithDuration:0.5
//                                  delay:0.0
//                                options: UIViewAnimationCurveEaseOut
//                             animations:^{
//                                 CGRect new_frame = closeView.frame;
//                                 new_frame.origin.y = -closeView.frame.size.height;
//                                 
//                                 closeView.frame = new_frame;
//                                 
//                                 [searchBar resignFirstResponder];
//                             }
//                             completion:^(BOOL finished){
//                                 //                             NSLog(@"Done!");
//                             }];
//            
//        }
    
    
    
    [searchBar resignFirstResponder];

}

/*
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
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
}*/
-(void)instagramDoubleTap:(UITapGestureRecognizer *)sender {
    //recognizer = (MediaInterface *)media_object.gestureRec;
    //MediaInterface *test = (MediaInterface*)media_object;
    //NSLog(test.actual_media_id);
    InstagramCell *test =[[((InstagramCell *) sender.view) superview] superview];
    if(test.like.backgroundColor != [UIColor grayColor]){
        NSString *temp_media = test.media_id;
        
        UITapGestureRecognizer *recognizer = sender;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        UIImageView *like_image = [[UIImageView alloc] initWithFrame:CGRectMake(recognizer.view.center.x - 75, recognizer.view.center.y-125, 150,150)];
        
        like_image.image = [UIImage imageNamed:@"heart_white.png"];
        [recognizer.view addSubview:like_image];
        
        like_image.alpha = 1.0;
        
        [UIView animateWithDuration:2.0 animations:^{
            like_image.alpha = 0.0;
        }completion:^(BOOL finished) {
            
        }];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *access = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"instagram_access_token"];
        
        NSString *post = [NSString stringWithFormat:@"access_token=%@",access];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/likes", temp_media]]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
        [request setHTTPBody:postData];
        //    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue]
                               completionHandler: ^(NSURLResponse * response, NSData * data, NSError * error) {
                                   NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)response;
                                   if(httpResponse.statusCode == 200) {
                                       NSLog(@"connected");
                                       [test.like setBackgroundColor:[UIColor grayColor]];
                                       [test.like_label setText:@"Liked"];
                                       [test.like_label setTextColor:[UIColor whiteColor]];
                                       [test.like_image setImage:[UIImage imageNamed:@"heart_tumblr.png"]];
                                       test.photo_likes.text = [CreationFunctions addInstagramLike:test.photo_likes.text];
                                       
                                       NSMutableDictionary *instagram_data = [CreationFunctions getUpdatedInstagram:temp_media];
                                       [instagram_data setObject:@"1" forKey:@"user_has_liked"];
                                       //        NSLog(@"%@", instagram_data);
                                       int index = 0;
                                       for(int i = 0; i < [local_universal_feed_array count]; i++){
                                           NSString *type = [[local_universal_feed_array objectAtIndex:i] objectForKeyedSubscript:@"type"];
                                           
                                           if([type isEqualToString:@"instagram"]){
                                               if([[[local_universal_feed_array objectAtIndex:i] valueForKey:@"id"] isEqualToString:temp_media]){
                                                   [local_universal_feed_array setObject:instagram_data atIndexedSubscript:i];
                                               }
                                           }
                                       }
                                       
                                       
                                   }
                               }
         ];

    }
    
}
-(void)instagramDelTap:(UITapGestureRecognizer *)sender {
    //recognizer = (MediaInterface *)media_object.gestureRec;
    //MediaInterface *test = (MediaInterface*)media_object;
    //NSLog(test.actual_media_id);
    InstagramCell *test =[[[((InstagramCell *) sender.view) superview] superview] superview];
    
    if(test.like.backgroundColor == [UIColor grayColor]){
        NSString *temp_media = test.media_id;
        
        UITapGestureRecognizer *recognizer = sender;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *access = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"instagram_access_token"];
        NSString *post = [NSString stringWithFormat:@"_method=DELETE"];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/likes?access_token=%@", temp_media, access]]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
        [request setHTTPBody:postData];
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        
        if(conn){
            NSLog(@"Connection Successful");
            [test.like setBackgroundColor:[UIColor colorWithWhite: 0.9 alpha:1]];
            [test.like_label setText:@"Like"];
            [test.like_label setTextColor:[UIColor colorWithWhite:0.5 alpha:1]];
            [test.like_image setImage:[UIImage imageNamed:@"heart_small.png"]];
            
            test.photo_likes.text = [CreationFunctions deleteInstagramLike:test.photo_likes.text];
            
            NSMutableDictionary *instagram_data = [CreationFunctions getUpdatedInstagram:temp_media];
            [instagram_data setObject:@"0" forKey:@"user_has_liked"];
            int index = 0;
            for(int i = 0; i < [local_universal_feed_array count]; i++){
                NSString *type = [[local_universal_feed_array objectAtIndex:i] objectForKeyedSubscript:@"type"];
                
                if([type isEqualToString:@"instagram"]){
                    if([[[local_universal_feed_array objectAtIndex:i] valueForKey:@"id"] isEqualToString:temp_media]){
                        [local_universal_feed_array setObject:instagram_data atIndexedSubscript:i];
                    }
                }
            }
            
        }
        else{
            NSLog(@"Connection could not be made");
        }

    }
}
-(void)likeTumblr:(UITapGestureRecognizer *)responder{
    
    DataClass *singleton_universal = [DataClass getInstance];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    TumblrCell *test =[[[((TumblrCell *) responder.view) superview] superview] superview];
    test.heart_view.image = [UIImage imageNamed:@"heart_tumblr.png"];
    
    
    if([test.liked isEqualToString:@"0"]){
        test.heart_view.image = [UIImage imageNamed:@"heart_tumblr.png"];
        
        [[TMAPIClient sharedInstance] like:test.unique_id reblogKey:test.reblog_key callback:^(id result, NSError *error) {
            
            if(error)
                NSLog(@"%@", [error localizedDescription]);
            if(!error){
                NSLog(@"liked");
                test.liked = @"1";
                for(int i = 0; i < [local_universal_feed_array count]; i++){
                    NSString *type = [[local_universal_feed_array objectAtIndex:i] objectForKeyedSubscript:@"type"];
                    if([type isEqualToString:@"tumblr"]){
                        if([[[[local_universal_feed_array objectAtIndex:i] objectForKey:@"id"] stringValue] isEqualToString:test.unique_id]){
                            NSMutableDictionary *temp = [local_universal_feed_array objectAtIndex:i];
                            BOOL te = 1;
                            [temp setObject:[NSNumber numberWithBool:te] forKey:@"liked"];
                        }
                    }
                }
            }
        }];
    }else{
        test.heart_view.image = [UIImage imageNamed:@"heart_small.png"];
        
        [[TMAPIClient sharedInstance] unlike:test.unique_id reblogKey:test.reblog_key callback:^(id result, NSError *error) {
            
            if(error)
                NSLog(@"%@", [error localizedDescription]);
            if(!error){
                NSLog(@"unliked");
                test.liked = @"0";
                for(int i = 0; i < [local_universal_feed_array count]; i++){
                    NSString *type = [[local_universal_feed_array objectAtIndex:i] objectForKeyedSubscript:@"type"];
                    if([type isEqualToString:@"tumblr"]){
                        if([[[[local_universal_feed_array objectAtIndex:i] objectForKey:@"id"] stringValue] isEqualToString:test.unique_id]){
                            NSMutableDictionary *temp = [local_universal_feed_array objectAtIndex:i];
                            BOOL te = 0;
                            [temp setObject:[NSNumber numberWithBool:te] forKey:@"liked"];
                        }
                    }
                }
            }
        }];
    }
    
}
-(void)likeDoubleTumblr:(UITapGestureRecognizer *)responder{
    
    DataClass *singleton_universal = [DataClass getInstance];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    TumblrCell *test =((TumblrCell *) responder.view);
    test.heart_view.image = [UIImage imageNamed:@"heart_tumblr.png"];
    
    
    if([test.liked isEqualToString:@"0"]){
        test.heart_view.image = [UIImage imageNamed:@"heart_tumblr.png"];
        
        [[TMAPIClient sharedInstance] like:test.unique_id reblogKey:test.reblog_key callback:^(id result, NSError *error) {
            
            if(error)
                NSLog(@"%@", [error localizedDescription]);
            if(!error){
                NSLog(@"liked");
                test.liked = @"1";
                for(int i = 0; i < [local_universal_feed_array count]; i++){
                    NSString *type = [[local_universal_feed_array objectAtIndex:i] objectForKeyedSubscript:@"type"];
                    if([type isEqualToString:@"tumblr"]){
                        if([[[[local_universal_feed_array objectAtIndex:i] objectForKey:@"id"] stringValue] isEqualToString:test.unique_id]){
                            NSMutableDictionary *temp = [local_universal_feed_array objectAtIndex:i];
                            BOOL te = 1;
                            [temp setObject:[NSNumber numberWithBool:te] forKey:@"liked"];
                        }
                    }
                }
            }
        }];
    }else{
        test.heart_view.image = [UIImage imageNamed:@"heart_small.png"];
        
        [[TMAPIClient sharedInstance] unlike:test.unique_id reblogKey:test.reblog_key callback:^(id result, NSError *error) {
            
            if(error)
                NSLog(@"%@", [error localizedDescription]);
            if(!error){
                NSLog(@"unliked");
                test.liked = @"0";
                for(int i = 0; i < [local_universal_feed_array count]; i++){
                    NSString *type = [[local_universal_feed_array objectAtIndex:i] objectForKeyedSubscript:@"type"];
                    if([type isEqualToString:@"tumblr"]){
                        if([[[[local_universal_feed_array objectAtIndex:i] objectForKey:@"id"] stringValue] isEqualToString:test.unique_id]){
                            NSMutableDictionary *temp = [local_universal_feed_array objectAtIndex:i];
                            BOOL te = 0;
                            [temp setObject:[NSNumber numberWithBool:te] forKey:@"liked"];
                        }
                    }
                }
            }
        }];
    }
}
@end
