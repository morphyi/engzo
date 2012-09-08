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
#import <Crashlytics/Crashlytics.h>
#import "Flurry.h"
#import <AFNetworking.h>
#import <Reachability.h>
#import <AFHTTPClient.h>

static NSString *kArchiveKey = @"archive";
NSURL *gBaseURL = nil;

@interface AppDelegate ()
- (void)uploadRecord:(NSData *)audioData withFileName:(NSString *)fileName andEmail:(NSString *)email andText:(NSString *)text andSentenceIndex:(NSUInteger)index;
- (void)uploadAllRecords;

@property Reachability *reach;
@end

@implementation AppDelegate
@synthesize client;
@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Flurry startSession:@"C8JJ7M84J3WKBDM53PTN"];
    
    gBaseURL = [[NSURL alloc] initWithString:@"http://www.liulishuo.com/"];
    self.client = [RKClient clientWithBaseURL:gBaseURL];
    [RKClient setSharedClient:self.client];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(reachabilityChanged:)
    //                                                 name:RKReachabilityDidChangeNotification
    //                                               object:self.client.reachabilityObserver];
    
    self.reach = [Reachability reachabilityWithHostname:@"www.liulishuo.com"];
    
    // tell the reachability that we DONT want to be reachable on 3G/EDGE/CDMA
    self.reach.reachableOnWWAN = NO;
    
    // here we set up a NSNotification observer. The Reachability that caused the notification
    // is passed in the object parameter
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [self.reach startNotifier];
    
    [Crashlytics startWithAPIKey:@"84190f5c58f93691273aef4ecdb1175a6a6fabf4"];
    
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
    NSLog(@"applicationDidBecomeActive");
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
        User *user = (User *)[unarchiver decodeObjectForKey:kArchiveKey];
        [unarchiver finishDecoding];
        
        return user;
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

- (void)uploadRecord:(NSData *)audioData withFileName:(NSString *)fileName andEmail:(NSString *)email andText:(NSString *)text andSentenceIndex:(NSUInteger)index {
    AFHTTPClient *afclient= [[AFHTTPClient alloc] initWithBaseURL:gBaseURL];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:email forKey:@"training_audio[email]"];
    [parameters setObject:text forKey:@"training_audio[text]"];
    
    NSMutableURLRequest *request = [afclient multipartFormRequestWithMethod:@"POST" path:@"/training_audios.json" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:audioData name:@"training_audio[audio]" fileName:fileName mimeType:@"applicaton/octet-stream"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
        
        NSLog(@"response string: %@ ", operation.responseString);

        NSLog(@"upload index:%u", index);
        NSString *path = [self getArchivePath:email];
        User *user = [self getUserFromFile:path];
        [user addUploadeddItem:index];
        NSLog(@"uploadlistxx:%@", user.uploadedList);
        [self archiveUser:user ToFile:path];
        user = [self getUserFromFile:path];
        NSLog(@"uploadlistxxxx:%@", user.uploadedList);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error: %@", operation.responseString);
        
    }];
    
    [operation start];
    
}

- (void)uploadAllRecords {
    NSLog(@"start upload all records");
    
    NSArray *sentenceList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sentences" ofType:@"plist"]];
    
    NSMutableArray *userList = [UserSelectController getUserListFromFile:[UserSelectController getUserListArchivePath]];
    for (NSString *userName in userList) {
        User *user = [self getUserFromFile:[self getArchivePath:userName]];
        NSLog(@"user:%@", user.userName);
        NSLog(@"finishedList:%@", user.finishedList);
        NSLog(@"uploadedList:%@", user.uploadedList);
        for (NSNumber *finishedIndex in user.finishedList) {
            if (![user.uploadedList containsObject:finishedIndex]) {
                NSLog(@"unuploadedIndex:%@", finishedIndex);
                TrainingAudio *audio = [[TrainingAudio alloc] init];
                audio.email = user.userName;
                audio.text = [sentenceList objectAtIndex:finishedIndex.unsignedIntegerValue];
                audio.path = [AppDelegate getRecordFilePath:user.userName forSentenceIndex:finishedIndex.unsignedIntegerValue];
                
                [self uploadRecord:[audio audioData] withFileName:[NSString stringWithFormat: @"%@%@.%@", userName, finishedIndex, @"alac"] andEmail:audio.email andText:audio.text andSentenceIndex:finishedIndex.unsignedIntegerValue];
            }
        }
    }
}

- (void)uploadOnlyWhenWifiAvailiable:(RKReachabilityObserver *)observer {
    if ([self.reach isReachableViaWiFi]) {
        NSLog(@"wifi available");
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self uploadAllRecords];
//        });
    } else {
        NSLog(@"no wifi");
    }
    
//    if ([observer isReachabilityDetermined] && [observer isNetworkReachable]) {
//        if ([observer isConnectionRequired]) {
//            NSLog(@"Connection is available...");
//            return;
//        }
//        
//        if (RKReachabilityReachableViaWiFi == [observer networkStatus]) {
//            NSLog(@"Online via WiFi!");
//            
//        }
//    } else {
//        NSLog(@"restkit Network unreachable!");
//    }
    
}

#pragma mark - Reachability Related
- (void)reachabilityChanged:(NSNotification*)notification {
    [self uploadOnlyWhenWifiAvailiable:nil];
    //    if ([notification.object isMemberOfClass:[RKReachabilityObserver  class]]) {
    //        RKReachabilityObserver *observer = (RKReachabilityObserver *)[notification object];
    //        [self uploadOnlyWhenWifiAvailiable:observer];
    //    }
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
