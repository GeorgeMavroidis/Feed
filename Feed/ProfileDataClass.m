//
//  ProfileDataClass.m
//  Feed
//
//  Created by George on 2014-06-24.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "ProfileDataClass.h"

@implementation ProfileDataClass
@synthesize str, universal_instagram_feed, universal_twitter_feed, universal_feed, mainTableView, universal_feed_array, universal_facebook_feed, universal_tumblr_feed, test_array, tumblrBlogs;
static ProfileDataClass *instance = nil;

+(ProfileDataClass *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [ProfileDataClass new];
        }
    }
    return instance;
}
@end
