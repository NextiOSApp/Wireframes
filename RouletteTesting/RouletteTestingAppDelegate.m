//
//  RouletteTestingAppDelegate.m
//  RouletteTesting
//
//  Created by Michael Parris on 2/8/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import "RouletteTestingAppDelegate.h"
//#import <Parse/Parse.h>

#import "RouletteTestingMasterViewController.h"
#import "ParseNetworkManager.h"

@implementation RouletteTestingAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    NSLog(@"APP Launch time.");
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
        RouletteTestingMasterViewController *controller = (RouletteTestingMasterViewController *)masterNavigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    }
    
    
    
#pragma mark Setup Parse Connection
    
    [ParseNetworkManager establishConnection];
    
#pragma mark Find or Create UUID for device
    //    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"UUID"];
    //    [NSUserDefaults resetStandardUserDefaults]; removeObjectForKey
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Grab UUID from device
    NSString *UUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
    
    if (!UUID) {
        NSLog(@"No UUID");
        NSLog(@"UUID: %@",UUID);
        
        // Create UUID and Store on Device
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        UUID = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        
        [[NSUserDefaults standardUserDefaults] setObject:UUID forKey:@"UUID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSLog(@"UUID: %@",UUID);
    
    #warning @"DEAL WITH OFFLINE!!!"
    
    ParseNetworkManager *parseManager = [[ParseNetworkManager alloc] init];
    [parseManager checkIfUserExists:UUID];
    
//    [self createConnectionsForTesting];
    
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Will help with 2 things:
    // 1. Find Deleted Connections Because server count would be different than current. *** Possible that someone deleted you but you re-add so you have same count
    // 2. Compare Updated At of local list with server.
    //      MAKING AN UPDATE TO THE MESSAGES WILL ALSO MAKE A CALL TO UPDATE THE CONNECTIONS TABLE.
    //      I WOULD WANT TO TAKE CURRENT TIME, UPDATE MY LOCAL OBJECT WITH THAT TIME AND UPDATE UPDATED_AT ON CONNECTIONS OBJECT    WITH TIME
    RouletteTestingMasterViewController *connectionsVC = (RouletteTestingMasterViewController*)self.window.rootViewController;
    NSLog(@"Root View is: %@", connectionsVC.class);
    
    [connectionsVC fetchNewConnectionsWithCompletionHandler:completionHandler];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RouletteTesting" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RouletteTesting.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Helper Methods For Testing Only
- (void)createConnectionsForTesting {
    PFObject *connection = [PFObject objectWithClassName:@"Connection"];
    [connection setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"] forKey:@"connection1_id"];
    [connection setObject:@"Mike's iPhone Sim" forKey:@"connection1_name"];
    [connection setObject:[NSNumber numberWithBool:NO] forKey:@"connection1_has_messages"];
    [connection setObject:@"4371E73A-15DF-4CA1-998D-10CB6B9B4A2D" forKey:@"connection2_id"];
    [connection setObject:@"Michael's iPhone 5" forKey:@"connection2_name"];
    [connection setObject:[NSNumber numberWithBool:NO] forKey:@"connection2_has_messages"];

    [connection saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Successfully Saved New Connection!");

        } else {
            NSString *networkError= [[error userInfo] objectForKey:@"error"];
            NSLog(@"Error: %@", networkError);
        }
    }];
}

@end
