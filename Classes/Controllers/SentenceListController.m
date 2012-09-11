//
//  SentenceListController.m
//  engzo
//
//  Created by Capricorn on 12-9-4.
//  Copyright (c) 2012年 engzo. All rights reserved.
//

#import "SentenceListController.h"
#import "User.h"
#import "AppDelegate.h"
#import "AudioRecorderController.h"

static NSString *kArchiveKey = @"archive";

@interface SentenceListController ()
@property (strong, nonatomic) NSArray *sentenceList;
@property (strong, nonatomic) User *user;

-(BOOL)isFinished:(NSUInteger)index;//第index＋1条sentence是否已录制过
@end

@implementation SentenceListController
@synthesize sentenceList;
@synthesize user;
@synthesize userName;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"例句";
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"sentences" ofType:@"plist"];
    self.sentenceList = [NSArray arrayWithContentsOfFile:plistPath];
}

- (void)viewWillAppear:(BOOL)animated {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    User *tmpUser = [appDelegate getUserFromFile:[appDelegate getArchivePath:self.userName]];
    if (!tmpUser) {
        tmpUser = [[User alloc] init];
        tmpUser.userName = self.userName;
    }
    self.user = tmpUser;
    
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return self.sentenceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"sentence cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%u.%@", indexPath.row + 1, [self.sentenceList objectAtIndex:indexPath.row]];
    cell.accessoryType = [self isFinished:indexPath.row] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
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

#pragma mark -
-(BOOL)isFinished:(NSUInteger)index {
    NSArray *finishedList = self.user.finishedList;
    for (NSNumber *finishedIndex in finishedList) {
        if (finishedIndex.unsignedIntegerValue == index) {
            return YES;
        }
    }
    
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    
    AudioRecorderController *destinationViewController = segue.destinationViewController;
    destinationViewController.sentenceIndex = path.row;
    destinationViewController.sentenceList = self.sentenceList;
    destinationViewController.user = self.user;
}

@end
