//
//  AppDelegate.m
//  engzo
//
//  Created by Capricorn on 12-9-3.
//  Copyright (c) 2012年 engzo. All rights reserved.
//

#import "AppDelegate.h"
#import <RestKit/RKReachabilityObserver.h>

static NSString *kArchiveKey = @"archive";
NSURL *gBaseURL = nil;

@implementation AppDelegate
@synthesize client;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    gBaseURL = [[NSURL alloc] initWithString:@"http://www.liulishuo.com/"];
    self.client = [RKClient clientWithBaseURL:gBaseURL];
    [RKClient setSharedClient:self.client];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:RKReachabilityDidChangeNotification
                                               object:self.client.reachabilityObserver];
    
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didEnterBackground" object:nil];
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:nil];
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

#pragma mark - Archive Related
- (void)archiveUser:(User *)aUser ToFile:(NSString*)path {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:aUser forKey:kArchiveKey];
    [archiver finishEncoding];
    [data writeToFile:path atomically: YES];
}

- (User *)getUserFromFile:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath: path]){
        NSData *data = [[NSData alloc] initWithContentsOfFile: path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: data];
        return (User *)[unarchiver decodeObjectForKey:kArchiveKey];
    }
    
    return nil;
}

- (NSString *)getArchivePath:(NSString *)aUserName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.archive", aUserName]];
    
    return path;
}

#pragma mark - Reachability Related
- (void)reachabilityChanged:(NSNotification*)notification {
    RKReachabilityObserver *observer = (RKReachabilityObserver *)[notification object];
    
    if ([observer isNetworkReachable]) {
        if ([observer isConnectionRequired]) {
            NSLog(@"Connection is available...");
            return;
        }
        
        if (RKReachabilityReachableViaWiFi == [observer networkStatus]) {
            NSLog(@"Online via WiFi!");
        }
    } else {
        NSLog(@"Network unreachable!");
    }
}

@end
