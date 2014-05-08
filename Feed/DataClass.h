//
//  DataClass.h
//  Feed
//
//  Created by George on 2014-03-12.
//  Copyright (c) 2014 George. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface DataClass : NSObject {
    NSString *str;
    NSMutableDictionary *universal_instagram_feed, *universal_twitter_feed, *universal_feed, *universal_facebook_feed;
    UITableView *mainTableView;
}
@property(nonatomic,retain)NSString *str;
@property(nonatomic, retain)NSMutableDictionary *universal_instagram_feed;
@property(nonatomic, retain)NSMutableDictionary *universal_twitter_feed;
@property(nonatomic, retain)NSMutableDictionary *universal_facebook_feed;
@property(nonatomic, retain)NSMutableDictionary *universal_feed;
@property(nonatomic, retain)NSMutableArray *universal_feed_array;
@property(nonatomic, retain)UITableView *mainTableView;
+(DataClass*)getInstance;
@end