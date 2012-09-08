//
//  UploadHelper.m
//  engzo
//
//  Created by Capricorn on 12-9-8.
//  Copyright (c) 2012年 engzo. All rights reserved.
//

#import "UploadHelper.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"

@implementation UploadHelper
- (void)uploadRecord:(NSData *)audioData withFileName:(NSString *)fileName andEmail:(NSString *)email andText:(NSString *)text andRequestId:(id)id {
    //    RKParams *params = [RKParams params];
    //    [params setData:[email dataUsingEncoding:NSUTF8StringEncoding] forParam:@"training_audio[email]"];
    //    [params setData:[text dataUsingEncoding:NSUTF8StringEncoding] forParam:@"training_audio[text]"];
    //
    //    RKParamsAttachment *attachment = [params setData:audioData forParam:@"training_audio[audio]"];
    //    attachment.MIMEType = @"applicaton/octet-stream";
    //    attachment.fileName = fileName;
    //
    //    RKRequest *request = [[RKClient sharedClient] post:@"/training_audios.json" params:params delegate:self];
    //    request.backgroundPolicy = RKRequestBackgroundPolicyContinue; // Continue the request in the background
    //    request.userData = id;
    AFHTTPClient *afclient= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://www.liulishuo.com"]];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:email forKey:@"training_audio[email]"];
    [parameters setObject:text forKey:@"training_audio[text]"];
    
//    [afclient multipartFormRequestWithMethod:@"POST" path:@"/training_audios.json" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        NSLog(@"");
//    }];
    
    //    NSMutableURLRequest *request = [afclient multipartFormRequestWithMethod:@"POST" path:@"/training_audios.json" parameters:parameters andAttachmentData:audioData withName:@"training_audio[audio]" fileName:fileName mimeType:@"applicaton/octet-stream"];
    //    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    //    [operation setCompletionBlockWithSuccess: ^(AFHTTPRequestOperation *operation, id responseObject) {
    //        NSLog(@"");
    //    } failure:nil];
    //    [operation start];
}
@end
