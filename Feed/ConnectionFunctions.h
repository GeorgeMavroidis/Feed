//
//  ConnectionFunctions.h
//  Feed
//
//  Created by George on 2014-08-01.
//  Copyright (c) 2014 George. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionFunctions : NSObject
-(BOOL)isNetworkAvailable;
+(BOOL)checkInstagramConnectionMeta:(NSDictionary *)meta;
@end
