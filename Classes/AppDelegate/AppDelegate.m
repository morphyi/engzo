//
//  AppDelegate.m
//  engzo
//
//  Created by Capricorn on 12-9-3.
//  Copyright (c) 2012年 engzo. All rights reserved.
//

#import "AppDelegate.h"
#import <RestKit/RKReachabilityObserver.h>
#import "UserSelectController.h"
#import "TrainingAudio.h"

static NSString *kArchiveKey = @"archive";
NSURL *gBaseURL = nil;

@interface AppDelegate ()
- (RKRequest *)uploadRecord:(NSData *)audioData withFileName:(NSString *)fileName andEmail:(NSString *)email andText:(NSString *)text;
- (void)uploadAllRecords;
- (void)uploadOnlyWhenWifiAvailiable:(RKReachabilityObserver *)observer;
@end

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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self uploadOnlyWhenWifiAvailiable:self.client.reachabilityObserver];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

+ (NSURL *)getRecordFilePath:(NSString *)userName forSentenceIndex:(NSUInteger)index {
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%@%u.%@", userName, index, @"alac"]]];
}

- (RKRequest *)uploadRecord:(NSData *)audioData withFileName:(NSString *)fileName andEmail:(NSString *)email andText:(NSString *)text {
    RKParams *params = [RKParams params];
    [params setData:[email dataUsingEncoding:NSUTF8StringEncoding] forParam:@"training_audio[email]"];
    [params setData:[text dataUsingEncoding:NSUTF8StringEncoding] forParam:@"training_audio[text]"];
    
    RKParamsAttachment *attachment = [params setData:audioData forParam:@"training_audio[audio]"];
    attachment.MIMEType = @"applicaton/octet-stream";
    attachment.fileName = fileName;
    
    RKRequest *request = [[RKClient sharedClient] post:@"/training_audios.json" params:params delegate:self];
    request.backgroundPolicy = RKRequestBackgroundPolicyContinue; // Continue the request in the background
    
    return request;
}

- (void)uploadAllRecords {
    NSLog(@"start upload all records");
    
    NSArray *sentenceList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sentences" ofType:@"plist"]];
    
    NSMutableArray *userList = [UserSelectController getUserListFromFile:[UserSelectController getUserListArchivePath]];
    for (NSString *userName in userList) {
        User *user = [self getUserFromFile:[self getArchivePath:userName]];
        NSLog(@"user:%@", user.userName);
        for (NSNumber *finishedIndex in user.finishedList) {
            NSLog(@"finishedIndex:%@", finishedIndex);
            if (![user.uploadedList containsObject:finishedIndex]) {
                NSLog(@"unuploadedIndex:%@", finishedIndex);
                TrainingAudio *audio = [[TrainingAudio alloc] init];
                audio.email = user.userName;
                audio.text = [sentenceList objectAtIndex:finishedIndex.unsignedIntegerValue];
                audio.path = [AppDelegate getRecordFilePath:user.userName forSentenceIndex:finishedIndex.unsignedIntegerValue];
                RKRequest *request = [self uploadRecord:[audio audioData] withFileName:[NSString stringWithFormat: @"%@%@.%@", userName, finishedIndex, @"alac"] andEmail:audio.email andText:audio.text];
                
                NSDictionary *requestId = [NSDictionary dictionaryWithKeysAndObjects:@"user", user, @"index", finishedIndex, nil];
                [request setUserData:requestId];
            }
        }
    }
}

- (void)uploadOnlyWhenWifiAvailiable:(RKReachabilityObserver *)observer {
    if ([observer isReachabilityDetermined] && [observer isNetworkReachable]) {
        if ([observer isConnectionRequired]) {
            NSLog(@"Connection is available...");
            return;
        }
        
        if (RKReachabilityReachableViaWiFi == [observer networkStatus]) {
            NSLog(@"Online via WiFi!");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self uploadAllRecords];
            });
        }
    } else {
        NSLog(@"Network unreachable!");
    }

}

#pragma mark - Reachability Related
- (void)reachabilityChanged:(NSNotification*)notification {
    RKReachabilityObserver *observer = (RKReachabilityObserver *)[notification object];    
    [self uploadOnlyWhenWifiAvailiable:observer];
}

#pragma mark - RKRequest Delegate
- (void)requestDidStartLoad:(RKRequest *)request
{
    NSLog(@"requestDidStartLoad");
}

- (void)request:(RKRequest *)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    NSLog(@"didSendBodyData");
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    NSDictionary *requestId = [request userData];
    User *user = [requestId objectForKey:@"user"];
    NSNumber *index = [requestId objectForKey:@"index"];
    [user addUploadeddItem:index.unsignedIntegerValue];
    [self archiveUser:user ToFile:[self getArchivePath:user.userName]];
    
    NSLog(@"didLoadResponse:%@%@",[response isOK]?@"success":@"fail", [response bodyAsString]);
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError:%@",error);
}

- (void)requestDidTimeout:(RKRequest *)request
{
    NSLog(@"Request timed out during background processing");
}

- (void)requestDidCancelLoad:(RKRequest *)request
{
    NSLog(@"Request canceled");
}

@end
