//
//  InstagramCompose.h
//  Feed
//
//  Created by George on 2014-06-26.
//  Copyright (c) 2014 George. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstagramCompose : UIViewController<UITextViewDelegate, UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (strong, nonatomic)UITextView *mainContent;
@property (strong, nonatomic) UITextView *mainImage;
-(void)createImageWithImage:(UIImage *)smallImage;
@property (nonatomic, retain) UIDocumentInteractionController *dic;  
@end
