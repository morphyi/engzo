//
//  User.h
//  engzo
//
//  Created by Capricorn on 12-9-4.
//  Copyright (c) 2012年 engzo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject <NSCoding> {
}

@property (copy, readonly, nonatomic) NSArray *finishedList; //已录过的sentence的编号
@property (strong, nonatomic) NSString *userName;

- (void)addFinishedItem:(NSUInteger)index;
@end
