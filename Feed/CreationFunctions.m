//
//  CreationFunctions.m
//  Feed
//
//  Created by George on 2014-03-17.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "CreationFunctions.h"
#import "DataClass.h"
#import "UIImageView+WebCache.h"
#import "STTwitter.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation CreationFunctions

+(NSMutableAttributedString *)returnInstagramAttributedText:(NSMutableAttributedString *)text{
    //NSLog(@"%@",text);
    NSString *converted = [text string];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    NSRegularExpression *regexAt = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&error];
    NSArray *matchesAt = [regexAt matchesInString:converted options:0 range:NSMakeRange(0, converted.length)];
    NSArray *matches = [regex matchesInString:converted options:0 range:NSMakeRange(0, converted.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString* word = [converted substringWithRange:wordRange];
        // NSLog(@"Found tag %@", word);
    }
    for (NSTextCheckingResult *match in matchesAt) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString* word = [converted substringWithRange:wordRange];
        // NSLog(@"Found tag %@", word);
    }
    NSRange range = NSMakeRange(0,text.length);
    
    [regex enumerateMatchesInString:converted options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange subStringRange = [result rangeAtIndex:0];
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0] range:subStringRange];
    }];
    [regexAt enumerateMatchesInString:converted options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange subStringRange = [result rangeAtIndex:0];
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0] range:subStringRange];
    }];
    return text;
}
+(InstagramCell *)createInstagramCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath singleton:(DataClass *)singleton_universal{
    
    // Similar to UITableViewCell, but
    InstagramCell *cell = [[InstagramCell alloc] init];
    
    // Just want to test, so I hardcode the data
    
    int path = indexPath.row;
    
    NSDictionary *temp_instagram = [singleton_universal.universal_feed_array objectAtIndex:path];

    //NSArray *temp_instagram = [singleton_universal.universal_feed objectForKey:@"instagram_entry"];
    
    //NSLog(@"%@", [temp_instagram objectAtIndex:(int)indexPath.row]);
    
    //NSLog(@"%@", [[[temp_instagram[(int)indexPath.row]objectForKey:@"caption"]objectForKey:@"from"]objectForKey:@"username"]);
    NSString *username = [[temp_instagram objectForKey:@"user"]objectForKey:@"username"];
    NSString *user_id = [[temp_instagram objectForKey:@"user"]objectForKey:@"id"];
    NSString *profile_picture = [[temp_instagram objectForKey:@"user"]objectForKey:@"profile_picture"];
    NSString *full_name = [[temp_instagram objectForKey:@"user"]objectForKey:@"full_name"];
    NSString  *created_time = [temp_instagram valueForKey:@"created_time"];
    
    
    NSArray *caption = [temp_instagram objectForKey:@"caption"];
    if(caption != (id)[NSNull null]){
        NSString *text = [[temp_instagram objectForKey:@"caption"]objectForKey:@"text"];
        NSString  *photo_id = [[temp_instagram objectForKey:@"caption"] objectForKey:@"id"];
        
        username = [username stringByAppendingString:@" "];
        text = [username stringByAppendingString:text];
        
        NSMutableAttributedString *attributed_caption = [[NSMutableAttributedString alloc] initWithString:text];
        cell.image_caption.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f];
        [attributed_caption addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0] range:NSMakeRange(0,[username length])];
        [attributed_caption addAttribute:NSFontAttributeName
                                   value:[UIFont fontWithName:@"Arial-BoldMT" size:13.8f]
                                   range:NSMakeRange(0, [username length])];
        [attributed_caption addAttribute:NSFontAttributeName
                                   value:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f]
                                   range:NSMakeRange([username length], [attributed_caption length]-[username length])];
        
        cell.image_caption.attributedText = [CreationFunctions returnInstagramAttributedText:attributed_caption];
        cell.image_caption.hidden = NO;
        cell.small_chat.hidden = NO;
    }else{
        NSString *username = @"";
        username = [username stringByAppendingString:@" "];
        NSString *text = @"";
        text = [username stringByAppendingString:text];
        
        cell.image_caption.text = text;
        //cell.time.text = @"";
        //cell.time.hidden = YES;
        cell.image_caption.hidden = YES;
        cell.small_chat.hidden = YES;
        //NSLog(@"here");
    }
    //[cell.image_caption sizeToFit];
    //[cell.image_caption layoutIfNeeded];
    float contentHeight =  cell.image_caption.contentSize.height;
    
    
    NSString *low_res= [[[temp_instagram objectForKey:@"images"]objectForKey:@"low_resolution"]objectForKey:@"url"];
    NSString *std_res = [[[temp_instagram objectForKey:@"images"]objectForKey:@"standard_resolution"]objectForKey:@"url"];
    
    
    NSString  *likes_count = [[temp_instagram objectForKey:@"likes"]valueForKey:@"count"];
    
    
    NSArray  *comments = [temp_instagram objectForKey:@"comments"];
    
    NSString *comments_string = @"";
    
    NSMutableAttributedString *comment_attributed = [[NSMutableAttributedString alloc] initWithString:comments_string];
    
    cell.comments_text.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f];
    
    if(comments != (id)[NSNull null]){
        
        NSString *count_of_comments= @"view all ";
        NSString *counts = [[temp_instagram objectForKey:@"comments"]valueForKey:@"count"];
        NSString *temp_counts = [NSString stringWithFormat:@"%@", counts];
        count_of_comments =[count_of_comments stringByAppendingString:temp_counts];
        count_of_comments = [count_of_comments stringByAppendingString:@" comments"];
        
        if([temp_counts isEqualToString:@"0"]){
            count_of_comments = @"";
        }else{
            NSArray  *last_comments = [[temp_instagram objectForKey:@"comments"]objectForKey:@"data"];
            int count = [last_comments count];
            
            for(NSDictionary *data in last_comments){
                if(count == [last_comments count] - 2){
                    NSString *comment_username = [[data objectForKey:@"from"]objectForKey:@"username"];
                    NSString *comment_text = [data objectForKey:@"text"];
                    comments_string = [comments_string stringByAppendingString:comment_username];
                    comments_string = [comments_string stringByAppendingString:@" "];
                    comments_string = [comments_string stringByAppendingString:comment_text];
                    comments_string = [comments_string stringByAppendingString:@"\n"];
                    
                    NSAttributedString *attr_user = [[NSAttributedString alloc] initWithString:comment_username attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0], NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:13.8f]}];
                    NSAttributedString *attr_comment = [[NSAttributedString alloc] initWithString:comment_text attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f]}];
                    NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" "];
                    NSAttributedString *nl = [[NSAttributedString alloc] initWithString:@"\n"];
                    
                    
                    [comment_attributed insertAttributedString:attr_user atIndex:0];
                    [comment_attributed insertAttributedString:space atIndex:[attr_user length]];
                    [comment_attributed insertAttributedString:attr_comment atIndex:[attr_user length]+[space length]];
                    [comment_attributed insertAttributedString:nl atIndex:[attr_comment length]+[attr_user length] + [space length]];
                    
                    count--;
                }
                if(count == [last_comments count] - 1){
                    NSString *comment_username = [[data objectForKey:@"from"]objectForKey:@"username"];
                    NSString *comment_text = [data objectForKey:@"text"];
                    comments_string = [comments_string stringByAppendingString:comment_username];
                    comments_string = [comments_string stringByAppendingString:@" "];
                    comments_string = [comments_string stringByAppendingString:comment_text];
                    comments_string = [comments_string stringByAppendingString:@"\n"];
                    NSAttributedString *attr_user = [[NSAttributedString alloc] initWithString:comment_username attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0], NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:13.8f]}];
                    NSAttributedString *attr_comment = [[NSAttributedString alloc] initWithString:comment_text attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f]}];
                    NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" "];
                    NSAttributedString *nl = [[NSAttributedString alloc] initWithString:@"\n"];
                    
                    
                    [comment_attributed insertAttributedString:attr_user atIndex:0];
                    [comment_attributed insertAttributedString:space atIndex:[attr_user length]];
                    [comment_attributed insertAttributedString:attr_comment atIndex:[attr_user length]+[space length]];
                    [comment_attributed insertAttributedString:nl atIndex:[attr_comment length]+[attr_user length] + [space length]];
                    
                    count--;
                }
                if(count == [last_comments count]){
                    NSString *comment_username = [[data objectForKey:@"from"]objectForKey:@"username"];
                    NSString *comment_text = [data objectForKey:@"text"];
                    comments_string = [comments_string stringByAppendingString:comment_username];
                    comments_string = [comments_string stringByAppendingString:@" "];
                    comments_string = [comments_string stringByAppendingString:comment_text];
                    comments_string = [comments_string stringByAppendingString:@"\n"];
                    NSAttributedString *attr_user = [[NSAttributedString alloc] initWithString:comment_username attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0], NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:13.8f]}];
                    NSAttributedString *attr_comment = [[NSAttributedString alloc] initWithString:comment_text attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f]}];
                    NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" "];
                    NSAttributedString *nl = [[NSAttributedString alloc] initWithString:@"\n"];
                    
                    
                    [comment_attributed insertAttributedString:attr_user atIndex:0];
                    [comment_attributed insertAttributedString:space atIndex:[attr_user length]];
                    [comment_attributed insertAttributedString:attr_comment atIndex:[attr_user length]+[space length]];
                    [comment_attributed insertAttributedString:nl atIndex:[attr_comment length]+[attr_user length] + [space length]];
                    count--;
                }
                
            }
            
        }
        cell.comments_count.text = count_of_comments;
        
        cell.comments_text.attributedText = [CreationFunctions returnInstagramAttributedText:comment_attributed];
        cell.comments_count.hidden = NO;
        cell.comments_text.hidden = NO;
    }else{
        cell.comments_count.hidden = YES;
        cell.comments_text.hidden = YES;
    }
    
    //NSLog(@"%d", (int)indexPath.row);
    //cell.textLabel.text = text;
    cell.username.text = username;
    [cell.profile_picture_image_view setImageWithURL:[NSURL URLWithString:profile_picture]
                                    placeholderImage:[UIImage imageNamed:@"insta_placeholder.png"]];
    [cell.main_picture_view setImageWithURL:[NSURL URLWithString:std_res]
                           placeholderImage:[UIImage imageNamed:@""]];
    NSString *temp_likes = [NSString stringWithFormat:@"%@", likes_count];
    temp_likes = [temp_likes stringByAppendingString:@" likes"];
    cell.photo_likes.text = temp_likes;
    cell.caption_username.text = username;
    
    
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSTimeInterval epoch = [created_time doubleValue];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:epoch];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSDate *now = [NSDate date];
    NSTimeInterval distanceBetweenDates = [now timeIntervalSinceDate:date];
    double seconds = 1;
    double minutes = 60;
    double hours = minutes*60;
    double days = hours * 24;
    double weeks = days * 7;
    NSInteger secondsBetweenDates = distanceBetweenDates;
    NSInteger minutesBetweenDates = distanceBetweenDates / minutes;
    NSInteger hoursBetweenDates = distanceBetweenDates / hours;
    NSInteger daysBetweenDates = distanceBetweenDates / days;
    NSInteger weeksBetweenDates = distanceBetweenDates / weeks;
    if(secondsBetweenDates < 60){
        created_time = [NSString stringWithFormat:@"%d", secondsBetweenDates];
        created_time = [created_time stringByAppendingString:@"s"];
        NSLog(@"%d", secondsBetweenDates);
    }else
        if(minutesBetweenDates < 60){
            created_time = [NSString stringWithFormat:@"%d", minutesBetweenDates];
            created_time = [created_time stringByAppendingString:@"m"];
        }else
            if(hoursBetweenDates < 24){
                created_time = [NSString stringWithFormat:@"%d", hoursBetweenDates];
                created_time = [created_time stringByAppendingString:@"h"];
            }else
                if(daysBetweenDates < 7){
                    created_time = [NSString stringWithFormat:@"%d", daysBetweenDates];
                    created_time = [created_time stringByAppendingString:@"d"];
                }
                else{
                    created_time = [NSString stringWithFormat:@"%d", weeksBetweenDates];
                    created_time = [created_time stringByAppendingString:@"w"];
                }
    
    cell.time.text = created_time;
    
    UIFont *font = [UIFont fontWithName:@"Arial-BoldMT" size:13.0f];
    
    
    NSDictionary *data = [singleton_universal.universal_feed_array objectAtIndex:path];
    NSString *text = @"";
    
    if(caption != (id)[NSNull null]){
        text = [[data objectForKey:@"caption"]objectForKey:@"text"];
        
        username = [username stringByAppendingString:@" "];
        text = [username stringByAppendingString:text];
    }
    
    
    int threeCommentsHeight = [self returnCommentsHeight:indexPath textString:comments_string];
    
    int commentsHeight = (int)font.lineHeight;
    CGRect frame = cell.image_caption.frame;
    frame.origin.y = [self returnCommentsHeight:indexPath textString:text]+commentsHeight+385;
    frame.size.height = commentsHeight;
    frame.origin.x = 25;
    cell.comments_count.frame = frame;
    
    CGRect comments_frame = cell.comments_text.frame;
    comments_frame.origin.y = cell.comments_count.frame.origin.y+commentsHeight-5;
    comments_frame.size.height = threeCommentsHeight+10;
    comments_frame.origin.x = 20;
    cell.comments_text.frame = comments_frame;
    cell.comments_text.backgroundColor = [UIColor clearColor];
    
    
    NSArray  *commentsD = [[temp_instagram objectForKey:@"comments"]objectForKey:@"data"];
    if(commentsD != (id)[NSNull null]){
        if([commentsD count] != 0){
            CGRect footer_frame = cell.foot.frame;
            footer_frame.origin.y = cell.comments_text.frame.origin.y+cell.comments_text.frame.size.height+10;
            footer_frame.origin.x = 5;
            cell.foot.frame = footer_frame;
        }else{
            CGRect footer_frame = cell.foot.frame;
            footer_frame.origin.y = cell.comments_count.frame.origin.y;
            footer_frame.origin.x = 5;
            cell.foot.frame = footer_frame;
        }
        
    }
    

    return cell;
}
+(int)returnCommentsHeight:(NSIndexPath*)indexPath textString:(NSString *)text {
    int addedHeight;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.5f];
    
    CGSize size = [text sizeWithFont:font
                   constrainedToSize:CGSizeMake(screenWidth-40, 1000)
                       lineBreakMode:UILineBreakModeWordWrap]; // default mode
    float numberOfLines = size.height / font.lineHeight;
    addedHeight = (int)numberOfLines * (int)font.lineHeight;
    
    
    return addedHeight;
    
}
+(int)returnFacebookMessageHeight:(NSIndexPath*)indexPath textString:(NSString *)text {
    int addedHeight;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:13.5f];
    
    CGRect size = [text
                   boundingRectWithSize:CGSizeMake(screenWidth-20, 500)
                   options:NSStringDrawingUsesLineFragmentOrigin
                   attributes:@{
                                NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:13.5f]
                                }
                   context:nil]; // default mode
    float numberOfLines = size.size.height / font.lineHeight;
    addedHeight = (int)numberOfLines * (int)font.lineHeight;
    
    
    return addedHeight;
    
}

+(CGFloat)tableView:(UITableView *)tableView heightForInstagram:(NSIndexPath *)indexPath singleton:(DataClass *)singleton_universal{
    UIFont *font = [UIFont fontWithName:@"Arial-BoldMT" size:13.0f];
    
    int commentsHeight = (int)font.lineHeight;
    
    int path = indexPath.row;
    
    NSDictionary *temp_instagram = [singleton_universal.universal_feed_array objectAtIndex:path];
    
    NSDictionary *data = temp_instagram;
    NSString *username = [[data objectForKey:@"user"]objectForKey:@"username"];
    NSString *text = @"";
    
    NSArray *caption = [data objectForKey:@"caption"];
    if(caption != (id)[NSNull null]){
        text = [[data objectForKey:@"caption"]objectForKey:@"text"];
        
        username = [username stringByAppendingString:@" "];
        text = [username stringByAppendingString:text];
    }
    NSString *comments_string = @"";
    
    NSArray *comments = [data objectForKey:@"comments"];
    if(comments != (id)[NSNull null]){
        
        NSString *count_of_comments= @"view all ";
        NSString *counts = [[temp_instagram objectForKey:@"comments"]valueForKey:@"count"];
        NSString *temp_counts = [NSString stringWithFormat:@"%@", counts];
        count_of_comments =[count_of_comments stringByAppendingString:temp_counts];
        count_of_comments = [count_of_comments stringByAppendingString:@" comments"];
        
        if([temp_counts isEqualToString:@"0"]){
            count_of_comments = @"";
            comments_string = @"";
        }else{
            NSArray  *last_comments = [[temp_instagram objectForKey:@"comments"]objectForKey:@"data"];
            int count = [last_comments count];
            
            for(NSDictionary *data in last_comments){
                if(count == [last_comments count] - 2){
                    NSString *comment_username = [[data objectForKey:@"from"]objectForKey:@"username"];
                    NSString *comment_text = [data objectForKey:@"text"];
                    comments_string = [comments_string stringByAppendingString:comment_username];
                    comments_string = [comments_string stringByAppendingString:@" "];
                    comments_string = [comments_string stringByAppendingString:comment_text];
                    comments_string = [comments_string stringByAppendingString:@"\n"];
                    count--;
                }
                if(count == [last_comments count] - 1){
                    NSString *comment_username = [[data objectForKey:@"from"]objectForKey:@"username"];
                    NSString *comment_text = [data objectForKey:@"text"];
                    comments_string = [comments_string stringByAppendingString:comment_username];
                    comments_string = [comments_string stringByAppendingString:@" "];
                    comments_string = [comments_string stringByAppendingString:comment_text];
                    comments_string = [comments_string stringByAppendingString:@"\n"];
                    count--;
                }
                if(count == [last_comments count]){
                    NSString *comment_username = [[data objectForKey:@"from"]objectForKey:@"username"];
                    NSString *comment_text = [data objectForKey:@"text"];
                    comments_string = [comments_string stringByAppendingString:comment_username];
                    comments_string = [comments_string stringByAppendingString:@" "];
                    comments_string = [comments_string stringByAppendingString:comment_text];
                    comments_string = [comments_string stringByAppendingString:@"\n"];
                    count--;
                }
                
            }
            
        }
    }
    
    int addedHeight = [CreationFunctions returnCommentsHeight:indexPath textString:text];
    int threeCommentsHeight = [CreationFunctions returnCommentsHeight:indexPath textString:comments_string];
    return 480+addedHeight+commentsHeight+threeCommentsHeight;

}
+(void)fetchInstagramFeed:(DataClass *)singleton_universal{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *access = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"instagram_access_token"];
    NSString *instagram_base_url = @"https://api.instagram.com/v1/users/self/feed?access_token=";
    NSString *instagram_feed_url = [instagram_base_url stringByAppendingString:access];
    instagram_feed_url =[instagram_feed_url stringByAppendingString:@"&count=30"];
    
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
    //NSLog(@"%@", instagram_data);
    //NSLog(@"%d",[instagram_data count]);
    singleton_universal.universal_instagram_feed = [[NSMutableDictionary alloc] init];
    [singleton_universal.universal_instagram_feed setObject:instagram_data forKey:@"instagram_data"];
    
    

}
+(void)fetchFacebookFeed:(DataClass *)singleton_universal{
//?filter=app_2305272732&fields=message,id,from,full_picture
    [FBRequestConnection startWithGraphPath:@"me/home/?filter=photos&limit=50"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  
                                //  NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                  NSArray *facebook_data = [result objectForKey:@"data"]; //2
                                  
                                  singleton_universal.universal_facebook_feed = [[NSMutableDictionary alloc] init];
                                  [singleton_universal.universal_facebook_feed setObject:facebook_data forKey:@"facebook_data"];
                                  [singleton_universal.universal_facebook_feed setObject:@"facebook" forKey:@"type"];

                                  
                                  NSLog(@"facebook count %d", [facebook_data count]);
                                  
                                  [self addFacebookToFeed:singleton_universal];
                                  
                                  [self sortUniversalFeedByTime:singleton_universal];
                                  
                              } else {
                                  NSLog(@"error %@", [error localizedDescription]);
                                  
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                              }
                          }];
    
    
    
}
+ (void)setTwitterOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:nil consumerKey:@"4tIoaRQHod1IQ00wtSmRw" consumerSecret:@"S6GATtE4xirn5WlfW79d6aSH4ciMD196hPQuL2g52M8"];
    [twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"-- screenName: %@", screenName);
        
        /*
         At this point, the user can use the API and you can read his access tokens with:
         
         _twitter.oauthAccessToken;
         _twitter.oauthAccessTokenSecret;
         
         You can store these tokens (in user default, or in keychain) so that the user doesn't need to authenticate again on next launches.
         
         Next time, just instanciate STTwitter with the class method:
         
         +[STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerSecret:oauthToken:oauthTokenSecret:]
         
         Don't forget to call the -[STTwitter verifyCredentialsWithSuccessBlock:errorBlock:] after that.
         */
        
    } errorBlock:^(NSError *error) {
        NSLog(@"-- %@", [error localizedDescription]);
    }];
    
}
+(void)fetchTwitterFeed:(DataClass *)singleton_universal{
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
    
    [twitter getHomeTimelineSinceID:nil
                              count:100
                       successBlock:^(NSArray *statuses) {
                           //NSLog(@"%@", statuses);
                           [singleton_universal.universal_twitter_feed setObject:statuses forKey:@"twitter_data"];
                           [singleton_universal.universal_twitter_feed setObject:@"twitter" forKey:@"type"];
                           [self addTwitterToFeed:singleton_universal];
                           [self sortUniversalFeedByTime:singleton_universal];
                           
                       } errorBlock:^(NSError *error) {
                           NSLog(@"%@",[error localizedDescription]);
                       }];
    
}
+(void)createUniversalFeed:(DataClass *)singleton_universal{
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
+(void)addTwitterToFeed:(DataClass *)singleton_universal{
    
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
+(void)addFacebookToFeed:(DataClass *)singleton_universal{
   
    NSMutableDictionary *test = [singleton_universal.universal_facebook_feed objectForKey:@"facebook_data"];
    
    [singleton_universal.universal_feed setObject:test forKey:@"facebook_entry"];
    for(NSMutableDictionary *dat in [singleton_universal.universal_feed objectForKey:@"facebook_entry"]){

        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:dat];
        [temp setObject:@"facebook" forKey:@"type"];
        [singleton_universal.universal_feed_array addObject:temp];
    }
    
    //NSLog(@"%d", [[singleton_universal.universal_feed objectForKey:@"facebook_entry"] count]);
    [singleton_universal.mainTableView reloadData];
}

+(TwitterCell *)createTwitterCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath singleton:(DataClass *)singleton_universal{
    
    // Similar to UITableViewCell, but
    TwitterCell *cell = [[TwitterCell alloc] init];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // Just want to test, so I hardcode the data
    
    int path = indexPath.row;
    
    NSDictionary *temp_twitter = [singleton_universal.universal_feed_array objectAtIndex:path];
    
   // NSLog(@"%@", [temp_twitter objectAtIndex:path]);
    
    //NSLog(@"%@", [[[temp_instagram[(int)indexPath.row]objectForKey:@"caption"]objectForKey:@"from"]objectForKey:@"username"]);
    NSString *text = [temp_twitter objectForKey:@"text"];
    NSMutableAttributedString *temp = [[NSMutableAttributedString alloc] initWithString:text];
    cell.tweet.attributedText = [self returnTwitterAttributedText:temp];
    cell.tweet.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f];
   // NSString *user_id = [[temp_twitter[path]objectForKey:@"user"]objectForKey:@"id"];
    NSString *profile_picture = [[temp_twitter objectForKey:@"user"]objectForKey:@"profile_image_url_https"];
    profile_picture = [profile_picture stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"];
    [cell.profile_picture_image_view setImageWithURL:[NSURL URLWithString:profile_picture]
                                    placeholderImage:[UIImage imageNamed:@"insta_placeholder.png"]];
    NSString *full_name = [[temp_twitter objectForKey:@"user"]objectForKey:@"name"];
    NSString *username = [[temp_twitter objectForKey:@"user"]objectForKey:@"screen_name"];
    NSString *created_at = [temp_twitter objectForKey:@"created_at"];
    
    NSString *favorite_count = [temp_twitter objectForKey:@"favorite_count"];
    
    NSString *temp_favs = [NSString stringWithFormat:@"%@", favorite_count];
    if(![temp_favs isEqualToString:@"0"]){
        cell.favorites.text = temp_favs;
        
    }
    NSString *retweet_count = [temp_twitter objectForKey:@"retweet_count"];
    
    NSString *retweet_favs = [NSString stringWithFormat:@"%@", retweet_count];
    if(![retweet_favs isEqualToString:@"0"]){
        cell.retweets.text = retweet_favs;
    }
    
    
    full_name = [full_name stringByAppendingString:@" "];
    full_name = [full_name stringByAppendingString:@"@"];
    full_name = [full_name stringByAppendingString:username];
    
    
    NSMutableAttributedString *temp_user = [[NSMutableAttributedString alloc] initWithString:full_name];
    cell.username.attributedText = [self returnTwitterUsername:temp_user];
    
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
    NSDate *tweetCreatedDate = [dateFormatter dateFromString:created_at];
    NSTimeInterval distanceBetweenDates = [now timeIntervalSinceDate:tweetCreatedDate];
    double seconds = 1;
    double minutes = 60;
    double hours = minutes*60;
    double days = hours * 24;
    double weeks = days * 7;
    NSInteger secondsBetweenDates = distanceBetweenDates;
    NSInteger minutesBetweenDates = distanceBetweenDates / minutes;
    NSInteger hoursBetweenDates = distanceBetweenDates / hours;
    NSInteger daysBetweenDates = distanceBetweenDates / days;
    NSInteger weeksBetweenDates = distanceBetweenDates / weeks;
    NSString *created_time = created_at;
    if(secondsBetweenDates < 60){
        created_time = [NSString stringWithFormat:@"%d", secondsBetweenDates];
        created_time = [created_time stringByAppendingString:@"s"];
        NSLog(@"%d", secondsBetweenDates);
    }else
        if(minutesBetweenDates < 60){
            created_time = [NSString stringWithFormat:@"%d", minutesBetweenDates];
            created_time = [created_time stringByAppendingString:@"m"];
        }else
            if(hoursBetweenDates < 24){
                created_time = [NSString stringWithFormat:@"%d", hoursBetweenDates];
                created_time = [created_time stringByAppendingString:@"h"];
            }else
                if(daysBetweenDates < 7){
                    created_time = [NSString stringWithFormat:@"%d", daysBetweenDates];
                    created_time = [created_time stringByAppendingString:@"d"];
                }
                else{
                    created_time = [NSString stringWithFormat:@"%d", weeksBetweenDates];
                    created_time = [created_time stringByAppendingString:@"w"];
                }
    
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGRect size = [text
                   boundingRectWithSize:CGSizeMake(screenWidth-65-75, 500)
                   options:NSStringDrawingUsesLineFragmentOrigin
                   attributes:@{
                                NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f]
                                }
                   context:nil]; // default mode
    float numberOfLines = size.size.height / font.lineHeight;
    int addedHeight = (int)numberOfLines * (int)font.lineHeight;
    
   // NSLog(@"%@ - %f", username, numberOfLines);
    cell.time_label.text = created_time;
    //NSString  *created_time = [temp_twitter[(int)indexPath.row]valueForKey:@"created_time"];
    CGRect footer_frame = cell.interact_footer.frame;
    
    footer_frame.origin.y = cell.tweet.frame.origin.y+addedHeight;
    
    cell.interact_footer.frame = footer_frame;
    
    return cell;
}

+(FacebookCell *)createFacebookCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath singleton:(DataClass *)singleton_universal{
    
    // Similar to UITableViewCell, but
    FacebookCell *cell = [[FacebookCell alloc] init];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // Just want to test, so I hardcode the data
    int path = indexPath.row;
    
    NSDictionary *temp_facebook = [singleton_universal.universal_feed_array objectAtIndex:path];
    
    NSString *username = [[temp_facebook objectForKey:@"from"] objectForKey:@"name"];
    NSString *profile_id = [[temp_facebook objectForKey:@"from"] objectForKey:@"id"];
    NSString *created_time_initial = [temp_facebook objectForKey:@"created_time"];
    NSString *full_picture = [temp_facebook objectForKey:@"picture"];
    full_picture = [full_picture stringByReplacingOccurrencesOfString:@"_s.jpg" withString:@"_o.jpg"];
    full_picture = [full_picture stringByReplacingOccurrencesOfString:@"_s.png" withString:@"_o.png"];
    //NSLog(full_picture);
    NSString *message = [temp_facebook objectForKey:@"message"];
    
    
   // [FBRequestConnection requestWithGraphPath:@"ID/likes"];
    
    
    NSString *base  =@"http://graph.facebook.com/";
    base = [base stringByAppendingString:profile_id];
    base = [base stringByAppendingString:@"/picture?width=200&height=200"];
    base = [base stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    [cell.main_picture setImageWithURL:[NSURL URLWithString:full_picture]
                                    placeholderImage:[UIImage imageNamed:@""]];
    
    
    [cell.profile_picture_image_view setImageWithURL:[NSURL URLWithString:base]
                                    placeholderImage:[UIImage imageNamed:@"insta_placeholder.png"]];
    cell.username.text = username;
    //cell.main_message.text = message;
    if(message == nil){
        
    }else{
        NSMutableAttributedString *attributed_caption = [[NSMutableAttributedString alloc] initWithString:message];
        cell.main_message.attributedText = [CreationFunctions returnTwitterAttributedText:attributed_caption];
    }
    CGRect frame = cell.main_message.frame;
    frame.origin.y = 60;
    frame.size.height = [self returnFacebookMessageHeight:indexPath textString:message]+20;
    cell.main_message.frame = frame;
    cell.main_message.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f];
    frame = cell.main_picture.frame;
    frame.origin.y = 85+[self returnFacebookMessageHeight:indexPath textString:message];
    cell.main_picture.frame = frame;
    frame.origin.y = cell.main_picture.frame.origin.y+200;
    cell.interact_footer.frame = frame;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    NSDate *date = [df dateFromString:created_time_initial];
    [df setDateFormat:@"eee MMM dd, yyyy hh:mm"];
    NSString *dateStr = [df stringFromDate:date];
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"eee MMM dd, yyyy hh:mm"];
    NSDate *facebookCreatedDate = [dateFormatter dateFromString:dateStr];
    NSTimeInterval distanceBetweenDates = [now timeIntervalSinceDate:facebookCreatedDate];
    double seconds = 1;
    double minutes = 60;
    double hours = minutes*60;
    double days = hours * 24;
    double weeks = days * 7;
    NSInteger secondsBetweenDates = distanceBetweenDates;
    NSInteger minutesBetweenDates = distanceBetweenDates / minutes;
    NSInteger hoursBetweenDates = distanceBetweenDates / hours;
    NSInteger daysBetweenDates = distanceBetweenDates / days;
    NSInteger weeksBetweenDates = distanceBetweenDates / weeks;
    NSString *created_time = dateStr;
    if(secondsBetweenDates < 60){
        created_time = [NSString stringWithFormat:@"%d", secondsBetweenDates];
        if(secondsBetweenDates == 1){
            created_time = [created_time stringByAppendingString:@" second ago"];
        }else{
            created_time = [created_time stringByAppendingString:@"s"];
        }
        NSLog(@"%d", secondsBetweenDates);
    }else
        if(minutesBetweenDates < 60){
            created_time = [NSString stringWithFormat:@"%d", minutesBetweenDates];
            if(minutesBetweenDates == 1){
                created_time = [created_time stringByAppendingString:@" minute ago"];
            }else{
                created_time = [created_time stringByAppendingString:@" minutes ago"];
            }
        }else
            if(hoursBetweenDates < 24){
                created_time = [NSString stringWithFormat:@"%d", hoursBetweenDates];
                if(hoursBetweenDates == 1){
                    created_time = [created_time stringByAppendingString:@" hour ago"];
                }else{
                    created_time = [created_time stringByAppendingString:@" hours ago"];
                }
            }else
                if(daysBetweenDates < 7){
                    created_time = [NSString stringWithFormat:@"%d", daysBetweenDates];
                    if(daysBetweenDates == 1){
                        created_time = [created_time stringByAppendingString:@" day ago"];
                    }else{
                        created_time = [created_time stringByAppendingString:@" days ago"];
                    }
                }
                else{
                    created_time = [NSString stringWithFormat:@"%d", weeksBetweenDates];
                    if(weeksBetweenDates == 1){
                        created_time = [created_time stringByAppendingString:@" week ago"];
                    }else{
                        created_time = [created_time stringByAppendingString:@" weeks ago"];
                    }
                }
    cell.time_label.text = created_time;
   // NSLog(dateStr);
    
    return cell;
}
+(CGFloat)tableView:(UITableView *)tableView heightForTwitter:(NSIndexPath *)indexPath singleton:(DataClass *)singleton_universal{
    int addedHeight;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    int path = indexPath.row;
    
    NSDictionary *temp_twitter = [singleton_universal.universal_feed_array objectAtIndex:path];
    
    NSString *text = [temp_twitter objectForKey:@"text"];

    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f];
    
    CGRect size = [text
                   boundingRectWithSize:CGSizeMake(screenWidth-65-75, 500)
                   options:NSStringDrawingUsesLineFragmentOrigin
                   attributes:@{
                                NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f]
                                }
                   context:nil]; // default mode
    float numberOfLines = size.size.height / font.lineHeight;
    addedHeight = (int)numberOfLines * (int)font.lineHeight;
    return 30+addedHeight+20;
    
}
+(CGFloat)tableView:(UITableView *)tableView heightForFacebook:(NSIndexPath *)indexPath singleton:(DataClass *)singleton_universal{
    int addedHeight;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    int path = indexPath.row;
    
    NSDictionary *temp_facebook = [singleton_universal.universal_feed_array objectAtIndex:path];
    
    NSString *text = [temp_facebook objectForKey:@"text"];
    
    NSString *message = [temp_facebook objectForKey:@"message"];
    NSString *main_id = [temp_facebook objectForKey:@"id"];
    
    addedHeight = [self returnFacebookMessageHeight:indexPath textString:message];
    return 250+addedHeight+80;
    
}
+(NSMutableAttributedString *)returnTwitterAttributedText:(NSMutableAttributedString *)text{
    //NSLog(@"%@",text);
    NSString *converted = [text string];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    NSRegularExpression *regexAt = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&error];
    NSRegularExpression *regexhttp = [NSRegularExpression regularExpressionWithPattern:@"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+" options:0 error:&error];
    NSArray *matchesAt = [regexAt matchesInString:converted options:0 range:NSMakeRange(0, converted.length)];
    NSArray *matches = [regex matchesInString:converted options:0 range:NSMakeRange(0, converted.length)];
    NSArray *matchesHttp = [regexhttp matchesInString:converted options:0 range:NSMakeRange(0, converted.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString* word = [converted substringWithRange:wordRange];
        // NSLog(@"Found tag %@", word);
    }
    for (NSTextCheckingResult *match in matchesAt) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString* word = [converted substringWithRange:wordRange];
        // NSLog(@"Found tag %@", word);
    }
    for (NSTextCheckingResult *match in matchesHttp) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString* word = [converted substringWithRange:wordRange];
        // NSLog(@"Found tag %@", word);
    }
    NSRange range = NSMakeRange(0,text.length);
    
    [regex enumerateMatchesInString:converted options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange subStringRange = [result rangeAtIndex:0];
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0] range:subStringRange];
    }];
    [regexAt enumerateMatchesInString:converted options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange subStringRange = [result rangeAtIndex:0];
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0] range:subStringRange];
    }];
    [regexhttp enumerateMatchesInString:converted options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange subStringRange = [result rangeAtIndex:0];
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0] range:subStringRange];

    }];
    
    //[[text mutableString] replaceOccurrencesOfString:@"http://" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, text.string.length)];
    
    return text;
}
+(NSMutableAttributedString *)returnTwitterUsername:(NSMutableAttributedString *)text{
    //NSLog(@"%@",text);
    NSString *converted = [text string];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:converted options:0 range:NSMakeRange(0, converted.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString* word = [converted substringWithRange:wordRange];
        // NSLog(@"Found tag %@", word);
    }
    NSRange range = NSMakeRange(0,text.length);
    
    [regex enumerateMatchesInString:converted options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange subStringRange = [result rangeAtIndex:0];
        [text addAttribute:NSFontAttributeName
                                   value:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.5f]
                                   range:subStringRange];
        
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:0.5 alpha:1] range:subStringRange];

    }];
    
    
    return text;
}
+(void)sortUniversalFeedByTime:(DataClass *)singleton_universal{
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:singleton_universal.universal_feed_array];
    NSMutableArray *insert = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dict in singleton_universal.universal_feed_array){
        NSString *type = [dict objectForKey:@"type"];
        if([type isEqualToString:@"instagram"]){
            
            NSString *created_at = [dict objectForKey:@"created_at"];
            NSTimeInterval distanceBetweenDates = [self returnInstagramTimeInterval:created_at];
            //int index = [self findNextInputSpot:distanceBetweenDates array:insert];
            
            int rand = (arc4random_uniform([insert count]));
            [insert insertObject:dict atIndex:rand];
            //NSLog(@"%d", index);
        }else if([type isEqualToString:@"twitter"]){
            NSString *created_at = [dict objectForKey:@"created_time"];
            NSTimeInterval distanceBetweenDates = [self returnTwitterTimeInterval:created_at];
           //int index = [self findNextInputSpot:distanceBetweenDates array:insert];
            int rand = (arc4random_uniform([insert count]));
            [insert insertObject:dict atIndex:rand];
        }else{
            NSLog(@"facebook");
            NSString *created_at = [dict objectForKey:@"created_time"];
            NSTimeInterval distanceBetweenDates = [self returnTwitterTimeInterval:created_at];
            //int index = [self findNextInputSpot:distanceBetweenDates array:insert];
            int rand = (arc4random_uniform([insert count]));
            [insert insertObject:dict atIndex:rand];
        }
    }
    
   // NSLog(@"%@", date_dic);
    
    
    NSArray* reversedArray = [[temp reverseObjectEnumerator] allObjects];
    singleton_universal.universal_feed_array = [NSMutableArray arrayWithArray:insert];
    
}
+(int) findNextInputSpot:(NSTimeInterval)interval array:(NSMutableArray *)inserted{
    int index = 0;
    int count = 0;
    for(NSMutableDictionary *dict in inserted){
        //NSLog(@"count = %d", count);
        //NSLog(@"%d", index);
        NSString *type = [dict objectForKey:@"type"];
        if([type isEqualToString:@"instagram"]){
            NSString *created_at = [dict objectForKey:@"created_time"];
            NSTimeInterval distanceBetweenDates = [self returnInstagramTimeInterval:created_at];
            
            if((NSInteger)interval < (NSInteger)distanceBetweenDates){
                //NSLog(@"Interval %@ > distance %@", interval, distanceBetweenDates);
                return index;
            }
        }else{
            NSString *created_at = [dict objectForKey:@"created_at"];
            NSTimeInterval distanceBetweenDates = [self returnTwitterTimeInterval:created_at];
            
            if((NSInteger)interval < (NSInteger)distanceBetweenDates){
                //NSLog(@"Interval %@ > distance %@", interval, distanceBetweenDates);
                return index;
            }
        }
        count++;
        index++;
    }
    return index;
}
+(NSTimeInterval) returnInstagramTimeInterval:(NSString *)response{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
    NSDate *tweetCreatedDate = [dateFormatter dateFromString:response];
    NSTimeInterval distanceBetweenDates = [now timeIntervalSinceDate:tweetCreatedDate];
    //NSLog(@"%ld", (long)distanceBetweenDates);
    return distanceBetweenDates;
}
+(NSTimeInterval) returnTwitterTimeInterval:(NSString *)response{
    NSTimeInterval epoch = [response doubleValue];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:epoch];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSDate *now = [NSDate date];
    NSTimeInterval distanceBetweenDates = [now timeIntervalSinceDate:date];
    return distanceBetweenDates;
}
@end
