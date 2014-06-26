//
//  ProfileView.m
//  Feed
//
//  Created by George on 2014-06-18.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "ProfileView.h"
#import "ProfileDataClass.h"
#import "DataClass.h"
@implementation ProfileView{
    NSString *profiled, *typed;
    UIView *headerViewNew;
    
    UISearchBar *searchBar;
    UITableView *main_tableView;
    UIRefreshControl *refresh;
    UILabel *profile;
    UIView *urlWrapper, *closeView,*profile_view;
    UIWebView *t;
    
    ProfileDataClass *singleton_universal;
    NSMutableArray *local_universal_feed_array;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}

-(id)initWithProfile:(NSString *)profile type:(NSString *)type{
    self = [super init];
    if (self) {
        profiled = profile;
        typed = type;
        NSLog(@"%@ %@", profiled, typed);
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:NO];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    singleton_universal = [ProfileDataClass getInstance];
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
    
    profile = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, screenWidth-80, 40)];
    profile.text = profiled;
    profile.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
    [profile setTextAlignment:NSTextAlignmentCenter];
    
//    [headerViewNew addSubview:hashtag];
//    [self fetchFeeds];
    
//    [HashtagFunctions sortUniversalFeedByTime:singleton_universal];
    
    local_universal_feed_array = singleton_universal.universal_feed_array;
    
    [main_tableView reloadData];
    

    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    //    [main_tableView scrollRectToVisible:CGRectMake(0, main_tableView.contentSize.height - main_tableView.bounds.size.height, screenWidth, screenHeight-55) animated:NO];
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

@end
