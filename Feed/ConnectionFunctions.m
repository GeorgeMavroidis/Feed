//
//  ConnectionFunctions.m
//  Feed
//
//  Created by George on 2014-08-01.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "ConnectionFunctions.h"
#include <unistd.h>
#include <netdb.h>

@implementation ConnectionFunctions
-(BOOL)isNetworkAvailable{
    char *hostname;
    struct hostent *hostinfo;
    hostname = "google.com";
    hostinfo = gethostbyname (hostname);
    if (hostinfo == NULL){
        NSLog(@"-> no connection!\n");
        
        return NO;
    }
    else{
        NSLog(@"-> connection established!\n");
        return YES;
    }
}
+(BOOL)checkInstagramConnectionMeta:(NSDictionary *)meta{
    BOOL connection = NO;
    NSString *code = [meta objectForKey:@"code"];
    if([code longLongValue] ==200)
        connection = YES;
    
    return connection;
}
@end
