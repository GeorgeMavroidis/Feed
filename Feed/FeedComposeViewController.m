//
//  FeedComposeViewController.m
//  Feed
//
//  Created by George on 2014-06-26.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "FeedComposeViewController.h"
#import "DataClass.h"
#import "AsyncImageView.h"
#import "TwitterCompose.h"
#import "MBProgressHUD.h"
#import "TumblrCompose.h"
#import "InstagramCompose.h"

@implementation FeedComposeViewController{
    UIView *kNavBar;
    UITextView *mainContent;
    UIImageView *mainImage;
    NSUserDefaults *defaults;
    UIView *mainCompose, *footer, *social_footer, *background_view, *m;
    UIScrollView *mainComposeScrollView;
    UIImageView *imageSelected;
    UIImageView *facebook_icon, *tumblr_icon, *twitter_icon, *ig_icon;
    
    UIPageControl *pageControl;
    
}
@synthesize socialScrollView;

-(void)viewDidLoad{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    defaults = [NSUserDefaults standardUserDefaults];
    DataClass *singleton_universal = [DataClass getInstance];
    
    background_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    background_view.alpha = 0.3;
    [background_view setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:background_view];
    
    [self.view setBackgroundColor:[UIColor colorWithRed: 50/255.0 green: 80/255.0 blue:109/255.0 alpha: 1.0]];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    float navController_y = 0;
    float navController_height = 40;
    
    kNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, navController_height)];
    [kNavBar setBackgroundColor:[UIColor colorWithRed: 50/255.0 green: 80/255.0 blue:109/255.0 alpha: 1.0]];
    [kNavBar setBackgroundColor:[UIColor clearColor]];
    //UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,kNavBar.frame.size.height-0.5, screenWidth, 0.5)];
    //lineView.backgroundColor = [UIColor lightGrayColor];
    //[kNavBar addSubview:lineView];
//    [self.view addSubview:kNavBar];
    
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
    title.text = @"Feed";
    title.font = [UIFont fontWithName:@"Arial-BoldMT" size:20.0f];
    title.textColor = [UIColor whiteColor];
    [kNavBar addSubview:title];
    
    UITapGestureRecognizer *sendPost = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postpost)];
    [post setUserInteractionEnabled:YES];
    sendPost.numberOfTapsRequired = 1;
    [post addGestureRecognizer:sendPost];
    post.userInteractionEnabled = YES;
    
    mainComposeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, screenWidth, screenHeight)];
    mainComposeScrollView.delegate = self;
    [mainComposeScrollView setContentSize:CGSizeMake(mainComposeScrollView.bounds.size.width, screenHeight+5)];
    [mainComposeScrollView setShowsVerticalScrollIndicator:NO];
    mainComposeScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:mainComposeScrollView];
    mainComposeScrollView.delegate = self;
    socialScrollView.delegate = self;
    
    socialScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight/2+screenHeight)];
    [mainComposeScrollView addSubview:socialScrollView];
    socialScrollView.contentSize = CGSizeMake(screenWidth, screenHeight);
    socialScrollView.pagingEnabled = YES;
    
    mainCompose = [[UIView alloc] initWithFrame:CGRectMake(10, 30, screenWidth-20, screenHeight-40-216-50)];
    //-256 for keyboard
    [mainCompose setBackgroundColor:[UIColor whiteColor]];
    [socialScrollView addSubview:mainCompose];
    
    UIView *headerCompose = [[UIView alloc] initWithFrame:CGRectMake(10, 0, mainCompose.frame.size.width-20, 30)];
    [headerCompose setBackgroundColor:[UIColor clearColor]];
    [mainCompose addSubview:headerCompose];
    
    mainContent = [[UITextView alloc] initWithFrame:CGRectMake(15, 70, screenWidth-40, mainCompose.frame.size.height-130)];
    mainContent.delegate = self;
    mainContent.font = [UIFont fontWithName:@"Avenir-Light" size:18.0f];
    [mainCompose.layer setCornerRadius:5.0f];
    [mainCompose addSubview:mainContent];
    
    [mainContent becomeFirstResponder];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(10, mainCompose.frame.size.height-30, screenWidth-40, 30)];
    [mainCompose addSubview:footerView];
    
    UIImageView *profile_picture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 30, 30)];
    [headerCompose addSubview:profile_picture];
    // Do any additional setup after loading the view.
    
    UIView *content_header = [[UIView alloc] initWithFrame:CGRectMake(10, 10, mainCompose.frame.size.width-20, 50)];
    UIImageView *profile_image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    [profile_image setBackgroundColor:[UIColor whiteColor]];
    profile_image.layer.cornerRadius = 40/2;
    NSString *prof_img = [defaults valueForKey:@"profile_image"];
    prof_img = [prof_img stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    profile_image.layer.masksToBounds = YES;
    profile_image.imageURL = [NSURL URLWithString:prof_img];
    [content_header addSubview:profile_image];
    profile_image.frame = CGRectMake(10, 5, 40, 40);
    profile_image.layer.cornerRadius = 40/2;
    [mainCompose addSubview:content_header];
    
    UILabel *usern = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, mainCompose.frame.size.width-50, 50)];
    usern.text = [defaults valueForKey:@"username"];
    usern.font = [UIFont fontWithName:@"Avenir-Black" size:15];
    [mainCompose addSubview:usern];
    
    social_footer = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight-40, screenWidth, 40)];
    [self.view addSubview:social_footer];
    
    footer = [[UIView alloc] initWithFrame:CGRectMake(0, mainCompose.frame.size.height-50, mainCompose.frame.size.width, 50)];
    [footer setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1]];
    [social_footer setBackgroundColor:[UIColor whiteColor]];
    [mainCompose setClipsToBounds:YES];
    [mainCompose addSubview:footer];
    
    UIView *camera = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    UIImageView *camera_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera.png"]];
    camera_icon.frame = CGRectMake(10, 10, 30, 30);
    [camera addSubview:camera_icon];
    [footer addSubview:camera];
    [camera addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraButtonTapped:)]];
    
    UIView *send = [[UIView alloc] initWithFrame:CGRectMake(footer.frame.size.width-40, 0, 90, 90)];
    UIImageView *send_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"send-grey.png"]];
    send_icon.frame = CGRectMake(0, 10, 30, 30);
    [send addSubview:send_icon];
    [footer addSubview:send];
    [send addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendButtonTapped:)]];
    
    int social_footer_width = screenWidth/4;
    UIView *facebookG = [[UIView alloc] initWithFrame:CGRectMake(0, 7, social_footer_width, 27)];
    facebook_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"facebook_a6a6a6_100.png"]];
    facebook_icon.frame = CGRectMake(social_footer_width/2-12, 0, 25, 25);
    [facebookG addSubview:facebook_icon];
//    [social_footer addSubview:facebookG];
    [facebookG addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(facebookCreateCompose:)]];
    
    UIView *twitterG = [[UIView alloc] initWithFrame:CGRectMake(social_footer_width, 5, social_footer_width, 30)];
    twitter_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitter_a6a6a6_100.png"]];
    twitter_icon.frame = CGRectMake(social_footer_width/2-15, 0, 30, 30);
    [twitterG addSubview:twitter_icon];
    [social_footer addSubview:twitterG];
    [twitterG addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twitterCreateCompose:)]];
    
    UIView *tumblrG = [[UIView alloc] initWithFrame:CGRectMake(social_footer_width*2, 5, social_footer_width, 27)];
    tumblr_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tumblr_a6a6a6_100.png"]];
    tumblr_icon.frame = CGRectMake(social_footer_width/2-13, 0, 27, 27);
    [tumblrG addSubview:tumblr_icon];
    [social_footer addSubview:tumblrG];
    [tumblrG addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tumblrCreateCompose:)]];
    
    UIView *igG = [[UIView alloc] initWithFrame:CGRectMake(social_footer_width*3, 5, social_footer_width, 27)];
    ig_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instagram_a6a6a6_100.png"]];
    ig_icon.frame = CGRectMake(social_footer_width/2-13, 0, 27, 27);
    [igG addSubview:ig_icon];
    [social_footer addSubview:igG];
    [igG addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(instagramCreateCompose:)]];
    
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feed_feed.png"]];
    bgImage.frame = CGRectMake(mainCompose.frame.size.width/2-50, 80, 100, 100);
    bgImage.alpha = 0.1;
    [mainCompose addSubview:bgImage];
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 285, screenWidth, 30)];
    [mainComposeScrollView addSubview:pageControl];
    pageControl.numberOfPages = 1;
    pageControl.currentPage = 0;
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
    
    
}
- (IBAction)changePage:(id)sender {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    UIPageControl *pager=sender;
    int page = pager.currentPage;
    CGSize scf = socialScrollView.contentSize;
    
    
    [socialScrollView setContentOffset:CGPointMake(screenWidth*page, 0) animated:YES];
}
-(IBAction)facebookCreateCompose:(id)sender{
    facebook_icon.image = [UIImage imageNamed:@"facebook_000000_100.png"];
}
-(IBAction)twitterCreateCompose:(id)sender{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *t = [d objectForKey:@"twitter_connect"];
    if([t isEqualToString:@"no"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection"
                                                        message:@"Connect a Twitter account from the settings page (on your profile)"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }else{
        [mainContent resignFirstResponder];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        twitter_icon.image = [UIImage imageNamed:@"twitter_000000_100.png"];
        TwitterCompose *twitterScroll = [[TwitterCompose alloc]init];
        twitterScroll.view.frame = CGRectMake(socialScrollView.contentSize.width, 0, screenWidth, screenHeight);
        twitterScroll.mainContent.text = mainContent.text;
        
        if(m != nil || m.alpha!=0){
            [twitterScroll createImageWithImage:imageSelected.image];
        }
        [self addChildViewController:twitterScroll];
        [socialScrollView addSubview:twitterScroll.view];
        socialScrollView.contentSize = CGSizeMake(socialScrollView.contentSize.width+screenWidth, screenHeight);
        pageControl.numberOfPages ++;
        pageControl.currentPage = pageControl.numberOfPages+1;
        [socialScrollView setContentOffset:CGPointMake(socialScrollView.contentSize.width-screenWidth, 0) animated:YES];
    }
}
-(IBAction)tumblrCreateCompose:(id)sender{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *t = [d objectForKey:@"tumblr_connect"];
    if([t isEqualToString:@"no"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection"
                                                        message:@"Connect a Tumblr account from the settings page (on your profile)"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }else{
    [mainContent resignFirstResponder];
    tumblr_icon.image = [UIImage imageNamed:@"tumblr_000000_100.png"];
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    TumblrCompose *tumblrScroll = [[TumblrCompose alloc]init];
    tumblrScroll.view.frame = CGRectMake(socialScrollView.contentSize.width, 0, screenWidth, screenHeight);
    [self addChildViewController:tumblrScroll];
    tumblrScroll.mainContent.text = mainContent.text;
    
    if(m != nil || m.alpha!=0){
        [tumblrScroll createImageWithImage:imageSelected.image];
    }
    [socialScrollView addSubview:tumblrScroll.view];
    socialScrollView.contentSize = CGSizeMake(socialScrollView.contentSize.width+screenWidth, screenHeight);
    [socialScrollView setContentOffset:CGPointMake(socialScrollView.contentSize.width-screenWidth, 0) animated:YES];
    
    pageControl.numberOfPages ++;
    pageControl.currentPage = pageControl.numberOfPages+1;
    }
    
}

-(IBAction)instagramCreateCompose:(id)sender{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *t = [d objectForKey:@"instagram_connect"];
    if([t isEqualToString:@"no"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection"
                                                        message:@"Connect an Instagram account from the settings page (on your profile)"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }else{
    [mainContent resignFirstResponder];
    ig_icon.image = [UIImage imageNamed:@"instagram_000000_100.png"];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    InstagramCompose *instagramScroll = [[InstagramCompose alloc]init];
    instagramScroll.view.frame = CGRectMake(socialScrollView.contentSize.width, 0, screenWidth, screenHeight);
    [self addChildViewController:instagramScroll];
    
    if(m != nil || m.alpha!=0){
        [instagramScroll createImageWithImage:imageSelected.image];
    }
    instagramScroll.mainContent.text = mainContent.text;
    [socialScrollView addSubview:instagramScroll.view];
    socialScrollView.contentSize = CGSizeMake(socialScrollView.contentSize.width+screenWidth, screenHeight);
    [socialScrollView setContentOffset:CGPointMake(socialScrollView.contentSize.width-screenWidth, 0) animated:YES];
    pageControl.numberOfPages ++;
    pageControl.currentPage = pageControl.numberOfPages+1;
    }
}
- (IBAction)cameraButtonTapped:(id)sender{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera] == YES){
        // Create image picker controller
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        // Set source to the camera
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        
        // Delegate is self
        imagePicker.delegate = self;
        
        // Show image picker
        [self presentModalViewController:imagePicker animated:YES];
    }else{
        // Device has no camera
        UIImage *image = [UIImage imageNamed:@"ItunesArtwork.png"];
        
        
        // Resize image
        UIGraphicsBeginImageContext(CGSizeMake(640, 960));
        [image drawInRect: CGRectMake(0, 0, 640, 960)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        NSData *imageData = UIImageJPEGRepresentation(image, 0.05f);
        
//        [self uploadImage:imageData];
    }

}
- (IBAction)sendButtonTapped:(id)sender{
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // Dismiss controller
    [picker dismissModalViewControllerAnimated:YES];
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    [image drawInRect: CGRectMake(0, 0, 640, 960)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Upload image
    NSData *imageData = UIImageJPEGRepresentation(image, 0.05f);
    m = [[UIView alloc] initWithFrame:CGRectMake(10, mainCompose.frame.size.height+mainCompose.frame.origin.y+20, screenWidth-20, screenHeight-100)];

    imageSelected = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth-20, screenHeight-100)];
    imageSelected.image = smallImage;
    [m addSubview:imageSelected];
    [m setBackgroundColor:[UIColor whiteColor]];
    //    [mainComposeScrollView addSubview:m];
    
    UILabel  *xlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, -10, 70, 70)];
    xlabel.text = @"X";
    xlabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40];
    [xlabel setUserInteractionEnabled:YES];
    [imageSelected setUserInteractionEnabled:YES];
    [imageSelected addSubview:xlabel];
    
    
    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(xImage)];
    t.numberOfTapsRequired = 1;
    [xlabel addGestureRecognizer:t];
    
    [socialScrollView addSubview:m];
    
    NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/feed_upload.png"];
    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/feed_upload.jpg"];
    
    // Write a UIImage to JPEG with minimum compression (best quality)
    // The value 'image' must be a UIImage object
    // The value '1.0' represents image compression quality as value from 0.0 to 1.0
//    [UIImageJPEGRepresentation(image, 1.0) writeToFile:jpgPath atomically:YES];
    
    // Write image to PNG
    [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
    
    // Let's check to see if files were successfully written...
    
    // Create file manager
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Document directory
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    // Write out the contents of home directory to console
    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    UIImageWriteToSavedPhotosAlbum(imageSelected.image, nil, nil, nil);

    //    [self uploadImage:imageData];
}
-(void)xImage{
    NSLog(@"here");
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationTransitionCurlDown
                     animations:^{
                         m.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         m = nil;
                         [m removeFromSuperview];
                         //                         NSLog(@"Done!");
                     }];
}
-(void)uploadImage:(NSData *)imageData{
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    //HUD creation here (see example for code)
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hide old HUD, show completed HUD (see example for code)
            
            // Create a PFObject around a PFFile and associate it with the current user
            PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
            [userPhoto setObject:imageFile forKey:@"imageFile"];
            
            // Set the access control list to current user for security purposes
            userPhoto.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            PFUser *user = [PFUser currentUser];
            [userPhoto setObject:user forKey:@"user"];
            
            [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [self refresh:nil];
                }
                else{
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else{
            [HUD hide:YES];
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
        refreshHUD.progress = (float)percentDone/100;
    }];
}
-(IBAction)refresh:(id)sender{
    refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:refreshHUD];
    
    // Register for HUD callbacks so we can remove it from the window at the right time
    refreshHUD.delegate = self;
    
    // Show the HUD while the provided method executes in a new thread
    [refreshHUD show:YES];

    [refreshHUD hide:YES afterDelay:3];
}

-(void)cancel{
    //self.view.alpha = 0;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [mainContent resignFirstResponder];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationTransitionCurlDown
                     animations:^{
                         social_footer.alpha = 0;
                         CGRect old_frame = mainComposeScrollView.frame;
                         old_frame.origin.y = screenHeight;
                         mainComposeScrollView.frame = old_frame;
                         background_view.alpha = 0;
                         
                     }
                     completion:^(BOOL finished){
                         CGRect old_frame = self.view.frame;
                         old_frame.origin.y = screenHeight;
                         self.view.frame = old_frame;
                         //                         NSLog(@"Done!");
                     }];
    //[self dismissViewControllerAnimated:YES completion:^{
    
    //}];
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
   [UIView animateWithDuration:0.25
                          delay:0.0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         CGRect old_frame = social_footer.frame;
                         old_frame.origin.y = screenHeight - 256;
                         social_footer.frame = old_frame;
                     }
                     completion:^(BOOL finished){
                         //                         NSLog(@"Done!");
                     }];
    
    // never called...
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         CGRect old_frame = social_footer.frame;
                         old_frame.origin.y = screenHeight -40;
                         social_footer.frame = old_frame;
    
                         
                     }
                     completion:^(BOOL finished){
                         //                         NSLog(@"Done!");
                     }];
    

}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    return YES;
}
-(void)postpost{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"Here %f", scrollView.contentOffset.y);
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGPoint location = [scrollView.panGestureRecognizer locationInView:scrollView];
    
    if(scrollView.contentOffset.y < -120){
        [self cancel];
    }
    
    float width =  socialScrollView.contentSize.width;
    float xPos = width/screenWidth;
//    NSLog(@"%f", width);
    //Calculate the page we are on based on x coordinate position and width of scroll view
    pageControl.currentPage = (int)xPos/width;
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD hides
    [HUD removeFromSuperview];
    HUD = nil;
}
-(void)reorder:(int)index{
    int count = 0;
    for (int subviews = 0; subviews < socialScrollView.subviews.count; subviews ++) {
        NSLog(@"%d count", count);
        count ++;
        
    }
    
    UIView *t = [socialScrollView.subviews objectAtIndex:index];
    [t removeFromSuperview];
    
    
}
-(void)reorder{
    int count = 0;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
//    NSLog(@"pos %d", (int)socialScrollView.contentOffset.x/(int)screenWidth);
    int pos = (int)socialScrollView.contentOffset.x/(int)screenWidth;
    int true_backlog = socialScrollView.subviews.count;
    int backlog = socialScrollView.subviews.count-4;
//    NSLog(@"true backlog %i", true_backlog);
//    NSLog(@"%d %d", pos+1, true_backlog-pos+1);
//    NSLog(@"backlog = %d", backlog);
    if(true_backlog-pos+1 == 4){
        
        UIView *t = [socialScrollView.subviews objectAtIndex:socialScrollView.subviews.count-1];
        [UIView animateWithDuration:0.45
                              delay:0.0
                            options: UIViewAnimationCurveEaseIn
                         animations:^{
                             CGRect old_frame = t.frame;
                             old_frame.origin.x = old_frame.origin.x - screenWidth;
                             t.frame = old_frame;
                             
                             
                             CGSize old_frames = socialScrollView.contentSize;
                             old_frames.width = old_frames.width- screenWidth;
                             socialScrollView.contentSize= old_frames;
                         }
                         completion:^(BOOL finished){
                             
                         }];
        //        NSLog(@"backlog %d", i+1);
    
    
    
    
    }else{
        for(int i= pos+1; i < true_backlog; i++){
            UIView *t = [socialScrollView.subviews objectAtIndex:i];
            [UIView animateWithDuration:0.45
                                  delay:0.0
                                options: UIViewAnimationCurveEaseIn
                             animations:^{
                                 CGRect old_frame = t.frame;
                                 old_frame.origin.x = old_frame.origin.x - screenWidth;
                                 t.frame = old_frame;
                                 
                                 
                             }
                             completion:^(BOOL finished){
                                 
                             }];
            //        NSLog(@"backlog %d", i+1);
        }
        
        
        CGSize old_frames = socialScrollView.contentSize;
        old_frames.width = old_frames.width- screenWidth;
        socialScrollView.contentSize= old_frames;
    }
    //    NSLog(@"%d %d", pos, backlog);
    pageControl.numberOfPages -= 1;
    
}

@end
