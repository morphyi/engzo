//
//  TrainingAudio.m
//  engzo
//
//  Created by Capricorn on 12-9-5.
//  Copyright (c) 2012年 engzo. All rights reserved.
//

#import "TrainingAudio.h"

@implementation TrainingAudio
@synthesize email, text;
@synthesize path;

- (NSData *)audioData {
    return [[NSData alloc] initWithContentsOfURL:self.path];
}

@end
