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

- (BOOL)checkIfUserExists:(NSString *)UUID {
    __block BOOL savedSuccessfully = YES;
    
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
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"messageIdsArray"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
    
    // Grabbed cached messaged IDs. Will be used to in query to make sure I don't grab these IDs because I have them already
    NSMutableArray *cachedMessagesIds = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"messageIdsArray"]];
    
    // Find all messages that were sent to me (message_fornbdefines this) but exclude the IDs that I already have.
    PFQuery *getMessageIds = [PFQuery queryWithClassName:@"ConnectionMessage"];
    [getMessageIds whereKey:@"message_for" equalTo:uuid];
    [getMessageIds whereKey:@"objectId" notContainedIn:cachedMessagesIds];
    
    [getMessageIds findObjectsInBackgroundWithBlock:^(NSArray *messageObjects, NSError *error) {
        if (!error) {
            if ([messageObjects count] > 0) {
                NSMutableArray *foundMessageIds = [[NSMutableArray alloc] init];
                NSMutableArray *messagesListArray = [[NSMutableArray alloc] init];
                
                for (PFObject *messageObject in messageObjects) {
                    // Keep track of the new message IDs. Looking at this now I guess I could just add to the existing cachedMessagesIds Array but will refactor later.
                    [foundMessageIds addObject:[messageObject objectId]];
                    
                    // The following creates a local Message Object with the values fetched from the DB
                    ConnectionMessageData *connectionMessage = [[ConnectionMessageData alloc] init];
                    connectionMessage.messageId = [messageObject objectId];
                    connectionMessage.connectionId = [messageObject valueForKey:@"connection_id"];
                    
                    // Only way to get an image from Parse. Can't directly grab it like other values
                    PFFile *imageFile = [messageObject objectForKey:@"image_message"];
                    UIImage *messageImage = [UIImage imageWithData:[imageFile getData]];
                    
                    // This was the major memory issue. Can't store an image as binary data liek I was doing so I store it in a directory on the phone and then store that unique string path in my Message Object
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", connectionMessage.messageId]];
                    [UIImageJPEGRepresentation(messageImage, .8) writeToFile:imagePath atomically:NO];
                    connectionMessage.imageMessageLocation = imagePath;
                    
                    [messagesListArray addObject:connectionMessage];
                }
                // This is where I think I can just add each Message Object ID to the cached list in the for loop
                [cachedMessagesIds addObjectsFromArray:foundMessageIds];
                [[NSUserDefaults standardUserDefaults] setObject:cachedMessagesIds forKey:@"messageIdsArray"];
                
                // Calls RouletteTestingMasterViewController.updateMessages
                // Because this is a background method, I needed to make a delegate method to notify when the background process has finished to update the UI.
                if ([self.delegate respondsToSelector:@selector(updateMessages:)])
                    [self.delegate updateMessages:messagesListArray];
            }
        }
        else {
            NSLog(@"ERROR FETCHING OBJECTS *****");
        }
        
        if ([self.delegate respondsToSelector:@selector(endRefresh)])
            [self.delegate endRefresh];
        
    }];
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
                    
//                    [object setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%@_has_messages", currentConnection.connectionNumber]];
                    
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
    PFQuery *query = [PFQuery queryWithClassName:@"ConnectionMessage"];
    
    [query getObjectInBackgroundWithId:message_id block:^(PFObject *object, NSError *error) {
        if (!error) {
            [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"SUCCESSFULLY DELETED MESSAGE");
                    NSMutableArray *cachedMessagesIds = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"messageIdsArray"]];
                    
                    [cachedMessagesIds removeObject:message_id];
                    
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