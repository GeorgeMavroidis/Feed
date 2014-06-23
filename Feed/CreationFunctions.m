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
#import <TMAPIClient.h>
#import "AsyncImageView.h"
#import "AppDelegate.h"
#import "ProfileView.h"
#import "TwitterComposeScreenViewController.h"
#import "InstagramCommentViewController.h"
#import "TumblrComposeViewController.h"
#import "HashtagSearch.h"

@interface MediaInterface : NSObject
    @property (nonatomic, strong) UITapGestureRecognizer *gestureRec;
    @property (nonatomic, strong) NSString *actual_media_id;
@end

@implementation MediaInterface
@synthesize gestureRec, actual_media_id;
-(id)init {
    self=[super init];
    if (self){
        gestureRec = [[UITapGestureRecognizer alloc] init];
        actual_media_id = @"";
    }
    return self;
}
@end


@interface RetweetActionSheet : UIActionSheet <UIActionSheetDelegate>
@property (nonatomic, strong) NSString *actual_media_id;
@property (nonatomic, strong) TwitterCell *twit_temp_cell;
-(id)initWithTitle:(NSString *)title med_id:(NSString *)med delegate:(id<UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;
@end

@implementation RetweetActionSheet
@synthesize actual_media_id, twit_temp_cell;
-(id)initWithTitle:(NSString *)title med_id:(NSString *)med cell:(TwitterCell *)temp_cell delegate:(id<UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    self = [super init];
    self = [super initWithTitle:title delegate:delegate cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles, nil];
    if (self){
        actual_media_id = med;
        twit_temp_cell = temp_cell;
    }
    return self;
    
}

@end

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
+(InstagramCell *)createInstagramCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath singleton:(NSMutableArray *)singleton_universal{
    
    // Similar to UITableViewCell, but
    InstagramCell *cell = [[InstagramCell alloc] init];
    
    // Just want to test, so I hardcode the data
    
    int path = indexPath.row;
    
//    NSDictionary *temp_instagram = [singleton_universal.universal_feed_array objectAtIndex:path];
    NSDictionary *temp_instagram = [singleton_universal objectAtIndex:path];

    //NSArray *temp_instagram = [singleton_universal.universal_feed objectForKey:@"instagram_entry"];
    
    //NSLog(@"%@", [temp_instagram objectAtIndex:(int)indexPath.row]);
    
    //NSLog(@"%@", [[[temp_instagram[(int)indexPath.row]objectForKey:@"caption"]objectForKey:@"from"]objectForKey:@"username"]);
    NSString *username = [[temp_instagram objectForKey:@"user"]objectForKey:@"username"];
    NSString *user_id = [[temp_instagram objectForKey:@"user"]objectForKey:@"id"];
    NSString *profile_picture = [[temp_instagram objectForKey:@"user"]objectForKey:@"profile_picture"];
    NSString *full_name = [[temp_instagram objectForKey:@"user"]objectForKey:@"full_name"];
    NSString  *created_time = [temp_instagram valueForKey:@"created_time"];
    NSString *get_media_id = [temp_instagram valueForKey:@"id"];
    
    cell.media_id = get_media_id;
    
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
            NSArray* reversedArray = [[last_comments reverseObjectEnumerator] allObjects];
            last_comments = reversedArray;
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
    cell.profile_picture_image_view.imageURL =[NSURL URLWithString:profile_picture];
    cell.main_picture_view.imageURL =[NSURL URLWithString:std_res];
//    [cell.profile_picture_image_view setImageWithURL:[NSURL URLWithString:profile_picture]
//                                placeholderImage:[UIImage imageNamed:@"insta_placeholder.png"]];
//    [cell.main_picture_view setImageWithURL:[NSURL URLWithString:std_res]
//                           placeholderImage:[UIImage imageNamed:@"insta_placeholders.png"]];
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
    
    
    NSDictionary *data = [singleton_universal objectAtIndex:path];
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
    
    //MediaInterface *media_int = [[MediaInterface alloc] init];
    //media_int.actual_media_id = get_media_id;
    //media_int.gestureRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(instagramDoubleTap:)];
    UITapGestureRecognizer *tapTwice = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(instagramDoubleTap:)];
    tapTwice.numberOfTapsRequired = 2;
    cell.main_picture_view.userInteractionEnabled = YES;
    [cell.main_picture_view addGestureRecognizer:tapTwice];
    
    UITapGestureRecognizer *commentView = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(loadCommentView:)];
    UITapGestureRecognizer *commentViewMain = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(loadCommentViewMiddle:)];
    cell.foot_comment.userInteractionEnabled = YES;
    [cell.foot_comment addGestureRecognizer:commentView];
    [cell.comments_count setUserInteractionEnabled:YES];
    [cell.comments_count addGestureRecognizer:commentViewMain];
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
    [gr setNumberOfTapsRequired:1];
    [cell.image_caption setUserInteractionEnabled:YES];
    [cell.image_caption setScrollEnabled:NO];
    [cell.image_caption setEditable:NO];
    [cell.image_caption addGestureRecognizer:gr];
    
    [cell.comments_text setUserInteractionEnabled:YES];
    [cell.comments_text setScrollEnabled:NO];
    [cell.comments_text setEditable:NO];
    [cell.comments_text addGestureRecognizer:gr];

    return cell;
}
+(void)instagramDoubleTap:(UITapGestureRecognizer *)sender {
    //recognizer = (MediaInterface *)media_object.gestureRec;
    //MediaInterface *test = (MediaInterface*)media_object;
    //NSLog(test.actual_media_id);
    InstagramCell *test =[[((InstagramCell *) sender.view) superview] superview];
    
    NSString *temp_media = test.media_id;
    
    UITapGestureRecognizer *recognizer = sender;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    UIImageView *like_image = [[UIImageView alloc] initWithFrame:CGRectMake(recognizer.view.center.x - 75, recognizer.view.center.y-125, 150,150)];
    
    like_image.image = [UIImage imageNamed:@"heart_white.png"];
    [recognizer.view addSubview:like_image];
    
    like_image.alpha = 1.0;
    
    [UIView animateWithDuration:2.0 animations:^{
        like_image.alpha = 0.0;
    }completion:^(BOOL finished) {
        
    }];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *access = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"instagram_access_token"];

    NSString *post = [NSString stringWithFormat:@"access_token=%@",access];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/likes", temp_media]]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if(conn){
        NSLog(@"Connection Successful");
    }
    else{
        NSLog(@"Connection could not be made");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
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
+(int)returnTumblrMessageHeight:(NSIndexPath*)indexPath textString:(NSAttributedString *)text {
    int addedHeight;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    UIFont *font = [UIFont fontWithName:@"Helvetica-Light" size:14.0f];
    CGRect size = [text boundingRectWithSize:CGSizeMake(screenWidth, 500) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    CGRect size_text = [[text string]
                   boundingRectWithSize:CGSizeMake(screenWidth, 500)
                   options:NSStringDrawingUsesLineFragmentOrigin
                   attributes:@{
                                NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Light" size:14.0f]
                                }
                        context:nil]; // default mode*/
    float numberOfLines = size.size.height / font.lineHeight;
    addedHeight = (int)numberOfLines * (int)font.lineHeight;

    
    float numberOfLines_text = size_text.size.height / font.lineHeight;
    int addedHeight_text = (int)numberOfLines * (int)font.lineHeight;
    
    return addedHeight_text;
    
}

+(CGFloat)tableView:(UITableView *)tableView heightForInstagram:(NSIndexPath *)indexPath singleton:(NSMutableArray *)singleton_universal{
    UIFont *font = [UIFont fontWithName:@"Arial-BoldMT" size:13.0f];
    
    int commentsHeight = (int)font.lineHeight;
    
    int path = indexPath.row;
    
    NSDictionary *temp_instagram = [singleton_universal objectAtIndex:path];
    
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
            NSArray* reversedArray = [[last_comments reverseObjectEnumerator] allObjects];
            last_comments = reversedArray;
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
+(void)fetchTumblrFeed:(DataClass *)singleton_universal{
    [TMAPIClient sharedInstance].OAuthConsumerKey = @"gPPreRGZ96PskkcUk9J0fg70gCjWtI8AfO3aq20Ssenqzj5KIs";
    [TMAPIClient sharedInstance].OAuthConsumerSecret = @"zDyi5guipOImlfJEAd7Q4aTodo1z7Y3p66cXOvrA4xa6b9gSiI";
    [TMAPIClient sharedInstance].OAuthToken = @"5HPnr9RGkFPNsGThFYoBehtBakYg46skHWNeLD9J5tmDHGHPyF";
    [TMAPIClient sharedInstance].OAuthTokenSecret = @"ok8fhbhadpJGlFFKpT645l6VhQpc53JoIF8WIZhaMCD5eZGVWc";
    
    NSDictionary *dashboardDict = @{@"limit"  : @"20",
                                    @"type" : @"photo",
                                    @"notes_info" : @"false",
                                    @"reblog_info"  : @"false"
                                    };
    [[TMAPIClient sharedInstance] dashboard:dashboardDict callback:^(id result, NSError *error) {
        if (!error) {
//            NSLog(@"%@", result);
            //  NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSArray *tumblr_data = [result objectForKey:@"posts"]; //2
            
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
+ (void)fadeInLayer:(CALayer *)l
{
    CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimate.duration            = 0.5;
    fadeInAnimate.repeatCount         = 1;
    fadeInAnimate.autoreverses        = NO;
    fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
    fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
    fadeInAnimate.removedOnCompletion = YES;
    [l addAnimation:fadeInAnimate forKey:@"animateOpacity"];
    return;
}
+(void)fetchFacebookFeed:(DataClass *)singleton_universal{
//?filter=app_2305272732&fields=message,id,from,full_picture
    [self checkFacebookSession];
    
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
                                  NSLog(@"error %@", error.description);
                                  
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                              }
                          }];
    
    
    
}
+(BOOL)checkFacebookSession
{
    if([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded){
        NSLog(@"Logged in to Facebook");
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile, user_friends"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          NSLog(@"not allowed login ui");
                                          AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
                                          [appDelegate sessionStateChanged:session state:state error:error];
                                          
                                          if(error) NSLog(@"eerrrooor %@", [error localizedDescription]);
                                          //NSLog(@"YES");
                                      }];
        
        return YES;
    }
    else{
        NSLog(@"Not logged in to Facebook");
        // Note this handler block should be the exact same as the handler passed to any open calls.
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                // Success! Include your code to handle the results here
                NSLog(@"user info: %@", result);
            } else {
                // An error occurred, we need to handle the error
                // See: https://developers.facebook.com/docs/ios/errors
            }
        }];
        return NO; //Show login flow.
    }
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
//                           NSLog(@"%@", statuses);
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
+(void)addTumblrToFeed:(DataClass *)singleton_universal{
    
    NSMutableDictionary *test = [singleton_universal.universal_tumblr_feed objectForKey:@"tumblr_data"];
    
    [singleton_universal.universal_feed setObject:test forKey:@"tumblr_entry"];
    for(NSMutableDictionary *dat in [singleton_universal.universal_feed objectForKey:@"tumblr_entry"]){
        
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:dat];
        [temp setObject:@"tumblr" forKey:@"type"];
        [singleton_universal.universal_feed_array addObject:temp];
    }
    
    //NSLog(@"%d", [[singleton_universal.universal_feed objectForKey:@"facebook_entry"] count]);
    [singleton_universal.mainTableView reloadData];
}

+(TwitterCell *)createTwitterCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath singleton:(NSMutableArray *)singleton_universal{
    
    // Similar to UITableViewCell, but
    TwitterCell *cell = [[TwitterCell alloc] init];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // Just want to test, so I hardcode the data
    
    int path = indexPath.row;
    
    //    NSDictionary *temp_twitter = [singleton_universal.universal_feed_array objectAtIndex:path];
     NSDictionary *temp_twitter = [singleton_universal objectAtIndex:path];
    
   // NSLog(@"%@", [temp_twitter objectAtIndex:path]);
    
    //NSLog(@"%@", [[[temp_instagram[(int)indexPath.row]objectForKey:@"caption"]objectForKey:@"from"]objectForKey:@"username"]);
    NSString *text = [temp_twitter objectForKey:@"text"];
    NSMutableAttributedString *temp = [[NSMutableAttributedString alloc] initWithString:text];
    cell.tweet.attributedText = [self returnTwitterAttributedText:temp];
    
    
    cell.tweet.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f];
   // NSString *user_id = [[temp_twitter[path]objectForKey:@"user"]objectForKey:@"id"];
    NSString *profile_picture = [[temp_twitter objectForKey:@"user"]objectForKey:@"profile_image_url_https"];
    profile_picture = [profile_picture stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"];
    cell.profile_picture_image_view.imageURL =[NSURL URLWithString:profile_picture];
//    [cell.profile_picture_image_view setImageWithURL:[NSURL URLWithString:profile_picture]
//                                    placeholderImage:[UIImage imageNamed:@"insta_placeholder.png"]];
    NSString *full_name = [[temp_twitter objectForKey:@"user"]objectForKey:@"name"];
    NSString *username = [[temp_twitter objectForKey:@"user"]objectForKey:@"screen_name"];
    NSString *created_at = [temp_twitter objectForKey:@"created_at"];
    NSString *twit_id_temp = [temp_twitter objectForKey:@"id"];
    NSString *twit_id = [NSString stringWithFormat:@"%@", twit_id_temp];
    
    
//    NSString *media_url = [[[temp_twitter objectForKey:@"entities"] objectForKey:@"media"]objectForKey:@"media_url"];
    
//    NSLog(@"media_url = ", media_url);
    
    cell.twitter_media_id = twit_id;
    cell.original_twitter_media_id = cell.twitter_media_id;
    
    NSString *favorite_count = [temp_twitter objectForKey:@"favorite_count"];
    NSString *is_favorite = [temp_twitter objectForKey:@"favorited"];
    NSString *is_favorited = [NSString stringWithFormat:@"%@", is_favorite];
    cell.favorited = is_favorited;
    if([cell.favorited isEqualToString:@"0"]){
        cell.fav_image.image = [UIImage imageNamed:@"fav.png"];
    }else{
        cell.fav_image.image = [UIImage imageNamed:@"yellow_fav.png"];
    }
    
    NSString *is_retweet = [temp_twitter objectForKey:@"retweeted"];
    NSString *is_retweeted = [NSString stringWithFormat:@"%@", is_retweet];
    cell.retweeted = is_retweeted;
    if([cell.retweeted isEqualToString:@"0"]){
        cell.retweet_image.image = [UIImage imageNamed:@"reweet.png"];
    }else{
        cell.retweet_image.image = [UIImage imageNamed:@"green_reweet.png"];
    }
    
    NSString *temp_favs = [NSString stringWithFormat:@"%@", favorite_count];
    if(![temp_favs isEqualToString:@"0"]){
        cell.favorites.text = temp_favs;
    }else{
        
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
    int addedPhoto = 0;
    if([[temp_twitter objectForKey:@"entities"] objectForKey:@"media"] != nil) {
        addedPhoto = 120;
        NSArray *media_url_array = [[[temp_twitter objectForKey:@"entities"] objectForKey:@"media"] valueForKey:@"media_url"];
        NSString *media_url = [media_url_array objectAtIndex:0];
        //        NSLog(@"%@",media_url);
        cell.optionalImage.imageURL = [NSURL URLWithString:media_url];
        
        cell.optionalImage.frame = CGRectMake(cell.tweet.frame.origin.x, cell.tweet.frame.origin.y+addedHeight, 240, 120);
        
        [cell.optionalImage setContentMode:UIViewContentModeScaleAspectFill];
        [cell.optionalImage setClipsToBounds:YES];
        cell.optionalImage.layer.cornerRadius = 5;
    }
   // NSLog(@"%@ - %f", username, numberOfLines);
    cell.time_label.text = created_time;
    //NSString  *created_time = [temp_twitter[(int)indexPath.row]valueForKey:@"created_time"];
    CGRect footer_frame = cell.interact_footer.frame;
    
    footer_frame.origin.y = cell.tweet.frame.origin.y+addedHeight+addedPhoto;
    
    cell.interact_footer.frame = footer_frame;
    
    UITapGestureRecognizer *favTap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(twitFavTap:)];
    favTap.numberOfTapsRequired = 1;
    cell.fav_image.userInteractionEnabled = YES;
    [cell.fav_image addGestureRecognizer:favTap];
    
    
    UITapGestureRecognizer *retweet_sheet = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(loadRetweetSheet:)];
    cell.retweet_image.userInteractionEnabled = YES;
    [cell.retweet_image addGestureRecognizer:retweet_sheet];
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
    [gr setNumberOfTapsRequired:1];
    [cell.tweet addGestureRecognizer:gr];
    
    UITapGestureRecognizer *twitterCompose = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(loadTwitterCompose:)];
    cell.reply_image.userInteractionEnabled = YES;
    [cell.reply_image addGestureRecognizer:twitterCompose];
    
    UITapGestureRecognizer *prof_pic_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profile_from_twitter_tap:)];
    cell.profile_picture_image_view.userInteractionEnabled = YES;
    
    [cell.profile_picture_image_view addGestureRecognizer:prof_pic_tap];
    
    UITapGestureRecognizer *prof_user_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profile_from_user_twitter_tap:)];
    cell.username.userInteractionEnabled = YES;
    [cell.username setScrollEnabled:NO];
    [cell.username addGestureRecognizer:prof_user_tap];

    return cell;
}


+(void)twitFavTap:(UITapGestureRecognizer *)sender{
    TwitterCell *test =[[[((TwitterCell *) sender.view) superview] superview] superview];
    NSString *temp_media = test.twitter_media_id;
    
    
    if([test.favorited isEqualToString:@"0"]){
        test.fav_image.image = [UIImage imageNamed:@"yellow_fav.png"];
        [UIView beginAnimations:@"Zoom" context:NULL];
        [UIView setAnimationDuration:0.2];
        test.fav_image.frame = CGRectMake(test.retweet_image.frame.origin.x+45, -15, 60, 60);
        [UIView commitAnimations];
        
        [UIView beginAnimations:@"Zoom" context:NULL];
        [UIView setAnimationDuration:0.8];
        test.fav_image.frame = CGRectMake(test.retweet_image.frame.origin.x+60, 0.0f, 30, 30);
        [UIView commitAnimations];
        NSString *currFav = test.favorites.text;
        int cur_int = [currFav intValue];
        cur_int += 1;
        test.favorites.text = [NSString stringWithFormat:@"%d", cur_int];
        test.favorited = @"1";
        
        [self favoriteTweet:temp_media];
    }else{
        test.fav_image.image = [UIImage imageNamed:@"fav.png"];
       [self deleteFavoriteTweet:temp_media];
        NSString *currFav = test.favorites.text;
        int cur_int = [currFav intValue];
        cur_int -= 1;
        test.favorites.text = [NSString stringWithFormat:@"%d", cur_int];
        test.favorited = @"0";
    }
}
+(NSString *)sendRetweet:(NSString *)media_id the_cell:(TwitterCell *)the_cell{
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
    
    [twitter postStatusRetweetWithID:media_id
        successBlock:^(NSDictionary *status) {
            //NSLog(@"%@", status);
            NSMutableDictionary *temp_status = [[NSMutableDictionary alloc] initWithDictionary: status];
            [temp_status setValue:@"twitter" forKey:@"type"];
            
            DataClass *singleton_universal = [DataClass getInstance];
            
            //NSDictionary *temp_twitter = [singleton_universal.universal_feed_array objectAtIndex:1];
            for(int i = 0; i < [singleton_universal.universal_feed_array count]; i++){
                NSDictionary *temp_twitter = [singleton_universal.universal_feed_array objectAtIndex:i];
                NSString *twit_id_temp = [temp_twitter objectForKey:@"id"];
                NSString *twit_id = [NSString stringWithFormat:@"%@", twit_id_temp];
                if([twit_id isEqualToString:media_id]){
                    NSMutableDictionary *updated_retweets = [singleton_universal.universal_feed_array objectAtIndex:i];
                    [updated_retweets setObject:@"true" forKey:@"retweeted"];
                    
                    NSString *twit_id_temp = [temp_status objectForKey:@"id"];
                    NSString *twittemp_id = [NSString stringWithFormat:@"%@", twit_id_temp];
                    [updated_retweets setObject:twittemp_id forKey:@"id"];
                    [updated_retweets setValue:@"retweed" forKey:@"retweeted-id"];
                    
                    [singleton_universal.universal_feed_array replaceObjectAtIndex:i withObject:updated_retweets];
                    
                    
                    TwitterCell *temp_cell = the_cell;
                    temp_cell.retweeted = @"1";
                    temp_cell.retweet_image.image = [UIImage imageNamed:@"green_reweet.png"];
                    NSString *currRet = temp_cell.retweets.text;
                    int cur_int = [currRet intValue];
                    cur_int += 1;
                    temp_cell.retweets.text = [NSString stringWithFormat:@"%d", cur_int];
                    temp_cell.twitter_media_id = twittemp_id;

                }
            }
            

    } errorBlock:^(NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    DataClass *singleton_universal = [DataClass getInstance];
    
    //NSDictionary *temp_twitter = [singleton_universal.universal_feed_array objectAtIndex:1];
    for(int i = 0; i < [singleton_universal.universal_feed_array count]; i++){
        NSDictionary *temp_twitter = [singleton_universal.universal_feed_array objectAtIndex:i];
        NSString *twit_id_temp = [temp_twitter valueForKey:@"retweeted-id"];
        NSString *twit_id = [NSString stringWithFormat:@"%@", twit_id_temp];
        if([twit_id isEqualToString:@"retweed"]){
            NSLog(@"ret %@", twit_id);
            NSString *twit_id_temps = [temp_twitter valueForKey:@"id"];
            NSString *twit_id_final = [NSString stringWithFormat:@"%@", twit_id_temps];
            
            return twit_id_final;
        }
    }
    
    return @"none";
}
+(NSString *)sendUndoRetweet:(NSString *)media_id the_cell:(TwitterCell *)the_cell{
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
    

    [twitter postStatusesDestroy:media_id trimUser:[NSNumber numberWithInt:0]
                        successBlock:^(NSDictionary *status) {
                            //NSLog(@"%@", status);
                            //NSLog(@"%@", status);
                          NSMutableDictionary *temp_status = [[NSMutableDictionary alloc] initWithDictionary: status];
                            [temp_status setValue:@"twitter" forKey:@"type"];
                            
                            DataClass *singleton_universal = [DataClass getInstance];
                            
                            //NSDictionary *temp_twitter = [singleton_universal.universal_feed_array objectAtIndex:1];
                            for(int i = 0; i < [singleton_universal.universal_feed_array count]; i++){
                                NSDictionary *temp_twitter = [singleton_universal.universal_feed_array objectAtIndex:i];
                                NSString *twit_id_temp = [temp_twitter objectForKey:@"id"];
                                NSString *twit_id = [NSString stringWithFormat:@"%@", twit_id_temp];
                                if([twit_id isEqualToString:media_id]){
                                    NSMutableDictionary *updated_retweets = [singleton_universal.universal_feed_array objectAtIndex:i];
                                    [updated_retweets setObject:@"0" forKey:@"retweeted"];
                                    
                                    TwitterCell *temp_cell = the_cell;
                                    
                                    NSString *twit_id_temp = [temp_status objectForKey:@"id"];
                                    NSString *twittemp_id = [NSString stringWithFormat:@"%@", twit_id_temp];
                                    [updated_retweets setObject:temp_cell.original_twitter_media_id forKey:@"id"];
                                    [updated_retweets setValue:@"not" forKey:@"retweeted-id"];
                                    
                                    [singleton_universal.universal_feed_array replaceObjectAtIndex:i withObject:updated_retweets];
                                    
                                    temp_cell.retweeted = @"0";
                                    temp_cell.retweet_image.image = [UIImage imageNamed:@"reweet.png"];
                                    NSString *currRet = temp_cell.retweets.text;
                                    int cur_int = [currRet intValue];
                                    cur_int -= 1;
                                    temp_cell.retweets.text = [NSString stringWithFormat:@"%d", cur_int];
                                    temp_cell.twitter_media_id = temp_cell.original_twitter_media_id;

                                }
                            }
                        } errorBlock:^(NSError *error) {
                            NSLog(@"%@",[error localizedDescription]);
                        }];
    return @"none";
}
+(void)favoriteTweet:(NSString *)media{
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
    
    [twitter postFavoriteCreateWithStatusID:media includeEntities:nil successBlock:^(NSDictionary *status) {
        //NSLog(@"%@", status);
        NSMutableDictionary *temp_status = [[NSMutableDictionary alloc] initWithDictionary: status];
        [temp_status setValue:@"twitter" forKey:@"type"];
        
        DataClass *singleton_universal = [DataClass getInstance];
        
        //NSDictionary *temp_twitter = [singleton_universal.universal_feed_array objectAtIndex:1];
        for(int i = 0; i < [singleton_universal.universal_feed_array count]; i++){
            NSDictionary *temp_twitter = [singleton_universal.universal_feed_array objectAtIndex:i];
            NSString *twit_id_temp = [temp_twitter objectForKey:@"id"];
            NSString *twit_id = [NSString stringWithFormat:@"%@", twit_id_temp];
            if([twit_id isEqualToString:media]){
                [singleton_universal.universal_feed_array replaceObjectAtIndex:i withObject:temp_status];

            }
        }
    } errorBlock:^(NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
}
+(void)deleteFavoriteTweet:(NSString *)media{
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
    
    [twitter postFavoriteDestroyWithStatusID:media includeEntities:nil successBlock:^(NSDictionary *status) {
        NSMutableDictionary *temp_status = [[NSMutableDictionary alloc] initWithDictionary: status];
        [temp_status setValue:@"twitter" forKey:@"type"];
        
        DataClass *singleton_universal = [DataClass getInstance];
        
        //NSDictionary *temp_twitter = [singleton_universal.universal_feed_array objectAtIndex:1];
        for(int i = 0; i < [singleton_universal.universal_feed_array count]; i++){
            NSDictionary *temp_twitter = [singleton_universal.universal_feed_array objectAtIndex:i];
            NSString *twit_id_temp = [temp_twitter objectForKey:@"id"];
            NSString *twit_id = [NSString stringWithFormat:@"%@", twit_id_temp];
            if([twit_id isEqualToString:media]){
                [singleton_universal.universal_feed_array replaceObjectAtIndex:i withObject:temp_status];
                
            }
        }
    } errorBlock:^(NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    
}
+(TumblrCell *)createTumblrCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath singleton:(NSMutableArray *)singleton_universal{
    
    // Similar to UITableViewCell, but
    TumblrCell *cell = [[TumblrCell alloc] init];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // Just want to test, so I hardcode the data
    
    int path = indexPath.row;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
//    NSDictionary *temp_tumblr = [singleton_universal.universal_feed_array objectAtIndex:path];
    NSDictionary *temp_tumblr = [singleton_universal objectAtIndex:path];
    
    NSString *username = [temp_tumblr objectForKey:@"blog_name"];
    NSString *caption = [temp_tumblr objectForKey:@"caption"];
    NSDictionary *photos = [temp_tumblr objectForKey:@"photos"];
    NSArray *tags = [temp_tumblr objectForKey:@"tags"];
    NSString *note_count = [[temp_tumblr objectForKey:@"note_count"] stringValue];
    //NSDate *date = [temp_tumblr objectForKey:@"date"];
    
    NSArray *reblog_key = [temp_tumblr objectForKey:@"reblog_key"];
    NSString *tumblr_id = [[temp_tumblr objectForKey:@"id"] stringValue];
    
    cell.reblog_key = reblog_key;
    cell.unique_id = tumblr_id;
    
    cell.username.text = username;
    note_count = [note_count stringByAppendingString:@" notes"];
    cell.notes_label.text = note_count;
    UIScrollView *tag_scroll_view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 20)];
    int content_width = 0;
    int last_width = 10;
    int final_width = 0;
    
    for(int i = 0; i < [tags count]; i ++){
        UILabel *temp_tag = [[UILabel alloc] initWithFrame:CGRectMake(last_width, 0, 0, 20)];
        [temp_tag setTextColor:[UIColor lightGrayColor]];
        temp_tag.font =[UIFont fontWithName:@"Helvetica-Light" size:14.0f];
        NSString *hashtag = [@"#" stringByAppendingString:[tags objectAtIndex:i]];
        temp_tag.text = hashtag;
        
        CGSize stringSize = [temp_tag.text sizeWithFont:[UIFont fontWithName:@"Helvetica-Light" size:14.0f]];
        CGFloat width = stringSize.width;
        CGRect new_frame = temp_tag.frame;
        new_frame.size.width = width;
        temp_tag.frame = new_frame;
        [tag_scroll_view addSubview:temp_tag];
//        temp_tag.contentMode = UIViewContentModeScaleAspectFit;
        last_width += width+10;
    }
    
    NSString *base  =@"http://api.tumblr.com/v2/blog/";
    base = [base stringByAppendingString:username];
    base = [base stringByAppendingString:@".tumblr.com/avatar/96"];
    base = [base stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    
    cell.profile_image_view.imageURL =[NSURL URLWithString:base];
//    [cell.profile_image_view setImageWithURL:[NSURL URLWithString:base]
//                                    placeholderImage:[UIImage imageNamed:@"insta_placeholder.png"]];
    
    
    NSMutableArray *sources_for_widths_array = [[NSMutableArray alloc] init];
    NSMutableArray *sources_for_heights_array = [[NSMutableArray alloc] init];
    for(NSDictionary *photo in photos){
        NSMutableDictionary *sources_for_widths = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *sources_for_heights = [[NSMutableDictionary alloc] init];
        NSArray *widths = [photo objectForKey:@"alt_sizes"];
        //if([widths objectForKey:@"width"] == @"500"){
        for (int i = 0; i < [widths count]; i++){
            NSDictionary *breaks = [widths objectAtIndex:i];
            NSString *actual_width_string = [[breaks objectForKey:@"width"] stringValue];
            long actual_width = [actual_width_string longLongValue];
            
            NSString *actual_height_string = [breaks objectForKey:@"height"];
            long actual_height = [actual_height_string longLongValue];
            
            [sources_for_widths setObject:[breaks objectForKey:@"url"] forKey:actual_width_string];
            [sources_for_heights setObject:[breaks objectForKey:@"height"] forKey:actual_width_string];
            
            
        }
        [sources_for_widths_array addObject:sources_for_widths];
        [sources_for_heights_array addObject:sources_for_heights];
        
    }
   
    NSMutableArray *photo_views_array = [[NSMutableArray alloc] initWithCapacity:[photos count]];
    int end_of_photo_content = 0;
    for(int i = 0; i < [photos count]; i++){
        
        
        NSArray *keys=[[sources_for_widths_array objectAtIndex:i] allKeys];
        int intended = 500;
        int closest = 1000;
        NSString *close_string;
        for(NSString *widths in keys){
            int value = [widths intValue];
            int difference = value - intended;
            difference = abs(difference);
            
            if(difference < closest){
                close_string = widths;
            }

        }
        
        NSString *height =[[sources_for_heights_array objectAtIndex:i] objectForKey:close_string];
        double height_int = [height doubleValue];
        double width_int = [close_string doubleValue];
        double ratio = height_int/width_int;
        
        UIImageView *content_image_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60+end_of_photo_content+(10*i), screenWidth, screenWidth*ratio)];
//        NSLog(@"we %f", 60+((screenWidth*ratio)*i)+(10*i));
//        NSLog(@"screenwidth *ratio %f", screenWidth*ratio);
//        NSLog(@"ratio %f", ratio);
        NSString *source_url =[[sources_for_widths_array objectAtIndex:i] objectForKey:close_string];
        
//        [content_image_view setImageWithURL:[NSURL URLWithString:source_url] placeholderImage:@"insta_placeholder.png"];
        content_image_view.imageURL = [NSURL URLWithString:source_url];
        
        [photo_views_array addObject:content_image_view];
        end_of_photo_content += content_image_view.frame.size.height;
        
    }
    end_of_photo_content += 60;
    [cell.contentView setFrame:CGRectMake(cell.contentView.frame.origin.x, cell.contentView.frame.origin.y, cell.contentView.frame.size.width, end_of_photo_content)];
    for(UIImageView *content_image_views in photo_views_array){
        CGRect frame = content_image_views.frame;
        [cell.contentView addSubview:content_image_views];
    }
    NSString *myHTML = caption;
    UIFont *font = [UIFont fontWithName:@"Helvetica-Light" size:14];
    NSString *htmlString = [NSString stringWithFormat:@"<html><body><div id='main'><style>  a:link { color:#000; text-decoration:underline; } img{width:300px; }</style> <span style=\"font-family: %@; font-size: %i;\">%@</span>",
                  font.fontName,
                  (int) font.pointSize,
                  caption];
    htmlString = [htmlString stringByAppendingString:@"</div></body></html>"];
    
//    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"string" withString:@"duck"];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 100)];
    webView.userInteractionEnabled = YES;
    webView.scrollView.scrollEnabled = YES;
    webView.delegate = self;
//    [webView loadHTMLString:htmlString baseURL:nil];
    //load file into webView
    [webView loadHTMLString:htmlString baseURL:nil];
    
    NSString *innerText = [self stringByStrippingHTML:htmlString];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName];
    NSAttributedString *attributed_string = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding]
                                                                             options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                       NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                                  documentAttributes:nil error:nil];
    
    //NSLog(@"%@", htmlString);
    
    int height = [self returnTumblrMessageHeight:indexPath textString:attributed_string];
    webView.frame = CGRectMake(0, 0, screenWidth, height);
    
//    webView.clipsToBounds = YES;
    
    CGRect new_frame = cell.textView.frame;
    new_frame.origin.y = end_of_photo_content;
    new_frame.size.height = height;
    //new_frame.size.height = webView.scrollView.contentSize.height;
    cell.textView.frame = new_frame;
    //webView.userInteractionEnabled = YES;
    [cell.textView addSubview:webView];
    
//    CGFloat hForT = [self tableView:tableView heightForTumblr:indexPath singleton:singleton_universal];
    
    new_frame = cell.interactView.frame;
//    new_frame.origin.y = hForT-50;
    new_frame.origin.y = cell.contentView.frame.origin.y +cell.contentView.frame.size.height;
    //NSLog(@"cell height %f", cell.frame.size.height);
    new_frame.size.height = 30;
    cell.interactView.frame = new_frame;
    
    tag_scroll_view.contentSize = CGSizeMake(last_width,20);
    tag_scroll_view.userInteractionEnabled = YES;
    [tag_scroll_view setShowsVerticalScrollIndicator:NO];
    [tag_scroll_view setShowsHorizontalScrollIndicator:NO];
    tag_scroll_view.scrollEnabled = YES;
    tag_scroll_view.canCancelContentTouches = YES;
    tag_scroll_view.delegate = self;
    
    new_frame = cell.tagView.frame;
    //    new_frame.origin.y = hForT-70;
    new_frame.origin.y = cell.contentView.frame.origin.y + cell.contentView.frame.size.height-20;
    //new_frame.origin.y = 0;
    cell.tagView.frame = new_frame;
    
    //[cell.contentView addSubview:scrollView];
    //[cell.tagView setContentSize:CGSizeMake(1000, 20)];
    [cell.tagView setShowsHorizontalScrollIndicator:NO];
    [cell.tagView setShowsVerticalScrollIndicator:NO];
    [cell.tagView setUserInteractionEnabled:YES];
    [cell.tagView setBackgroundColor:[UIColor whiteColor]];
    [cell.tagView addSubview:tag_scroll_view];
   // [cell.contentView addSubview:cell.tagView];
    
    
    new_frame = cell.interactView.frame;
    new_frame.origin.y += height;
    cell.interactView.frame = new_frame;
    
    new_frame = cell.interactView.frame;
    new_frame.origin.y -= 30;
    cell.tagView.frame = new_frame;
    
    
    
    UITapGestureRecognizer *tumblrReblog = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(loadTumblrCompose:)];
    cell.reblog_view.userInteractionEnabled = YES;
    [cell.reblog_view addGestureRecognizer:tumblrReblog];
    
    UITapGestureRecognizer *tumblrShare = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(shareTumblr:)];
    cell.share_view.userInteractionEnabled = YES;
    [cell.share_view addGestureRecognizer:tumblrShare];

    
    return cell;
}
+(void)loadTumblrCompose:(UITapGestureRecognizer *)responder{
    
    DataClass *singleton_universal = [DataClass getInstance];
    
    [singleton_universal.mainNavController setNavigationBarHidden:YES animated:YES];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    TumblrCell *test =[[[((TumblrCell *) responder.view) superview] superview] superview];
    
    TumblrComposeViewController *compose = [[TumblrComposeViewController alloc] initFromPost:test.unique_id reblogKey:test.reblog_key];
    compose.view.frame = CGRectMake(0, screenHeight, screenWidth, screenHeight);
    //TumblrComposeViewController *compose = [[TumblrComposeViewController alloc] init];
    compose.view.alpha = 0.95;
    [singleton_universal.mainViewController addChildViewController:compose];
    
    [singleton_universal.mainViewController.view addSubview:compose.view];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         CGRect old_frame = compose.view.frame;
                         old_frame.origin.y = 0;
                         compose.view.frame = old_frame;
                     }
                     completion:^(BOOL finished){
                         //                         NSLog(@"Done!");
                     }];
    
    // [self.navigationController presentViewController:compose animated:YES completion:^{
    
    // }];
    
}

+(void)loadRetweetSheet:(UITapGestureRecognizer *)responder{
    TwitterCell *test =[[[((TwitterCell *) responder.view) superview] superview]superview];
    DataClass *singleton_universal = [DataClass getInstance];
    [UIView beginAnimations:@"Zoom" context:NULL];
    [UIView setAnimationDuration:0.2];
    test.retweet_image.frame = CGRectMake(test.reply_image.frame.origin.x+45, -5, 40, 40);
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"Zoom" context:NULL];
    [UIView setAnimationDuration:0.8];
    test.retweet_image.frame = CGRectMake(test.reply_image.frame.origin.x+60, 6.0f, 20, 20);
    [UIView commitAnimations];
    
    NSString *media = test.twitter_media_id;
    NSString *destruct = @"Retweet";
    NSString *other1 = @"Quote Tweet";
    if(![test.retweeted isEqualToString:@"0"]){
        other1 = nil;
        destruct = @"Undo Retweet";
    }
    // NSString *actionSheetTitle = @"Action Sheet Demo"; //Action Sheet Title
    // NSString *destructiveTitle = @"Destructive Button"; //Action Sheet Button Titles
    
    NSString *cancelTitle = @"Cancel";
    
    RetweetActionSheet *actionSheet = [[RetweetActionSheet alloc]
                                       initWithTitle:@""
                                       med_id:media
                                       cell:test
                                       delegate:self
                                       cancelButtonTitle:cancelTitle
                                       destructiveButtonTitle:destruct
                                       otherButtonTitles:other1, nil];
    
    [actionSheet showInView:singleton_universal.mainViewController.view];
    test.retweeted = @"0";
    
}
+(void)loadUnRetweetSheet:(UITapGestureRecognizer *)responder{
    TwitterCell *test =[[[[((TwitterCell *) responder.view) superview] superview] superview] superview];
    DataClass *singleton_universal = [DataClass getInstance];
    NSString *media = test.twitter_media_id;
    NSString *destruct = @"Undo Retweet";
    // NSString *other1 = @"Quote Tweet";
    
    // NSString *actionSheetTitle = @"Action Sheet Demo"; //Action Sheet Title
    // NSString *destructiveTitle = @"Destructive Button"; //Action Sheet Button Titles
    NSString *other1 = @"Undo Retweet";
    NSString *cancelTitle = @"Cancel";
    
    RetweetActionSheet *actionSheet = [[RetweetActionSheet alloc]
                                       initWithTitle:@""
                                       med_id:media
                                       cell:test
                                       delegate:self
                                       cancelButtonTitle:cancelTitle
                                       destructiveButtonTitle:destruct
                                       otherButtonTitles: nil];
    
    [actionSheet showInView:singleton_universal.mainViewController.view];
    test.retweeted = @"0";
    
}
+ (void)actionSheet:(RetweetActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Work ons ubclassing
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:@"Retweet"]) {
        NSLog(actionSheet.actual_media_id);
        NSString *new_id = [CreationFunctions sendRetweet:actionSheet.actual_media_id the_cell:actionSheet.twit_temp_cell];
    }
    if  ([buttonTitle isEqualToString:@"Undo Retweet"]) {
        NSLog(actionSheet.actual_media_id);
        NSString *new_id = [CreationFunctions sendUndoRetweet:actionSheet.actual_media_id the_cell:actionSheet.twit_temp_cell];
    }
    if ([buttonTitle isEqualToString:@"Quote Tweet"]) {
        NSLog(@"Quote Tweet Pressed");
    }
    if ([buttonTitle isEqualToString:@"Cancel Button"]) {
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
    }
}
+(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *output = [webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
//    NSLog(@"height: %@", output);
    
    TumblrCell *test =[[[((TumblrCell *) webView) superview] superview] superview];
    CGRect frame = webView.frame;
    
    frame.size.height = [output floatValue];
    webView.frame = frame;
//    [webView setBackgroundColor:[UIColor blackColor]];
    
//    [self setTumblrLayout:output withCell:test];
    
}
+(void)setTumblrLayout:(NSString *)height withCell:(TumblrCell *)cell{
    NSLog(height);
    if([height floatValue] == 100){
        height = @"0";
    }
    CGRect new_frame = cell.interactView.frame;
    new_frame.origin.y += [height floatValue] - 35;
    cell.interactView.frame = new_frame;
    
    new_frame = cell.interactView.frame;
    new_frame.origin.y -= 30;
    cell.tagView.frame = new_frame;
    
    
    
}
+(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    NSLog(@"Error for WEBVIEW: %@", [error description]);
}
+(NSString *)stringByStrippingHTML:(NSString*)str{
        NSRange r;
        while ((r = [str rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound){
            str = [str stringByReplacingCharactersInRange:r withString:@""];
        }
        return str;
}
+(FacebookCell *)createFacebookCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath singleton:(NSMutableArray *)singleton_universal{
    
    // Similar to UITableViewCell, but
    FacebookCell *cell = [[FacebookCell alloc] init];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // Just want to test, so I hardcode the data
    int path = indexPath.row;
    
    NSDictionary *temp_facebook = [singleton_universal objectAtIndex:path];
    
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
    
    cell.main_picture.imageURL = [NSURL URLWithString:full_picture];
//    [cell.main_picture setImageWithURL:[NSURL URLWithString:full_picture]
//                                    placeholderImage:[UIImage imageNamed:@""]];
    
    cell.profile_picture_image_view.imageURL =[NSURL URLWithString:base];
//    [cell.profile_picture_image_view setImageWithURL:[NSURL URLWithString:base]
//                                    placeholderImage:[UIImage imageNamed:@"insta_placeholder.png"]];
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
+(CGFloat)tableView:(UITableView *)tableView heightForTwitter:(NSIndexPath *)indexPath singleton:(NSMutableArray *)singleton_universal{
    int addedHeight;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    int path = indexPath.row;
    
    NSDictionary *temp_twitter = [singleton_universal objectAtIndex:path];
    
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
    int addedPhoto = 0;
    if([[temp_twitter objectForKey:@"entities"] objectForKey:@"media"] != nil) {
        addedPhoto = 120;
    }
    
    return 30+addedHeight+20 + addedPhoto;
    
}
+(CGFloat)tableView:(UITableView *)tableView heightForTumblr:(NSIndexPath *)indexPath singleton:(NSMutableArray *)singleton_universal{
    int path = indexPath.row;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    NSDictionary *temp_tumblr = [singleton_universal objectAtIndex:path];
    
    NSString *username = [temp_tumblr objectForKey:@"blog_name"];
    NSString *caption = [temp_tumblr objectForKey:@"caption"];
    NSDictionary *photos = [temp_tumblr objectForKey:@"photos"];
    
    
    NSMutableArray *sources_for_widths_array = [[NSMutableArray alloc] init];
    NSMutableArray *sources_for_heights_array = [[NSMutableArray alloc] init];
    for(NSDictionary *photo in photos){
        NSMutableDictionary *sources_for_widths = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *sources_for_heights = [[NSMutableDictionary alloc] init];
        NSArray *widths = [photo objectForKey:@"alt_sizes"];
        //if([widths objectForKey:@"width"] == @"500"){
        for (int i = 0; i < [widths count]; i++){
            NSDictionary *breaks = [widths objectAtIndex:i];
            NSString *actual_width_string = [[breaks objectForKey:@"width"] stringValue];
            long actual_width = [actual_width_string longLongValue];
            
            NSString *actual_height_string = [breaks objectForKey:@"height"];
            long actual_height = [actual_height_string longLongValue];
            
            [sources_for_widths setObject:[breaks objectForKey:@"url"] forKey:actual_width_string];
            [sources_for_heights setObject:[breaks objectForKey:@"height"] forKey:actual_width_string];
            
            
        }
        [sources_for_widths_array addObject:sources_for_widths];
        [sources_for_heights_array addObject:sources_for_heights];
        
    }
    
    NSMutableArray *photo_views_array = [[NSMutableArray alloc] initWithCapacity:[photos count]];
    double photo_content_height = 0;
    for(int i = 0; i < [photos count]; i++){
        
        
        NSArray *keys=[[sources_for_widths_array objectAtIndex:i] allKeys];
        int intended = 1000;
        int closest = 1000;
        NSString *close_string;
        for(NSString *widths in keys){
            int value = [widths intValue];
            int difference = value - intended;
            difference = abs(difference);
            
            if(difference < closest){
                close_string = widths;
            }
            
        }
        
        NSString *height =[[sources_for_heights_array objectAtIndex:i] objectForKey:close_string];
        double height_int = [height doubleValue];
        double width_int = [close_string doubleValue];
        double ratio = height_int/width_int;
        photo_content_height = photo_content_height + screenWidth*ratio;
    }
    //photo_content_height += 60;
    
    NSString *myHTML = caption;
    UIFont *font = [UIFont fontWithName:@"Helvetica-Light" size:14];
    NSString *htmlString = [NSString stringWithFormat:@"<body><style>  a:link { color:#000; text-decoration:underline; } img{width:300px;}</style> <span style=\"font-family: %@; font-size: %i;\">%@</span>",
                            font.fontName,
                            (int) font.pointSize,
                            caption];
    htmlString = [htmlString stringByAppendingString:@"</body>"];
    
    NSAttributedString *attributed_string = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding]
                                                                             options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                       NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding), NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Light" size:14.0f]}
                                                                  documentAttributes:nil error:nil];
    
    int height = [self returnTumblrMessageHeight:indexPath textString:attributed_string];
//    int height = 0;
    
    return 60+ photo_content_height + 10*[photos count] + height+20 +45+10;
    
}
+(CGFloat)tableView:(UITableView *)tableView heightForFacebook:(NSIndexPath *)indexPath singleton:(NSMutableArray *)singleton_universal{
    int addedHeight;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    int path = indexPath.row;
    
    NSDictionary *temp_facebook = [singleton_universal objectAtIndex:path];
    
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
        [text addAttribute:@"hashtag" value:@"1" range:subStringRange];
    }];
    [regexAt enumerateMatchesInString:converted options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange subStringRange = [result rangeAtIndex:0];
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0] range:subStringRange];
    }];
    [regexhttp enumerateMatchesInString:converted options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange subStringRange = [result rangeAtIndex:0];
        [text addAttribute:NSLinkAttributeName value:[UIColor colorWithRed: 81/255.0 green: 127/255.0 blue:164/255.0 alpha: 1.0] range:subStringRange];

    }];
    
    [[text mutableString] replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSCaseInsensitiveSearch range:NSMakeRange(0, text.string.length)];
    
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
        }else if([type isEqualToString:@"tumblr"]){
            NSString *created_at = [dict objectForKey:@"date"];
            NSTimeInterval distanceBetweenDates = [self returnTumblrTimeInterval:created_at];
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
        }if([type isEqualToString:@"twitter"]){
            NSString *created_at = [dict objectForKey:@"created_at"];
            NSTimeInterval distanceBetweenDates = [self returnTwitterTimeInterval:created_at];
            
            if((NSInteger)interval < (NSInteger)distanceBetweenDates){
                //NSLog(@"Interval %@ > distance %@", interval, distanceBetweenDates);
                return index;
            }
        }else{
            NSString *created_at = [dict objectForKey:@"date"];
            NSTimeInterval distanceBetweenDates = [self returnTumblrTimeInterval:created_at];
            
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
+(void)profile_from_twitter_tap:(UITapGestureRecognizer *)recognizer{
    
    TwitterCell *test =[[((TwitterCell *) recognizer.view) superview] superview];
    NSString *name = test.username.text;
    DataClass *singleton_universal = [DataClass getInstance];
    NSRange range = [name rangeOfString:@" " options:NSBackwardsSearch];
    NSString *result = [name substringFromIndex:range.location+1];
    ProfileView *profile = [[ProfileView alloc] initWithProfile:result type:@"twitter"];
    [singleton_universal.mainNavController pushViewController:profile animated:YES];
    
}
+(void)loadTwitterCompose:(UITapGestureRecognizer *)responder{
    TwitterCell *test =[[[((TwitterCell *) responder.view) superview] superview] superview];
    
    DataClass *singleton_universal = [DataClass getInstance];
    
    [UIView beginAnimations:@"Zoom" context:NULL];
    [UIView setAnimationDuration:0.2];
    test.reply_image.frame = CGRectMake(55, -5, 37, 37);
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"Zoom" context:NULL];
    [UIView setAnimationDuration:0.8];
    test.reply_image.frame = CGRectMake(70, 6.0f, 17, 17);
    [UIView commitAnimations];
    
    TwitterComposeScreenViewController *compose = [[TwitterComposeScreenViewController alloc] init];
    [singleton_universal.mainNavController presentViewController:compose animated:YES completion:^{
        
    }];
    
}
+(void)shareTumblr:(UITapGestureRecognizer *)responder{
    NSArray *activityItems = nil;
    NSArray * applicationActivities = nil;
    NSArray * excludeActivities = @[ UIActivityTypeAddToReadingList, UIActivityTypeSaveToCameraRoll, UIActivityTypePrint, UIActivityTypeMessage];
    
    DataClass *singleton_universal = [DataClass getInstance];
    
    NSString *postText = [[NSString alloc] initWithFormat:@"Testing send sheet"];
    activityItems = @[postText];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [singleton_universal.mainNavController presentViewController:activityController animated:YES completion:nil];
}


+(void)profile_from_user_twitter_tap:(UITapGestureRecognizer *)recognizer{
    
    TwitterCell *test =[[((TwitterCell *) recognizer.view) superview] superview];
    NSString *name = test.username.text;
    DataClass *singleton_universal = [DataClass getInstance];
    NSRange range = [name rangeOfString:@" " options:NSBackwardsSearch];
    NSString *result = [name substringFromIndex:range.location+1];
    ProfileView *profile = [[ProfileView alloc] initWithProfile:result type:@"twitter"];
    [singleton_universal.mainNavController pushViewController:profile animated:YES];
    
}
+(void)loadCommentView:(UITapGestureRecognizer *)responder{
    InstagramCell *test =[[[((InstagramCell *) responder.view) superview] superview] superview];
    DataClass *singleton_universal = [DataClass getInstance];
    NSString *media = test.media_id;
    InstagramCommentViewController *commentView = [[InstagramCommentViewController alloc] initWithMedia:media];
    [singleton_universal.mainNavController pushViewController:commentView animated:YES];
    
}
+(void)loadCommentViewMiddle:(UITapGestureRecognizer *)responder{
    InstagramCell *test =[[((InstagramCell *) responder.view) superview] superview];
    DataClass *singleton_universal = [DataClass getInstance];
    NSString *media = test.media_id;
    InstagramCommentViewController *commentView = [[InstagramCommentViewController alloc] initWithMedia:media];
    [singleton_universal.mainNavController pushViewController:commentView animated:YES];
}
+ (void)textTapped:(UITapGestureRecognizer *)recognizer
{
    
//    TwitterCell *test =[((TwitterCell *) recognizer.view) superview];
    
    DataClass *singleton_universal = [DataClass getInstance];
    UITextView *textView = (UITextView *)recognizer.view;
    
    // Location of the tap in text-container coordinates
    
    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [recognizer locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    
    // Find the character that's been tapped on
    
    NSUInteger characterIndex;
    characterIndex = [layoutManager characterIndexForPoint:location
                                           inTextContainer:textView.textContainer
                  fractionOfDistanceBetweenInsertionPoints:NULL];
    
    if (characterIndex < textView.textStorage.length) {
        
        NSRange range;
        
        id value = [textView.attributedText attribute:@"NSLinkAttributeName" atIndex:characterIndex effectiveRange:&range];
        NSRange needleRange = NSMakeRange(range.location,
                                          range.length);
        NSString *needle = [textView.attributedText.string substringWithRange:needleRange];
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        
        if ( [needle rangeOfString:@"http://" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
            singleton_universal.urlWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight , screenWidth, screenHeight)];
            [singleton_universal.mainViewController.view addSubview:singleton_universal.urlWrapper];
            
            singleton_universal.closeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
            [singleton_universal.closeView setBackgroundColor:[UIColor whiteColor]];
            
            UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeURLView:)];
            [singleton_universal.closeView addGestureRecognizer:tgr];
            
            UILabel *closeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth-10, 40)];
            closeLabel.text = @"X";
            closeLabel.textAlignment = NSTextAlignmentRight;
            closeLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
            [singleton_universal.closeView addSubview:closeLabel];
            
            singleton_universal.t = [[UIWebView alloc] initWithFrame:CGRectMake(0, 40, screenWidth, screenHeight-0)];
            singleton_universal.t.delegate = singleton_universal.mainViewController;
            singleton_universal.t.scalesPageToFit=YES;
            singleton_universal.t.scrollView.delegate = singleton_universal.mainViewController;
            NSURL *url = [NSURL URLWithString:needle];
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            [singleton_universal.t loadRequest:request];
            [singleton_universal.urlWrapper addSubview:singleton_universal.t];
            [singleton_universal.urlWrapper addSubview:singleton_universal.closeView];
            
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options: UIViewAnimationCurveEaseOut
                             animations:^{
                                 CGRect new_frame = singleton_universal.urlWrapper.frame;
                                 new_frame.origin.y = 0;
                                 singleton_universal.urlWrapper.frame = new_frame;
                                 
                                 [singleton_universal.mainNavController setNavigationBarHidden:YES];
                             }
                             completion:^(BOOL finished){
                                 //                             NSLog(@"Done!");
                             }];
            
            
        }else{
            //            NSLog(@"not");
        }
        if ( [needle rangeOfString:@"#" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
            
            HashtagSearch *hashtag = [[HashtagSearch alloc] initWithSearch:needle];
            [singleton_universal.mainNavController pushViewController:hashtag animated:YES];
        }
        if ( [needle rangeOfString:@"@" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
            
            ProfileView *profile = [[ProfileView alloc] initWithProfile:needle type:@"twitter"];
            [singleton_universal.mainNavController pushViewController:profile animated:YES];
        }
        //
    }
}
+(void)closeURLView:(UITapGestureRecognizer *)sender{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    DataClass *singleton_universal = [DataClass getInstance];
    [singleton_universal.mainNavController setNavigationBarHidden:NO];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         CGRect new_frame = singleton_universal.urlWrapper.frame;
                         new_frame.origin.y = screenHeight;
                         singleton_universal.urlWrapper.frame = new_frame;
                         
                         [singleton_universal.mainNavController setNavigationBarHidden:YES];
                     }
                     completion:^(BOOL finished){
                         singleton_universal.t.delegate = nil;
                         singleton_universal.t = nil;
                         [singleton_universal.t removeFromSuperview];
                         [singleton_universal.urlWrapper removeFromSuperview];
                         
                         
                     }];
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
+(NSTimeInterval) returnTumblrTimeInterval:(NSString *)response{
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
