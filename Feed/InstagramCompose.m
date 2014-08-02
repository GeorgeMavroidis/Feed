//
//  InstagramCompose.m
//  Feed
//
//  Created by George on 2014-06-26.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "InstagramCompose.h"
#import "AsyncImageView.h"
#import "DataClass.h"
#import "FeedComposeViewController.h"

@implementation InstagramCompose{
    NSUserDefaults *defaults;
    UIScrollView *mainComposeScrollView;
    UIView *mainCompose;
    UIView *footer;
    UIImageView *imageSelected;
    int count;
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
    mainComposeScrollView.delegate = self;
    [mainComposeScrollView setContentSize:CGSizeMake(mainComposeScrollView.bounds.size.width, screenHeight+5)];
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
    
    
    
    UILabel *usern = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, mainCompose.frame.size.width-50, 50)];
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
    UIImageView *profile_picture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 30, 30)];
    [headerCompose addSubview:profile_picture];
    // Do any additional setup after loading the view.
    
    UIView *content_header = [[UIView alloc] initWithFrame:CGRectMake(10, 10, mainCompose.frame.size.width-20, 50)];
    UIImageView *profile_image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    [profile_image setBackgroundColor:[UIColor whiteColor]];
    profile_image.layer.cornerRadius = 40/2;
    NSString *prof_img = [instagram_data objectForKey:@"profile_picture"];
    prof_img = [prof_img stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    profile_image.layer.masksToBounds = YES;
    profile_image.imageURL = [NSURL URLWithString:prof_img];
    [content_header addSubview:profile_image];
    profile_image.frame = CGRectMake(10, 5, 40, 40);
    profile_image.layer.cornerRadius = 40/2;
    [mainCompose addSubview:content_header];
    //    NSLog(@"data %@", instagram_data);
    usern.text = [instagram_data objectForKey:@"username" ];
    usern.font = [UIFont fontWithName:@"Avenir-Black" size:15];
    [mainCompose addSubview:usern];
   
    
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
    [send setUserInteractionEnabled:YES];
    [send addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendButtonTapped:)]];
    
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instagram_a6a6a6_100.png"]];
    bgImage.frame = CGRectMake(mainCompose.frame.size.width/2-50, 80, 100, 100);
    bgImage.alpha = 0.3;
    [mainCompose addSubview:bgImage];
    mainComposeScrollView.delegate = self;
    count = 0;
    
}
-(void)sendButtonTapped:(UITapGestureRecognizer *)sender{
    
    if(imageSelected == nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"You must include a photo for Instagram."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }else{
        NSString* imagePath = [NSString stringWithFormat:@"%@/instagramShare.igo", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        
        UIImage *instagramImage = imageSelected.image;
        [UIImagePNGRepresentation(instagramImage) writeToFile:imagePath atomically:YES];
        NSLog(@"Image Size >>> %@", NSStringFromCGSize(instagramImage.size));
        
        self.dic=[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
        self.dic.delegate = self;
        self.dic.UTI = @"com.instagram.exclusivegram";
        self.dic.annotation = @{@"InstagramCaption": [NSString stringWithFormat:@"%@ #feedapp",mainContent.text]};
        [self.dic presentOpenInMenuFromRect: self.view.frame inView:self.view animated:YES ];
        

    }
}
- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Note"
                                                    message:@"Please note that this photo will be posted to the Instagram profile that you are signed into Instagram's app with."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}
-(void)createImageWithImage:(UIImage *)smallImage{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    mainImage = [[UIView alloc] initWithFrame:CGRectMake(10, mainCompose.frame.size.height+mainCompose.frame.origin.y+20, screenWidth-20, screenHeight-60)];
    imageSelected = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth-20, screenHeight-60)];
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
    
    NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/instagram_upload.png"];
    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/instagram_upload.igo"];
    // Write image to PNG
    [UIImagePNGRepresentation(smallImage) writeToFile:pngPath atomically:YES];
    [UIImageJPEGRepresentation(smallImage, 0.5) writeToFile:jpgPath atomically:YES];
    // Let's check to see if files were successfully written...
    
    // Create file manager
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Document directory
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    // Write out the contents of home directory to console
    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);//    UIImageWriteToSavedPhotosAlbum(imageSelected.image, nil, nil, nil);
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
    mainImage = [[UIView alloc] initWithFrame:CGRectMake(10, mainCompose.frame.size.height+mainCompose.frame.origin.y+20, screenWidth-20, screenHeight-60)];
    imageSelected = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth-20, screenHeight-60)];
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
    NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/instagram_upload.png"];
    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/instagram_upload.jpg"];
    // Write image to PNG
    [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
    [UIImageJPEGRepresentation(image, 0.5) writeToFile:jpgPath atomically:YES];
    
    // Let's check to see if files were successfully written...
    
    // Create file manager
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Document directory
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    // Write out the contents of home directory to console
    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    UIImageWriteToSavedPhotosAlbum(smallImage, nil, nil, nil);
}
-(void)xImage{
    
    imageSelected = nil;
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
