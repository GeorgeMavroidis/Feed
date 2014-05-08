//
//  TwitterCell.m
//  Feed
//
//  Created by George on 2014-03-17.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "TwitterCell.h"

@implementation TwitterCell
@synthesize profile_picture_image_view, username,  time_label, retweets, favorites, tweet, interact_footer;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        [self setBackgroundColor:[UIColor clearColor]];
        
        profile_picture_image_view = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        profile_picture_image_view.layer.cornerRadius = 4;
        profile_picture_image_view.layer.masksToBounds = YES;
        [self addSubview:profile_picture_image_view];
        
        tweet = [[UITextView alloc] initWithFrame:CGRectMake(65, 20, screenWidth-75, 200)];
        tweet.userInteractionEnabled = NO;
        tweet.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f];
        [self addSubview:tweet];
        
        username = [[UITextView alloc] initWithFrame:CGRectMake(65, 0, screenWidth-95, 30)];
        username.userInteractionEnabled = NO;
        username.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.5f];
        [self addSubview:username];
        
        time_label = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-30, 0, 100, 30)];
        time_label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.5f];
        [time_label setTextColor:[UIColor colorWithWhite:0.5 alpha:1]];
        [self addSubview:time_label];
        
        interact_footer = [[UIView alloc] initWithFrame:CGRectMake(0, 100, screenWidth, 40)];
        
        UIImageView *reply_image = [[UIImageView alloc] initWithFrame:CGRectMake(70, 6, 17,17)];
        reply_image.image = [UIImage imageNamed:@"reply.png"];
        [interact_footer addSubview:reply_image];
        
        UIImageView *retweet_image = [[UIImageView alloc] initWithFrame:CGRectMake(reply_image.frame.origin.x+60, 6, 20,20)];
        retweet_image.image = [UIImage imageNamed:@"reweet.png"];
        //[interact_footer setBackgroundColor:[UIColor blackColor]];
        [interact_footer addSubview:retweet_image];
        
        UIImageView *fav_image = [[UIImageView alloc] initWithFrame:CGRectMake(retweet_image.frame.origin.x+60, 0, 30,30)];
        fav_image.image = [UIImage imageNamed:@"fav.png"];
        [interact_footer addSubview:fav_image];
        [interact_footer setAlpha:0.6];
        
        retweets = [[UILabel alloc] initWithFrame:CGRectMake(retweet_image.frame.origin.x+25, 0, 50, 30)];
        retweets.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.5f];
        [retweets setTextColor:[UIColor colorWithWhite:0.5 alpha:1]];
        [interact_footer addSubview:retweets];

        favorites = [[UILabel alloc] initWithFrame:CGRectMake(fav_image.frame.origin.x+25, 0, 50, 30)];
        favorites.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.5f];
        [favorites setTextColor:[UIColor colorWithWhite:0.5 alpha:1]];
        [interact_footer addSubview:favorites];
        
        [self addSubview:interact_footer];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
