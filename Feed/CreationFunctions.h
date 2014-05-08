//
//  CreationFunctions.h
//  Feed
//
//  Created by George on 2014-03-17.
//  Copyright (c) 2014 George. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstagramCell.h"
#import "TwitterCell.h"
#import "FacebookCell.h"
#import "DataClass.h"

@interface CreationFunctions : NSObject
+(NSMutableAttributedString *)returnInstagramAttributedText:(NSMutableAttributedString *)text;
+(InstagramCell *)createInstagramCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath singleton:(DataClass *)singleton_universal;
+(TwitterCell *)createTwitterCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath singleton:(DataClass *)singleton_universal;
+(FacebookCell *)createFacebookCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath singleton:(DataClass *)singleton_universal;
+(int)returnCommentsHeight:(NSIndexPath*)indexPath textString:(NSString *)text;
+(CGFloat)tableView:(UITableView *)tableView heightForInstagram:(NSIndexPath *)indexPath singleton:(DataClass *)singleton_universal;

+(void)fetchInstagramFeed:(DataClass *)singleton_universal;
+(void)fetchTwitterFeed:(DataClass *)singleton_universal;
+(void)fetchFacebookFeed:(DataClass *)singleton_universal;

+ (void)setTwitterOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier;
+(void)createUniversalFeed:(DataClass *)singleton_universal;
+(void)addTwitterToFeed:(DataClass *)singleton_universal;
+(void)addFacebookToFeed:(DataClass *)singleton_universal;

+(CGFloat)tableView:(UITableView *)tableView heightForTwitter:(NSIndexPath *)indexPath singleton:(DataClass *)singleton_universal;
+(CGFloat)tableView:(UITableView *)tableView heightForFacebook:(NSIndexPath *)indexPath singleton:(DataClass *)singleton_universal;
+(NSMutableAttributedString *)returnTwitterAttributedText:(NSMutableAttributedString *)text;
+(NSMutableAttributedString *)returnTwitterUsername:(NSMutableAttributedString *)text;
+(void)sortUniversalFeedByTime:(DataClass *)singleton_universal;
+(NSTimeInterval) returnInstagramTimeInterval:(NSString *)response;
+(NSTimeInterval) returnTwitterTimeInterval:(NSString *)response;
+(int) findNextInputSpot:(NSTimeInterval)interval array:(NSMutableArray *)inserted;
@end
