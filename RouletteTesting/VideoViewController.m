//
//  VideoViewController.m
//  RouletteTesting
//
//  Created by Michael Parris on 2/26/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import "VideoViewController.h"
#import "NSString+FontAwesome.h"
#import "RouletteTestingMasterViewController.h"
#import "ConnectionsViewController.h"

#import <Parse/Parse.h>
#import "ConnectionData.h"

@interface VideoViewController ()

@end

@implementation VideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    self.connectionsLabel.font = [UIFont fontWithName:@"FontAwesome" size:30];
//    self.connectionsLabel.text = [NSString awesomeIcon:FaAngleDoubleLeft];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(connectionsView:)];
    [self.connectionsLabel addGestureRecognizer:tap];
    
}

// This is for when a new connection is made rather than just the button to view being hit.
- (void)newConnection {
    [self createConnectionsForTesting];
}

- (IBAction)connView:(id)sender {
    NSLog(@"CONNECTIONS button clicked.");
    
    // HACKING CONNECTION PART SINCE THIS IS NOT SETUP
    
    // Fetch existing users
//    PFQuery *fetchUsersQuery = [PFQuery queryWithClassName:@"User"];
//    NSArray *usersArray = [fetchUsersQuery findObjects];
//    
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    
//    for (PFObject *user in usersArray){
//        NSString *uuid = [user objectForKey:@"uuid"];
//        NSString *connectionName = [[NSString alloc] init];
//        
//
//        if ([uuid isEqualToString:@"418201B4-96EA-4BB9-9D12-EC861C09E094"])
//            connectionName = @"Mike's iPhone Sim";
//        else
//            connectionName = @"Michael's iPhone 5";
//        
//        PFObject *connection = [PFObject objectWithClassName:@"Connection"];
//        [connection setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"] forKey:@"connection1_id"];
//        [connection setObject:@"Chris Hayes iPhone" forKey:@"connection1_name"];
//        [connection setObject:[NSNumber numberWithBool:NO] forKey:@"connection1_has_messages"];
//        [connection setObject:uuid forKey:@"connection2_id"];
//        [connection setObject:connectionName forKey:@"connection2_name"];
//        [connection setObject:[NSNumber numberWithBool:NO] forKey:@"connection2_has_messages"];
//        
//        [connection save];
//        
//        PFQuery *queryId = [PFQuery queryWithClassName:@"Connection"];
//        [queryId whereKey:@"connection1_id" containsString:uuid];
//        
//        PFObject *object = [queryId getFirstObject];
//        NSString *objectId = [object objectId];
//        
//        
//        
//        ConnectionData *connectionToCache = [[ConnectionData alloc] init];
//        connectionToCache.connectionUUID = uuid;
//        connectionToCache.connectionName = connectionName;
//        connectionToCache.connectionId = objectId;
//        
//        [array addObject:connectionToCache];
//    }
//    
//    
//    NSFileManager *fileMgr;
//    NSString *docsDir;
//    NSArray *dirPaths;
//    
//    fileMgr = [NSFileManager defaultManager];
//    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    docsDir = dirPaths[0];
//    
//    NSString *dataFilePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"data.archive"]];
//    
//    [NSKeyedArchiver archiveRootObject:array toFile:dataFilePath];
    
    // For testing I'm doing this
//    [self newConnection];
    
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
//    RouletteTestingMasterViewController *cV = (RouletteTestingMasterViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"connections1"];
//    [self presentViewController:cV animated:YES completion:nil];
    
    [self performSegueWithIdentifier:@"PushConnections" sender:self];
}

- (void)connectionsView {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    RouletteTestingMasterViewController *cV = (RouletteTestingMasterViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"connections1"];
//    ConnectionsViewController *cV = (ConnectionsViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"connections2"];
    [self presentViewController:cV animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createConnectionsForTesting {
    PFObject *connection = [PFObject objectWithClassName:@"Connection"];
    [connection setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"] forKey:@"connection1_id"];
    [connection setObject:@"Mike's iPhone Sim" forKey:@"connection1_name"];
    [connection setObject:[NSNumber numberWithBool:NO] forKey:@"connection1_has_messages"];
    [connection setObject:@"4371E73A-15DF-4CA1-998D-10CB6B9B4A2D" forKey:@"connection2_id"];
    [connection setObject:@"Michael's iPhone 5" forKey:@"connection2_name"];
    [connection setObject:[NSNumber numberWithBool:NO] forKey:@"connection2_has_messages"];
    
    
//    NSError *error;
//    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:_docPath withIntermediateDirectories:YES attributes:nil error:&error];
//    if (!success) {
//        NSLog(@"Error creating data path: %@", [error localizedDescription]);
//    }
    
    NSFileManager *fileMgr;
    NSString *docsDir;
    NSArray *dirPaths;
    
    fileMgr = [NSFileManager defaultManager];
    
    // Get documetns directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    // Build path to data file
    NSString *dataFilePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"data.archive"]];
    
    
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"messageIdsArray"];
//    [[NSUserDefaults standardUserDefaults] synchronize];

    
    ConnectionData *connectionToCache = [[ConnectionData alloc] init];
    connectionToCache.connectionUUID = @"4371E73A-15DF-4CA1-998D-10CB6B9B4A2D";
    connectionToCache.connectionName = @"Michael's iPhone 5";
    connectionToCache.connectionId = @"RF66NWsMlU";
    
    // FOR IPHONE
//    connectionToCache.connectionUUID = @"418201B4-96EA-4BB9-9D12-EC861C09E094";
//    connectionToCache.connectionName = @"Mike's iPhone Sim";
//    connectionToCache.connectionId = @"RF66NWsMlU";
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:connectionToCache, nil];
    
    NSLog(@"%@", dataFilePath);
    
    [NSKeyedArchiver archiveRootObject:array toFile:dataFilePath];
    return;
    [connection saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Successfully Saved New Connection!");
            
            NSFileManager *fileMgr;
            NSString *docsDir;
            NSArray *dirPaths;
            
            fileMgr = [NSFileManager defaultManager];
            
            // Get documetns directory
            dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            docsDir = dirPaths[0];
            
            // Build path to data file
            NSString *dataFilePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"data.archive"]];
            
            ConnectionData *connectionToCache = [[ConnectionData alloc] init];
            connectionToCache.connectionUUID = [connection valueForKey:@"connection2_id"];
            connectionToCache.connectionName = [connection valueForKey:@"connection2_name"];
            connectionToCache.connectionId = connection.objectId;
            
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:connectionToCache, nil];

            [NSKeyedArchiver archiveRootObject:array toFile:dataFilePath];
            
            [self connectionsView];
            
        } else {
            // Delete Connection
            NSString *networkError= [[error userInfo] objectForKey:@"error"];
            NSLog(@"Error: %@", networkError);
        }
    }];
}

@end
