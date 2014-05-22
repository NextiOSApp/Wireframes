//
//  EditFriendsViewController.m
//  Next
//
//  Created by Chris Hayes on 5/16/14.
//  Copyright (c) 2014 CAV. All rights reserved.
//

#import "EditFriendsViewController.h"

@interface EditFriendsViewController ()

@end

@implementation EditFriendsViewController

@synthesize parseManager;

- (void)viewDidLoad
{
    [super viewDidLoad];

    parseManager = [[ParseManager alloc] init];
    parseManager.delegate = self;
    [parseManager getFriendsWithFilter:@"All"];
}

#pragma mark - ParseManager delegate methods

- (void)updateFriends:(NSArray *)foundFriends {
    self.allUsers = foundFriends;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    NSArray *friendObjectIds = [self.friends valueForKey:@"objectId"];
    if ([friendObjectIds containsObject:[user objectId]])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}


#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    NSArray *friendObjectIds = [self.friends valueForKey:@"objectId"];
    if ([friendObjectIds containsObject:[user objectId]]) {
        int indexToRemove = [friendObjectIds indexOfObject:[user objectId]];
        [self.friends removeObjectAtIndex:indexToRemove];
        
        // Remove Checkmark
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        // Remove from Backend
        [parseManager removeFriend:user];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.friends addObject:user];
        [parseManager addFriend:user];
    }
}

#pragma mark - Helper Methods

@end
