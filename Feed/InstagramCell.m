//
//  InstagramCell.m
//  Feed
//
//  Created by George on 2014-03-12.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "InstagramCell.h"
#import <QuartzCore/QuartzCore.h>
@implementation InstagramCell
@synthesize descriptionLabel, username, profile_picture_image_view, main_picture_view, photo_likes, time, caption_username, image_caption, small_chat, small_heart, clock_view, header, comments_count, comments_text, foot, like, foot_comment, media_id, user_id, like_label, like_image;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        [self setBackgroundColor:[UIColor clearColor]];
        // configure control(s)
        
        username = [[UILabel alloc] initWithFrame:CGRectMake(47, 10, screenWidth, 30)];
        [username setTextColor:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0]];
        username.font = [UIFont fontWithName:@"Arial-BoldMT" size:13.8f];
        [self addSubview:username];
        
        small_heart = [[UIImageView alloc] initWithFrame:CGRectMake(5, 380, 15, 15)];
        small_heart.image = [UIImage imageNamed:@"heart_small.png"];
        [self addSubview:small_heart];
        
        small_chat = [[UIImageView alloc] initWithFrame:CGRectMake(5, 400, 15,15)];
        small_chat.image = [UIImage imageNamed:@"speech_bubble.png"];
        [self addSubview:small_chat];
        
        photo_likes = [[UILabel alloc] initWithFrame:CGRectMake(25, 377, screenWidth, 20)];
        [photo_likes setTextColor:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0]];
        photo_likes.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0f];
        
        caption_username = [[UILabel alloc] initWithFrame:CGRectMake(25, 397, 200, 20)];
        [caption_username setTextColor:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0]];
        caption_username.font = [UIFont fontWithName:@"Arial-BoldMT" size:13.8f];
        
       // [self addSubview:caption_username];
        
        //Changed height from 1000 to 200... and back - need to do this properly
        image_caption = [[UITextView alloc] initWithFrame:CGRectMake(20, 390, screenWidth-40, 1000)];
        
        image_caption.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f];
        image_caption.userInteractionEnabled = YES;
        
        image_caption.scrollEnabled = NO;
        image_caption.editable = NO;
        image_caption.selectable = NO;
        
        [image_caption setBackgroundColor:[UIColor clearColor]];
        [self addSubview:image_caption];
        [self addSubview:photo_likes];
        
        main_picture_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 56, screenWidth, 320)];
        [main_picture_view setBackgroundColor:[UIColor clearColor]];
        [self addSubview:main_picture_view];
        
        profile_picture_image_view = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 32, 32)];
        
        CALayer *imageLayer = profile_picture_image_view.layer;
        [imageLayer setCornerRadius:32/2];
        [imageLayer setMasksToBounds:YES];
        //[self addSubview:profile_picture_image_view];
        
        
        clock_view = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-48, 16.5, 15, 15)];
        clock_view.image = [UIImage imageNamed:@"clocks.png"];
       // [self addSubview:clock_view];
        
        time = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 30, 10, screenWidth, 30)];
        time.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        time.textColor = [UIColor lightGrayColor];
        
        comments_count = [[UILabel alloc] initWithFrame:CGRectMake(5, 100, screenWidth, 30)];
        comments_count.font = [UIFont fontWithName:@"Arial-BoldMT" size:13.0f];
        comments_count.textColor = [UIColor lightGrayColor];
        [self addSubview:comments_count];
        
        comments_text = [[UITextView alloc] initWithFrame:CGRectMake(5, 100, screenWidth-40, 30)];
        comments_text.font = [UIFont fontWithName:@"Arial-BoldMT" size:13.0f];
        comments_text.textColor = [UIColor lightGrayColor];
        comments_text.userInteractionEnabled = NO;
        [comments_text setBackgroundColor:[UIColor clearColor]];
        [self addSubview:comments_text];

        
        //[self addSubview:time];
        foot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 25)];
        
        like = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 65, 35)];
        [like setBackgroundColor:[UIColor colorWithWhite: 0.9 alpha:1]];
        foot_comment = [[UIView alloc] initWithFrame:CGRectMake(75, 0, 95, 35)];
        [foot_comment setBackgroundColor:[UIColor colorWithWhite: 0.9 alpha:1]];
        foot.layer.cornerRadius = 2;
        like.layer.masksToBounds = YES;
        like.layer.cornerRadius = 2;
        foot.layer.masksToBounds = YES;
        
        like_label = [[UILabel alloc] initWithFrame:CGRectMake(25, -5, like.frame.size.width, like.frame.size.height)];
        like_label.text = @"Like";
        [like_label setTextColor:[UIColor colorWithWhite:0.5 alpha:1]];
        like_label.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        [like addSubview:like_label];
        
        UILabel *comment_label = [[UILabel alloc] initWithFrame:CGRectMake(26, -5, foot_comment.frame.size.width, foot_comment.frame.size.height)];
        comment_label.text = @"Comment";
        [comment_label setTextColor:[UIColor colorWithWhite:0.5 alpha:1]];
        comment_label.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        [foot_comment addSubview:comment_label];
        
        like_image = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 20,20)];
        like_image.image = [UIImage imageNamed:@"heart_small.png"];
        [like addSubview:like_image];
        
        UIImageView *comment_image = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 20,20)];
        comment_image.image = [UIImage imageNamed:@"speech_bubble.png"];
        [foot_comment addSubview:comment_image];
        
        [foot addSubview:like];
        [foot addSubview:foot_comment];
        [self addSubview:foot];
        
        header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
        [header setBackgroundColor:[UIColor whiteColor]];
        [header addSubview:profile_picture_image_view];
        [header addSubview:username];
        [header addSubview:clock_view];
        [header addSubview:time];
        [header setAlpha:0.9];
        [self addSubview:header];
        
        media_id = [[NSString alloc] init];
        user_id = [[NSString alloc] init];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
