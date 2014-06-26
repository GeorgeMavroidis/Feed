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
+(void)fetchTumblrFeed:(NSString *)hashtag singleton:(HashtagDataClass *)singleton_universal;
+(void)addTwitterToFeed:(HashtagDataClass *)singleton_universal;
+(void)addInstagramFeed:(HashtagDataClass *)singleton_universal;
+(void)addTumblrFeed:(HashtagDataClass *)singleton_universal;

+(void)sortUniversalFeedByTime:(HashtagDataClass *)singleton_universal;

@end
