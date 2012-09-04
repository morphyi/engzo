//
//  UserSelectController.m
//  engzo
//
//  Created by Capricorn on 12-9-4.
//  Copyright (c) 2012年 engzo. All rights reserved.
//

#import "UserSelectController.h"
#import "User.h"

static NSString *kArchiveKey = @"archive";

@interface UserSelectController ()

@property (strong, nonatomic) NSMutableArray *userList;

- (void)archiveListToFile:(NSString*)path;
- (void)getListFromFile:(NSString *)path;
- (NSString *)getArchivePath;
- (void)didEnterBackground;
@end

@implementation UserSelectController
@synthesize tableView;
@synthesize userList;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:@"didEnterBackground" object:nil];
    [self getListFromFile:[self getArchivePath]];
}

- (void)viewDidUnload
{
    [self archiveListToFile:[self getArchivePath]];
    self.tableView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc {
    [self archiveListToFile:[self getArchivePath]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didEnterBackground" object:nil];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"user cell"];
    User *user = [self.userList objectAtIndex:indexPath.row];
    cell.textLabel.text = user.userName;
    return cell;
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

- (void)archiveListToFile:(NSString *)path {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.userList forKey:kArchiveKey];
    [archiver finishEncoding];
    [data writeToFile:path atomically: YES];
}

- (void)getListFromFile:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath: path]){
        NSData *data = [[NSData alloc] initWithContentsOfFile: path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: data];
        self.userList = [unarchiver decodeObjectForKey:kArchiveKey];
    }
}

- (NSString *)getArchivePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"userList.archive"];
    
    return path;
}

- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{
    NSLog(@"done:%d", aTextField.hasText);

    [aTextField resignFirstResponder];
    
    if (!self.userList) {
        self.userList = [[NSMutableArray alloc] init];
    }
    
    User *user = [[User alloc] init];
    user.userName = aTextField.text;
    NSLog(@"userName:%@", user.userName);
    [self.userList addObject:user];
    [self.tableView reloadData];
    
    return YES;
}

- (void)didEnterBackground {
    [self archiveListToFile:[self getArchivePath]];
}

@end
