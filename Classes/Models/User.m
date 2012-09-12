//
//  User.m
//  engzo
//
//  Created by Capricorn on 12-9-4.
//  Copyright (c) 2012年 engzo. All rights reserved.
//

#import "User.h"

static NSString *kFinishedKey = @"finished";
static NSString *kUploadedKey = @"uploadedNew";
static NSString *kNameKey = @"name";

@interface User () {
    NSMutableArray *_finishedList;
    NSMutableArray *_uploadedList;
}

@end

@implementation User
@synthesize userName;
@synthesize finishedList = _finishedList, uploadedList = _uploadedList;

- (BOOL)checkExisted:(NSUInteger)index; {
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
    if ([self checkExisted:index]) {
        return;
    }
    
    if (!_finishedList) {
        _finishedList = [[NSMutableArray alloc] init];
    }
    
    [_finishedList addObject:[[NSNumber alloc] initWithUnsignedInteger:index]];
}

- (void)addUploadeddItem:(NSUInteger)index {
    if (!_uploadedList) {
        _uploadedList = [[NSMutableArray alloc] init];
    }
    
    [_uploadedList addObject:[[NSNumber alloc] initWithUnsignedInteger:index]];
}

- (void)removeUploadeddItem:(NSUInteger)index {
    if (!_uploadedList) {
        _uploadedList = [[NSMutableArray alloc] init];
    }
    
    [_uploadedList removeObject:[[NSNumber alloc] initWithUnsignedInteger:index]];
}

- (NSArray *)getFinishedList {
    return [[NSArray alloc] initWithArray:_finishedList];
}

- (NSArray *)getUploadedList {
    return [[NSArray alloc] initWithArray:_uploadedList];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_finishedList forKey:kFinishedKey];
    [aCoder encodeObject:_uploadedList forKey:kUploadedKey];
    [aCoder encodeObject:self.userName forKey:kNameKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    // Init first.
    if(self = [self init]) {
        _finishedList = [aDecoder decodeObjectForKey:kFinishedKey];
        _uploadedList = [aDecoder decodeObjectForKey:kUploadedKey];
        self.userName = [aDecoder decodeObjectForKey:kNameKey];
    }
    
    return self;
}

@end
