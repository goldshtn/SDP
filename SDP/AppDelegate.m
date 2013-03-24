//
//  AppDelegate.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/14/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "AppDelegate.h"
#import "LocalNotificationConstants.h"
#import "GAITrackerContainer.h"
#import "AppDefaults.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    //If the schedule is stale, we would rather drop the saved state and look at the most up to
    //date schedule than to reload possibly stale state.
    return ![AppDefaults shouldReloadSchedule];
}

- (void)customizeAppearance {
    [[UINavigationBar appearance] setTintColor:[UIColor orangeColor]];
    [[UITabBar appearance] setTintColor:[UIColor orangeColor]];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:
     @{ UITextAttributeTextColor : [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:
     @{ UITextAttributeTextColor : [UIColor whiteColor] }
                                             forState:UIControlStateHighlighted];
    [[UISearchBar appearance] setTintColor:[UIColor orangeColor]];
}

- (void)showReminderForNotification:(UILocalNotification *)notification
                        application:(UIApplication *)application {
    if (notification) {
        NSString *sessionTitle = notification.userInfo[USER_INFO_SESSION_TITLE];
        NSString *sessionTime = notification.userInfo[USER_INFO_SESSION_TIME];
        [[[UIAlertView alloc] initWithTitle:@"Reminder"
                                    message:[NSString stringWithFormat:@"The SDP session \"%@\" is scheduled for %@, which is pretty soon.", sessionTitle, sessionTime]
                                   delegate:nil
                          cancelButtonTitle:@"Thanks"
                          otherButtonTitles:nil]
         show];
        
        //This has the effect of removing stale local notifications.
        application.scheduledLocalNotifications = application.scheduledLocalNotifications;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self customizeAppearance];
    [GAITrackerContainer setupGoogleAnalytics];

    UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    [self showReminderForNotification:notification application:application];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self showReminderForNotification:notification application:application];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
