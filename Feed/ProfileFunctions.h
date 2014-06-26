//
//  ProfileFunctions.h
//  Feed
//
//  Created by George on 2014-06-24.
//  Copyright (c) 2014 George. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProfileDataClass.h"

@interface ProfileFunctions : NSObject
+(void)fetchTwitterFeed:(NSString *)Profile singleton:(ProfileDataClass *)singleton_universal;
+(void)fetchInstagramFeed:(NSString *)Profile singleton:(ProfileDataClass *)singleton_universal;
+(void)fetchTumblrFeed:(NSString *)Profile singleton:(ProfileDataClass *)singleton_universal;
+(void)addTwitterToFeed:(ProfileDataClass *)singleton_universal;
+(void)addInstagramFeed:(ProfileDataClass *)singleton_universal;
+(void)addTumblrFeed:(ProfileDataClass *)singleton_universal;

+(void)sortUniversalFeedByTime:(ProfileDataClass *)singleton_universal;
@end
