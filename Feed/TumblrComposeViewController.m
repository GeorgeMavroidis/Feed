//
//  TumblrComposeViewController.m
//  Feed
//
//  Created by George on 2014-05-27.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "TumblrComposeViewController.h"
#import "UIImageView+WebCache.h"
#import "AsyncImageView.h"
#import <TMAPIClient.h>
#import "DataClass.h"
#import <QuartzCore/QuartzCore.h>

@interface TumblrComposeViewController (){
    UIScrollView *mainComposeScrollView;
    UIScrollView *s;
    UIImageView *profile_picture;
    UILabel *user_name;
}

@end
@implementation TumblrComposeViewController
@synthesize kNavBar, mainContent, blogs, tumblr_reblog_key, tumblr_unique_id, chosen_blog;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id) initFromPost:(NSString *)media reblogKey:(NSString *)reblog_key {
    if ((self = [super initWithNibName:nil bundle:nil])){
        tumblr_unique_id = media;
        tumblr_reblog_key  = reblog_key;
       // media_id = media;
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    DataClass *singleton_universal = [DataClass getInstance];
    
    UIView *background_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    background_view.alpha = 0.5;
    [self.view setBackgroundColor:[UIColor colorWithRed: 50/255.0 green: 80/255.0 blue:109/255.0 alpha: 1.0]];
    
    
    float navController_y = 0;
    float navController_height = 40;
    
    kNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, navController_height)];
    [kNavBar setBackgroundColor:[UIColor colorWithRed: 50/255.0 green: 80/255.0 blue:109/255.0 alpha: 1.0]];
    //UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,kNavBar.frame.size.height-0.5, screenWidth, 0.5)];
    //lineView.backgroundColor = [UIColor lightGrayColor];
    //[kNavBar addSubview:lineView];
    [self.view addSubview:kNavBar];
    
    UILabel *cancel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, kNavBar.frame.size.height)];
    cancel.text = @"Cancel";
    cancel.textColor = [UIColor lightGrayColor];
    [kNavBar addSubview:cancel];
    
    UITapGestureRecognizer *canc = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
    [cancel setUserInteractionEnabled:YES];
    canc.numberOfTapsRequired = 1;
    [cancel addGestureRecognizer:canc];
    
    UILabel *post = [[UILabel alloc] initWithFrame:CGRectMake(kNavBar.frame.size.width-45, 0, 50, kNavBar.frame.size.height)];
    post.text = @"Post";
    post.textColor = [UIColor whiteColor];
    [kNavBar addSubview:post];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(kNavBar.frame.size.width/2-30, 0, 100, kNavBar.frame.size.height)];
    title.text = @"Reblog";
    title.font = [UIFont fontWithName:@"Arial-BoldMT" size:20.0f];
    title.textColor = [UIColor whiteColor];
    [kNavBar addSubview:title];
    
    UITapGestureRecognizer *sendPost = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postpost)];
    [post setUserInteractionEnabled:YES];
    sendPost.numberOfTapsRequired = 1;
    [post addGestureRecognizer:sendPost];
    post.userInteractionEnabled = YES;
    
    mainComposeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,kNavBar.frame.size.height+10, screenWidth, screenHeight)];
    [mainComposeScrollView setContentSize:CGSizeMake(mainComposeScrollView.bounds.size.width, mainComposeScrollView.bounds.size.height+5)];
    [mainComposeScrollView setShowsVerticalScrollIndicator:NO];
    mainComposeScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:mainComposeScrollView];
    
    
    UIView *mainCompose = [[UIView alloc] initWithFrame:CGRectMake(10, 0, screenWidth-20, screenHeight-20-256)];
    [mainCompose setBackgroundColor:[UIColor whiteColor]];
    [mainComposeScrollView addSubview:mainCompose];
    
    UIView *headerCompose = [[UIView alloc] initWithFrame:CGRectMake(10, 0, mainCompose.frame.size.width-20, 30)];
    [headerCompose setBackgroundColor:[UIColor clearColor]];
    [mainCompose addSubview:headerCompose];
    
    mainContent = [[UITextView alloc] initWithFrame:CGRectMake(5, headerCompose.frame.size.height+headerCompose.frame.origin.y+20, screenWidth-40, mainCompose.frame.size.height-headerCompose.frame.size.height-40)];
    mainContent.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    [mainCompose.layer setCornerRadius:5.0f];
    [mainCompose addSubview:mainContent];
    
    [mainContent becomeFirstResponder];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(10, mainCompose.frame.size.height-30, screenWidth-40, 30)];
    [mainCompose addSubview:footerView];
    
    profile_picture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 30, 30)];
    [headerCompose addSubview:profile_picture];
    
    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeUser)];
    UIView *clicker = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
//    [mainComposeScrollView addSubview:clicker];
    [clicker setBackgroundColor:[UIColor blackColor]];
    [mainComposeScrollView setUserInteractionEnabled:YES];
    [clicker addGestureRecognizer:t];
    [clicker setUserInteractionEnabled:YES];
    // Do any additional setup after loading the view.
    
    
    NSDictionary *defTumb = [[NSDictionary alloc] init];
    
    defTumb = [singleton_universal.tumblrBlogs objectAtIndex:0];
    
    chosen_blog = [defTumb objectForKey:@"name"];
    [profile_picture setImageWithURL:[NSURL URLWithString:[self returnTumblrProfilePicture:chosen_blog]] placeholderImage:[UIImage imageNamed:@"insta_placeholder.png"]];
    
    user_name = [[UILabel alloc] initWithFrame:CGRectMake(40, 15, screenWidth-50, 20)];
    user_name.text = [defTumb objectForKey:@"name"];
    user_name.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:14.0f];
    [user_name setTextColor:[UIColor blackColor]];
    [headerCompose addSubview:user_name];
    
    [user_name setUserInteractionEnabled:YES];
    [user_name addGestureRecognizer:t];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10,45, screenWidth-40, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    lineView.alpha = 0.4;
    [mainCompose addSubview:lineView];
    
}
-(void)changeUser{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    s = [[UIScrollView alloc] initWithFrame:CGRectMake(20, 40, screenWidth, 200 )];
    [s setBackgroundColor:[UIColor whiteColor]];
//    [s setBackgroundColor:[UIColor blackColor]];
    [mainComposeScrollView addSubview:s];
    DataClass *su = [DataClass getInstance];
    
    int numberOfBlogs = [su.tumblrBlogs count];
    for(int i =0; i < numberOfBlogs; i++){
        UIView *temp = [[UIView alloc] initWithFrame:CGRectMake(0, 40*i, s.frame.size.width, 40)];
        [s addSubview:temp];
        
        UILabel *tt = [[UILabel alloc] initWithFrame:CGRectMake(40, 40*i, 200, 40)];
        tt.text = [[su.tumblrBlogs objectAtIndex:i] objectForKey:@"name"];
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
    [s setContentSize:CGSizeMake(mainComposeScrollView.frame.size.width-100, numberOfBlogs*40+40)];
    
    NSLog(@"here");
}
-(void)actualChange:(UITapGestureRecognizer *) resp{
    UILabel *m = (UILabel *)resp.view;
    NSLog(m.text);
    [s removeFromSuperview];
    chosen_blog = m.text;
    user_name.text = m.text;
    profile_picture.imageURL = [NSURL URLWithString:[self returnTumblrProfilePicture:m.text]];
    
}
-(NSString *)returnTumblrProfilePicture:(NSString *)username{
    NSString *base  =@"http://api.tumblr.com/v2/blog/";
    base = [base stringByAppendingString:username];
    base = [base stringByAppendingString:@".tumblr.com/avatar/96"];
    base = [base stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return base;
}
-(void)cancel{
    //self.view.alpha = 0;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [mainContent resignFirstResponder];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         CGRect old_frame = self.view.frame;
                         old_frame.origin.y = screenHeight;
                         self.view.frame = old_frame;
                     }
                     completion:^(BOOL finished){
//                         NSLog(@"Done!");
                     }];
    //[self dismissViewControllerAnimated:YES completion:^{
        
    //}];
}
-(void)postpost{
//    NSLog(@"tumb unique id %@", tumblr_unique_id);
//    NSLog(@"tumblr reblog %@", tumblr_reblog_key);
//    NSLog(@"blog %@", chosen_blog);
    NSDictionary *params = @{@"id":tumblr_unique_id,
                            @"reblog_key" : tumblr_reblog_key,
                             @"comment" : mainContent.text};
    
    
    [[TMAPIClient sharedInstance] reblogPost:chosen_blog parameters:params callback:^(id result, NSError *error) {
        if(!error){
            //NSLog(@"%@", result);
            [self cancel];
            
        }
        if(error) NSLog(@"%@", [error localizedDescription]);
    }];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
