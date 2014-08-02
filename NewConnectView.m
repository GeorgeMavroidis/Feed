//
//  NewConnectView.m
//  Feed
//
//  Created by George on 2014-06-30.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "NewConnectView.h"
#import <QuartzCore/QuartzCore.h>
#import <TMAPIClient.h>
#import "FeedMainViewController.h"
#import "TumblrComposeViewController.h"
#import "DataClass.h"

@implementation NewConnectView{
    CGRect screenRect;
    CGFloat screenWidth, screenHeight;
    UIScrollView *mainScrollView;
    UIWebView *webView;
}
-(void)viewDidAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewDidLoad{
    screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    
    UIImageView *backgrounds_poly = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    backgrounds_poly.image = [UIImage imageNamed:@"smaller_darker_blue.jpg"];
    backgrounds_poly.contentMode = UIViewContentModeScaleToFill;
    [backgrounds_poly setAlpha:0.6];
    [self.view addSubview:backgrounds_poly];
    
    UIView *black = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [black setBackgroundColor:[UIColor blackColor]];
    black.alpha = 0.6;
//    [self.view addSubview:black];
    
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    mainScrollView.contentSize = CGSizeMake(screenWidth, screenHeight+20);
    [mainScrollView setBackgroundColor:[UIColor clearColor]];
    mainScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:mainScrollView];
    
    
    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(10, 120, screenWidth-20, 300)];
    [card setBackgroundColor:[UIColor whiteColor]];
    [mainScrollView addSubview:card];
    [card.layer setCornerRadius:10.0f];
    
    UILabel *thanks = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, card.frame.size.width, 50)];
    thanks.text = @"Thanks!";
    thanks.textAlignment = NSTextAlignmentCenter;
    thanks.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
    [card addSubview:thanks];
    
    UILabel *please = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, card.frame.size.width, 50)];
    please.text = @"Please connect at least one other service";
    please.textAlignment = NSTextAlignmentCenter;
    please.font = [UIFont fontWithName:@"AvenirNext-Medium" size:15];
    [card addSubview:please];
    
    UIImageView *insta = [[UIImageView alloc] initWithFrame:CGRectMake(50, 170, 70, 70)];
    insta.image = [UIImage imageNamed:@"instagrams.png"];
    [card addSubview:insta];
    
    UIImageView *tumblr = [[UIImageView alloc] initWithFrame:CGRectMake(card.frame.size.width-130, 170, 70, 70)];
    tumblr.image = [UIImage imageNamed:@"tumblr.png"];
    [card addSubview:tumblr];
    
    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(instagramTap:)];
    [insta setUserInteractionEnabled:YES];
    [insta addGestureRecognizer:t];
    
    UITapGestureRecognizer *tu = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tumblrTap:)];
    [tumblr setUserInteractionEnabled:YES];
    [tumblr addGestureRecognizer:tu];
    
    
//    [self drawNext];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
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
-(void)myTimerTick:(NSTimer *)timer
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
        
        [defaults setObject:@"yes" forKey:@"instagram_connect"];
        
        //NSLog(split[1]);
        [timer invalidate];
        [self dismissModalViewControllerAnimated:YES];
        [self drawNext];
    }
    
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
-(void)closeModal{
    [self dismissModalViewControllerAnimated:YES];
}
-(void)drawNext{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGFloat nextHeight = 50;
    UIView *next = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight-nextHeight, screenWidth, nextHeight)];
    
    [next  setBackgroundColor:[UIColor colorWithRed: 0/255.0 green: 172.0/255.0 blue:245.0/255.0 alpha: 1.0]];
    //[next setAlpha:0.95];
    [self.view addSubview:next];
    
    UILabel *nextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, next.frame.size.width, next.frame.size.height)];
    
    nextLabel.text = @"Next";
    [nextLabel setTextColor:[UIColor whiteColor]];
    nextLabel.textAlignment = NSTextAlignmentCenter;
    nextLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:20.0f];
    [next addSubview:nextLabel];
    
    UITapGestureRecognizer *next_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextTap:)];
    [next addGestureRecognizer:next_recognizer];
}
- (void)nextTap:(UITapGestureRecognizer *)recognizer {
    FeedMainViewController *main = [[FeedMainViewController alloc] init];
    [self.navigationController pushViewController:main animated:YES];
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
        [defaults setObject:@"0" forKey:@"defaultTumblrBlog"];
        [defaults setObject:@"yes" forKey:@"tumblr_connect"];
        
        [timer invalidate];
        int defTB = 0;
        [defaults setInteger:0 forKey:@"defaultTumblrBlog"];
        [defaults setObject:@"yes" forKey:@"tumblr_connect"];
        NSLog(@"set in");
        
        
        DataClass *d_su = [DataClass getInstance];
        
        [[TMAPIClient sharedInstance] userInfo:^(id result, NSError *error) {
            if (!error){
                NSDictionary *t = result;
                NSMutableDictionary *blogs = [[result objectForKey:@"user"] objectForKey:@"blogs"];
                d_su.tumblrBlogs = blogs;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:blogs forKey:@"tumblrBlogs"];
                [defaults setObject:[[[defaults objectForKey:@"tumblrBlogs"] objectAtIndex:defTB] objectForKey:@"name"] forKey:@"default_tumblr_blog"];
                
            }
        }];

        [self dismissModalViewControllerAnimated:YES];
        
        [self drawNext];
    }
    
}

@end
