//
//  FacebookCell.m
//  Feed
//
//  Created by George on 2014-04-16.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "FacebookCell.h"

@implementation FacebookCell
@synthesize username, time_label, main_message, likes_gauge, comments_gauge, interact_footer, profile_picture_image_view, main_picture;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        [self setBackgroundColor:[UIColor clearColor]];
        
        profile_picture_image_view = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [self addSubview:profile_picture_image_view];
        
        
        username = [[UITextView alloc] initWithFrame:CGRectMake(65, 0, screenWidth-95, 30)];
        username.userInteractionEnabled = NO;
        username.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.5f];
        [self addSubview:username];
        
        time_label = [[UILabel alloc] initWithFrame:CGRectMake(70, 20, 100, 30)];
        time_label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.5f];
        [time_label setTextColor:[UIColor colorWithWhite:0.5 alpha:1]];
        [self addSubview:time_label];
        
        main_picture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 70, screenWidth, 200)];
        [self addSubview:main_picture];
        
        main_message = [[UITextView alloc] initWithFrame:CGRectMake(5, 50, screenWidth-10, 50)];
        //main_message.font = [UIFont fontWithName:@"HelveticaNeue" size:13.5f];
        [main_message setTextColor:[UIColor colorWithWhite:0 alpha:1]];
        main_message.userInteractionEnabled = NO;
        main_message.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
        [self addSubview:main_message];
        
        likes_gauge = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 100)];
        //[self addSubview:likes_gauge];
        
        comments_gauge = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 0, 0)];
        //[self addSubview:comments_gauge];
        
        interact_footer = [[UIView alloc] initWithFrame:CGRectMake(300, 0, screenWidth, 50)];
        UIImageView *footer_image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth,40)];
        footer_image.image = [UIImage imageNamed:@"facebook_interact_bar.png"];
        [interact_footer addSubview:footer_image];
        [self addSubview:interact_footer];
        //[self setBackgroundColor:[UIColor blackColor]];
        

        
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
