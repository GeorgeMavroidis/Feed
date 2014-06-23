//
//  DataClass.m
//  Feed
//
//  Created by George on 2014-03-12.
//  Copyright (c) 2014 George. All rights reserved.
//
#import "DataClass.h"

@implementation DataClass
@synthesize str, universal_instagram_feed, universal_twitter_feed, universal_feed, mainTableView, universal_feed_array, universal_facebook_feed, universal_tumblr_feed, test_array, tumblrBlogs, mainNavController, mainViewController, urlWrapper, t, closeView, profileView;
static DataClass *instance =nil;
+(DataClass *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [DataClass new];
        }
    }
    return instance;
}
@end
