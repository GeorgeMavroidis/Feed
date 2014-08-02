//
//  FeedLoginViewController.m
//  Feed
//
//  Created by George on 2/13/2014.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "FeedLoginViewController.h"
#import "FacebookSDK.framework/Headers/FacebookSDK.h"
#import "FeedConnectViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "STTwitter/STTwitterAPI.h"
#import "MBProgressHUD.h"
#import "NewConnectView.h"

@interface FeedLoginViewController (){
    UIImageView *back, *close_button;
    UIView *gtNav;
    UILabel *label;
    UITextField *username, *password;
    UIScrollView *getStartedView;
    FBLoginView *loginView;
    UIWebView *webView;
}

@end

@implementation FeedLoginViewController{
    
    UILabel *connectFacebook;
}

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
    [self createBackgroundImage];
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.navigationController setNavigationBarHidden:YES];
    
    UILongPressGestureRecognizer *singleFingerTap =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleSingleTap:)];
    [back addGestureRecognizer:singleFingerTap];
    back.userInteractionEnabled = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    close_button.userInteractionEnabled = YES;
    
    
    
}
- (void)handleSingleTap:(UILongPressGestureRecognizer *)recognizer {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    if(recognizer.state == 1){
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             back.frame = CGRectMake(0, screenHeight/2-100,  screenWidth, screenWidth/1.6);
                         }
                         completion:^(BOOL finished){
                         }];
        
    }
    if(recognizer.state == 3){
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             float skew = 1.4;
                             back.frame = CGRectMake(-400*skew, 0*skew, 800*skew, 500*skew);

                         }
                         completion:^(BOOL finished){
                             [self animateBack];
                         }];
    }
    
    
    //Do stuff here...
}
-(void)createBackgroundImage{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    UIImageView *backgrounds_poly = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    backgrounds_poly.image = [UIImage imageNamed:@"smaller_blue_poly.jpg"];
    backgrounds_poly.contentMode = UIViewContentModeScaleToFill;
    [backgrounds_poly setAlpha:1];
    [self.view addSubview:backgrounds_poly];
//    back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nyc.jpg"]];
//    
//    float skew = 1.4;
//    back.frame = CGRectMake(-400*skew, 0*skew, 800*skew, 500*skew);
    UIView *back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [back setBackgroundColor:[UIColor whiteColor]];
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, screenWidth, 65)];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:85.0f]];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Feed";
//    [self.view addSubview:back];
    
    [self.view addSubview:label];
    
//    [self animateBack];
    
    UIButton *getStarted = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [getStarted setBackgroundColor:[UIColor colorWithRed: 99.0/255.0 green: 184.0/255.0 blue:255.0/255.0 alpha: 1.0]];
    getStarted.layer.cornerRadius = 5; // this value vary as per your desire
    [getStarted addTarget:self action:@selector(getStarted)
     forControlEvents:UIControlEventTouchDown];
    getStarted.titleLabel.font = [UIFont  systemFontOfSize:20.0f];
    [getStarted setTitle:@"Get Started" forState:UIControlStateNormal];
    [getStarted setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];
    [getStarted setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    getStarted.frame = CGRectMake(10, screenHeight-125, screenWidth-20, 40.0);
//    [self.view addSubview:getStarted];
    
    UIButton *signIn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [signIn setBackgroundColor:[UIColor colorWithRed: 230.0/255.0 green: 230.0/255.0 blue:230.0/255.0 alpha: 1.0]];
    signIn.layer.cornerRadius = 5; // this value vary as per your desire
    [signIn addTarget:self action:@selector(signin)
         forControlEvents:UIControlEventTouchDown];
    signIn.titleLabel.font = [UIFont  systemFontOfSize:20.0f];
    [signIn setTitle:@"Sign In" forState:UIControlStateNormal];
    [signIn setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];
    [signIn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    signIn.frame = CGRectMake(10, screenHeight-70, screenWidth-20, 40.0);
//    [self.view addSubview:signIn];
    
    getStartedView = [[UIScrollView alloc] init];
    [getStartedView setBackgroundColor:[UIColor whiteColor]];
    [getStartedView setFrame:CGRectMake(screenWidth, 0, screenWidth, screenHeight)];
    [getStartedView setBackgroundColor:[UIColor colorWithRed: 235.0/255.0 green: 235.0/255.0 blue:235.0/255.0 alpha: 1.0]];
    getStartedView.contentSize =CGSizeMake(screenWidth, screenHeight+40);
//    [self.view addSubview:getStartedView];
    
    gtNav = [[UIView alloc] init];
    [gtNav setFrame:CGRectMake(screenWidth, 0, screenWidth, 50)];
    gtNav.userInteractionEnabled = YES;
    [gtNav setBackgroundColor:[UIColor colorWithRed: 255.0/255.0 green: 255.0/255.0 blue:255.0/255.0 alpha: 1.0]];
//    [self.view addSubview:gtNav];
    
    
    close_button = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"close_button.png"]];
    close_button.frame = CGRectMake(5, 5, 40, 40);
    close_button.userInteractionEnabled = YES;
    
    [gtNav addSubview:close_button];
    
    UIButton *create = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [create setBackgroundColor:[UIColor colorWithRed: 99.0/255.0 green: 184.0/255.0 blue:255.0/255.0 alpha: 1.0]];
    create.layer.cornerRadius = 3; // this value vary as per your desire
    [create addTarget:self action:@selector(getStarted)
         forControlEvents:UIControlEventTouchDown];
    create.titleLabel.font = [UIFont  systemFontOfSize:20.0f];
    [create setTitle:@"Create" forState:UIControlStateNormal];
    [create setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [create setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    create.frame = CGRectMake(screenWidth-70, 10, 60, 30.0);
    [gtNav addSubview:create];
    
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToBeginningView:)];
    [close_button addGestureRecognizer:singleFingerTap];
    
    UILabel *getStarted_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
    [getStarted_label setFont:[UIFont fontWithName:@"HelveticaNeue" size:22.0f]];
    getStarted_label.textAlignment = NSTextAlignmentCenter;
    getStarted_label.text = @"Get Started";
    [gtNav addSubview:getStarted_label];
    
    UILabel *first_instruction = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, screenWidth, 50)];
    [first_instruction setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f]];
    [first_instruction setTextColor:[UIColor colorWithRed: 130.0/255.0 green: 130.0/255.0 blue:130.0/255.0 alpha: 1.0]];
    first_instruction.textAlignment = NSTextAlignmentCenter;
    first_instruction.text = @"First let's create your Feed account";
    [getStartedView addSubview:first_instruction];
    
    UIButton *facebook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [facebook setBackgroundColor:[UIColor colorWithRed: 59.0/255.0 green: 89.0/255.0 blue:152.0/255.0 alpha: 1.0]];
    facebook.layer.cornerRadius = 5; // this value vary as per your desire
    [facebook addTarget:self action:@selector(facebook)
     forControlEvents:UIControlEventTouchDown];
    facebook.titleLabel.font = [UIFont  systemFontOfSize:20.0f];
    [facebook setTitle:@"Facebook Instant" forState:UIControlStateNormal];
    [facebook setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];
    [facebook setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    facebook.frame = CGRectMake(10, 120, screenWidth-20, 40.0);
    [getStartedView addSubview:facebook];
    
    
    UIImageView *or = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"or.png"]];
    or.frame = CGRectMake(0, 160, screenWidth, 50);
    [getStartedView addSubview:or];
    
    UIView *login_view = [[UIView alloc] init];
    login_view.frame = CGRectMake(0, 220, screenWidth, 80);
    [login_view setBackgroundColor:[UIColor whiteColor]];
    [getStartedView addSubview:login_view];
    
    username = [[UITextField alloc] initWithFrame:CGRectMake(70, 0, screenWidth-70, 40)];
    username.borderStyle = UITextBorderStyleNone;
    username.font = [UIFont systemFontOfSize:15];
    username.placeholder = @"Username";
    username.autocorrectionType = UITextAutocorrectionTypeNo;
    username.keyboardType = UIKeyboardTypeDefault;
    username.returnKeyType = UIReturnKeyNext;
    username.clearButtonMode = UITextFieldViewModeWhileEditing;
    username.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    username.delegate = self;
    [login_view addSubview:username];

    password = [[UITextField alloc] initWithFrame:CGRectMake(70, 35, screenWidth-70, 40)];
    password.borderStyle = UITextBorderStyleNone;
    password.font = [UIFont systemFontOfSize:15];
    password.placeholder = @"Password";
    password.autocorrectionType = UITextAutocorrectionTypeNo;
    password.keyboardType = UIKeyboardTypeDefault;
    password.returnKeyType = UIReturnKeyDone;
    password.clearButtonMode = UITextFieldViewModeWhileEditing;
    password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    password.delegate = self;
    [login_view addSubview:password];
    
    UIImageView *user_pic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"username.png"]];
    user_pic.frame = CGRectMake(20, 5, 30, 30);
    [login_view addSubview:user_pic];
    UIImageView *pass_pic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password.png"]];
    pass_pic.frame = CGRectMake(20, 40, 30, 30);
    [login_view addSubview:pass_pic];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(60, 40, screenWidth-60, 1)];
    lineView.backgroundColor = [UIColor colorWithRed: 230.0/255.0 green: 230.0/255.0 blue:230.0/255.0 alpha: 1.0];
    [login_view addSubview:lineView];
    
    connectFacebook = [[UILabel alloc] initWithFrame:CGRectMake(40, 430, screenWidth-80, 50)];
    connectFacebook.text = @"Connect with Facebook";
    connectFacebook.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f];
    [connectFacebook setTextAlignment:NSTextAlignmentCenter];
    [connectFacebook setTextColor:[UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/215.0f alpha:1]];
//    [self.view addSubview:connectFacebook];
    loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile", @"email", @"read_stream"]];
    loginView.frame = connectFacebook.frame;
    loginView.delegate = self;
//    [self.view addSubview:loginView];
    //fbloginView = [[FBLoginView alloc] init];
    //fbloginView.frame = facebook.frame;
    //[getStartedView addSubview:fbloginView];

//    UITapGestureRecognizer *facebookTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(facebookButtonTouched:)];
//    connectFacebook.userInteractionEnabled = YES;
//    [connectFacebook addGestureRecognizer:facebookTap];
    
    UILabel *connectTwitter = [[UILabel alloc] initWithFrame:CGRectMake(40, 390, screenWidth-80, 50)];
    connectTwitter.text = @"Connect with Twitter";
    connectTwitter.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f];
    [connectTwitter setTextAlignment:NSTextAlignmentCenter];
    [connectTwitter setTextColor:[UIColor whiteColor]];
//    [connectTwitter setTextColor:[UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/215.0f alpha:1]];
    [self.view addSubview:connectTwitter];
    
    UITapGestureRecognizer *twitter_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twitterTap:)];
    [connectTwitter setUserInteractionEnabled:YES];
    [connectTwitter addGestureRecognizer:twitter_recognizer];
    
//    FBLoginView *loginView = [[FBLoginView alloc] init];
//    loginView.alpha = 0;
    // Align the button in the center horizontally
//    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), connectFacebook.frame.origin.y);
//    loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    //    loginView.delegate = self;
    
    //    [self.view addSubview:loginView];
    // Do any additional setup after loading the view.
    


}
- (IBAction)facebookButtonTouched:(id)sender
{
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        
        NSLog(@"here");
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [FBSession.activeSession closeAndClearTokenInformation];
                
                
            } else {
                // An error occurred, we need to handle the error
                // See: https://developers.facebook.com/docs/ios/errors
            }
        }];
        
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Retrieve the app delegate
             AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
         }];
    }
}

-(void)facebookTap{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)twitterTap:(UITapGestureRecognizer *)recognizer {
    
//    [self webLogin];
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
        
        
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(myTimerTick:) userInfo:nil repeats:YES]; // the interval is in seconds...
        
        //Your code goes here
        
    });
    
}


-(void)closeModal{
    [self dismissModalViewControllerAnimated:YES];
    
}
-(void)myTimerTick:(NSTimer *)timer{
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    NSLog(html);
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
        [defaults setObject:@"yes" forKey:@"twitter_connect"];
       
        NSMutableArray *twitter_auth = [NSMutableArray arrayWithContentsOfFile:storePath];
        //oAuthToken, oAuthTokenSecret, @"4tIoaRQHod1IQ00wtSmRw", @"S6GATtE4xirn5WlfW79d6aSH4ciMD196hPQuL2g52M8",
        NSString *oauthToken = [twitter_auth objectAtIndex:0];
        NSString *oauthTokenSecret = [twitter_auth objectAtIndex:1];
        NSString *consumerToken = [twitter_auth objectAtIndex:2];
        NSString *consumerTokenSecret = [twitter_auth objectAtIndex:3];
        
        STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerToken consumerSecret:consumerTokenSecret oauthToken:oauthToken oauthTokenSecret:oauthTokenSecret];
        [twitter verifyCredentialsWithSuccessBlock:^(NSString *usernam) {
            [twitter getUserInformationFor:usernam successBlock:^(NSDictionary *user) {
                NSData* data=[NSKeyedArchiver archivedDataWithRootObject:user];
                [defaults setObject:data forKey:@"twitter_user_info"];
               
                NSString *thing = [user objectForKey:@"profile_image_url"];
                [thing stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                
                PFUser *puser = [PFUser user];
                puser.username = usernam;
                puser.password = @"";
                puser.email = [user objectForKey:@"email"];
                puser[@"profile_image"] = [NSString stringWithFormat:thing];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setValue:thing forKey:@"profile_image"];
                [defaults setValue:usernam forKey:@"username"];
                [defaults synchronize];
                
                [puser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        // Hooray! Let them use the app now.
                        NSLog(@"Signed up on Parse");
                    } else {
                        NSString *errorString = [error userInfo][@"error"];
                        // Show the errorString somewhere and let the user try again.
                    }
                }];
            } errorBlock:^(NSError *error) {
                
            }];
            
        } errorBlock:^(NSError *error) {
            NSLog(@"ee %@", [error localizedDescription]);
        }];

        [self nextScreen];
        
    }
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
-(void)facebook{
    NSLog(@"test");
    
    
}
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
//    NSLog(@"%@", user);
    //NSLog(user.id);
    /*FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
    NSArray* friends = [result objectForKey:@"data"];
    NSLog(@"Found: %i friends", friends.count);
    for (NSDictionary<FBGraphUser>* friend in friends) {
        NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
    }
    }];
     */
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
   
    PFUser *puser = [PFUser user];
    puser.username = [user objectForKey:@"email"];
    puser.password = @"";
    puser.email = [user objectForKey:@"email"];
    puser[@"facebook_id"] = user.id;
    puser[@"facebook_first_name"] = user.first_name;
    puser[@"facebook_last_name"] = user.last_name;
    puser[@"facebook_link"] = user.link;
    puser[@"profile_image"] = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=200&height=200", user.id];
    NSString *link_cover =[NSString stringWithFormat:@"http://graph.facebook.com/%@?fields=cover", user.id];
    NSURL *url = [[NSURL alloc] initWithString:link_cover];
//    NSLog(@"%@", urlAsString);
    
    NSData *data=[NSData dataWithContentsOfURL:url];
    NSError *err=nil;
    NSDictionary *response=[NSJSONSerialization JSONObjectWithData:data options:
                 NSJSONReadingMutableContainers error:&err];

    NSString *photo_id = [[response objectForKey:@"cover"] objectForKey:@"id"];
    NSString *cover = [NSString stringWithFormat:@"http://graph.facebook.com/%@?fields=cover", user.id];
    cover =[[response objectForKey:@"cover"] objectForKey:@"source"];
    NSLog(@"%@", response);
    //puser[@"cover_image"] =
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=200&height=200", user.id] forKey:@"profile_image"];
    [defaults setValue:cover forKey:@"cover_image"];
    [defaults setValue:[NSString stringWithFormat:@"%@ %@", user.first_name, user.last_name] forKey:@"username"];
    [defaults synchronize];
    
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    
    NSString *filePath = [documentsDirectory
                          stringByAppendingPathComponent:@"facebook_username.txt"];
    NSError *error;
    // Write to the file
    
    [user.id writeToFile:filePath atomically:YES
               encoding:NSUTF8StringEncoding error:&error];
    
    
    [puser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
        } else {
            NSString *errorString = [error userInfo][@"error"];
            // Show the errorString somewhere and let the user try again.
        }
    }];
}
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}
-(void)backToBeginningView:(UITapGestureRecognizer *)recognizer {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect orignalFrame = getStartedView.frame;
    orignalFrame.origin.x = screenWidth;
    CGRect selfFrame = back.frame;
    selfFrame.origin.x = 0;
    
    CGRect orignalgtFrame = gtNav.frame;
    orignalgtFrame.origin.x = screenWidth;
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         getStartedView.frame = orignalFrame;
                         gtNav.frame = orignalgtFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    [username endEditing:YES];
    [password endEditing:YES];
}
-(void)getStarted{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect orignalFrame = getStartedView.frame;
    orignalFrame.origin.x = 0;
    CGRect orignalgtFrame = gtNav.frame;
    orignalgtFrame.origin.x = 0;
    CGRect selfFrame = back.frame;
    selfFrame.origin.x = -selfFrame.size.width;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         getStartedView.frame = orignalFrame;
                         gtNav.frame = orignalgtFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    [username becomeFirstResponder];
    
    
}
-(void)signin{
    
}
-(void)animateBack{
    float skew = 1.4;
    float skew2 = 1.2;
    [UIView animateWithDuration:10.0
                          delay:0.0
                        options:(UIViewAnimationCurveLinear | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat)
                     animations:^{
                         back.frame = CGRectMake(0, 0,  800*skew2, 500*skew2);
                     }
                     completion:^(BOOL finished){
                     }];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    if (textField == username) {
		[username resignFirstResponder];
		[password becomeFirstResponder];
        [getStartedView setContentOffset:CGPointMake(0, getStartedView.contentSize.height - getStartedView.bounds.size.height)
                                 animated:YES];
        return NO;
	}
    if(textField == password){
        [password resignFirstResponder];
        [getStartedView setContentOffset:CGPointMake(0, 0)
                                animated:YES];

    }
	return YES;
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
                                                                    [defaults setObject:@"yes" forKey:@"twitter_connect"];
                                                                    
                                                                    [twitter getUserInformationFor:username successBlock:^(NSDictionary *user) {
                                                                        NSData* data=[NSKeyedArchiver archivedDataWithRootObject:user];
                                                                        [defaults setObject:data forKey:@"twitter_user_info"];
                                                                        
                                                                        NSString *thing = [user objectForKey:@"profile_image_url"];
                                                                        [thing stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                                                                        
                                                                        PFUser *puser = [PFUser user];
                                                                        puser.username = username;
                                                                        puser.password = @"";
                                                                        puser.email = [user objectForKey:@"email"];
                                                                        puser[@"profile_image"] = [NSString stringWithFormat:thing];
                                                                        
                                                                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                                        [defaults setValue:thing forKey:@"profile_image"];
                                                                        [defaults setValue:username forKey:@"username"];
                                                                        [defaults synchronize];
                                                                        
                                                                        [puser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                                            if (!error) {
                                                                                // Hooray! Let them use the app now.
                                                                                NSLog(@"Signed up on Parse");
                                                                            } else {
                                                                                NSString *errorString = [error userInfo][@"error"];
                                                                                // Show the errorString somewhere and let the user try again.
                                                                            }
                                                                        }];
                                                                        //            screen_name.text = [user objectForKey:@"name"];
                                                                    } errorBlock:^(NSError *error) {
                                                                        
                                                                    }];

                                                                    [self nextScreen];
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
-(void)nextScreen{
    NewConnectView *new = [[NewConnectView alloc] init];
    [self.navigationController pushViewController:new animated:NO];
    
//    FeedConnectViewController *c = [[FeedConnectViewController alloc] init];
//    [self.navigationController pushViewController:c animated:NO];
}

@end
