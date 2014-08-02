//
//  TumblrCell.h
//  Feed
//
//  Created by George on 2014-05-10.
//  Copyright (c) 2014 George. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TumblrCell : UITableViewCell

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *textView;
@property (nonatomic, strong) UIScrollView *tagView;
@property (nonatomic, strong) UILabel *notes_label;
@property (nonatomic, strong) UIView *interactView;

@property (nonatomic, strong) UIImageView *profile_image_view;
@property (nonatomic, strong) UIImageView *reblog_view;
@property (nonatomic, strong) UIImageView *share_view;
@property (nonatomic, strong) UIImageView *heart_view;
@property (nonatomic, strong) UILabel *username;

@property (nonatomic, strong) NSString *unique_id;
@property (nonatomic, strong) NSString *reblog_key;

@property (nonatomic, strong) NSString *liked;
@property (nonatomic, strong) NSString *post_url;


@end
