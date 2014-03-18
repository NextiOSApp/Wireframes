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
#import "RouletteTestingMasterViewController.h"

@implementation ParseNetworkManager

+ (void)establishConnection {
    [Parse setApplicationId:@"DDcRvrl0DybiPV3VyTJpTMpvFrOYrUCCTlf5glgX" clientKey:@"31cjkmYUxviwxVh8OO7JTY3Jku3VnMvZ9wnKm51u"];
}

+ (void)fetchNewConnectionsWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // Need to either figure out how to grab an instance of that view or could just make a call to cache the new results
    //    [self getConnections:(RouletteTestingMasterViewController *)]
    completionHandler(UIBackgroundFetchResultNewData);
}

- (BOOL)checkIfUserExists:(NSString *)UUID {
    __block BOOL savedSuccessfully = YES;
    
    // Check if user exists. If not, save as new user with device's UUID

    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"uuid" equalTo:UUID];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (!error) {
            if (users == nil || [users count] == 0) {
                PFObject *user = [PFObject objectWithClassName:@"User"];
                [user setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"] forKey:@"uuid"];
            
                [user saveEventually:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Successfully Saved New User");
                        
                    } else {
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

- (void)getConnections:(UIView*)currentView {
    __block BOOL isCacheCycle = YES;
    __block NSInteger rowCounter = 0;
    __block NSString *connectionKey = nil;
    __block NSString *myKey = nil;
    
    NSString *currentUUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"connection1_id = %@ OR connection2_id = %@", currentUUID, currentUUID];
    
    PFQuery *getConnectionsList = [PFQuery queryWithClassName:@"Connection" predicate:predicate];
    getConnectionsList.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    NSMutableArray *cachedConnectionsListArray = [[NSMutableArray alloc] init];
    NSMutableArray *messagesListArray = [[NSMutableArray alloc] init];
    
    MBProgressHUD *spinner = [MBProgressHUD showHUDAddedTo:currentView animated:YES];
    spinner.mode = MBProgressHUDModeIndeterminate;
    spinner.labelText = @"Uploading";
    [spinner show:YES];
    
    __block BOOL cachedResponseExists = [getConnectionsList hasCachedResult];
    NSLog(@"CACHED RESPONSE??? %@", cachedResponseExists ? @"YES" : @"NO");
    //    [getConnectionsList clearCachedResult];
    
    NSLog(@"ABOUT TO DISPATCH BACKGROUD PROCESS FOR GETTING LIST OF CONNECTIONS *****");
    
    // If there is no cached query then we go straight to the network method
    if (!cachedResponseExists) {
        isCacheCycle = NO;
    }
    
    [getConnectionsList findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            rowCounter = 0;
            if (isCacheCycle) {
                isCacheCycle = NO;
                
                for (PFObject *connectionResponse in objects) {
                    ConnectionData *connection = [[ConnectionData alloc] init];
                    
                    if ([currentUUID isEqualToString:[connectionResponse objectForKey:@"connection1_id"]]) {
                        connectionKey = @"connection2";
                        myKey = @"connection1";
                    } else {
                        connectionKey = @"connection1";
                        myKey = @"connection2";
                    }
                    
                    connection.connectionUUID = [connectionResponse objectForKey:[NSString stringWithFormat:@"%@_id", connectionKey]];
                    connection.connectionName = [connectionResponse objectForKey:[NSString stringWithFormat:@"%@_name", connectionKey]];
                    connection.connectionId = [connectionResponse objectId];
                    connection.connectionNumber = connectionKey;
                    connection.myNumber = myKey;
                    connection.hasMessages = [[connectionResponse objectForKey:[NSString stringWithFormat:@"%@_has_messages", myKey]] boolValue];
                    connection.rowNumber = rowCounter;
                    
                    PFQuery *getMessages = [PFQuery queryWithClassName:@"ConnectionMessage"];
                    getMessages.cachePolicy = kPFCachePolicyCacheOnly;
                    [getMessages whereKey:@"connection_id" equalTo:[connectionResponse objectId]];
                    [getMessages whereKey:@"message_for" equalTo:currentUUID];
                    
                    NSArray *messageArray = [[NSArray alloc] initWithArray:[getMessages findObjects]];
                    for (PFObject *connectionMessage in messageArray) {
                        ConnectionMessageData *message = [[ConnectionMessageData alloc] init];
                        PFFile *imageFile = [connectionMessage objectForKey:@"image_message"];
                        if (imageFile) {
                            message.imageMessage = [UIImage imageWithData:[imageFile getData]];
                        } else {
                            imageFile = [connectionMessage objectForKey:@"image_message"];
                        }
                        
                        message.messageId = [connectionMessage objectId];
                        [messagesListArray addObject:message];
                    }
                    
                    connection.messagesArray = messagesListArray;
                    [cachedConnectionsListArray addObject:connection];
                }
                rowCounter++;

                if ([self.delegate respondsToSelector:@selector(updateConnections:)])
                    [self.delegate updateConnections:cachedConnectionsListArray];
                
            }
            else {
                [cachedConnectionsListArray removeAllObjects];
                
                for (PFObject *connectionResponse in objects) {
                    ConnectionData *connection = [[ConnectionData alloc] init];
                    
                    if ([currentUUID isEqualToString:[connectionResponse objectForKey:@"connection1_id"]]) {
                        connectionKey = @"connection2";
                        myKey = @"connection1";
                    } else {
                        connectionKey = @"connection1";
                        myKey = @"connection2";
                    }
                    
                    connection.connectionUUID = [connectionResponse objectForKey:[NSString stringWithFormat:@"%@_id", connectionKey]];
                    connection.connectionName = [connectionResponse objectForKey:[NSString stringWithFormat:@"%@_name", connectionKey]];
                    connection.connectionId = [connectionResponse objectId];
                    connection.connectionNumber = connectionKey;
                    connection.myNumber = myKey;
                    connection.hasMessages = [[connectionResponse objectForKey:[NSString stringWithFormat:@"%@_has_messages", myKey]] boolValue];
                    connection.rowNumber = rowCounter;
                    
                    // No reason to fetch messages if there are no messages for the connection
                    if (connection.hasMessages) {
                        PFQuery *getMessages = [PFQuery queryWithClassName:@"ConnectionMessage"];
                        getMessages.cachePolicy = kPFCachePolicyNetworkOnly;
                        
                        [getMessages whereKey:@"connection_id" equalTo:[connectionResponse objectId]];
                        [getMessages whereKey:@"message_for" equalTo:currentUUID];
                        
                        [getMessages findObjectsInBackgroundWithBlock:^(NSArray *messageArray, NSError *error) {
                            if (!error) {
                                for (PFObject *connectionMessage in messageArray) {
                                    PFFile *imageFile = [connectionMessage objectForKey:@"image_message"];
                                    
                                    ConnectionMessageData *message = [[ConnectionMessageData alloc] init];
                                    message.imageMessage = [UIImage imageWithData:[imageFile getData]];
                                    message.messageId = [connectionMessage objectId];
                                    
                                    [messagesListArray addObject:message];
                                }
                                
                                connection.messagesArray = messagesListArray;
                                
                                if ([self.delegate respondsToSelector:@selector(updateConnection:)])
                                    [self.delegate updateConnection:connection];
                            }
                            else {
                                NSLog(@"ERRORRRR *****");
                            }
                        }];
                        
                    }
                    
                    connection.messagesArray = messagesListArray;
                    [cachedConnectionsListArray addObject:connection];
                    
                }
                rowCounter++;

                if ([self.delegate respondsToSelector:@selector(updateConnections:)])
                    [self.delegate updateConnections:cachedConnectionsListArray];
            }
        }
    }];
    [spinner hide:YES];
}




#warning @"IGNORE FOR NOW. NOT USING THIS AT THE MOMENT BUT THIS HAS ELEMENTS OF A DIFFERENT CACHING METHOD WE MAY WANT TO USE."
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

- (BOOL)uploadMessage:(NSData *)imageData connection:(ConnectionData *)currentConnection forView:(UIView*)currentView {
    __block BOOL uploadSuccess = YES;
    
    PFFile *imageFile = [PFFile fileWithName:@"image.jpg" data:imageData];
    
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
            
            // Update Boolean value on Connection object if there are currently no messages
            // Point of this is to help determine when we need to actually query the ConnectionMessage table in getConnections call
            if (!currentConnection.hasMessages) {
                PFQuery *getCurrentConnection = [PFQuery queryWithClassName:@"Connection"];
                
                [getCurrentConnection getObjectInBackgroundWithId:currentConnection.connectionId block:^(PFObject *object, NSError *error) {
                    
                    [object setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%@_has_messages", currentConnection.connectionNumber]];
                    
                    [object saveInBackground];
                }];
            }

        } else {
            NSLog(@"Error Updating Entry: %@ %@", error, [error userInfo]);
        }
    }];
    
    [spinner hide:YES];
    return uploadSuccess;
}

- (BOOL)uploadVideoMessage:(NSData *)imageData recieverUUID:(NSString *)currentConnectionUUID forView:(UIView*)currentView {
    __block BOOL uploadSuccess = YES;
    
    return uploadSuccess;
}

- (void)deleteImageMessage:(NSString*)message_id {
    #warning @"Store Object ID From Results To Make Query More Eficient."
    
    PFQuery *query = [PFQuery queryWithClassName:@"ConnectionMessage"];
    
    [query getObjectInBackgroundWithId:message_id block:^(PFObject *object, NSError *error) {
        if (!error) {
            [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"SUCCESSFULLY DELETED MESSAGE");
                } else {
                    NSLog(@"Error Deleting Entry: %@ %@", error, [error userInfo]);
                }
            }];
        } else {
            NSLog(@"Error Finding Entry: %@ %@", error, [error userInfo]);
        }
    }];
}

@end