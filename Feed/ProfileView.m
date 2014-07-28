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
#import "InstagramCell.h"
#import "TwitterCell.h"
#import "TumblrCell.h"
#import "ProfileFunctions.h"
#import "CreationFunctions.h"
#import "STTwitterAPI.h"
#import <TMAPIClient.h>
#import <Accounts/Accounts.h>
#import "MBProgressHUD.h"
#import "AsyncImageView.h"

@implementation ProfileView{
    NSString *profiled, *typed, *insta_id;
    UIView *headerViewNew;
    
    UISearchBar *searchBar;
    UIRefreshControl *refresh;
    UILabel *profile;
    UIView *urlWrapper, *closeView,*profile_view;
    UIWebView *t;
    
    ProfileDataClass *singleton_universal;
    NSMutableArray *local_universal_feed_array;
    
    UIScrollView *mainSettingSV;
    UIWebView *webView;
    
    UILabel *twitter_username, *tumblr_username;
    UIScrollView *s;
    UIView *tumblr_view, *connectV;
}
@synthesize main_tableView;
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
-(id)initForInstagram:(NSString *)profile user_id:(NSString *)the_id type:(NSString *)type{
    self = [super init];
    if (self) {
        profiled = profile;
        typed = type;
        insta_id = the_id;
        NSLog(@"%@ %@", profiled, typed);
    }
    return self;
}
-(id)initForSelf:(NSString *)profile type:(NSString *)type{
    self = [super init];
    if (self) {
        profiled = profile;
        typed = type;
        NSLog(@"%@ %@", profiled, typed);
    }
    return self;
}
-(id)initForSelf{
    self = [super init];
    if (self) {
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        profiled = [d objectForKey:@"username"];
        typed = @"self";
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
//    self.view = main_tableView;
    singleton_universal.mainTableView = main_tableView;
    refresh = [[UIRefreshControl alloc] init];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [refresh addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [main_tableView addSubview:refresh];
    
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    mainSettingSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -screenHeight, screenWidth, screenHeight)];
    [mainSettingSV setBackgroundColor:[UIColor whiteColor]];
    [mainSettingSV setContentSize:CGSizeMake(screenWidth, screenHeight+40)];
    [self.view addSubview:mainSettingSV];
    
    headerViewNew = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 42)];
    [headerViewNew setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:headerViewNew];
    
    profile = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, screenWidth-80, 40)];
    profile.text = profiled;
    profile.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
    [profile setTextAlignment:NSTextAlignmentCenter];
    profile.text = profiled;
    [headerViewNew addSubview:profile];
    
    UIImageView *back_btn = [[UIImageView alloc] initWithFrame:CGRectMake(5, 13, 23, 20)];
    back_btn.image = [UIImage imageNamed:@"arrow_back.png"];
    [headerViewNew addSubview:back_btn];
    
//    [headerViewNew addSubview:hashtag];
    [self fetchFeeds];
    
//    [HashtagFunctions sortUniversalFeedByTime:singleton_universal];
    
    local_universal_feed_array = singleton_universal.universal_feed_array;
    
    [main_tableView reloadData];
    
    [self createSettingsPage];
    
    [main_tableView setContentInset:UIEdgeInsetsMake(40,0,0,0)];
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
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    //    [main_tableView scrollRectToVisible:CGRectMake(0, main_tableView.contentSize.height - main_tableView.bounds.size.height, screenWidth, screenHeight-55) animated:NO];
    DataClass *singleton_universal =[DataClass getInstance];
    
    singleton_universal.mainTableView = main_tableView;
    //    singleton_universal.mainNavController = self.navigationController;
    singleton_universal.mainViewController = self;
    
}
-(void)update{
    [refresh beginRefreshing];
    local_universal_feed_array = singleton_universal.universal_feed_array;
    [main_tableView reloadData];
    [main_tableView setNeedsDisplay];
    [refresh endRefreshing];
}
-(void)fetchFeeds{
    if([typed isEqualToString:@"instagram"]){
        [ProfileFunctions fetchTwitterFeed:profiled singleton:singleton_universal];
        
        [ProfileFunctions fetchInstagramFeed:insta_id singleton:singleton_universal];
        
        [ProfileFunctions addInstagramFeed:singleton_universal];
    }
    if([typed isEqualToString:@"twitter"]){
        [ProfileFunctions fetchTwitterFeed:profiled singleton:singleton_universal];
    }
    if([typed isEqualToString:@"tumblr"]){
        [ProfileFunctions fetchTumblrFeed:profiled singleton:singleton_universal];
    }
    if([typed isEqualToString:@"self"]){
        DataClass *su = [DataClass getInstance];
        
        
        NSString *documentsDirectory = [NSHomeDirectory()
                                        stringByAppendingPathComponent:@"Documents"];
        NSString *storePath = [documentsDirectory stringByAppendingPathComponent:@"twitter_auth"];
        NSMutableArray *twitter_auth = [NSMutableArray arrayWithContentsOfFile:storePath];
        //oAuthToken, oAuthTokenSecret, @"4tIoaRQHod1IQ00wtSmRw", @"S6GATtE4xirn5WlfW79d6aSH4ciMD196hPQuL2g52M8",
        NSString *oauthToken = [twitter_auth objectAtIndex:0];
        NSString *oauthTokenSecret = [twitter_auth objectAtIndex:1];
        NSString *consumerToken = [twitter_auth objectAtIndex:2];
        NSString *consumerTokenSecret = [twitter_auth objectAtIndex:3];
        
        STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerToken consumerSecret:consumerTokenSecret oauthToken:oauthToken oauthTokenSecret:oauthTokenSecret];
        
        [twitter verifyCredentialsWithSuccessBlock:^(NSString *usernam) {
            [ProfileFunctions fetchTwitterFeed:usernam singleton:singleton_universal];
            
        } errorBlock:^(NSError *error) {
            NSLog(@"ee %@", [error localizedDescription]);
        }];
        
        [ProfileFunctions fetchInstagramFeedForSelf:singleton_universal];
        [ProfileFunctions addInstagramFeed:singleton_universal];
        //Get blog 1
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        int defTB = [defaults integerForKey:@"defaultTumblrBlog"];
        if(defTB != 0){
            defTB = 0;
            [defaults setInteger:0 forKey:@"defaultTumblrBlog"];
            NSString *i = [[[defaults objectForKey:@"tumblrBlogs"] objectAtIndex:defTB] objectForKey:@"name"];
            [ProfileFunctions fetchTumblrFeed:i singleton:singleton_universal];
            
        }else{
            NSString *i = [defaults objectForKey:@"default_tumblr_blog"];
            
            [ProfileFunctions fetchTumblrFeed:i singleton:singleton_universal];
        }

       
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        UIImageView *settings_btn = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-37, 7, 30, 30)];
        settings_btn.image = [UIImage imageNamed:@"gear.png"];
        [headerViewNew addSubview:settings_btn];
        
        UIBarButtonItem *actual_settings_btn = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(settings)];
        self.navigationItem.rightBarButtonItem=actual_settings_btn;
        
    }
    
//    [HashtagFunctions fetchTumblrFeed:searched singleton:singleton_universal];
    
    //    [HashtagFunctions addTumblrFeed:singleton_universal];
    
    local_universal_feed_array = singleton_universal.universal_feed_array;
    [main_tableView reloadData];
}
-(void)createSettingsPage{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    connectV = [[UIView alloc] initWithFrame:CGRectMake(0, 120, screenWidth, 300)];
    [mainSettingSV addSubview:connectV];
    
    UIView *twitter_view = [[UIView alloc] initWithFrame:CGRectMake(20, 0, screenWidth-40, 50)];
    [connectV addSubview:twitter_view];
    
    UILabel *twitter_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth-40, 50)];
    twitter_label.text = @"Twitter";
    [twitter_view addSubview:twitter_label];
    
    UIView *instagram_view = [[UIView alloc] initWithFrame:CGRectMake(20, 50, screenWidth-40, 50)];
    [connectV addSubview:instagram_view];
    
    UILabel *instagram_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth-40, 50)];
    instagram_label.text = @"Instagram";
    [instagram_view addSubview:instagram_label];
    
    tumblr_view = [[UIView alloc] initWithFrame:CGRectMake(20, 100, screenWidth-40, 50)];
    [connectV addSubview:tumblr_view];
    
    UILabel *tumblr_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth-40, 50)];
    tumblr_label.text = @"Tumblr";
    [tumblr_view addSubview:tumblr_label];
    
    
    
    twitter_username = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, screenWidth, 50)];
    
    NSData* data_tui = [defaults objectForKey:@"twitter_user_info"];
    NSDictionary *tui = [NSKeyedUnarchiver unarchiveObjectWithData:data_tui];
    
    twitter_username.text = [NSString stringWithFormat:@"@%@", [tui objectForKey:@"screen_name"]];
            
    

    [twitter_view addSubview:twitter_username];
    
    UILabel *instagram_username = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, screenWidth, 50)];
    
    NSString *access = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"instagram_access_token"];
    NSString *instagram_base_url = @"https://api.instagram.com/v1/users/self/?access_token=";
    NSString *instagram_feed_url = [instagram_base_url stringByAppendingString:access];
    
    NSString *instagram_user_feed = [NSString stringWithFormat:instagram_feed_url];
    NSURL *url = [NSURL URLWithString:instagram_feed_url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSData *jsonData = data;
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:jsonData //1
                          
                          options:kNilOptions
                          error:&error];
    
    NSDictionary *instagram_data = [json objectForKey:@"data"]; //2
//    NSLog(@"data %@", instagram_data);
    instagram_username.text = [instagram_data objectForKey:@"username" ];
    [instagram_view addSubview:instagram_username];
    
    tumblr_username = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, screenWidth, 50)];
    DataClass *dc = [DataClass getInstance];
//    NSLog(@"tumblrLogs %@",[defaults objectForKey:@"tumblrBlogs"]);
    int defTB = [defaults integerForKey:@"defaultTumblrBlog"];
    if(defTB != 0){
        defTB = 0;
        [defaults setInteger:0 forKey:@"defaultTumblrBlog"];
        NSLog(@"set in");
        tumblr_username.text = [[[defaults objectForKey:@"tumblrBlogs"] objectAtIndex:defTB] objectForKey:@"name"];
        
    }else{
        tumblr_username.text = [defaults objectForKey:@"default_tumblr_blog"];
    }
//    defTB = 0;
    [tumblr_view addSubview:tumblr_username];
    
    
    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(instagramTap:)];
    [instagram_view setUserInteractionEnabled:YES];
    [instagram_view addGestureRecognizer:t];
    
//    UITapGestureRecognizer *tu = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tumblrTap:)];
    UITapGestureRecognizer *tu = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeUser)];
    [tumblr_view setUserInteractionEnabled:YES];
    [tumblr_view addGestureRecognizer:tu];
    
    
    UITapGestureRecognizer *twitter_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twitterTap:)];
    [twitter_view setUserInteractionEnabled:YES];
    [twitter_view addGestureRecognizer:twitter_recognizer];
}
- (void)twitterTap:(UITapGestureRecognizer *)recognizer {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    
    // Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        // Get the list of Twitter accounts.
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            if([accountsArray count] == 0){
                [self webLogin];
            }else{
                //NSLog(@"%@", accountsArray);
                [self performSelectorOnMainThread:@selector(populateSheetAndShow:) withObject:accountsArray waitUntilDone:NO];
            }
        }else{
            [self webLogin];
        }
    }];
}
-(void)webLogin{
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        NSString *urlAddress = @"http://www.georgemavroidis.com/feed/twitter/t4/index.php";
        NSURL *url = [NSURL URLWithString:urlAddress];
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        if ([strData rangeOfString:@"REQUEST_LINK"].location == NSNotFound) {
            NSLog(@"none");
        } else {
            //NSLog(@"contains access token");
            NSArray *split = [strData componentsSeparatedByString:@"|||"];
            urlAddress = split[1];
            //        NSLog(urlAddress);
        }
        CGRect webFrame = CGRectMake(0.0, 0.0, screenWidth, screenHeight);
        
        webView = [[UIWebView alloc] init];
        webView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        [webView setBackgroundColor:[UIColor clearColor]];
        
        url = [NSURL URLWithString:urlAddress];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [webView loadRequest:requestObj];
        
        UIViewController *viewController = [[UIViewController alloc] init];
        viewController.view = webView;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeModal)];
        
        [self presentViewController:navigationController animated:YES completion:nil];
        
        
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(myTwitterTimerTick:) userInfo:nil repeats:YES]; // the interval is in seconds...
        
        //Your code goes here
        
    });
    
}

-(void)closeModal{
    [self dismissModalViewControllerAnimated:YES];
    
}
-(void)myTimerTick:(NSTimer *)timer{
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    //    NSLog(html);
    if ([html rangeOfString:@"OAUTH_TOKEN"].location == NSNotFound) {
        NSLog(@"none");
    } else {
        //NSLog(@"contains access token");
        NSArray *split = [html componentsSeparatedByString:@"|||"];
        NSString *os = split[1];
        
        split = [html componentsSeparatedByString:@"||||"];
        NSString *osec = split[1];
        NSLog(@"%@ %@", os, osec);
        
        NSMutableArray *twitter_auth_array = [[NSMutableArray alloc] initWithObjects:os, osec, @"4tIoaRQHod1IQ00wtSmRw", @"S6GATtE4xirn5WlfW79d6aSH4ciMD196hPQuL2g52M8", nil];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:twitter_auth_array forKey:@"twitter_auth_array"];
        NSString *documentsDirectory = [NSHomeDirectory()
                                        stringByAppendingPathComponent:@"Documents"];
        
        NSString *storePath = [documentsDirectory stringByAppendingPathComponent:@"twitter_auth.txt"];
        [@"yes" writeToFile:storePath atomically:YES];
        storePath = [documentsDirectory stringByAppendingPathComponent:@"twitter_auth"];
        [twitter_auth_array writeToFile:storePath atomically:YES];
        [timer invalidate];
        [self dismissModalViewControllerAnimated:YES];
        
        [defaults setObject:@"yes" forKey:@"twitter"];
        
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
        
    }else{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Do something...
        });
        //  [actionSheet dismissWithClickedButtonIndex:<#(NSInteger)#> animated:<#(BOOL)#>]
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        
        // Create an account type that ensures Twitter accounts are retrieved.
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
        
        ACAccount *acct = [accountsArray objectAtIndex:(int)buttonIndex - 1];
        //self.STTwitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:@"4tIoaRQHod1IQ00wtSmRw" consumerSecret:@"S6GATtE4xirn5WlfW79d6aSH4ciMD196hPQuL2g52M8"];
        //self.STTwitter = [STTwitterAPI twitterAPIOSWithAccount:acct];
        
        STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:nil consumerKey:@"4tIoaRQHod1IQ00wtSmRw" consumerSecret:@"S6GATtE4xirn5WlfW79d6aSH4ciMD196hPQuL2g52M8"];
        
        [twitter postReverseOAuthTokenRequest:^(NSString *authenticationHeader) {
            
            STTwitterAPI *twitterAPIOS = [STTwitterAPI twitterAPIOSWithAccount:acct];
            
            [twitterAPIOS verifyCredentialsWithSuccessBlock:^(NSString *username) {
                
                [twitterAPIOS postReverseAuthAccessTokenWithAuthenticationHeader:authenticationHeader
                                                                    successBlock:^(NSString *oAuthToken,
                                                                                   NSString *oAuthTokenSecret,
                                                                                   NSString *userID,
                                                                                   NSString *screenName) {
                                                                        NSLog(screenName);
                                                                        NSMutableArray *twitter_auth_array = [[NSMutableArray alloc] initWithObjects:oAuthToken, oAuthTokenSecret, @"4tIoaRQHod1IQ00wtSmRw", @"S6GATtE4xirn5WlfW79d6aSH4ciMD196hPQuL2g52M8", nil];
                                                                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                                        [defaults setObject:twitter_auth_array forKey:@"twitter_auth_array"];
                                                                        NSString *documentsDirectory = [NSHomeDirectory()
                                                                                                        stringByAppendingPathComponent:@"Documents"];
                                                                        
                                                                        NSString *storePath = [documentsDirectory stringByAppendingPathComponent:@"twitter_auth.txt"];
                                                                        [@"yes" writeToFile:storePath atomically:YES];
                                                                        storePath = [documentsDirectory stringByAppendingPathComponent:@"twitter_auth"];
                                                                        [twitter_auth_array writeToFile:storePath atomically:YES];
                                                                        
                                                                        [defaults setObject:@"yes" forKey:@"twitter"];
                                                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                                        
                                                                        twitter_username.text = [NSString stringWithFormat:@"@%@",username];
                                                                        
                                                                        [twitter getUserInformationFor:username successBlock:^(NSDictionary *user) {
                                                                            NSData* data=[NSKeyedArchiver archivedDataWithRootObject:user];
                                                                            [defaults setObject:data forKey:@"twitter_user_info"];
                                                                            
                                                                            //            screen_name.text = [user objectForKey:@"name"];
                                                                        } errorBlock:^(NSError *error) {
                                                                            
                                                                        }];
                                                                        
                                                                        [self refreshTable];
                                                                        // use the tokens...
                                                                    } errorBlock:^(NSError *error) {
                                                                        NSLog(@"error: %@", [error localizedDescription]);
                                                                        // ...
                                                                    }];
                
            } errorBlock:^(NSError *error) {
                // ...
            }];
            
        } errorBlock:^(NSError *error) {
            // ...
        }];
    }
    
    //[self fetchTimelineForUser:[actionSheet buttonTitleAtIndex:buttonIndex]];
    
}
-(void)populateSheetAndShow:(NSArray *) accountsArray {
    NSMutableArray *buttonsArray = [NSMutableArray array];
    
    [accountsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [buttonsArray addObject:((ACAccount*)obj).username];
    }];
    //NSLog(@"%@", buttonsArray);
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:nil];
    actionSheet.delegate = self;
    for( NSString *title in buttonsArray)
        [actionSheet addButtonWithTitle:title];
    [actionSheet showInView:self.view];
}

-(void)settings{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    if(mainSettingSV.frame.origin.y == -screenHeight){
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             CGRect new_f = mainSettingSV.frame;
                             new_f = CGRectMake(0, 40, screenWidth, screenHeight);
                             mainSettingSV.frame = new_f;
                         }
                         completion:^(BOOL finished){
                             NSLog(@"Done!");
                         }];
    }else{
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             CGRect new_f = mainSettingSV.frame;
                             new_f = CGRectMake(0, -screenHeight, screenWidth, screenHeight);
                             mainSettingSV.frame = new_f;
                         }
                         completion:^(BOOL finished){
                             NSLog(@"Done!");
                         }];
    }
    
}
-(void)changeUser{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    s = [[UIScrollView alloc] initWithFrame:CGRectMake(tumblr_view.frame.origin.x,connectV.frame.origin.y+ tumblr_view.frame.size.height+tumblr_view.frame.origin.y, screenWidth-40, 160)];
    [s setBackgroundColor:[UIColor whiteColor]];
    //    [s setBackgroundColor:[UIColor blackColor]];
    [mainSettingSV addSubview:s];
    
    DataClass *su = [DataClass getInstance];
    
    int numberOfBlogs = [[defaults objectForKey:@"tumblrBlogs"] count];
    for(int i =0; i < numberOfBlogs; i++){
        UIView *temp = [[UIView alloc] initWithFrame:CGRectMake(0, 40*i, s.frame.size.width, 40)];
        [s addSubview:temp];
        
        UILabel *tt = [[UILabel alloc] initWithFrame:CGRectMake(40, 40*i, 200, 40)];
        tt.text = [[[defaults objectForKey:@"tumblrBlogs"] objectAtIndex:i] objectForKey:@"name"];
        [s addSubview:tt];
        
        UIImageView *ti = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40*i+5, 30, 30)];
        //        [ti setImageWithURL:[NSURL URLWithString:[self returnTumblrProfilePicture:tt.text]] placeholderImage:[UIImage imageNamed:@"insta_placeholder.png"]];
        ti.imageURL = [NSURL URLWithString:[self returnTumblrProfilePicture:tt.text]];
        [s addSubview:ti];
        
        UITapGestureRecognizer *m = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actualChange:)];
        [tt setUserInteractionEnabled:YES];
        [ti setUserInteractionEnabled:YES];
        //        [ti addGestureRecognizer:m];
        [tt addGestureRecognizer:m];
        
    }
    [s setContentSize:CGSizeMake(tumblr_view.frame.size.width-100, numberOfBlogs*40+40)];
    
    NSLog(@"here");
}

-(NSString *)returnTumblrProfilePicture:(NSString *)username{
    NSString *base  =@"http://api.tumblr.com/v2/blog/";
    base = [base stringByAppendingString:username];
    base = [base stringByAppendingString:@".tumblr.com/avatar/96"];
    base = [base stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return base;
}
-(void)actualChange:(UITapGestureRecognizer *) resp{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UILabel *m = (UILabel *)resp.view;
    [s removeFromSuperview];
    tumblr_username.text = m.text;
    [defaults setObject:m.text forKey:@"default_tumblr_blog"];
    
    [self refreshTable];
//    usern.text = m.text;
//    profile_image.imageURL = [NSURL URLWithString:[self returnTumblrProfilePicture:m.text]];
    
}

- (void)tumblrTap:(UITapGestureRecognizer *)recognizer {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect webFrame = CGRectMake(0.0, 0.0, screenWidth, screenHeight);
    webView = [[UIWebView alloc] initWithFrame:webFrame];
    [webView setBackgroundColor:[UIColor clearColor]];
    NSString *urlAddress = @"http://georgemavroidis.com/feed/tumblr/connect.php";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view = webView;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeModal)];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(myTumblrTimerTick:) userInfo:nil repeats:YES]; // the interval is in seconds...
    
}
- (void)instagramTap:(UITapGestureRecognizer *)recognizer {
    //Instagram authentication Url = https://api.instagram.com/oauth/authorize/?client_id=a0225acb81dd48c78b10359080d6146d&amp;redirect_uri=http://www.georgemavroidis.com/feed/instagram/instagram.php;response_type=code&scope=basic+likes+comments+relationships
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect webFrame = CGRectMake(0.0, 0.0, screenWidth, screenHeight);
    webView = [[UIWebView alloc] initWithFrame:webFrame];
    [webView setBackgroundColor:[UIColor clearColor]];
    NSString *urlAddress = @"https://api.instagram.com/oauth/authorize/?client_id=a0225acb81dd48c78b10359080d6146d&amp;redirect_uri=http://www.georgemavroidis.com/feed/instagram/instagram.php;response_type=code&scope=basic+likes+comments+relationships";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view = webView;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeModal)];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(myTimerTick:) userInfo:nil repeats:YES]; // the interval is in seconds...
    
}
-(void)myTwitterTimerTick:(NSTimer *)timer
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    
    if ([html rangeOfString:@"Access Token"].location == NSNotFound) {
        NSLog(@"none");
    } else {
        //NSLog(@"contains access token");
        NSArray *split = [html componentsSeparatedByString:@"|||"];
        [defaults setValue:split[1] forKey:@"instagram_access_token"];
        [defaults setObject:split[1] forKey:@"@instagram_auth_array"];
        NSString *documentsDirectory = [NSHomeDirectory()
                                        stringByAppendingPathComponent:@"Documents"];
        
        NSString *storePath = [documentsDirectory stringByAppendingPathComponent:@"instagram_auth.txt"];
        [@"yes" writeToFile:storePath atomically:YES];
        
        
        //NSLog(split[1]);
        [timer invalidate];
        [self dismissModalViewControllerAnimated:YES];
//        [self drawNext];
    }
    
}
-(void)myTumblrTimerTick:(NSTimer *)timer
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    
    if ([html rangeOfString:@"oauth_token:|||"].location == NSNotFound) {
        NSLog(@"none");
    } else {
        
        //NSLog(@"contains access token");
        NSArray *split = [html componentsSeparatedByString:@"|||"];
        NSString *os = split[1];
        
        split = [html componentsSeparatedByString:@"||||"];
        NSString *osec = split[1];
        
        [TMAPIClient sharedInstance].OAuthToken = os;
        [TMAPIClient sharedInstance].OAuthTokenSecret = osec;
        
        
        NSLog(@"%@ %@", os, osec);
        [defaults setObject:os forKey:@"Tumblr_OAuthToken"];
        [defaults setObject:osec forKey:@"Tumblr_OAuthTokenSecret"];
        [defaults setInteger:0 forKey:@"defaultTumblrBlog"];
        [timer invalidate];
        [self dismissModalViewControllerAnimated:YES];
        
    }
    
}
- (void)refreshTable{
    [refresh beginRefreshing];
    
    [singleton_universal.universal_facebook_feed removeAllObjects];
    [singleton_universal.universal_feed_array removeAllObjects];
    [singleton_universal.universal_instagram_feed removeAllObjects];
    [singleton_universal.universal_tumblr_feed removeAllObjects];
    [singleton_universal.universal_twitter_feed removeAllObjects];
    
    
    [self fetchFeeds];
    local_universal_feed_array = singleton_universal.universal_feed_array;
    [main_tableView reloadData];
    [main_tableView setNeedsDisplay];
    [refresh endRefreshing];
    
    
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
@end
