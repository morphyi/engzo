//
//  UserSelectController.h
//  engzo
//
//  Created by Capricorn on 12-9-4.
//  Copyright (c) 2012年 engzo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserSelectController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
