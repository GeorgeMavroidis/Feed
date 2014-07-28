//
//  TumblrCompose.m
//  Feed
//
//  Created by George on 2014-06-26.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "TumblrCompose.h"
#import "DataClass.h"
#import "AsyncImageView.h"
#import "FeedComposeViewController.h"
#import <TMAPIClient.h>
#import "UIImageView+WebCache.h"

@implementation TumblrCompose{
    NSUserDefaults *defaults;
    UIScrollView *mainComposeScrollView;
    UIView *mainCompose;
    UIView *footer;
    int count;
    UIImageView *imageSelected;
    UIScrollView *s;
    NSString *chosen_blog, *prof_img;
    UIImageView *profile_image;
    UILabel *usern;
    
}
@synthesize mainContent, mainImage;

-(void)viewDidLoad{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    defaults = [NSUserDefaults standardUserDefaults];
    DataClass *singleton_universal = [DataClass getInstance];
    
    
    [self.view setBackgroundColor:[UIColor colorWithRed: 50/255.0 green: 80/255.0 blue:109/255.0 alpha: 1.0]];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    float navController_y = 0;
    float navController_height = 40;
    
    mainComposeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, screenWidth, screenHeight)];
    [mainComposeScrollView setContentSize:CGSizeMake(mainComposeScrollView.bounds.size.width, mainComposeScrollView.bounds.size.height+5)];
    [mainComposeScrollView setShowsVerticalScrollIndicator:NO];
    mainComposeScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:mainComposeScrollView];
    mainComposeScrollView.delegate = self;
    
    mainCompose = [[UIView alloc] initWithFrame:CGRectMake(10, 30, screenWidth-20, screenHeight-40-216-50)];
    //-256 for keyboard
    [mainCompose setBackgroundColor:[UIColor whiteColor]];
    [mainComposeScrollView addSubview:mainCompose];
    
    UIView *headerCompose = [[UIView alloc] initWithFrame:CGRectMake(10, 0, mainCompose.frame.size.width-20, 30)];
    [headerCompose setBackgroundColor:[UIColor clearColor]];
    [mainCompose addSubview:headerCompose];
    
    mainContent = [[UITextView alloc] initWithFrame:CGRectMake(15, 70, screenWidth-40, mainCompose.frame.size.height-130)];
    mainContent.delegate = self;
    mainContent.font = [UIFont fontWithName:@"Avenir-Light" size:18.0f];
    [mainCompose.layer setCornerRadius:5.0f];
    [mainCompose addSubview:mainContent];
    
//    [mainContent becomeFirstResponder];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(10, mainCompose.frame.size.height-30, screenWidth-40, 30)];
    [mainCompose addSubview:footerView];
    
    UIImageView *profile_picture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 30, 30)];
    [headerCompose addSubview:profile_picture];
    // Do any additional setup after loading the view.
    
    UIView *content_header = [[UIView alloc] initWithFrame:CGRectMake(10, 10, mainCompose.frame.size.width-20, 50)];
    profile_image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    [profile_image setBackgroundColor:[UIColor whiteColor]];
    profile_image.layer.cornerRadius = 40/2;
    prof_img = [defaults valueForKey:@"profile_image"];
    prof_img = [prof_img stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    profile_image.layer.masksToBounds = YES;
    profile_image.imageURL = [NSURL URLWithString:prof_img];
    [content_header addSubview:profile_image];
    profile_image.frame = CGRectMake(10, 5, 40, 40);
    profile_image.layer.cornerRadius = 40/2;
    [mainCompose addSubview:content_header];
    
    chosen_blog = 0;
    NSDictionary *defTumb = [[NSDictionary alloc] init];
    
    defTumb = [singleton_universal.tumblrBlogs objectAtIndex:0];
    
    chosen_blog = [defTumb objectForKey:@"name"];
    [profile_image setImageWithURL:[NSURL URLWithString:[self returnTumblrProfilePicture:chosen_blog]] placeholderImage:[UIImage imageNamed:@"insta_placeholder.png"]];
    


    
    usern = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, mainCompose.frame.size.width-50, 50)];
    usern.text = [defaults valueForKey:@"username"];
    usern.font = [UIFont fontWithName:@"Avenir-Black" size:15];
    [mainCompose addSubview:usern];
    
    usern.text = [defTumb objectForKey:@"name"];
    
    
    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeUser)];
    [usern addGestureRecognizer:t];
    [usern setUserInteractionEnabled:YES];
    
    
    footer = [[UIView alloc] initWithFrame:CGRectMake(0, mainCompose.frame.size.height-50, mainCompose.frame.size.width, 50)];
    [footer setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1]];
    
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
    
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tumblr_a6a6a6_100.png"]];
    bgImage.frame = CGRectMake(mainCompose.frame.size.width/2-50, 80, 100, 100);
    bgImage.alpha = 0.3;
    [mainCompose addSubview:bgImage];
    count = 0;
    mainComposeScrollView.delegate = self;
}
-(void)sendButtonTapped:(UITapGestureRecognizer *)sender{
    
    NSDictionary *params = @{@"body" : mainContent.text};
    
    [[TMAPIClient sharedInstance] post:chosen_blog type:@"text" parameters:params callback:^(id result, NSError *error) {
        [self send];
        if(error)
            NSLog(@"%@", [error localizedDescription]);
    }];
     
}
-(void)send{
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [mainContent resignFirstResponder];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    UIScrollView* mySuperFrameView = (UIScrollView*)self.view.superview;
    FeedComposeViewController *t = (FeedComposeViewController *)[self.view.superview.superview.superview nextResponder];
    
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationTransitionCurlDown
                     animations:^{
                         CGRect old_frame = mainComposeScrollView.frame;
                         old_frame.origin.y = -screenHeight;
                         mainComposeScrollView.frame = old_frame;
                         
                     }
                     completion:^(BOOL finished){
                         [t reorder];
                         
                         CGRect old_frame = self.view.frame;
                         old_frame.origin.y = screenHeight;
                         self.view.frame = old_frame;
                         float tw = mySuperFrameView.contentSize.width;
                         //                         [mySuperFrameView setContentOffset:CGPointMake(tw-screenWidth, 0) animated:YES];
                         [UIView animateWithDuration:0.4
                                               delay:0.0
                                             options: UIViewAnimationTransitionCurlDown
                                          animations:^{
                                              //                                              mySuperFrameView.contentSize = CGSizeMake(mySuperFrameView.contentSize.width-screenWidth, screenHeight);
                                              
                                          }completion:^(BOOL finished) {
                                              //                                              [self removeFromParentViewController];
                                              [self.view removeFromSuperview];
                                          }];
                         
                         //                         NSLog(@"Done!");
                     }];
    
    
    //[self dismissViewControllerAnimated:YES completion:^{
    
    //}];
    
}
-(void)changeUser{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    s = [[UIScrollView alloc] initWithFrame:CGRectMake(20, 50, screenWidth-40, 200 )];
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

-(NSString *)returnTumblrProfilePicture:(NSString *)username{
    NSString *base  =@"http://api.tumblr.com/v2/blog/";
    base = [base stringByAppendingString:username];
    base = [base stringByAppendingString:@".tumblr.com/avatar/96"];
    base = [base stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return base;
}
-(void)actualChange:(UITapGestureRecognizer *) resp{
    UILabel *m = (UILabel *)resp.view;
    [s removeFromSuperview];
    chosen_blog = m.text;
    usern.text = m.text;
    profile_image.imageURL = [NSURL URLWithString:[self returnTumblrProfilePicture:m.text]];
    
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
    mainImage = [[UIView alloc] initWithFrame:CGRectMake(10, mainCompose.frame.size.height+mainCompose.frame.origin.y+20, screenWidth-20, 300)];
    imageSelected = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth-20, 300)];
    imageSelected.image = smallImage;
    [mainImage addSubview:imageSelected];
    [mainImage setBackgroundColor:[UIColor whiteColor]];
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
    [mainComposeScrollView addSubview:mainImage];
    //    [self uploadImage:imageData];
}
-(void)createImageWithImage:(UIImage *)smallImage{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    mainImage = [[UIView alloc] initWithFrame:CGRectMake(10, mainCompose.frame.size.height+mainCompose.frame.origin.y+20, screenWidth-20, 300)];
    imageSelected = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth-20, 300)];
    imageSelected.image = smallImage;
    [mainImage addSubview:imageSelected];
    [mainImage setBackgroundColor:[UIColor whiteColor]];
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
    
    [mainComposeScrollView addSubview:mainImage];
}
-(void)xImage{
    NSLog(@"here");
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationTransitionCurlDown
                     animations:^{
                         mainImage.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [mainImage removeFromSuperview];
                         //                         NSLog(@"Done!");
                     }];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGPoint location = [scrollView.panGestureRecognizer locationInView:scrollView];
    
    if(scrollView.contentOffset.y < -120){
        if(count == 0){
            [self cancel];
            count++;
        }
    }
    
}
-(void)cancel{
    //self.view.alpha = 0;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [mainContent resignFirstResponder];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    UIScrollView* mySuperFrameView = (UIScrollView*)self.view.superview;
    FeedComposeViewController *t = (FeedComposeViewController *)[self.view.superview.superview.superview nextResponder];
    
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationTransitionCurlDown
                     animations:^{
                         CGRect old_frame = mainComposeScrollView.frame;
                         old_frame.origin.y = screenHeight;
                         mainComposeScrollView.frame = old_frame;
                         
                     }
                     completion:^(BOOL finished){
                         [t reorder];
                         
                         CGRect old_frame = self.view.frame;
                         old_frame.origin.y = screenHeight;
                         self.view.frame = old_frame;
                         float tw = mySuperFrameView.contentSize.width;
                         //                         [mySuperFrameView setContentOffset:CGPointMake(tw-screenWidth, 0) animated:YES];
                         [UIView animateWithDuration:0.4
                                               delay:0.0
                                             options: UIViewAnimationTransitionCurlDown
                                          animations:^{
                                              //                                              mySuperFrameView.contentSize = CGSizeMake(mySuperFrameView.contentSize.width-screenWidth, screenHeight);
                                              
                                          }completion:^(BOOL finished) {
                                              //                                              [self removeFromParentViewController];
                                              [self.view removeFromSuperview];
                                          }];
                         
                         //                         NSLog(@"Done!");
                     }];
    
    
    //[self dismissViewControllerAnimated:YES completion:^{
    
    //}];
}
@end
