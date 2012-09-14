//
//  AppDelegate.m
//  engzo
//
//  Created by Capricorn on 12-9-3.
//  Copyright (c) 2012年 engzo. All rights reserved.
//

#import "AppDelegate.h"
#import "UserSelectController.h"
#import "TrainingAudio.h"
#import <Crashlytics/Crashlytics.h>
#import "Flurry.h"
#import <AFNetworking.h>
#import <Reachability.h>
#import <AFHTTPClient.h>
#import "MobClick.h"

static NSString *kArchiveKey = @"userArchive";
NSURL *gBaseURL = nil;

@interface AppDelegate ()
- (void)uploadRecord:(NSData *)audioData withFileName:(NSString *)fileName andEmail:(NSString *)email andText:(NSString *)text andSentenceIndex:(NSUInteger)index;
- (void)uploadAllRecords:(UIView *)loadingView;
@property (readwrite, nonatomic, retain) NSOperationQueue *operationQueue;

@property Reachability *reach;
@end

@implementation AppDelegate
@synthesize window;
@synthesize reach;
@synthesize operationQueue = _operationQueue;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
#define TESTING 1
#ifdef TESTING
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    [Flurry startSession:@"C8JJ7M84J3WKBDM53PTN"];
    [MobClick startWithAppkey:@"50489cba52701510ec00000a" reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    [TestFlight takeOff:@"5bcb9d06f6bf1992c7980c398a75c8e2_MTMwODYzMjAxMi0wOS0xMSAwODo1MDo1Ny41MDMwNTU"];   


    self.operationQueue = [[NSOperationQueue alloc] init];
    [self.operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    
    gBaseURL = [[NSURL alloc] initWithString:@"http://localhost:3000/"];
    
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
    //[self uploadOnlyWhenWifiAvailiable];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"%@%u.%@", userName, index, @"alac"]]];
}

- (void)uploadRecord:(NSData *)audioData withFileName:(NSString *)fileName andEmail:(NSString *)email andText:(NSString *)text andSentenceIndex:(NSUInteger)index {
    AFHTTPClient *afclient= [[AFHTTPClient alloc] initWithBaseURL:gBaseURL];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:email forKey:@"training_audio[email]"];
    [parameters setObject:text forKey:@"training_audio[text]"];
    
    NSMutableURLRequest *request = [afclient multipartFormRequestWithMethod:@"POST" path:@"/training_audios.json" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:audioData name:@"training_audio[audio]" fileName:fileName mimeType:@"applicaton/octet-stream"];
    }];
    
    [request setTimeoutInterval:2];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
        
        NSLog(@"response string: %@ ", operation.responseString);

        NSLog(@"upload index:%u", index);
        NSString *path = [self getArchivePath:email];
        User *user = [self getUserFromFile:path];
        [user addUploadeddItem:index];
        [self archiveUser:user ToFile:path];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error: %@", operation.responseString);
        
    }];
    
    [self.operationQueue addOperation:operation];
    //[operation start];
    
}

- (AFHTTPRequestOperation *)getRequestOperation:(AFHTTPClient *)httpClient withAudio:(NSData *)audioData withFileName:(NSString *)fileName andEmail:(NSString *)email andText:(NSString *)text andSentenceIndex:(NSInteger)index {
    
    NSLog(@"get request operation for sentence %d", index);
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:email forKey:@"training_audio[email]"];
    [parameters setObject:text forKey:@"training_audio[text]"];
    [parameters setObject:[NSString stringWithFormat:@"%d", index] forKey:@"training_audio[text_index]"];
    
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/training_audios.json" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
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
        [self archiveUser:user ToFile:path];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //NSLog(@"error: %@", [operation.response statusCode]);
        //NSLog(@"error response string: %@", operation.responseString);
        
    }];
    
    return operation;
}

- (NSMutableURLRequest *)getRequest:(AFHTTPClient *)httpClient withAudio:(NSData *)audioData withFileName:(NSString *)fileName andEmail:(NSString *)email andText:(NSString *)text andSentenceIndex:(NSUInteger)index {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:email forKey:@"training_audio[email]"];
    [parameters setObject:text forKey:@"training_audio[text]"];
    
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/training_audios.json" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:audioData name:@"training_audio[audio]" fileName:fileName mimeType:@"applicaton/octet-stream"];
    }];
        
    return request;
}

- (void)uploadAllRecords:(UIView *)loadingView {
    NSLog(@"start upload all records");
    AFHTTPClient *httpClient= [[AFHTTPClient alloc] initWithBaseURL:gBaseURL];
    NSArray *sentenceList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sentences" ofType:@"plist"]];
    NSMutableArray *userList = [UserSelectController getUserListFromFile:[UserSelectController getUserListArchivePath]];    
    NSMutableArray *operations = [NSMutableArray array];

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
                
                [operations addObject:[self getRequestOperation:httpClient withAudio:[audio audioData] withFileName:[NSString stringWithFormat: @"%@%@.%@", userName, finishedIndex, @"alac"] andEmail:audio.email andText:audio.text andSentenceIndex:finishedIndex.unsignedIntegerValue]];
            }
        }
    }
    
    [httpClient enqueueBatchOfHTTPRequestOperations:operations progressBlock:^(NSUInteger numberOfCompletedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"%d out of %d is uploaded", numberOfCompletedOperations, totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) {
        loadingView.hidden = YES;
        NSLog(@"all record is uploaded");
    }];

}

- (void)uploadOnlyWhenWifiAvailiable:(UIView *)loadingView {
    if ([self.reach isReachableViaWiFi]) {
        NSLog(@"wifi available");
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self uploadAllRecords:loadingView];
//        });
    } else {
        NSLog(@"no wifi");
    }
}

#pragma mark - Reachability Related
- (void)reachabilityChanged:(NSNotification*)notification {
    //[self uploadOnlyWhenWifiAvailiable];
}

@end
