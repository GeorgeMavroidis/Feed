//
//  HashtagDataClass.m
//  Feed
//
//  Created by George on 2014-06-18.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "HashtagDataClass.h"

@implementation HashtagDataClass

@synthesize str, universal_instagram_feed, universal_twitter_feed, universal_feed, mainTableView, universal_feed_array, universal_facebook_feed, universal_tumblr_feed, test_array, tumblrBlogs;
static HashtagDataClass *instance = nil;

+(HashtagDataClass *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [HashtagDataClass new];
        }
    }
    return instance;
}

@end
