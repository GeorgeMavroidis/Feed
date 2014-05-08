//
//  FeedConnectViewController.h
//  Feed
//
//  Created by George on 2/13/2014.
//  Copyright (c) 2014 George. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>

@interface FeedConnectViewController : UIViewController <FBLoginViewDelegate, GPPSignInDelegate, UIActionSheetDelegate>
@end