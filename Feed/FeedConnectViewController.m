//
//  FeedConnectViewController.m
//  Feed
//
//  Created by George on 2/13/2014.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "FeedConnectViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <Twitter/Twitter.h>
#import "UIImageView+WebCache.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import <GooglePlus/GPPSignIn.h>
#import <GoogleOpenSource/GTLPlusConstants.h>
#import "FeedMainViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "AsyncImageView.h"
#import "STTwitter.h"
#import "DataClass.h"
#import "AppDelegate.h"
#import <TMAPIClient.h>


@interface FeedConnectViewController (){
    UIScrollView *mainSV;
    UIView *facebook, *twitter, *plus, *instagram, *tumblr, *pinterest, *flickr, *linkedin;
    UILabel *facebookLabel, *twitterLabel, *plusLabel, *instagramLabel, *tumblrLabel, *pinterestLabel, *flickrLabel, *linkedinLabel;
    UIImageView *profilePictureView, *tprofilePictureView;
    NSString *twitProfURL;
    UIImageView *back;
    GPPSignIn *signIn;
    DataClass *singleton_universal;
}
//@property (strong, nonatomic) NSArray *array;
@property (nonatomic) ACAccountStore *accountStore;
@property (nonatomic, strong) STTwitterAPI *STTwitter;
@end

@implementation FeedConnectViewController
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
    [self setUserDefaults];
    singleton_universal = [[DataClass alloc] init];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent
                                                animated:YES];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    [GPPSignInButton class];
    signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // "https://www.googleapis.com/auth/plus.login" scope
    
    signIn.delegate = self;

    _accountStore = [[ACAccountStore alloc] init];
    tprofilePictureView = [[UIImageView alloc] init];
    
    mainSV = [[UIScrollView alloc] init];
    [mainSV setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [mainSV setBackgroundColor:[UIColor clearColor]];
    mainSV.contentSize =CGSizeMake((screenWidth-100)*8, screenHeight);
    //mainSV.pagingEnabled = YES;
    
    back = [[UIImageView alloc] init];
    [back setImageWithURL:[NSURL URLWithString:@"http://georgemavroidis.com/feed/images/Eiffel-Tower-Paris.jpg"] placeholderImage:[UIImage imageNamed:@"nyc.jpg"]];
    float skew = 1.4;
    back.frame = CGRectMake(-100*skew, -40, 800*skew, 500*skew);
    
    [self.view addSubview:back];
    [self.view addSubview:mainSV];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    self.title = @"Connect";
    [self drawConnections];
    [signIn trySilentAuthentication];
    
    [TMAPIClient sharedInstance].OAuthConsumerKey = @"gPPreRGZ96PskkcUk9J0fg70gCjWtI8AfO3aq20Ssenqzj5KIs";
    [TMAPIClient sharedInstance].OAuthConsumerSecret = @"zDyi5guipOImlfJEAd7Q4aTodo1z7Y3p66cXOvrA4xa6b9gSiI";
    
    [self nextScreen];
}
-(void)setUserDefaults{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
}
-(void)drawConnections{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGFloat socialWidth = screenWidth-100;
    CGFloat socialHeight = screenHeight/1.7;
    CGFloat socialTop = 100;
    CGFloat socialSpace = socialWidth+20;
    facebook = [[UIView alloc] init];
    facebook.frame = CGRectMake(30+socialSpace*0, socialTop, socialWidth, socialHeight);
    [facebook setBackgroundColor:[UIColor colorWithRed: 59.0/255.0 green: 89.0/255.0 blue:152.0/255.0 alpha: 1.0]];
    facebook.clipsToBounds = YES;
    [mainSV addSubview:facebook];
    
    twitter = [[UIView alloc] init];
    twitter.frame = CGRectMake(30+socialSpace*1, socialTop, socialWidth, socialHeight);
    [twitter setBackgroundColor:[UIColor colorWithRed: 0/255.0 green: 172.0/255.0 blue:237.0/255.0 alpha: 1.0]];
    twitter.clipsToBounds = YES;
    [mainSV addSubview:twitter];
   
    plus = [[UIView alloc] init];
    plus.frame = CGRectMake(30+socialSpace*2, socialTop, socialWidth, socialHeight);
    [plus setBackgroundColor:[UIColor colorWithRed: 221/255.0 green: 75/255.0 blue:57/255.0 alpha: 1.0]];
    plus.clipsToBounds = YES;
    [mainSV addSubview:plus];

    instagram = [[UIView alloc] init];
    instagram.frame = CGRectMake(30+socialSpace*3, socialTop, socialWidth, socialHeight);
    [instagram setBackgroundColor:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0]];
    instagram.clipsToBounds = YES;
    [mainSV addSubview:instagram];
    
    tumblr = [[UIView alloc] init];
    tumblr.frame = CGRectMake(30+socialSpace*4, socialTop, socialWidth, socialHeight);
    [tumblr setBackgroundColor:[UIColor colorWithRed: 50/255.0 green: 80/255.0 blue:109/255.0 alpha: 1.0]];
    instagram.clipsToBounds = YES;
    [mainSV addSubview:tumblr];

    pinterest = [[UIView alloc] init];
    pinterest.frame = CGRectMake(30+socialSpace*5, socialTop, socialWidth, socialHeight);
    [pinterest setBackgroundColor:[UIColor colorWithRed: 203/255.0 green: 32/255.0 blue:39/255.0 alpha: 1.0]];
    facebook.clipsToBounds = YES;
    [mainSV addSubview:pinterest];

    flickr = [[UIView alloc] init];
    flickr.frame = CGRectMake(30+socialSpace*6, socialTop, socialWidth, socialHeight);
    [flickr setBackgroundColor:[UIColor colorWithRed: 255/255.0 green: 0/255.0 blue:132/255.0 alpha: 1.0]];
    flickr.clipsToBounds = YES;
    [mainSV addSubview:flickr];

   /* linkedin = [[UIView alloc] init];
    linkedin.frame = CGRectMake(30, 800, screenWidth-60, 100);
    [linkedin setBackgroundColor:[UIColor colorWithRed: 0/255.0 green: 123/255.0 blue:182/255.0 alpha: 1.0]];
    [mainSV addSubview:linkedin];*/
    
    
    //Labels
    facebookLabel = [[UILabel alloc] init];
    facebookLabel.text = @"Facebook";
    facebookLabel.frame = CGRectMake(0, 0, facebook.frame.size.width, facebook.frame.size.height);
    [facebookLabel setCenter:facebookLabel.center];
    [facebookLabel setTextColor:[UIColor whiteColor]];
    [facebookLabel setFont:[UIFont systemFontOfSize:22.0f]];
    facebookLabel.textAlignment = NSTextAlignmentCenter;
    [facebook addSubview:facebookLabel];
    
    twitterLabel = [[UILabel alloc] init];
    twitterLabel.text = @"Twitter";
    twitterLabel.frame = CGRectMake(0, 0, twitter.frame.size.width, twitter.frame.size.height);
    [twitterLabel setCenter:facebookLabel.center];
    [twitterLabel setTextColor:[UIColor whiteColor]];
    [twitterLabel setFont:[UIFont systemFontOfSize:22.0f]];
    twitterLabel.textAlignment = NSTextAlignmentCenter;
    [twitter addSubview:twitterLabel];
    
    plusLabel = [[UILabel alloc] init];
    plusLabel.text = @"Google+";
    plusLabel.frame = CGRectMake(0, 0, plus.frame.size.width, plus.frame.size.height);
    [plusLabel setCenter:facebookLabel.center];
    [plusLabel setTextColor:[UIColor whiteColor]];
    [plusLabel setFont:[UIFont systemFontOfSize:22.0f]];
    plusLabel.textAlignment = NSTextAlignmentCenter;
    [plus addSubview:plusLabel];
    
    instagramLabel = [[UILabel alloc] init];
    instagramLabel.text = @"Instagram";
    instagramLabel.frame = CGRectMake(0, 0, instagram.frame.size.width, instagram.frame.size.height);
    [instagramLabel setCenter:facebookLabel.center];
    [instagramLabel setTextColor:[UIColor whiteColor]];
    [instagramLabel setFont:[UIFont systemFontOfSize:22.0f]];
    instagramLabel.textAlignment = NSTextAlignmentCenter;
    [instagram addSubview:instagramLabel];
    
    tumblrLabel = [[UILabel alloc] init];
    tumblrLabel.text = @"Tumblr";
    tumblrLabel.frame = CGRectMake(0, 0, tumblr.frame.size.width, tumblr.frame.size.height);
    [tumblrLabel setCenter:facebookLabel.center];
    [tumblrLabel setTextColor:[UIColor whiteColor]];
    [tumblrLabel setFont:[UIFont systemFontOfSize:22.0f]];
    tumblrLabel.textAlignment = NSTextAlignmentCenter;
    [tumblr addSubview:tumblrLabel];
    
    pinterestLabel = [[UILabel alloc] init];
    pinterestLabel.text = @"Pinterest";
    pinterestLabel.frame = CGRectMake(0, 0, pinterest.frame.size.width, pinterest.frame.size.height);
    [pinterestLabel setCenter:facebookLabel.center];
    [pinterestLabel setTextColor:[UIColor whiteColor]];
    [pinterestLabel setFont:[UIFont systemFontOfSize:22.0f]];
    pinterestLabel.textAlignment = NSTextAlignmentCenter;
    [pinterest addSubview:pinterestLabel];
    
    flickrLabel = [[UILabel alloc] init];
    flickrLabel.text = @"Flickr";
    flickrLabel.frame = CGRectMake(0, 0, flickr.frame.size.width, flickr.frame.size.height);
    [flickrLabel setCenter:facebookLabel.center];
    [flickrLabel setTextColor:[UIColor whiteColor]];
    [flickrLabel setFont:[UIFont systemFontOfSize:22.0f]];
    flickrLabel.textAlignment = NSTextAlignmentCenter;
    [flickr addSubview:flickrLabel];
    
    //Make them into buttons
    UITapGestureRecognizer *facebook_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(facebookTap:)];
    [facebook addGestureRecognizer:facebook_recognizer];
    
    UITapGestureRecognizer *twitter_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twitterTap:)];
    [twitter addGestureRecognizer:twitter_recognizer];
    
    UITapGestureRecognizer *plus_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(plusTap:)];
    [plus addGestureRecognizer:plus_recognizer];
    
    UITapGestureRecognizer *instagram_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(instagramTap:)];
    [instagram addGestureRecognizer:instagram_recognizer];
    
    UITapGestureRecognizer *tumblr_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tumblrTap:)];
    [tumblr addGestureRecognizer:tumblr_recognizer];
    
    UITapGestureRecognizer *pinterest_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pinterestTap:)];
    [pinterest addGestureRecognizer:pinterest_recognizer];
    
    UITapGestureRecognizer *flickr_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flickrTap:)];
    [flickr addGestureRecognizer:flickr_recognizer];
    
    [self drawNext];
    
    
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
- (void)nextScreen {
    FeedMainViewController *main = [[FeedMainViewController alloc] init];
    [self.navigationController pushViewController:main animated:YES];
}
//Event Handling Method
- (void)facebookTap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"facebook");
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    NSString *schedule_path = [documentsDirectory
                               stringByAppendingPathComponent:@"facebook.txt"];
    NSString *check_facebook = [NSString stringWithContentsOfFile:schedule_path
                                                         encoding:NSUTF8StringEncoding
                                                            error:NULL];
    check_facebook = @"no";
    check_facebook = @"yes";
    if([check_facebook isEqualToString:@"yes"]){
        
        
        // If the session state is any of the two "open" states when the button is clicked
        if (FBSession.activeSession.state == FBSessionStateOpen
            || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
            
            // Close the session and remove the access token from the cache
            // The session state handler (in the app delegate) will be called automatically
            [FBSession.activeSession closeAndClearTokenInformation];
            
            // If the session state is not any of the two "open" states when the button is clicked
        } else {
            // Open a session showing the user the login UI
            // You must ALWAYS ask for basic_info permissions when opening a session
            //USed to be basic_info
            [FBSession openActiveSessionWithReadPermissions:@[@"public_profile, user_friends"]
                                               allowLoginUI:YES
                                          completionHandler:
             ^(FBSession *session, FBSessionState state, NSError *error) {
                 
                 // Retrieve the app delegate
                 AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
                 // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
                 [appDelegate sessionStateChanged:session state:state error:error];

             }];
        }
        
        
    }else{
        // Initialize a session object
        FBSession *session = [[FBSession alloc] init];
        // Set the active session
        [FBSession setActiveSession:session];
        // Open the session
        [session openWithBehavior:FBSessionLoginBehaviorWithNoFallbackToWebView
            completionHandler:^(FBSession *session,
                                FBSessionState status,
                                NSError *error) {
                // Respond to session state changes,
                // ex: updating the view
            }];
    }
}
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    NSLog(user.id);
}
-(void)drawFacebookLoggedIn{
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    NSString *schedule_path = [documentsDirectory
                               stringByAppendingPathComponent:@"facebook_username.txt"];
    NSString *facebook_username = [NSString stringWithContentsOfFile:schedule_path
                                                         encoding:NSUTF8StringEncoding
                                                            error:NULL];

    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", facebook_username];
    NSURL *url = [NSURL URLWithString:userImageURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    profilePictureView = [[UIImageView alloc] initWithImage:img];
    profilePictureView.frame = CGRectMake(5, 15, 70, 70);
    profilePictureView.clipsToBounds = YES;
    profilePictureView.layer.cornerRadius = 35.0f;
    
    NSString *coverImageURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@?fields=cover", facebook_username];
    url = [NSURL URLWithString:coverImageURL];
    data = [NSData dataWithContentsOfURL:url];
    NSData *jsonData = data;
    NSError *e;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
    NSDictionary *cover = [dict objectForKey:@"cover"];
    NSString *source = [cover objectForKey:@"source"];
    NSURL *coverurl = [NSURL URLWithString:source];
    NSData *coverdata = [NSData dataWithContentsOfURL:coverurl];
    UIImage *coverimg = [[UIImage alloc] initWithData:coverdata];
    UIImageView *coverView = [[UIImageView alloc] initWithImage:coverimg];
    CGFloat width = coverimg.size.width;
    CGFloat height = coverimg.size.height;
    coverView.frame = CGRectMake(0, 0, width/2.5, height/2.5);
    
    
    [facebook addSubview:coverView];
    [facebook addSubview:profilePictureView];
    [facebook addSubview:facebookLabel];
    CGRect frame = facebookLabel.frame;
    frame.origin.x = 70;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         facebookLabel.frame = frame;
                         [facebook setAlpha:0.5];
                     }
                     completion:^(BOOL finished){
                         
                     }];

    
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
            //NSLog(@"%@", accountsArray);
            [self performSelectorOnMainThread:@selector(populateSheetAndShow:) withObject:accountsArray waitUntilDone:NO];
        }else{
            [self twitterFallback];
        }
    }];
}
-(void)twitterFallback{
    NSLog(@"fallback");
}
-(void)populateSheetAndShow:(NSArray *) accountsArray {
    NSMutableArray *buttonsArray = [NSMutableArray array];
    [accountsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [buttonsArray addObject:((ACAccount*)obj).username];
    }];
    //NSLog(@"%@", buttonsArray);
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.delegate = self;
    for( NSString *title in buttonsArray)
        [actionSheet addButtonWithTitle:title];
    [actionSheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
  //  [actionSheet dismissWithClickedButtonIndex:<#(NSInteger)#> animated:<#(BOOL)#>]
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
    
    ACAccount *acct = [accountsArray objectAtIndex:(int)buttonIndex];
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
                                                                    NSMutableArray *twitter_auth_array = [[NSMutableArray alloc] initWithObjects:oAuthToken, oAuthTokenSecret, @"4tIoaRQHod1IQ00wtSmRw", @"S6GATtE4xirn5WlfW79d6aSH4ciMD196hPQuL2g52M8", nil];
                                                                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                                    [defaults setObject:twitter_auth_array forKey:@"twitter_auth_array"];
                                                                    NSString *documentsDirectory = [NSHomeDirectory()
                                                                                                    stringByAppendingPathComponent:@"Documents"];
                                                                    
                                                                    NSString *storePath = [documentsDirectory stringByAppendingPathComponent:@"twitter_auth.txt"];
                                                                    [@"yes" writeToFile:storePath atomically:YES];
                                                                    storePath = [documentsDirectory stringByAppendingPathComponent:@"twitter_auth"];
                                                                    [twitter_auth_array writeToFile:storePath atomically:YES];

                                                                    // use the tokens...
                                                                } errorBlock:^(NSError *error) {
                                                                    // ...
                                                                }];
            
        } errorBlock:^(NSError *error) {
            // ...
        }];
        
    } errorBlock:^(NSError *error) {
        // ...
    }];
    
    //[self fetchTimelineForUser:[actionSheet buttonTitleAtIndex:buttonIndex]];

}- (void)plusTap:(UITapGestureRecognizer *)recognizer {
    // Make sure the GPPSignInButton class is linked in because references from
    // xib file doesn't count.
    [signIn authenticate];
    
    
}
- (void)instagramTap:(UITapGestureRecognizer *)recognizer {
    //Instagram authentication Url = https://api.instagram.com/oauth/authorize/?client_id=a0225acb81dd48c78b10359080d6146d&amp;redirect_uri=http://www.georgemavroidis.com/feed/instagram/instagram.php;response_type=code&scope=basic+likes+comments+relationships
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect webFrame = CGRectMake(0.0, 0.0, screenWidth, screenHeight);
    UIWebView *webView = [[UIWebView alloc] initWithFrame:webFrame];
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
    NSString *urlAddress = @"https://api.instagram.com/oauth/authorize/?client_id=a0225acb81dd48c78b10359080d6146d&amp;redirect_uri=http://www.georgemavroidis.com/feed/instagram/instagram.php;response_type=code&scope=basic+likes+comments+relationships";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([strData rangeOfString:@"Access Token"].location == NSNotFound) {
        NSLog(@"none");
    } else {
        //NSLog(@"contains access token");
        NSArray *split = [strData componentsSeparatedByString:@"|||"];
        [defaults setValue:split[1] forKey:@"instagram_access_token"];
        [defaults setObject:split[1] forKey:@"@instagram_auth_array"];
        NSString *documentsDirectory = [NSHomeDirectory()
                                        stringByAppendingPathComponent:@"Documents"];
        
        NSString *storePath = [documentsDirectory stringByAppendingPathComponent:@"instagram_auth.txt"];
        [@"yes" writeToFile:storePath atomically:YES];

        
        //NSLog(split[1]);
        [timer invalidate];
        [self dismissModalViewControllerAnimated:YES];
    }
    
}
- (void)tumblrTap:(UITapGestureRecognizer *)recognizer {
    // Make the request
    
}
- (void)pinterestTap:(UITapGestureRecognizer *)recognizer {
    
}
- (void)flickrTap:(UITapGestureRecognizer *)recognizer {
    
}
-(void)closeModal{
    [self dismissModalViewControllerAnimated:YES];
    
}
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    if (error) {
        NSLog(@"Received error %@ and auth object %@",error, auth);
    } else {
        
        NSLog(@"%@", signIn.authentication.userEmail);
        
        //[self refreshInterfaceBasedOnSignIn];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)fetchTimelineForUser:(NSString *)username
{
    //  Step 0: Check that the user has local Twitter accounts
    if ([self userHasAccessToTwitter]) {
        
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType =
        [self.accountStore accountTypeWithAccountTypeIdentifier:
         ACAccountTypeIdentifierTwitter];
        
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [self.accountStore accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                               @"/1.1/statuses/user_timeline.json"];
                 NSDictionary *params = @{@"screen_name" : username,
                                          @"include_rts" : @"0",
                                          @"trim_user" : @"1",
                                          @"count" : @"1"};
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:
                  ^(NSData *responseData,
                    NSHTTPURLResponse *urlResponse,
                    NSError *error) {
                      
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 &&
                              urlResponse.statusCode < 300) {
                              
                              NSError *jsonError;
                              NSDictionary *timelineData =
                              [NSJSONSerialization
                               JSONObjectWithData:responseData
                               options:NSJSONReadingAllowFragments error:&jsonError];
                              if (timelineData) {
                                  NSLog(@"Timeline Response: %@\n", timelineData);
                              }
                              else {
                                  // Our JSON deserialization went awry
                                  NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          }
                          else {
                              // The server did not respond ... were we rate-limited?
                              NSLog(@"The response status code is %d",
                                    urlResponse.statusCode);
                          }
                      }
                  }];
             }
             else {
                 // Access was not granted, or an error occurred
                 NSLog(@"%@", [error localizedDescription]);
             }
         }];
    }
}

@end
