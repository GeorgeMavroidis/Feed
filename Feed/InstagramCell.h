//
//  InstagramCell.h
//  Feed
//
//  Created by George on 2014-03-12.
//  Copyright (c) 2014 George. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstagramCell : UITableViewCell

@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *username;
@property (nonatomic, strong) UIImageView *profile_picture_image_view;
@property (nonatomic, strong) UIImageView *main_picture_view;
@property (nonatomic, strong) UIImageView *clock_view;
@property (nonatomic, strong) UILabel *photo_likes;
@property (nonatomic, strong) UILabel *time;
@property (nonatomic, strong) UILabel *caption_username;
@property (nonatomic, strong) UITextView *image_caption;
@property (nonatomic, strong) UIImageView *small_heart;
@property (nonatomic, strong) UIImageView *small_chat;
@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UILabel *comments_count;
@property (nonatomic, strong) UITextView *comments_text;

@property (nonatomic, strong) UIView *foot;
@property (nonatomic, strong) UIView *like;
@property (nonatomic, strong) UIView *foot_comment;

@property (nonatomic, strong) NSString *media_id;
@property (nonatomic, strong) NSString *user_id;


@property (nonatomic, strong) UILabel *like_label;
@property (nonatomic, strong) UIImageView *like_image;
@end
