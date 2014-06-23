//
//  HashtagFunctions.h
//  Feed
//
//  Created by George on 2014-06-18.
//  Copyright (c) 2014 George. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HashtagDataClass.h"
#import "TwitterCell.h"
@interface HashtagFunctions : NSObject

+(void)fetchTwitterFeed:(NSString *)hashtag singleton:(HashtagDataClass *)singleton_universal;
+(void)fetchInstagramFeed:(NSString *)hashtag singleton:(HashtagDataClass *)singleton_universal;
+(void)addTwitterToFeed:(HashtagDataClass *)singleton_universal;
+(void)addInstagramFeed:(HashtagDataClass *)singleton_universal;

+(TwitterCell *)createTwitterCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath singleton:(NSMutableArray *)singleton_universal;
+(void)sortUniversalFeedByTime:(HashtagDataClass *)singleton_universal;

+(CGFloat)tableView:(UITableView *)tableView heightForTwitter:(NSIndexPath *)indexPath singleton:(HashtagDataClass *)singleton_universal;
@end
