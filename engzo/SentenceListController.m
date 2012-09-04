//
//  SentenceListController.m
//  engzo
//
//  Created by Capricorn on 12-9-4.
//  Copyright (c) 2012年 engzo. All rights reserved.
//

#import "SentenceListController.h"
#import "User.h"

static NSString *kArchiveKey = @"archive";

@interface SentenceListController ()
@property (strong, nonatomic) NSArray *sentenceList;
@property (strong, nonatomic) User *user;

- (NSString *)getArchivePath:(NSString *)userName;
- (User *)getUserFromFile:(NSString *)path;
- (void)archiveUser:(User *)aUser ToFile:(NSString*)path;

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
    
    User *tmpUser = [self getUserFromFile:[self getArchivePath:self.userName]];
    if (!tmpUser) {
        tmpUser = [[User alloc] init];
        tmpUser.userName = self.userName;
    }
    self.user = tmpUser;
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
    
    cell.textLabel.text = [self.sentenceList objectAtIndex:indexPath.row];
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

#pragma mark - Archive related
- (void)archiveUser:(User *)aUser ToFile:(NSString*)path {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:aUser forKey:kArchiveKey];
    [archiver finishEncoding];
    [data writeToFile:path atomically: YES];
}

- (User *)getUserFromFile:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath: path]){
        NSData *data = [[NSData alloc] initWithContentsOfFile: path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: data];
        return (User *)[unarchiver decodeObjectForKey:kArchiveKey];
    }
    
    return nil;
}

- (NSString *)getArchivePath:(NSString *)aUserName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.archive", aUserName]];
    
    return path;
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
    [segue.destinationViewController performSelector:@selector(setSentence:)
                                          withObject:[self.sentenceList objectAtIndex:path.row]];
}

@end
