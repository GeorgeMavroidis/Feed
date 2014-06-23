//
//  HashtagSearch.h
//  Feed
//
//  Created by George on 2014-06-18.
//  Copyright (c) 2014 George. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HashtagSearch : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UITextViewDelegate, UIWebViewDelegate, UIScrollViewDelegate, UISearchBarDelegate>
-(id)initWithSearch:(NSString *)search;
@end
