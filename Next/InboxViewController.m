//
//  InboxViewController.m
//  Next
//
//  Created by Chris Hayes on 5/16/14.
//  Copyright (c) 2014 CAV. All rights reserved.
//

#import "InboxViewController.h"

@interface InboxViewController ()

@end

@implementation InboxViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser)
    {
        NSLog(@"Current user: %@", currentUser.username);
        self.moviePlayer = [[MPMoviePlayerController alloc] init];
    }
    else
    {
          [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __block BOOL isCheckCacheRound = YES;
    
    [self.navigationController.navigationBar setHidden:NO];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query whereKey:@"recipientIds" equalTo:[[PFUser currentUser] objectId]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            if ([[error userInfo] valueForKey:@"code"] == [NSNumber numberWithInteger:120])
                NSLog(@"** CACHE MISS **");
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            isCheckCacheRound = NO;
        } else {
            if (isCheckCacheRound) {
                NSLog(@"*** FOUND %d messages FROM THE CACHE ***", [self.messages count]);
                self.cachedMessages = self.messages = objects;
                [self.tableView reloadData];
                isCheckCacheRound = NO;
            } else {
                BOOL cacheOutOfDate = NO;
                NSLog(@"FOUND %d MESSAGES FROM THE NETWORK", [self.messages count]);
                
                NSArray *cachedMessageIds = [[NSArray alloc] initWithArray:[self.cachedMessages valueForKey:@"objectId"]];
                NSArray *networkMessageIds = [[NSArray alloc] initWithArray:[objects valueForKey:@"objectId"]];
                
                for (NSString *objectId in cachedMessageIds) {
                    if (![networkMessageIds containsObject:objectId]) {
                        // Cache is out of date so reload table. Cache is automatically updated after this call too
                        cacheOutOfDate = YES;
                        break;
                    }
                }
                
                if (cacheOutOfDate) {
                    self.messages = objects;
                    [self.tableView reloadData];
                }
            }
        }
    }];
}

#pragma mark - INBOX

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

#pragma mark - Inbox Naming
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.messages count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if ([self.messages count] <= indexPath.row)
        return cell;
    
    PFObject *message = [self.messages objectAtIndex:indexPath.row];
    cell.textLabel.text = [message objectForKey:@"senderName"];
    
    NSString *fileType = [message objectForKey:@"fileType"];
    if ([fileType isEqualToString:@"image"]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_image"];
    }
    else {
        cell.imageView.image = [UIImage imageNamed:@"icon_video"];
    }

    return cell;
}

#pragma mark - Image/Video Display

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.messages count] <= indexPath.row)
        return;
    
    self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
    NSString *fileType = [self.selectedMessage objectForKey:@"fileType"];
    if ([fileType isEqualToString:@"image"])
    {
        [self performSegueWithIdentifier:@"showImage" sender:self];
    }
    else
    {
        PFFile *videoFile = [self.selectedMessage objectForKey:@"file"];
        NSURL *fileURL = [NSURL URLWithString:videoFile.url];
        self.moviePlayer.contentURL = fileURL;
        [self.moviePlayer prepareToPlay];
        // There's a slightly faster way to add the thumbnail images if we decide... justbecause it's deprecated now
        // http://stackoverflow.com/questions/19105721/thumbnailimageattime-now-deprecated-whats-the-alternative
        [self.moviePlayer thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES];
    }
    // DELETING
    NSMutableArray *recipientIds = [NSMutableArray arrayWithArray:[self.selectedMessage objectForKey:@"recipientIds"]];
    NSLog(@"Recipients: %@", recipientIds);
    
    if ([recipientIds count] == 1)
    {
        [self.selectedMessage deleteInBackground];
    }
    else
    {
        [self.selectedMessage removeObject:[[PFUser currentUser] objectId] forKey:@"recipientIds"];
        [self.selectedMessage saveInBackground];
    }
        
}

#pragma mark - Helper Methods

- (IBAction)logout:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showLogin"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    } else  if ([segue.identifier isEqualToString:@"showImage"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        ImageViewController *imageViewController = (ImageViewController *)segue.destinationViewController;
        imageViewController.message = self.selectedMessage;
    }
}






@end
