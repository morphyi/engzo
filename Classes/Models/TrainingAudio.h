//
//  TrainingAudio.h
//  engzo
//
//  Created by Capricorn on 12-9-5.
//  Copyright (c) 2012年 engzo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrainingAudio : NSObject
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSURL *path;

- (NSData *)audioData;
@end
