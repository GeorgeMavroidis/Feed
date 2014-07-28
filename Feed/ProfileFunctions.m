//
//  ProfileFunctions.m
//  Feed
//
//  Created by George on 2014-06-18.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "ProfileFunctions.h"
#import "STTwitter.h"
#import "CreationFunctions.h"
#import "TwitterCell.h"
#import "AsyncImageView.h"

#import <TMAPIClient.h>
#import "ProfileView.h"

@implementation ProfileFunctions

+(void)fetchTwitterFeed:(NSString *)hashtag singleton:(ProfileDataClass *)singleton_universal{
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
    
    hashtag = [hashtag stringByReplacingOccurrencesOfString:@" " withString:@""];
    hashtag = [hashtag stringByReplacingOccurrencesOfString:@"@" withString:@""];
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerToken consumerSecret:consumerTokenSecret oauthToken:oauthToken oauthTokenSecret:oauthTokenSecret];
//    NSLog(@"~%@~", hashtag);
    singleton_universal.universal_twitter_feed = [[NSMutableDictionary alloc] init];
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
        [twitter getUserTimelineWithScreenName:hashtag count:100 successBlock:^(NSArray *statuses) {
            [singleton_universal.universal_twitter_feed setObject:statuses forKey:@"twitter_data"];
            [singleton_universal.universal_twitter_feed setObject:@"twitter" forKey:@"type"];
            [self addTwitterToFeed:singleton_universal];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self sortUniversalFeedByTime:singleton_universal];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    
                    DataClass *su = [DataClass getInstance];
                    ProfileView *t = (ProfileView *)su.mainViewController;
                    [t update];
                    [t.main_tableView reloadData];
                    NSLog(@"donezo");
                });
//                [t.main_tableView reloadData];
            });
        } errorBlock:^(NSError *error) {
            NSLog(@"%@", [error localizedDescription]);
        }];

        
    } errorBlock:^(NSError *error) {
        // ...
    }];
    
}
+(void)addTumblrToFeed:(ProfileDataClass *)singleton_universal{
    
    
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
+(void)fetchTumblrFeed:(NSString *)hashtag singleton:(ProfileDataClass *)singleton_universal{
    
    hashtag = [hashtag stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSDictionary *dashboardDict = @{@"limit"  : @"20"};

    [[TMAPIClient sharedInstance] posts:hashtag type:@"photo" parameters:dashboardDict  callback:^(id result, NSError *error) {
        if (!error) {
//            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:&error];
            NSArray *tumblr_data = [result objectForKey:@"posts"]; //2
            NSMutableArray *tumb_dat  = [[NSMutableArray alloc] init];
            for(NSDictionary *t in tumblr_data){
                if([[t objectForKey:@"type"] isEqualToString:@"photo"]){
                    [tumb_dat addObject:t];
                }
            }
            tumblr_data = tumb_dat;
            singleton_universal.universal_tumblr_feed = [[NSMutableDictionary alloc] init];
            [singleton_universal.universal_tumblr_feed setObject:tumblr_data forKey:@"tumblr_data"];
            [singleton_universal.universal_tumblr_feed setObject:@"tumblr" forKey:@"type"];
            
            [self addTumblrToFeed:singleton_universal];
            
        } else {
            NSLog(@"errors %@", [error localizedDescription]);
        }
    }];
    
    
    
}
+(void)fetchInstagramFeed:(NSString *)hashtag singleton:(ProfileDataClass *)singleton_universal{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *access = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"instagram_access_token"];
    hashtag = [hashtag stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSString *instagram_base_url = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent?access_token=%@", hashtag, access];
    //    NSString *instagram_feed_url =[instagram_base_url stringByAppendingString:@"&count=30"];
    NSString *instagram_feed_url =[instagram_base_url stringByAppendingString:@""];
    
    NSString *instagram_user_feed = [NSString stringWithFormat:instagram_feed_url];
    NSURL *url = [NSURL URLWithString:instagram_feed_url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSData *jsonData = data;
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:jsonData //1
                          
                          options:kNilOptions
                          error:&error];
    
    NSArray *instagram_data = [json objectForKey:@"data"]; //2
    //    NSLog(@"%@", instagram_data);
    //NSLog(@"%d",[instagram_data count]);
    singleton_universal.universal_instagram_feed = [[NSMutableDictionary alloc] init];
    [singleton_universal.universal_instagram_feed setObject:instagram_data forKey:@"instagram_data"];
    
    
    
}
+(void)fetchInstagramFeedForSelf:(ProfileDataClass *)singleton_universal{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *access = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"instagram_access_token"];
    NSArray* foo = [access componentsSeparatedByString: @"."];
    NSString* day = [foo objectAtIndex: 0];
    NSString *hashtag = day;
    hashtag = [hashtag stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSString *instagram_base_url = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent?access_token=%@", hashtag, access];
    //    NSString *instagram_feed_url =[instagram_base_url stringByAppendingString:@"&count=30"];
    NSString *instagram_feed_url =[instagram_base_url stringByAppendingString:@""];
    
    NSString *instagram_user_feed = [NSString stringWithFormat:instagram_feed_url];
    NSURL *url = [NSURL URLWithString:instagram_feed_url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSData *jsonData = data;
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:jsonData //1
                          
                          options:kNilOptions
                          error:&error];
    
    NSArray *instagram_data = [json objectForKey:@"data"]; //2
    //    NSLog(@"%@", instagram_data);
    //NSLog(@"%d",[instagram_data count]);
    singleton_universal.universal_instagram_feed = [[NSMutableDictionary alloc] init];
    [singleton_universal.universal_instagram_feed setObject:instagram_data forKey:@"instagram_data"];
    
    
    
}
+(void)addTwitterToFeed:(ProfileDataClass *)singleton_universal{
    
    
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
+(void)addInstagramFeed:(ProfileDataClass *)singleton_universal{
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

+(void)sortUniversalFeedByTime:(ProfileDataClass *)singleton_universal{
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:singleton_universal.universal_feed_array];
    NSSortDescriptor *hopProfileDescriptor =  [[NSSortDescriptor alloc] initWithKey:@"eti" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObjects:hopProfileDescriptor, nil];
    NSArray *sortedArrayOfDictionaries = [temp sortedArrayUsingDescriptors:descriptors];
    singleton_universal.universal_feed_array = [NSMutableArray arrayWithArray:sortedArrayOfDictionaries];
}

@end
