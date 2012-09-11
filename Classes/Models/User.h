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

@property (readonly, nonatomic) NSArray *uploadedList; //已上传的sentence的编号
@property (readonly, nonatomic) NSArray *finishedList; //已录过的sentence的编号
@property (strong, nonatomic) NSString *userName;

- (BOOL)checkExisted:(NSUInteger)index;//检查是否已录过，不要重复添加
- (void)addFinishedItem:(NSUInteger)index;
- (void)addUploadeddItem:(NSUInteger)index;
@end
