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
        
        [twitter getSearchTweetsWithQuery:hashtag successBlock:^(NSDictionary *searchMetadata, NSArray *statuses) {
//            NSLog(@"%@", statuses);
            
            [singleton_universal.universal_twitter_feed setObject:statuses forKey:@"twitter_data"];
            [singleton_universal.universal_twitter_feed setObject:@"twitter" forKey:@"type"];
            [self addTwitterToFeed:singleton_universal];
            [self sortUniversalFeedByTime:singleton_universal];
            
        } errorBlock:^(NSError *error) {
            NSLog(@"%@", [error localizedDescription]);
        }];
    } errorBlock:^(NSError *error) {
        // ...
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
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:jsonData //1
                          
                          options:kNilOptions
                          error:&error];
    
    NSArray *instagram_data = [json objectForKey:@"data"]; //2
    NSLog(@"%@", instagram_data);
    //NSLog(@"%d",[instagram_data count]);
    singleton_universal.universal_instagram_feed = [[NSMutableDictionary alloc] init];
    [singleton_universal.universal_instagram_feed setObject:instagram_data forKey:@"instagram_data"];
    
    
    
}
+(void)addTwitterToFeed:(HashtagDataClass *)singleton_universal{
    
    NSMutableDictionary *test = [singleton_universal.universal_twitter_feed objectForKey:@"twitter_data"];
    
    [singleton_universal.universal_feed setObject:test forKey:@"twitter_entry"];
    for(NSMutableDictionary *dat in [singleton_universal.universal_feed objectForKey:@"twitter_entry"]){
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:dat];
        [temp setObject:@"twitter" forKey:@"type"];
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
            [singleton_universal.universal_feed_array addObject:temp];
        }
    }
    
    
    
}

+(void)sortUniversalFeedByTime:(HashtagDataClass *)singleton_universal{
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:singleton_universal.universal_feed_array];
    NSMutableArray *insert = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dict in singleton_universal.universal_feed_array){
        NSString *type = [dict objectForKey:@"type"];
        if([type isEqualToString:@"instagram"]){
            
            NSString *created_at = [dict objectForKey:@"created_at"];
            NSTimeInterval distanceBetweenDates = [CreationFunctions returnInstagramTimeInterval:created_at];
            //int index = [self findNextInputSpot:distanceBetweenDates array:insert];
            
            int rand = (arc4random_uniform([insert count]));
            
            [insert insertObject:dict atIndex:rand];
            //NSLog(@"%d", index);
        }else if([type isEqualToString:@"twitter"]){
            NSString *created_at = [dict objectForKey:@"created_time"];
            NSTimeInterval distanceBetweenDates = [CreationFunctions returnTwitterTimeInterval:created_at];
            //int index = [self findNextInputSpot:distanceBetweenDates array:insert];
            int rand = (arc4random_uniform([insert count]));
            [insert insertObject:dict atIndex:rand];
        }else if([type isEqualToString:@"tumblr"]){
            NSString *created_at = [dict objectForKey:@"date"];
            NSTimeInterval distanceBetweenDates = [CreationFunctions returnTumblrTimeInterval:created_at];
            //int index = [self findNextInputSpot:distanceBetweenDates array:insert];
            int rand = (arc4random_uniform([insert count]));
            [insert insertObject:dict atIndex:rand];
        }else{
            NSLog(@"facebook");
            NSString *created_at = [dict objectForKey:@"created_time"];
            NSTimeInterval distanceBetweenDates = [CreationFunctions returnTwitterTimeInterval:created_at];
            //int index = [self findNextInputSpot:distanceBetweenDates array:insert];
            int rand = (arc4random_uniform([insert count]));
            [insert insertObject:dict atIndex:rand];
        }
    }
    
    // NSLog(@"%@", date_dic);
    
    
    NSArray* reversedArray = [[temp reverseObjectEnumerator] allObjects];
    singleton_universal.universal_feed_array = [NSMutableArray arrayWithArray:insert];
    
}
@end
