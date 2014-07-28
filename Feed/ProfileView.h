//
//  ProfileView.h
//  Feed
//
//  Created by George on 2014-06-18.
//  Copyright (c) 2014 George. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileView : UIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UITextViewDelegate, UIWebViewDelegate, UIScrollViewDelegate, UISearchBarDelegate>
-(id)initWithProfile:(NSString *)profile type:(NSString *)type;
-(id)initForInstagram:(NSString *)profile user_id:(NSString *)the_id type:(NSString *)type;
-(id)initForSelf:(NSString *)profile type:(NSString *)type;
-(id)initForSelf;
-(void)update;

- (void)refreshTable;
@property (nonatomic, strong) UITableView *main_tableView;
@end
