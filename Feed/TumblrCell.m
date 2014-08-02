//
//  TumblrCell.m
//  Feed
//
//  Created by George on 2014-05-10.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "TumblrCell.h"

@implementation TumblrCell
@synthesize contentView, textView, tagView, interactView, profile_image_view, username, notes_label, reblog_view, unique_id, reblog_key, share_view, heart_view, liked, post_url;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        unique_id = @"";
        reblog_key = @"";
        
        liked = @"";
        post_url=@"";
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        [self setBackgroundColor:[UIColor clearColor]];
        
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, screenWidth, 100)];
        [contentView setBackgroundColor:[UIColor clearColor]];
        profile_image_view = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        username = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, screenWidth, 20)];
        textView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, screenWidth, 50)];
        [textView setBackgroundColor:[UIColor clearColor]];
        interactView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, screenWidth, 30)];
        //[interactView setBackgroundColor:[UIColor clearColor]];
        
        notes_label = [[UILabel alloc] initWithFrame:CGRectMake(10, -10, screenWidth, 50)];
        tagView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 20)];
        [tagView setBackgroundColor:[UIColor clearColor]];
        
        username.font = [UIFont fontWithName:@"Arial-BoldMT" size:13.8f];
        notes_label.font =[UIFont fontWithName:@"Arial-BoldMT" size:13.8f];
        notes_label.textColor = [UIColor lightGrayColor];
        [notes_label setBackgroundColor:[UIColor clearColor]];
        
        
        share_view = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-140, 0, 25, 30)];
        share_view.image = [UIImage imageNamed:@"shares.png"];
        reblog_view = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-90, 0, 30, 30)];
        reblog_view.image = [UIImage imageNamed:@"reweet.png"];
        heart_view = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-40, 0, 28, 28)];
        heart_view.image = [UIImage imageNamed:@"heart_small.png"];
        [interactView addSubview:share_view];
        [interactView addSubview:reblog_view];
        [interactView addSubview:heart_view];
        [interactView setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:contentView];
        [contentView setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:profile_image_view];
        [self addSubview:username];
        [self addSubview:textView];
        [interactView addSubview:notes_label];
        [self addSubview:interactView];
        [self addSubview:tagView];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
