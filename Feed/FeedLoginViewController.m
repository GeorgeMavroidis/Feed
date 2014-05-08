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

@interface FeedLoginViewController (){
    UIImageView *back, *close_button;
    UIView *gtNav;
    UILabel *label;
    UITextField *username, *password;
    UIScrollView *getStartedView;
    FBLoginView *loginView;
}

@end

@implementation FeedLoginViewController

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
    
    back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nyc.jpg"]];
    float skew = 1.4;
    back.frame = CGRectMake(-400*skew, 0*skew, 800*skew, 500*skew);
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, screenWidth, 65)];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:85.0f]];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Feed";
    [self.view addSubview:back];
    
    [self.view addSubview:label];
    
    [self animateBack];
    
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
    [self.view addSubview:getStarted];
    
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
    [self.view addSubview:signIn];
    
    getStartedView = [[UIScrollView alloc] init];
    [getStartedView setBackgroundColor:[UIColor whiteColor]];
    [getStartedView setFrame:CGRectMake(screenWidth, 0, screenWidth, screenHeight)];
    [getStartedView setBackgroundColor:[UIColor colorWithRed: 235.0/255.0 green: 235.0/255.0 blue:235.0/255.0 alpha: 1.0]];
    getStartedView.contentSize =CGSizeMake(screenWidth, screenHeight+40);
    [self.view addSubview:getStartedView];
    
    gtNav = [[UIView alloc] init];
    [gtNav setFrame:CGRectMake(screenWidth, 0, screenWidth, 50)];
    gtNav.userInteractionEnabled = YES;
    [gtNav setBackgroundColor:[UIColor colorWithRed: 255.0/255.0 green: 255.0/255.0 blue:255.0/255.0 alpha: 1.0]];
    [self.view addSubview:gtNav];
    
    
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
    
    loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email", @"read_stream"]];
    loginView.frame = facebook.frame;
    loginView.delegate = self;
    [getStartedView addSubview:loginView];
    //fbloginView = [[FBLoginView alloc] init];
    //fbloginView.frame = facebook.frame;
    //[getStartedView addSubview:fbloginView];
    
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

}
-(void)facebook{
    NSLog(@"test");
    
    
}
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
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
    
    PFUser *puser = [PFUser user];
    puser.username = user.username;
    puser.password = @"";
    puser.email = [user objectForKey:@"email"];
    puser[@"facebook_id"] = user.id;
    puser[@"facebook_first_name"] = user.first_name;
    puser[@"facebook_last_name"] = user.last_name;
    puser[@"facebook_link"] = user.link;
    
    
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
@end
