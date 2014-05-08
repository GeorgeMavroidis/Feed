//
//  FacebookCell.h
//  Feed
//
//  Created by George on 2014-04-16.
//  Copyright (c) 2014 George. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookCell : UITableViewCell


@property (nonatomic, strong) UITextView *username;
@property (nonatomic, strong) UILabel *time_label;
@property (nonatomic, strong) UITextView *main_message;
@property (nonatomic, strong) UILabel *likes_gauge;
@property (nonatomic, strong) UILabel *comments_gauge;
@property (nonatomic, strong) UIView *interact_footer;


@property (nonatomic, strong) UIImageView *profile_picture_image_view;
@property (nonatomic, strong) UIImageView *main_picture;

@end
