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
    
    NSLog(@"APP Launch time.");
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
        RouletteTestingMasterViewController *controller = (RouletteTestingMasterViewController *)masterNavigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    } //else {
//        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
//        RouletteTestingMasterViewController *controller = (RouletteTestingMasterViewController *)navigationController.topViewController;
//        controller.managedObjectContext = self.managedObjectContext;
//    }
    
    
    
#pragma mark Setup Parse Connection
    
    [ParseNetworkManager establishConnection];
    
//    [Parse setApplicationId:@"DDcRvrl0DybiPV3VyTJpTMpvFrOYrUCCTlf5glgX" clientKey:@"31cjkmYUxviwxVh8OO7JTY3Jku3VnMvZ9wnKm51u"];
    
    ////    [keychain setObject:(id)kSecAttrAccessibleAlwaysThisDeviceOnly forKey:(id)kSecAttrAccessible];
    //    NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
    ////    [strApplicationUUID setString:[oNSUUID UUIDString]];
    //    NSLog(@"UUID: %@",[oNSUUID UUIDString]);
    
    
#pragma mark Find or Create UUID for device
    //    if (![FDKey])
    
    //    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"UUID"];
    //    [NSUserDefaults resetStandardUserDefaults]; removeObjectForKey
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Grab UUID from device
    NSString *UUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
    
    // Create a UUID
//    NSString *CFUUID = nil;
//    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
//    CFUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));

    
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
    
//    if ([parseManager checkIfUserExists:UUID]) {
//        // Move On. Success
//        NSLog(@"Request Success");
//    } else {
//        NSLog(@"Request Failed... Trying Again");
//        // Retry
//        #warning @"DEAL WITH MULTIPLE FAILED TRIES TO SAVE OR FETCH USER."
//        if (![parseManager checkIfUserExists:UUID])
//            NSLog(@"*** NETWORK ERROR!!! ***");
//    }
    
    
//    // Check if user exists. If not, save as new user with device's UUID
//    PFQuery *checkIfUserExistsQuery = [PFQuery queryWithClassName:@"User"];
//    [checkIfUserExistsQuery whereKey:@"uuid" equalTo:UUID];
//    
//    [checkIfUserExistsQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
//        if (!error) {
//            // User Doe Not Exist
//            if (users == nil || [users count] == 0) {
//                PFObject *user = [PFObject objectWithClassName:@"User"];
//                [user setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"] forKey:@"uuid"];
//                
//                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                    if (succeeded) {
//                        NSLog(@"Successfully Saved New User");
//                        
//                    } else {
//                        NSString *networkError= [[error userInfo] objectForKey:@"error"];
//                        NSLog(@"Error: %@", networkError);
//                    }
//                }];
//            } else {
//                NSLog(@"USER EXISTS!");
//            }
//        }
//        else {
//            NSString *networkError = [[error userInfo] objectForKey:@"error"];
//            NSLog(@"Error: %@", networkError);
//        }
//    }];
    
//    PFObject *connection = [PFObject objectWithClassName:@"Connection"];
//    [connection setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"] forKey:@"connection1_id"];
//    [connection setObject:@"Michael's iPhone 5" forKey:@"connection1_name"];
//    [connection setObject:@"418201B4-96EA-4BB9-9D12-EC861C09E094" forKey:@"connection2_id"];
//    [connection setObject:@"Mike's iPhone Sim" forKey:@"connection2_name"];
//    
//    [connection saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            NSLog(@"Successfully Saved New Connection!");
//            
//        } else {
//            NSString *networkError= [[error userInfo] objectForKey:@"error"];
//            NSLog(@"Error: %@", networkError);
//        }
//    }];
    
    
    
//        // Reason why I'm setting up Connection user_id to have other users id is because I'm his connection.
//        // Also because it made for a more efficient process with the server with the back end architecture set up.
//        PFObject *connection = [PFObject objectWithClassName:@"Connection"];
//        [connection setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"] forKey:@"user_uuid"];
//        [connection setObject:@"418201B4-96EA-4BB9-9D12-EC861C09E094" forKey:@"connection_uuid"];
//        [connection setObject:@"iPhone Sim" forKey:@"connection_name"];
//    
//        [connection saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (succeeded) {
//                NSLog(@"Successfully Saved New Connection!");
//    
//            } else {
//                NSString *networkError= [[error userInfo] objectForKey:@"error"];
//                NSLog(@"Error: %@", networkError);
//            }
//        }];
    
    

    
    // To Validate that there doesn't already exist an entry
    
//    var BusStop = Parse.Object.extend("BusStop");
//    
//    // Check if stopId is set, and enforce uniqueness based on the stopId column.
//    Parse.Cloud.beforeSave("BusStop", function(request, response) {
//        if (!request.object.get("stopId")) {
//            response.error('A BusStop must have a stopId.');
//        } else {
//            var query = new Parse.Query(BusStop);
//            query.equalTo("stopId", request.object.get("stopId"));
//            query.first({
//            success: function(object) {
//                if (object) {
//                    response.error("A BusStop with this stopId already exists.");
//                } else {
//                    response.success();
//                }
//            },
//            error: function(error) {
//                response.error("Could not validate uniqueness for this BusStop object.");
//            }
//            });
//        }
//    });
    
    
    
    
    
    return YES;
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

@end
