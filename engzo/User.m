//
//  User.m
//  engzo
//
//  Created by Capricorn on 12-9-4.
//  Copyright (c) 2012年 engzo. All rights reserved.
//

#import "User.h"

static NSString *kListKey = @"list";
static NSString *kNameKey = @"name";

@interface User () {
    NSMutableArray *_finishedList;
}

- (BOOL)checkConflict:(NSUInteger)index;//检查是否已录过，不要重复添加
@end

@implementation User
@synthesize userName;

- (BOOL)checkConflict:(NSUInteger)index {
    if (!_finishedList) {
        return NO;
    }
    
    for (NSNumber *existedIndex in _finishedList) {
        if (existedIndex.unsignedIntegerValue == index) {
            return YES;
        }
    }
    
    return NO;
}

- (void)addFinishedItem:(NSUInteger)index {
    if ([self checkConflict:index]) {
        return;
    }
    
    if (!_finishedList) {
        _finishedList = [[NSMutableArray alloc] init];
    }
    
    [_finishedList addObject:[[NSNumber alloc] initWithUnsignedInteger:index]];
}

- (NSArray *)getFinishedList {
    return [[NSArray alloc] initWithArray:_finishedList];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_finishedList forKey:kListKey];
    [aCoder encodeObject:self.userName forKey:kNameKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    // Init first.
    if(self = [self init]) {
        _finishedList = [aDecoder decodeObjectForKey:kListKey];
        self.userName = [aDecoder decodeObjectForKey:kNameKey];
    }
    
    return self;
}

@end
