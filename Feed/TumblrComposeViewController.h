//
//  TumblrComposeViewController.h
//  Feed
//
//  Created by George on 2014-05-27.
//  Copyright (c) 2014 George. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TumblrComposeViewController : UIViewController



@property (nonatomic, strong) UIView *kNavBar;
@property (nonatomic, strong) UITextView *mainContent;
@property (nonatomic, strong) NSMutableDictionary *blogs;

@property (nonatomic, strong) NSString *tumblr_reblog_key;
@property (nonatomic, strong) NSString *tumblr_unique_id;


@property (nonatomic, strong) NSString *chosen_blog;

-(id)initFromPost:(NSString *)unique_id reblogKey:(NSString *)reblog_key;
@end
