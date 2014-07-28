//
//  InstagramCommentViewController.m
//  Feed
//
//  Created by George on 2014-05-12.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "InstagramCommentViewController.h"
#import "InstagramCommentCell.h"
#import "UIImageView+WebCache.h"
#import "CreationFunctions.h"
#import "ProfileView.h"
#import "AsyncImageView.h"

@interface InstagramCommentViewController ()

@end
@implementation InstagramCommentViewController{
    UIView *kNavBar;
    UITableView *main_tableView;
    UIView *inputBar;
    UITextView *inputTextView;
    UIView *sendText;
    UILabel *send;
    UILabel *placeholderLabel;
    NSString *media_id;
    NSArray *instagram_data;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id) initWithMedia:(NSString *)media {
    if ((self = [super initWithNibName:nil bundle:nil])){
        media_id = media;
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    main_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-50) style:UITableViewStylePlain];
    
    main_tableView.scrollEnabled = YES;
    main_tableView.showsVerticalScrollIndicator = YES;
    main_tableView.userInteractionEnabled = YES;
    main_tableView.bounces = YES;
    // main_tableView.backgroundColor = [UIColor blackColor];
    
    main_tableView.delegate = self;
    main_tableView.dataSource = self;
    [self.view addSubview:main_tableView];
    
    kNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, self.navigationController.navigationBar.frame.size.height)];
    [kNavBar setBackgroundColor:[UIColor whiteColor]];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,kNavBar.frame.size.height-0.5, screenWidth, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [kNavBar addSubview:lineView];
    [self.view addSubview:kNavBar];
    
    
    UIImageView *back_btn = [[UIImageView alloc] initWithFrame:CGRectMake(5, 13, 23, 20)];
    back_btn.image = [UIImage imageNamed:@"arrow_back.png"];
    [kNavBar addSubview:back_btn];
    
    UIImageView *insta_comment_title = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2-50, 15, 100, 100/6.21428571429)];
    insta_comment_title.image = [UIImage imageNamed:@"instagram_comment_title.png"];
    [kNavBar addSubview:insta_comment_title];
    
    inputBar = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight-50, screenWidth, 50)];
    [inputBar setBackgroundColor:[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1]];
    [self.view addSubview:inputBar];
    
    inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, inputBar.frame.size.width-90, 30)];
    [inputTextView.layer setCornerRadius:5.0f];
    UIView *tran = [[UIView alloc] initWithFrame:inputBar.frame];
    [tran setBackgroundColor:[UIColor blackColor]];
    [tran setAlpha:0.5];
    [self.view addSubview:tran];
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0, .0, inputTextView.frame.size.width - 20.0, 34.0)];
    [placeholderLabel setText:@"Add a comment..."];
    // placeholderLabel is instance variable retained by view controller
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    //[placeholderLabel setFont:[challengeDescription font]];
    [placeholderLabel setTextColor:[UIColor lightGrayColor]];
    
    // textView is UITextView object you want add placeholder text to
    [inputTextView addSubview:placeholderLabel];
    
    [inputBar addSubview:inputTextView];
    
    sendText = [[UIView alloc] initWithFrame:CGRectMake(screenWidth-70, 10, 60, 30)];
    [sendText setBackgroundColor:[UIColor colorWithRed:61/255.0 green:175/255.0 blue:4/255.0 alpha:1]];
    send = [[UILabel alloc] initWithFrame:CGRectMake(10.0, -2.0, inputTextView.frame.size.width - 20.0, 34.0)];
    [send setText:@"Send"];
    [send setTextColor:[UIColor clearColor]];
    [send setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5]];
    [sendText addSubview:send];
    [sendText.layer setCornerRadius:5.0f];
    
    
    [inputBar addSubview:sendText];
    instagram_data = [[NSArray alloc] init];
    [self fetchInstagramFeed:media_id];
    
    [main_tableView setSeparatorColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.2]];
    
    inputTextView.delegate = self;
    inputTextView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    main_tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(revealGesture:)];
    recognizer.delegate = self;

    [main_tableView addGestureRecognizer:recognizer];
    
    //[inputTextView becomeFirstResponder];
    
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}
-(void)revealGesture:(UIPanGestureRecognizer *)rec{
    CGPoint vel = [rec velocityInView:self.view];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGPoint currentlocation = [rec locationInView:self.view];
    CGRect tableFrame = main_tableView.frame;
    CGRect new_frame = main_tableView.frame;
    CGRect navBarFrame = inputBar.frame;
   /* if (vel.y > 0){
        if(currentlocation.y > (inputBar.frame.origin.y + inputBar.frame.size.height)){
            new_frame.origin.y += currentlocation.y - (inputBar.frame.origin.y + inputBar.frame.size.height);
            navBarFrame.origin.y += currentlocation.y- (inputBar.frame.origin.y + inputBar.frame.size.height);
            inputBar.frame = navBarFrame;
            main_tableView.frame = new_frame;
        }
    }else {
        if(currentlocation.y < (inputBar.frame.origin.y + inputBar.frame.size.height) && (currentlocation.y > screenHeight-210)){
            new_frame.origin.y = currentlocation.y-(main_tableView.frame.size.height);
            navBarFrame.origin.y = currentlocation.y-inputBar.frame.size.height;
            inputBar.frame = navBarFrame;
            main_tableView.frame = new_frame;
        }
    }*/
    
}
- (IBAction)Back
{
    NSLog(@"here");
    [self dismissViewControllerAnimated:YES completion:nil]; // ios 6
}
-(NSMutableAttributedString *)returnInstagramAttributedText:(NSMutableAttributedString *)text{
    //NSLog(@"%@",text);
    NSString *converted = [text string];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    NSRegularExpression *regexAt = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&error];
    NSArray *matchesAt = [regexAt matchesInString:converted options:0 range:NSMakeRange(0, converted.length)];
    NSArray *matches = [regex matchesInString:converted options:0 range:NSMakeRange(0, converted.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString* word = [converted substringWithRange:wordRange];
        // NSLog(@"Found tag %@", word);
    }
    for (NSTextCheckingResult *match in matchesAt) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString* word = [converted substringWithRange:wordRange];
        // NSLog(@"Found tag %@", word);
    }
    NSRange range = NSMakeRange(0,text.length);
    
    [regex enumerateMatchesInString:converted options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange subStringRange = [result rangeAtIndex:0];
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0] range:subStringRange];
    }];
    [regexAt enumerateMatchesInString:converted options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange subStringRange = [result rangeAtIndex:0];
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0] range:subStringRange];
    }];
    return text;
}

-(void)fetchInstagramFeed:(NSString *)media{
    //api.instagram.com/v1/media/555/comments?access_token=ACCESS-TOKEN
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *access = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"instagram_access_token"];
    NSString *instagram_base_url = @"https://api.instagram.com/v1/media/";
    instagram_base_url = [instagram_base_url stringByAppendingString:media];
    instagram_base_url = [instagram_base_url stringByAppendingString:@"/comments?access_token="];
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
    
    instagram_data = [json objectForKey:@"data"]; //2
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
   
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    [main_tableView scrollRectToVisible:CGRectMake(0, main_tableView.contentSize.height - main_tableView.bounds.size.height, screenWidth, screenHeight-55) animated:NO];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [inputTextView resignFirstResponder];
    
    
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"InstagramCell";
    
    InstagramCommentCell *cell = (InstagramCommentCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[InstagramCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    NSDictionary *data = [instagram_data objectAtIndex:indexPath.row];
    
    NSString *text = [data objectForKey:@"text"];
    cell.text.text = text;
    
    NSString *username = [[data objectForKey:@"from"] objectForKey:@"username"];
    NSString  *created_time = [data valueForKey:@"created_time"];
    NSString *profile_picture = [[data objectForKey:@"from"]objectForKey:@"profile_picture"];
    NSString *full_name = [[data objectForKey:@"from"]objectForKey:@"full_name"];
    
    username = [username stringByAppendingString:@" "];
    
    NSMutableAttributedString *attributed_caption = [[NSMutableAttributedString alloc] initWithString:text];
    cell.text.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f];
    //[attributed_caption addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0] range:NSMakeRange(0,[username length])];
    //[attributed_caption addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial-BoldMT" size:13.8f] range:NSMakeRange(0, [username length])];
    [attributed_caption addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f] range:NSMakeRange(0, [attributed_caption length])];
    
    cell.text.attributedText = [self returnInstagramAttributedText:attributed_caption];
    
    cell.username.text = username;
    cell.username.font = [UIFont fontWithName:@"Arial-BoldMT" size:13.8f];
    cell.username.textColor = [UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0];
    
    cell.profile_picture_image_view.imageURL = [NSURL URLWithString:profile_picture];
//    [cell.profile_picture_image_view setImageWithURL:[NSURL URLWithString:profile_picture]
//                                    placeholderImage:[UIImage imageNamed:@"insta_placeholder.png"]];
    NSTimeInterval epoch = [created_time doubleValue];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:epoch];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSDate *now = [NSDate date];
    NSTimeInterval distanceBetweenDates = [now timeIntervalSinceDate:date];
    double seconds = 1;
    double minutes = 60;
    double hours = minutes*60;
    double days = hours * 24;
    double weeks = days * 7;
    NSInteger secondsBetweenDates = distanceBetweenDates;
    NSInteger minutesBetweenDates = distanceBetweenDates / minutes;
    NSInteger hoursBetweenDates = distanceBetweenDates / hours;
    NSInteger daysBetweenDates = distanceBetweenDates / days;
    NSInteger weeksBetweenDates = distanceBetweenDates / weeks;
    if(secondsBetweenDates < 60){
        created_time = [NSString stringWithFormat:@"%d", secondsBetweenDates];
        created_time = [created_time stringByAppendingString:@"s"];
        NSLog(@"%d", secondsBetweenDates);
    }else
        if(minutesBetweenDates < 60){
            created_time = [NSString stringWithFormat:@"%d", minutesBetweenDates];
            created_time = [created_time stringByAppendingString:@"m"];
        }else
            if(hoursBetweenDates < 24){
                created_time = [NSString stringWithFormat:@"%d", hoursBetweenDates];
                created_time = [created_time stringByAppendingString:@"h"];
            }else
                if(daysBetweenDates < 7){
                    created_time = [NSString stringWithFormat:@"%d", daysBetweenDates];
                    created_time = [created_time stringByAppendingString:@"d"];
                }
                else{
                    created_time = [NSString stringWithFormat:@"%d", weeksBetweenDates];
                    created_time = [created_time stringByAppendingString:@"w"];
                }
    
    cell.time.text = created_time;
    
    NSString *user_id = [[data objectForKey:@"from"]objectForKey:@"id"];
    
    cell.user_id = user_id;
    UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(launchProfile:)];
    [cell.profile_picture_image_view setUserInteractionEnabled:YES];
    [cell.profile_picture_image_view addGestureRecognizer:tg];
    
    
    tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(launchProfile:)];
    [cell.username setUserInteractionEnabled:YES];
    [cell.username addGestureRecognizer:tg];
    
    return cell;
    
}
-(void)launchProfile:(UITapGestureRecognizer *)recognizer{
    InstagramCommentCell *test =[[((InstagramCommentCell *) recognizer.view) superview] superview];
    NSString *name = test.username.text;
    DataClass *singleton_universal = [DataClass getInstance];
    
    ProfileView *profile = [[ProfileView alloc] initForInstagram:name user_id:test.user_id type:@"instagram"];
    [self.navigationController pushViewController:profile animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *data = [instagram_data objectAtIndex:indexPath.row];
    
    NSString *text = [data objectForKey:@"text"];

    return [self returnCommentsHeight:indexPath textString:text]+30 +10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [instagram_data count];
}
-(void) textViewDidBeginEditing:(UITextView *)textView {
    [UIView beginAnimations:nil context:NULL];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.265];
    CGRect rect = main_tableView.frame;
    rect.origin.y -= 210;
    main_tableView.frame = rect;
    
    rect = inputBar.frame;
    rect.origin.y -= 210;
    inputBar.frame = rect;
    [UIView commitAnimations];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect rect = main_tableView.frame;
    CGRect originalRect =rect;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //0.265
    [UIView setAnimationDuration:0.2];
    rect.origin.y = screenHeight - main_tableView.frame.size.height-50;
    main_tableView.frame = rect;
    
    rect = inputBar.frame;
    rect.origin.y = screenHeight - inputBar.frame.size.height;
    inputBar.frame = rect;
    
    [UIView commitAnimations];
    
    //main_tableView.frame = originalRect;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
-(int)returnCommentsHeight:(NSIndexPath*)indexPath textString:(NSString *)text {
    int addedHeight;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f];
    
    CGSize size = [text sizeWithFont:font
                   constrainedToSize:CGSizeMake(screenWidth-50, 1000)
                       lineBreakMode:UILineBreakModeWordWrap]; // default mode
    float numberOfLines = size.height / font.lineHeight;
    addedHeight = (int)numberOfLines * (int)font.lineHeight;
    
    
    return addedHeight;
    
}

@end
