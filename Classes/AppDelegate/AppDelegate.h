//
//  AppDelegate.h
//  engzo
//
//  Created by Capricorn on 12-9-3.
//  Copyright (c) 2012年 engzo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "User.h"

// Import the base URL defined in the app delegate
extern NSURL *gBaseURL;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RKClient *client;

- (NSString *)getArchivePath:(NSString *)userName;
- (User *)getUserFromFile:(NSString *)path;
- (void)archiveUser:(User *)aUser ToFile:(NSString*)path;

@end
