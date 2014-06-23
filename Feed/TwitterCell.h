//
//  TwitterCell.h
//  Feed
//
//  Created by George on 2014-03-17.
//  Copyright (c) 2014 George. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterCell : UITableViewCell

@property (nonatomic, strong) UITextView *username;
@property (nonatomic, strong) UILabel *time_label;
@property (nonatomic, strong) UILabel *retweets;
@property (nonatomic, strong) UILabel *favorites;
@property (nonatomic, strong) UITextView *tweet;
@property (nonatomic, strong) UIView *interact_footer;


@property (nonatomic, strong) UIImageView *profile_picture_image_view;
@property (nonatomic, strong) UIImageView *optionalImage;
@property (nonatomic, strong) UIImageView *fav_image;
@property (nonatomic, strong) UIImageView *retweet_image;
@property (nonatomic, strong) UIImageView *reply_image;
@property (nonatomic, strong) NSString *twitter_media_id;
@property (nonatomic, strong) NSString *original_twitter_media_id;
@property (nonatomic, strong) NSString *favorited;
@property (nonatomic, strong) NSString *retweeted;

@end
