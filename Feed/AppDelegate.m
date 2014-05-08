//
//  AppDelegate.m
//  Feed
//
//  Created by George on 2/12/2014.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "AppDelegate.h"
#import "FeedLoginViewController.h"
#import "FacebookSDK.framework/Headers/FacebookSDK.h"
#import "FeedConnectViewController.h"
#import "Parse.framework/Headers/Parse.h"
#import <GooglePlus/GooglePlus.h>

@implementation AppDelegate{
    UINavigationController *mainNavController;
}

static NSString * const kClientId = @"1067683679558-8870rh1fl1d8hi1sjd6neeecgjtqrtg8.apps.googleusercontent.com";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [GPPSignIn sharedInstance].clientID = kClientId;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [Parse setApplicationId:@"ps2iLUr8PrrKai7FX9YXQijqiBb6ifQTFYRoxnXN"
                  clientKey:@"N7C8G9OWHCjGidnSTsd81EykIhi4aSJyVUdWyq71"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFFacebookUtils initializeFacebook];
    [PFTwitterUtils initializeWithConsumerKey:@"4tIoaRQHod1IQ00wtSmRw"
                               consumerSecret:@"S6GATtE4xirn5WlfW79d6aSH4ciMD196hPQuL2g52M8"];
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    NSString *schedule_path = [documentsDirectory
                               stringByAppendingPathComponent:@"facebook.txt"];
    NSString *check_facebook = [NSString stringWithContentsOfFile:schedule_path
                                                   encoding:NSUTF8StringEncoding
                                                    error:NULL];
    //check_facebook = @"no";
    //NSLog(check_facebook);
    if([check_facebook isEqualToString:@"yes"]){
        // Whenever a person opens the app, check for a cached session
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            
            // If there's one, just open the session silently, without showing the user the login UI
            [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                               allowLoginUI:NO
                                          completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                              // Handler for session state changes
                                              // This method will be called EACH time the session state changes,
                                              // also for intermediate states and NOT just when the session open
                                              [self sessionStateChanged:session state:state error:error];
                                              //NSLog(@"YES");
                                          }];
        }
        
        FeedConnectViewController *connect = [[FeedConnectViewController alloc]  init];
        [connect.navigationController.navigationItem hidesBackButton];
        mainNavController = [[UINavigationController alloc] initWithRootViewController:connect];
    }else{
    //NSArray *stack = [NSArray arrayWithObjects:overViewController, tableViewController, newItemViewController, nil];
    //navController.viewControllers = stack;
        
        FeedLoginViewController *mainViewController = [[FeedLoginViewController alloc] init];
        
        mainNavController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    
    }
    [[self window] setRootViewController:mainNavController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // You can add your app-specific url handling code here if needed
    FeedConnectViewController *feed = [[FeedConnectViewController alloc] init];
    [mainNavController pushViewController:feed animated:NO];
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    NSString *schedule_path = [documentsDirectory
                               stringByAppendingPathComponent:@"facebook.txt"];
    NSString *check_facebook = [NSString stringWithContentsOfFile:schedule_path
                                                         encoding:NSUTF8StringEncoding
                                                            error:NULL];
    check_facebook = @"no";
    if([check_facebook isEqualToString:@"yes"]){
        
        NSLog(@"here");
        return [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
        
    }else{
        
        // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
        BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
        
        NSString *filePath = [documentsDirectory
                              stringByAppendingPathComponent:@"facebook.txt"];
        NSError *error;
        // Write to the file
        
        [@"yes" writeToFile:filePath atomically:YES
                   encoding:NSUTF8StringEncoding error:&error];
        
        // Note this handler block should be the exact same as the handler passed to any open calls.
        [FBSession.activeSession setStateChangeHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Retrieve the app delegate
             AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
         }];
        return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    }
  
}
// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        // [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        //[self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            // [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                // [self showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                // [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        //[self userLoggedOut];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
