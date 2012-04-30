//
//  JHAppDelegate.m
//  jHouse
//
//  Created by Greg on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHAppDelegate.h"
#import "JHConstants.h"
#import "JHLocationUpdater.h"
#import "JHConfig.h"
#import "JHApnsProviderUpdater.h"

#include "TargetConditionals.h"

@implementation JHAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Create app's UUID
    [self createUUID];
    
#if !(TARGET_IPHONE_SIMULATOR)
    // Register for push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
#endif
    
    // Get app background status
    BOOL isInBackground = ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground);
    
    // If we don't have the server URL and we're not in the background, ask the user for the server URL
    if ([[NSUserDefaults standardUserDefaults] stringForKey:JHServerURL] == nil && !isInBackground)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Server URL" message:@"You must specify the server URL" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alertView show];
    }
    
    return YES;
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
    
    [[JHConfig shared] dehydrateToCache];
    
    BOOL sendLocationUpdates = [[NSUserDefaults standardUserDefaults] boolForKey:JHConfigLocationSendUpdates];
    BOOL sendBackgroundLocationUpdates = [[NSUserDefaults standardUserDefaults] boolForKey:JHConfigLocationBackgroundUpdates];
    if (sendLocationUpdates && sendBackgroundLocationUpdates)
    {
        [[JHLocationUpdater shared] enteringBackground];
    }
    else
    {
        [[JHLocationUpdater shared] stopAllUpdates];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    BOOL sendLocationUpdates = [[NSUserDefaults standardUserDefaults] boolForKey:JHConfigLocationSendUpdates];
    if (sendLocationUpdates)
    {
        [[JHLocationUpdater shared] startUpdatingLocation];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Push notification delegates

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[[deviceToken description] stringByTrimmingCharactersInSet:
                           [NSCharacterSet characterSetWithCharactersInString:@"<>"]] 
                          stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[[JHApnsProviderUpdater alloc] init] updateProviderWithToken:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Failed to register for push notifications: %@", error.localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView setAlertViewStyle:UIAlertViewStyleDefault];
    [alertView show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[NSUserDefaults standardUserDefaults] setValue:[alertView textFieldAtIndex:0].text forKey:JHServerURL];
}

#pragma mark - Misc Methods

- (void)createUUID
{
    // If UUID isn't found, generate one and save it
    if (![[NSUserDefaults standardUserDefaults] valueForKey:JHConfigAppUUID])
    {
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuidStrRef = CFUUIDCreateString(NULL, uuidRef);
        NSString *uuid = [NSString stringWithFormat:@"%@", uuidStrRef];
        [[NSUserDefaults standardUserDefaults] setValue:uuid forKey:JHConfigAppUUID];
        CFRelease(uuidRef);
        CFRelease(uuidStrRef);
    }
}

@end
