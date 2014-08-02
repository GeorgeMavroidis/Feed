//
//  HashtagFunctions.m
//  Feed
//
//  Created by George on 2014-06-18.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "HashtagFunctions.h"
#import "STTwitter.h"
#import "CreationFunctions.h"
#import "TwitterCell.h"
#import "AsyncImageView.h"
#import "HashtagSearch.h"
#import <TMAPIClient.h>
#import "ConnectionFunctions.h"

@implementation HashtagFunctions

+(void)fetchTwitterFeed:(NSString *)hashtag singleton:(HashtagDataClass *)singleton_universal{
    // NSMutableArray *twitter_auth = [[NSUserDefaults standardUserDefaults] objectForKey:@"twitter_auth_array"];
    
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    NSString *storePath = [documentsDirectory stringByAppendingPathComponent:@"twitter_auth"];
    NSMutableArray *twitter_auth = [NSMutableArray arrayWithContentsOfFile:storePath];
    //oAuthToken, oAuthTokenSecret, @"4tIoaRQHod1IQ00wtSmRw", @"S6GATtE4xirn5WlfW79d6aSH4ciMD196hPQuL2g52M8",
    NSString *oauthToken = [twitter_auth objectAtIndex:0];
    NSString *oauthTokenSecret = [twitter_auth objectAtIndex:1];
    NSString *consumerToken = [twitter_auth objectAtIndex:2];
    NSString *consumerTokenSecret = [twitter_auth objectAtIndex:3];
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerToken consumerSecret:consumerTokenSecret oauthToken:oauthToken oauthTokenSecret:oauthTokenSecret];

    singleton_universal.universal_twitter_feed = [[NSMutableDictionary alloc] init];
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
        [twitter getSearchTweetsWithQuery:hashtag geocode:nil lang:nil locale:nil resultType:nil count:@"100" until:nil sinceID:nil maxID:nil includeEntities:nil callback:nil successBlock:^(NSDictionary *searchMetadata, NSArray *statuses) {
            [singleton_universal.universal_twitter_feed setObject:statuses forKey:@"twitter_data"];
            [singleton_universal.universal_twitter_feed setObject:@"twitter" forKey:@"type"];
            [self addTwitterToFeed:singleton_universal];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self sortUniversalFeedByTime:singleton_universal];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    
                    DataClass *su = [DataClass getInstance];
                    HashtagSearch *t = (HashtagSearch *)su.mainViewController;
                    [t update];
                    [su.mainTableView reloadData];
                    NSLog(@"donezo");
                });
                //                [t.main_tableView reloadData];
            });

        }errorBlock:^(NSError *error) {
            NSLog(@"%@", [error localizedDescription]);
        }];
        
    } errorBlock:^(NSError *error) {
        // ...
    }];
    
}
+(void)addTumblrToFeed:(HashtagDataClass *)singleton_universal{
    
    NSMutableDictionary *test = [singleton_universal.universal_tumblr_feed objectForKey:@"tumblr_data"];
    
    [singleton_universal.universal_feed setObject:test forKey:@"tumblr_entry"];
    for(NSMutableDictionary *dat in [singleton_universal.universal_feed objectForKey:@"tumblr_entry"]){
        
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:dat];
        [temp setObject:@"tumblr" forKey:@"type"];
        
        NSString *created_at = [temp objectForKey:@"date"];
        NSTimeInterval equalizedTimeInterval = [CreationFunctions returnTumblrTimeInterval:created_at];
        [temp setObject:[NSNumber numberWithLong:(long)equalizedTimeInterval] forKey:@"eti"];
        
        [singleton_universal.universal_feed_array addObject:temp];
    }
    
    //NSLog(@"%d", [[singleton_universal.universal_feed objectForKey:@"facebook_entry"] count]);
    [singleton_universal.mainTableView reloadData];
}

+(void)fetchTumblrFeed:(NSString *)hashtag singleton:(HashtagDataClass *)singleton_universal{
    hashtag = [hashtag stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSDictionary *dashboardDict = @{@"limit"  : @"20"
                                    };
    [[TMAPIClient sharedInstance] tagged:hashtag parameters:dashboardDict callback:^(id result, NSError *error) {
        if (!error) {
//            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:&error];
            
            
            NSArray *tumblr_data = result; //2
            NSMutableArray *tumb_dat  = [[NSMutableArray alloc] init];
            for(NSDictionary *t in tumblr_data){
                if([[t objectForKey:@"type"] isEqualToString:@"photo"]){
                    [tumb_dat addObject:t];
                }
            }
            tumblr_data = tumb_dat;
            
//            NSLog(@"%@", tumblr_data);
            singleton_universal.universal_tumblr_feed = [[NSMutableDictionary alloc] init];
            [singleton_universal.universal_tumblr_feed setObject:tumblr_data forKey:@"tumblr_data"];
            [singleton_universal.universal_tumblr_feed setObject:@"tumblr" forKey:@"type"];
            
            [self addTumblrToFeed:singleton_universal];
            
            singleton_universal.tumblrBlogs = [[NSMutableDictionary alloc] init];
            
            [[TMAPIClient sharedInstance] userInfo:^(id result, NSError *error) {
                if (!error){
                    NSDictionary *t = result;
                    NSMutableDictionary *blogs = [[result objectForKey:@"user"] objectForKey:@"blogs"];
                    singleton_universal.tumblrBlogs = blogs;
                    //                    NSLog(@"%@", singleton_universal.tumblrBlogs);
                }
            }];
            
        } else {
            NSLog(@"error %@", [error localizedDescription]);
            
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
        }
    }];
    
    
    
}
+(void)fetchInstagramFeed:(NSString *)hashtag singleton:(HashtagDataClass *)singleton_universal{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *access = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"instagram_access_token"];
    hashtag = [hashtag stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSString *instagram_base_url = [NSString stringWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?access_token=%@", hashtag, access];
//    NSString *instagram_feed_url =[instagram_base_url stringByAppendingString:@"&count=30"];
     NSString *instagram_feed_url =[instagram_base_url stringByAppendingString:@""];
    
    NSString *instagram_user_feed = [NSString stringWithFormat:instagram_feed_url];
    NSURL *url = [NSURL URLWithString:instagram_feed_url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSData *jsonData = data;
    //parse out the json data
    singleton_universal.universal_instagram_feed = [[NSMutableDictionary alloc] init];
    if(jsonData != nil){
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:jsonData //1
                              
                              options:kNilOptions
                              error:&error];
        
        BOOL dataExists = [ConnectionFunctions checkInstagramConnectionMeta:[json objectForKey:@"meta"]];
        if(dataExists){
            NSArray *instagram_data = [json objectForKey:@"data"];
            [singleton_universal.universal_instagram_feed setObject:instagram_data forKey:@"instagram_data"];
            [self addInstagramFeed:singleton_universal];
        }
    }
    
    
    
}
+(void)addTwitterToFeed:(HashtagDataClass *)singleton_universal{
    
    
    NSMutableDictionary *test = [singleton_universal.universal_twitter_feed objectForKey:@"twitter_data"];
    
    [singleton_universal.universal_feed setObject:test forKey:@"twitter_entry"];
    for(NSMutableDictionary *dat in [singleton_universal.universal_feed objectForKey:@"twitter_entry"]){
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:dat];
        [temp setObject:@"twitter" forKey:@"type"];
        
        NSString *created_at = [temp objectForKey:@"created_at"];
        NSTimeInterval equalizedTimeInterval = [CreationFunctions returnTwitterTimeInterval:created_at];
        [temp setObject:[NSNumber numberWithLong:(long)equalizedTimeInterval] forKey:@"eti"];
        
        [singleton_universal.universal_feed_array addObject:temp];
    }
    //NSLog(@"%d", [[singleton_universal.universal_feed objectForKey:@"twitter_entry"] count]);
    [singleton_universal.mainTableView reloadData];
}
+(void)addInstagramFeed:(HashtagDataClass *)singleton_universal{
    //First check which feeds to consolidate
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    
    NSString *storePath = [documentsDirectory stringByAppendingPathComponent:@"instagram_auth.txt"];
    NSString *content = [NSString stringWithContentsOfFile:storePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    if([content isEqualToString:@"yes"]){
        [singleton_universal.universal_feed setObject:[singleton_universal.universal_instagram_feed objectForKey:@"instagram_data"] forKey:@"instagram_entry"];
        for(NSMutableDictionary *dat in [singleton_universal.universal_feed objectForKey:@"instagram_entry"]){
            NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:dat];
            [temp setObject:@"instagram" forKey:@"type"];
            
            NSString *new_created_at = [temp objectForKey:@"created_time"];
            NSTimeInterval equalizedTimeInterval = [CreationFunctions returnInstagramTimeInterval:new_created_at];
            [temp setObject:[NSNumber numberWithLong:(long)equalizedTimeInterval] forKey:@"eti"];
            
            [singleton_universal.universal_feed_array addObject:temp];
        }
    }
    
    
    
}

+(void)sortUniversalFeedByTime:(HashtagDataClass *)singleton_universal{
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:singleton_universal.universal_feed_array];
    NSSortDescriptor *hopProfileDescriptor =  [[NSSortDescriptor alloc] initWithKey:@"eti" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObjects:hopProfileDescriptor, nil];
    NSArray *sortedArrayOfDictionaries = [temp sortedArrayUsingDescriptors:descriptors];
    singleton_universal.universal_feed_array = [NSMutableArray arrayWithArray:sortedArrayOfDictionaries];
}
@end
