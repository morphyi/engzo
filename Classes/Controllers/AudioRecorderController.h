//
//  AudioRecorderController.h
//  engzo
//
//  Created by Capricorn on 12-9-3.
//  Copyright (c) 2012年 engzo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import <RestKit/RestKit.h>

@interface AudioRecorderController : UIViewController <RKRequestDelegate>
@property (copy, nonatomic) NSArray *sentenceList;
@property (assign, nonatomic) NSUInteger sentenceIndex;
@property (weak, nonatomic) User *user;
@end
