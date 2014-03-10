//
//  ParseNetworkManager.m
//  RouletteTesting
//
//  Created by Michael Parris on 2/26/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import "ParseNetworkManager.h"
#import "ConnectionData.h"
#import "ConnectionMessageData.h"
#import "MBProgressHUD.h"

@implementation ParseNetworkManager

+ (void)establishConnection {
    [Parse setApplicationId:@"DDcRvrl0DybiPV3VyTJpTMpvFrOYrUCCTlf5glgX" clientKey:@"31cjkmYUxviwxVh8OO7JTY3Jku3VnMvZ9wnKm51u"];
}

- (BOOL)changedList:(NSMutableArray *)newConnections currentList:(NSMutableArray *)oldConnections {
    // If not the same size, we know we have a new list of connections
    if ([newConnections count] != [oldConnections count])
        return YES;

//    for (ConnectionData *connection in newConnections) {
    for (int i=0; i < [newConnections count]; i++) {
//        if (![oldConnections containsObject:connection]) {
//            NSLog(@"DIDN'T FIND NEW CONNECTION IN CACHED LIST *****");
//            return YES;
//        }
        
        #warning @"SLOWWWWWWW"
        if (![[[oldConnections objectAtIndex:i] connectionUUID] isEqualToString:[[newConnections objectAtIndex:i] connectionUUID]]) {
            NSLog(@"DIDN'T FIND NEW CONNECTION IN CACHED LIST. UPDATE *****");
//            return YES;
        }
    }
    
    return NO;
}

- (BOOL)authenticateUser:(NSString *)UUID {
    #warning @"Make PFQuery so you only have to init once."
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"uuid" equalTo:UUID];

    PFObject *user = [query getFirstObject];
//    PFObject *user = [PFObject objectWithClassName:@"User"];
    [user setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"] forKey:@"uuid"];
    
    // Same as normal Save except this will cache save query in background if no network connection
    [user saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Successfully Saved New User");
            
        } else {
            // S
            
            NSString *networkError= [[error userInfo] objectForKey:@"error"];
            NSLog(@"Error: %@", networkError);
//            NSLog(@"HOW DID USER GET DELETED?");
        }
    }];
    return YES;
    
}

- (BOOL)checkIfUserExists:(NSString *)UUID {
    __block BOOL savedSuccessfully = YES;
    
    // Check if user exists. If not, save as new user with device's UUID

    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"uuid" equalTo:UUID];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (!error) {
            // User Does Not Exist
            if (users == nil || [users count] == 0) {
                PFObject *user = [PFObject objectWithClassName:@"User"];
                [user setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"] forKey:@"uuid"];
                
                // Same as normal Save except this will cache save query in background if no network connection
                [user saveEventually:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Successfully Saved New User");
                        
                    } else {
                        // Failed Saving User. Should raise an alert *****
                        NSString *networkError= [[error userInfo] objectForKey:@"error"];
                        NSLog(@"Error: %@", networkError);
                    }
                }];
            } else {
                NSLog(@"USER EXISTS!");
            }
        }
        else {
            savedSuccessfully = NO;
            NSString *networkError = [[error userInfo] objectForKey:@"error"];
            NSLog(@"Error: %@", networkError);
        }
    }];
    
    return savedSuccessfully;
}

//- (NSString*)fetchConnectionObjectId:(NSString *)currentUserUUID currentConnectionUUID:(NSString *)connectionUUID {
//    PFQuery *query = [PFQuery queryWithClassName:@"Connection"];
//    [query whereKey:@"user_uuid" equalTo:connectionUUID];
//    [query whereKey:@"connection_uuid" equalTo:currentUserUUID];
//    
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if (!error) {
//            NSLog(@"Successfully retrieved object!");
//        } else {
//            NSLog(@"Failed To Retrieve Object!");
//        }
//    }];
//}

- (void)getConnections:(UIView*)currentView {
    __block BOOL cacheValueExists = NO;
    __block BOOL checkedCacheCycle = NO;
    __block NSString *connectionKey = nil;
    
    NSString *currentUUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"connection1_id = %@ OR connection2_id = %@", currentUUID, currentUUID];
    
    PFQuery *getConnectionsList = [PFQuery queryWithClassName:@"Connection" predicate:predicate];
    
    // Query Cache Policy checks cache first then network.
    // Point of this is because cache is quicker but might not be up to date so need to compare with server response
//    getConnectionsList.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    NSLog(@"Looking for Connections with UUID: %@", currentUUID);
    
    NSMutableArray *cachedConnectionsListArray = [[NSMutableArray alloc] init];
    NSMutableArray *networkConnectionsListArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *messagesListArray = [[NSMutableArray alloc] init];
    
    MBProgressHUD *spinner = [MBProgressHUD showHUDAddedTo:currentView animated:YES];
    spinner.mode = MBProgressHUDModeIndeterminate;
    spinner.labelText = @"Uploading";
    [spinner show:YES];
    
    
    __block BOOL cachedResponseExists = [getConnectionsList hasCachedResult];
    NSLog(@"CACHED RESPONSE??? %@", cachedResponseExists ? @"YES" : @"NO");
    //    [getConnectionsList clearCachedResult];
    
    
    NSLog(@"ABOUT TO DISPATCH BACKGROUD PROCESS FOR GETTING LIST OF CONNECTIONS *****");
    
    [getConnectionsList findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *connectionResponse in objects) {
                ConnectionData *connection = [[ConnectionData alloc] init];
                
                if ([currentUUID isEqualToString:[connectionResponse objectForKey:@"connection1_id"]]) {
                    connectionKey = @"connection2";
                } else {
                    connectionKey = @"connection1";
                }
                
                connection.connectionUUID = [connectionResponse objectForKey:[NSString stringWithFormat:@"%@_id", connectionKey]];
                connection.connectionName = [connectionResponse objectForKey:[NSString stringWithFormat:@"%@_name", connectionKey]];
                connection.connectionId = [connectionResponse objectId];
                
                
                
                
                PFQuery *getMessages = [PFQuery queryWithClassName:@"ConnectionMessage"];
                
                [getMessages whereKey:@"connection_id" equalTo:[connectionResponse objectId]];
                [getMessages whereKey:@"message_for" equalTo:currentUUID];
                
                UIImage *messageImage = [[UIImage alloc] init];
                
                NSArray *messageArray = [[NSArray alloc] initWithArray:[getMessages findObjects]];
                for (PFObject *connectionMessage in messageArray) {
                    PFFile *imageFile = [connectionResponse objectForKey:@"image_message"];
                    
                    ConnectionMessageData *message = [[ConnectionMessageData alloc] init];
                    message.imageMessage = [UIImage imageWithData:[imageFile getData]];
                    message.messageId = [connectionMessage objectId];
                    
                    [messagesListArray addObject:message];
                }
                
//                [getMessages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                    if (!error) {
//                        for (PFObject *connectionMessage in objects) {
//                            ConnectionMessageData *message = [[ConnectionMessageData alloc] init];
//                            
//                            message.imageMessage = [connectionMessage objectForKey:@"imageMessage"];
//                            message.messageId = [connectionMessage objectId];
//                            
//                            [messagesListArray addObject:message];
//                            
//                            [NSKeyedArchiver archiveRootObject:messagesListArray
//                                                        toFile:[NSTemporaryDirectory() stringByAppendingPathComponent:@"Messages.cache"]];
//                            
//                            if ([self.delegate respondsToSelector:@selector(updateConnections:)])
//                                [self.delegate updateConnectionMessages:messagesListArray];
//                        }
//                        
//                    } else {
//                        NSLog(@"ERROR!! *****");
//                    }
//
//                }];
                
                connection.messagesArray = messagesListArray;
                [cachedConnectionsListArray addObject:connection];
            }
//            [NSKeyedArchiver archiveRootObject:cachedConnectionsListArray
//                                        toFile:[NSTemporaryDirectory() stringByAppendingPathComponent:@"Connections.cache"]];
            if ([self.delegate respondsToSelector:@selector(updateConnections:)])
                [self.delegate updateConnections:cachedConnectionsListArray];
        }
    }];
    [spinner hide:YES];
}





// WE SHOULD PULL CACHE AND MAKE QUERY IN BACKGROUND AND THEN COMPARE RESULTS TO SEE IF WE NEED TO UPDATE
- (void)fetchConnectionsList:(UIView*)currentView {
    __block BOOL cacheValueExists = NO;
    __block BOOL checkedCacheCycle = NO;
    
    PFQuery *getConnectionsList = [PFQuery queryWithClassName:@"Connection"];
    
    // Query Cache Policy checks cache first then network.
    // Point of this is because cache is quicker but might not be up to date so need to compare with server response
    getConnectionsList.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    
    NSString *currentUUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
    [getConnectionsList whereKey:@"user_uuid" equalTo:currentUUID];
    
    NSLog(@"Looking for Connections with UUID: %@", currentUUID);
    
    NSMutableArray *cachedConnectionsListArray = [[NSMutableArray alloc] init];
    NSMutableArray *networkConnectionsListArray = [[NSMutableArray alloc] init];
    
    MBProgressHUD *spinner = [MBProgressHUD showHUDAddedTo:currentView animated:YES];
    spinner.mode = MBProgressHUDModeIndeterminate;
    spinner.labelText = @"Uploading";
    [spinner show:YES];
    
    
    __block BOOL cachedResponseExists = [getConnectionsList hasCachedResult];
    NSLog(@"CACHED RESPONSE??? %@", cachedResponseExists ? @"YES" : @"NO");
//    [getConnectionsList clearCachedResult];
    
    
    NSLog(@"ABOUT TO DISPATCH BACKGROUD PROCESS FOR GETTING LIST OF CONNECTIONS *****");
    
    [getConnectionsList findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (!checkedCacheCycle) {
                checkedCacheCycle = YES;
                if (cachedResponseExists) {
                    // Loading Cached Objects
                    if (objects.count > 0) {
                        for (PFObject *connectionResponse in objects) {
                            ConnectionData *connection = [[ConnectionData alloc] init];
                            connection.connectionName = [connectionResponse objectForKey:@"connection_name"];
                            connection.connectionUUID = [connectionResponse objectForKey:@"connection_uuid"];
                            
                            // Grab stored image path to get cached image
                            NSString *cachedImagePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"image_message"];
                            UIImage *cachedImage = [UIImage imageWithContentsOfFile:cachedImagePath];
                            
                            NSLog(@"CACHED IMAGE PATH: %@ *****", cachedImagePath);
                            
                            // Cached query has an image
                            if ([connectionResponse objectForKey:@"image_message"]) {
                                
                                if (cachedImage) {
                                    // No need to update this row from network
                                    NSLog(@"FOUND CACHED IMAGE *****");
//                                    connection.imageMessages = cachedImage;
//                                    cacheValueExists = YES;
                                } else {
                                    // We dissmissed an image or deleted a row
                                    // Row already looks updated because we do that on dismiss or delete
                                    
                                    // Don't need to check network for this 1 row because query with correct so there's no imageMessage
                                }
                            } else {
                                if (cachedImage) {
                                    NSLog(@"This should never happen!!!");
                                    #warning @"Should put analytics here to check this never happens."
                                } else {
                                    // Possible this is correct but still need to check network.
                                    
                                    // Ok with the quick delay if there is a new message??
                                    // SLOW SPOT
                                    cacheValueExists = NO;
                                }
                            }
                            
                            
//                            // This means that this row is up to date (Not a dissmiss or delete) ***
//                            if (cachedImage && connection.imageMessage) {
//                                NSLog(@"FOUND CACHED IMAGE *****");
//                                connection.imageMessage = cachedImage;
//                                cacheValueExists = YES;
//                            } else {
//                                // Image has been deleted so this is an update
//                                
//                                NSLog(@"Need to move on");
//                            }
                            
                            [cachedConnectionsListArray addObject:connection];
                        }
                        
                        NSLog(@"ABOUT TO DISPATCH BACKGROUND PROCESS FOR UPDATING CONNECTIONS LIST *****");
                        
    //                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
    //                                                             (unsigned long)NULL), ^(void) {
                        
                        // There was something in the cache so lets load the table while we check if any new entries
                            if ([self.delegate respondsToSelector:@selector(updateConnections:)])
                                [self.delegate updateConnections:cachedConnectionsListArray];
    //                    });
                        
                        
                    }
                }
//            } else if (objects.count != cachedConnectionsListArray.count) {
            } else if (!cacheValueExists){ //if ( objects.count != cachedConnectionsListArray.count) {
                
                NSLog(@"SECOND TIME AROUND RESPONSE FROM SERVER *****");
                
                if (objects.count > 0) {
                    for (PFObject *connectionResponse in objects) {
                        ConnectionData *connection = [[ConnectionData alloc] init];
//                        connection.connectionObjectId = connectionResponse.objectId;
                        connection.connectionName = [connectionResponse objectForKey:@"connection_name"];
                        connection.connectionUUID = [connectionResponse objectForKey:@"connection_uuid"];
                        
                        // Grab stored image path to get cached image
//                        NSString *cachedImagePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"image_message"];
//                        UIImage *cachedImage = [UIImage imageWithContentsOfFile:cachedImagePath];
                        
                        if (NO) {
//                            connection.imageMessage = cachedImage;
                        } else {
                            // This throws a Parse warning because it's synchronous
                            // Think this is ok since files are smaller but should look into for videos
                            PFFile *imageFile = [connectionResponse objectForKey:@"image_message"];
//                            connection.imageMessages = [UIImage imageWithData:[imageFile getData]];
                        }
                        
                        if (connection.messagesArray) {
                            // Store locally in documents directory
                            // NOTE: MAY NOT EXIST. POSSIBLE SUGGESSTED ALTERNATIVE: NSFILEMANAGER
                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                            NSString *documentsDirectory = [paths objectAtIndex:0];
                            
                            NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", connection.connectionUUID]];
                            
                            NSLog((@"pre writing to file"));
                            
//                            if (![UIImageJPEGRepresentation(connection.imageMessages, .8) writeToFile:imagePath atomically:NO])
                            if (YES)
                            {
                                NSLog((@"Failed to cache image data to disk"));
                            }
                            else
                            {
                                // Save Path To Cache
                                [[NSUserDefaults standardUserDefaults] setObject:imagePath forKey:@"image_message"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                                NSLog(@"the cachedImagedPath is %@",imagePath);
                            }
                        }
                        
                        [networkConnectionsListArray addObject:connection];
                    }
                    
                    if (NO) {
//                    if (![self changedList:networkConnectionsListArray currentList:cachedConnectionsListArray]) {
                        // Do Nothing. List is up to date
                        NSLog(@"Do Nothing. List is up to date");
                    } else {
                        // List is different now so use fetched from network list
                        if ([self.delegate respondsToSelector:@selector(updateConnections:)])
                            [self.delegate updateConnections:networkConnectionsListArray];
                    }

                }
                
                NSLog(@"BASCIALLY DONE UPDATING CONNECTIONS *****");
                
            }
//            NSLog(@"Successfully retrieved: %@", objects);
//            
//            if (objects.count > 0) {
//                for (PFObject *connectionResponse in objects) {
//                    ConnectionData *connection = [[ConnectionData alloc] init];
//                    connection.connectionName = [connectionResponse objectForKey:@"connection_name"];
//                    connection.connectionUUID = [connectionResponse objectForKey:@"connection_uuid"];
//                    PFFile *imageFile = [connectionResponse objectForKey:@"image_message"];
//                    
//                    connection.imageMessage = [UIImage imageWithData:[imageFile getData]];
            
                    // This is running in background while process moves on to add connection
//                    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//                        if (!error) {
//                            connection.imageMessage = [UIImage imageWithData:data];
//                        }
//                    } progressBlock:^(int percentDone) {
//                        // Update Spinner. percentDone <> 0, 100
//                    }];
                    
//                    PFFile *videoFile = [connectionResponse objectForKey:@"image_message"];
//                    [videoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//                        if (!error) {
//                            connection.videoMessage = [UIImage imageWithData:data];
//                        }
//                    }];
                    
//                    [connectionsListArray addObject:connection];
//                }
            
//                if ([self.delegate respondsToSelector:@selector(dataRetrieved)])
//                    [self.delegate dataRetrieved];
            
//            } else {
//                // What???
//                NSLog(@"*** NO CONNECTIONS?? ***");
//            }
        } else {
            NSString *networkError = [[error userInfo] objectForKey:@"error"];
            NSLog(@"Error: %@", networkError);
            checkedCacheCycle = YES;
        }
    }];
    [spinner hide:YES];
//    return connectionsListArray;
}

- (void)uploadImageMessage:(NSData*)imageData parseConnectionObject:(NSString*)objectId {
    PFFile *imageFile = [PFFile fileWithName:@"image.jpg" data:imageData];
    
    NSLog(@"SAVING NEW IMAGE IN BACKGROUND *****");
    [imageFile saveInBackground];
    
    PFObject *currentConnection = [PFObject objectWithoutDataWithClassName:@"Connection" objectId:objectId];
    [currentConnection setValue:imageFile forKey:@"image_message"];
    
    NSLog(@"SENDING IMAGE MESSAGE TO CONNECTION IN BACKGROUND ***** ");
    [currentConnection saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Successfully Updated!");
        } else {
            NSLog(@"Error Updating Entry: %@ %@", error, [error userInfo]);
        }
    }];
}

- (BOOL)uploadMessage:(NSData *)imageData connection:(ConnectionData *)currentConnection forView:(UIView*)currentView {
    __block BOOL uploadSuccess = YES;
    
    // Create Parse Image File
    PFFile *imageFile = [PFFile fileWithName:@"image.jpg" data:imageData];
    [imageFile saveInBackground];
    
    MBProgressHUD *spinner = [MBProgressHUD showHUDAddedTo:currentView animated:YES];
    spinner.mode = MBProgressHUDModeIndeterminate;
    spinner.labelText = @"Uploading";
    [spinner show:YES];
    
    PFObject *newMessage = [PFObject objectWithClassName:@"ConnectionMessage"];
    [newMessage setValue:currentConnection.connectionId forKey:@"connection_id"];
    [newMessage setValue:currentConnection.connectionUUID forKey:@"message_for"];
    [newMessage setValue:imageFile forKey:@"image_message"];
    
    [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"SUCCESSFULLY SENT MESSAGE TO %@, TIED TO CONNECTION ID: %@", currentConnection.connectionName, currentConnection.connectionId);
        } else {
            NSLog(@"Error Updating Entry: %@ %@", error, [error userInfo]);
        }
    }];
    
    
    
    
    
    
    
//    PFQuery *query = [PFQuery queryWithClassName:@"ConnectionMessage"];
////    [query whereKey:@"user_uuid" equalTo:currentConnectionUUID];
//    
//    #warning @"Store current user uuid in delegate for global use."
//    // Maybe can globally keep currentUserUUID
////    [query whereKey:@"connection_uuid" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"]];
//    
//    // Can probably combine this with the whole thing
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            PFObject *foundConnection = [objects objectAtIndex:0];
//            
//            if (foundConnection != nil) {
//                [foundConnection setValue:imageFile forKey:@"image_message"];
//                
//                [foundConnection saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                    if (!error) {
//                        NSLog(@"Successfully Updated!");
//                    } else {
//                        uploadSuccess = NO;
//                        NSLog(@"Error Updating Entry: %@ %@", error, [error userInfo]);
//                    }
//                }];
//            }
//            
//        }
//        else {
//            uploadSuccess = NO;
//            NSLog(@"Error Finding Entry: %@ %@", error, [error userInfo]);
//        }
//    }];
    
    [spinner hide:YES];
    return uploadSuccess;
}

- (BOOL)uploadVideoMessage:(NSData *)imageData recieverUUID:(NSString *)currentConnectionUUID forView:(UIView*)currentView {
    __block BOOL uploadSuccess = YES;
    
    // Create Parse Image File
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    MBProgressHUD *spinner = [MBProgressHUD showHUDAddedTo:currentView animated:YES];
    spinner.mode = MBProgressHUDModeIndeterminate;
    spinner.labelText = @"Uploading";
    [spinner show:YES];
    
#warning @"Can we combine save in background for PFFile and PFObject? Seems Redundant."
    // Try to Save Image
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Set Table Name and Params To Query
            PFObject *userVideo = [PFObject objectWithClassName:@"Connection"];
            [userVideo setObject:imageFile forKey:@"video_message"];
            
            // Save Image To Parse
            [userVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"Image Saved Successfully!");
                    
                    PFQuery *query = [PFQuery queryWithClassName:@"Connection"];
                    [query whereKey:@"user_uuid" equalTo:currentConnectionUUID];
                    
#warning @"Store current user uuid in delegate for global use."
                    // Maybe can globally keep currentUserUUID
                    [query whereKey:@"connection_uuid" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"]];
                    
                    // Can probably combine this with the whole thing
                    // Update the returned Connection object with { has_pending_connection: YES }
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            PFObject *foundConnection = [objects objectAtIndex:0];
                            
                            // Parse BOOL columns use numbers for values
                            [foundConnection setValue:userVideo forKey:@"video_message"];
                            
                            [foundConnection saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (!error) {
                                    NSLog(@"Successfully Updated!");
                                } else {
                                    uploadSuccess = NO;
                                    NSLog(@"Error Updating Entry: %@ %@", error, [error userInfo]);
                                }
                            }];
                            
                        }
                        else {
                            uploadSuccess = NO;
                            NSLog(@"Error Finding Entry: %@ %@", error, [error userInfo]);
                        }
                    }];
                    //                        PFObject *object = [query get];
                    //                        [query setValue:[NSNumber numberWithBool:YES] forKey:@"has_pending_connection"];
                }
                else {
                    uploadSuccess = NO;
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else {
            uploadSuccess = NO;
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    [spinner hide:YES];
    return uploadSuccess;
}

- (void)deleteImageMessage:(NSString*)connection_uuid {
    #warning @"Store Object ID From Results To Make Query More Eficient."
    
    PFQuery *query = [PFQuery queryWithClassName:@"Connection"];
    [query whereKey:@"connection_uuid" equalTo:connection_uuid];
    [query whereKey:@"user_uuid" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            [object removeObjectForKey:@"image_message"];
            [object saveInBackground];
        } else {
            NSLog(@"Error Finding Entry: %@ %@", error, [error userInfo]);
        }
    }];
}

@end