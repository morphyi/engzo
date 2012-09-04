//
//  UserSelectController.m
//  engzo
//
//  Created by Capricorn on 12-9-4.
//  Copyright (c) 2012年 engzo. All rights reserved.
//

#import "UserSelectController.h"

@interface UserSelectController ()

@property (strong, nonatomic) NSMutableArray *userList;

@end

@implementation UserSelectController
@synthesize tableView;
@synthesize userList;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    self.tableView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    PoiListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PoiListCell"];
//    
//    const NSInteger index = indexPath.row;
//    PoiInfo *info = [_poiListWrapper.poiInfos objectAtIndex:index];
//    [cell.logoImage setImageWithURL:[NSURL URLWithString:@"http://collider.com/wp-content/uploads/lego-image.jkkpg"]
//                   placeholderImage:[[UIImage imageNamed:@"class_icon_org_jianshen.png"] imageTintedWithColor:[UIColor redColor] fraction:0.0]];
//    cell.nameLabel.text = info.name;
//    cell.ratingBar.rate = info.rank / 10.;
//    
//    return cell;
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


@end
