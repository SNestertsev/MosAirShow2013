//
//  ASAppDelegate.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 28.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASAppDelegate.h"

@implementation ASAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSDate *now = [NSDate date];
    // Устанавливаем нотификацию о начале работы МАКСа
    NSDateComponents *compsDate = [[NSDateComponents alloc] init];
    [compsDate setYear:2013];
    [compsDate setMonth:8];
    [compsDate setDay:27];
    [compsDate setHour:8];
    NSDate *fireDate = [[NSCalendar currentCalendar] dateFromComponents:compsDate];
    NSComparisonResult comp = [fireDate compare:now];
    if (comp == NSOrderedDescending) {
        UILocalNotification* ln = [UILocalNotification new];
        ln.alertBody = @"Сегодня МАКС-2013 открывается для специалистов";
        ln.fireDate = fireDate;
        ln.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:ln];
    }
    // Нотификация о первом дне массового посещения
    [compsDate setDay:30];
    fireDate = [[NSCalendar currentCalendar] dateFromComponents:compsDate];
    comp = [fireDate compare:now];
    if (comp == NSOrderedDescending) {
        UILocalNotification* ln = [UILocalNotification new];
        ln.alertBody = @"Сегодня МАКС-2013 открывает свои двери для широкой публики";
        ln.fireDate = fireDate;
        ln.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:ln];
    }
    // Нотификация о втором дне массового посещения
    [compsDate setDay:31];
    fireDate = [[NSCalendar currentCalendar] dateFromComponents:compsDate];
    comp = [fireDate compare:now];
    if (comp == NSOrderedDescending) {
        UILocalNotification* ln = [UILocalNotification new];
        ln.alertBody = @"Сегодня второй день массового посещения на МАКС-2013";
        ln.fireDate = fireDate;
        ln.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:ln];
    }
    // Нотификация о заключительном дне работы выставки
    [compsDate setMonth:9];
    [compsDate setDay:1];
    fireDate = [[NSCalendar currentCalendar] dateFromComponents:compsDate];
    comp = [fireDate compare:now];
    if (comp == NSOrderedDescending) {
        UILocalNotification* ln = [UILocalNotification new];
        ln.alertBody = @"Сегодня заключительный день МАКС-2013";
        ln.fireDate = fireDate;
        ln.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:ln];
    }
    return YES;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
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
