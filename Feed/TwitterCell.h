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

@end
