//
//  FeedComposeViewController.h
//  Feed
//
//  Created by George on 2014-06-26.
//  Copyright (c) 2014 George. All rights reserved.
//
//ViewController.h

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#include <stdlib.h>

@interface FeedComposeViewController : UIViewController <UITextViewDelegate, UIScrollViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate, UIPageViewControllerDelegate>
{
    IBOutlet UIScrollView *photoScrollView;
    NSMutableArray *allImages;
    
    MBProgressHUD *HUD;
    MBProgressHUD *refreshHUD;
    UIScrollView *socialScrollView;
}

- (IBAction)refresh:(id)sender;
- (IBAction)cameraButtonTapped:(id)sender;
- (void)uploadImage:(NSData *)imageData;
- (void)setUpImages:(NSArray *)images;
- (void)buttonTouched:(id)sender;
@property (nonatomic, strong) UIScrollView *socialScrollView;
-(void)reorder:(int)index;
-(void)reorder;
@end
