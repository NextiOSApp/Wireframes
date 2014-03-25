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
    NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];

    NSMutableArray *cachedMessagesIds = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"messageIdsArray"]];
    
    PFQuery *getMessageIds = [PFQuery queryWithClassName:@"ConnectionMessage"];
    [getMessageIds whereKey:@"message_for" equalTo:uuid];
    [getMessageIds whereKey:@"objectId" notContainedIn:cachedMessagesIds];
    
    [getMessageIds findObjectsInBackgroundWithBlock:^(NSArray *messageObjects, NSError *error) {
        if (!error) {
            if ([messageObjects count] > 0) {
                NSMutableArray *foundMessageIds = [[NSMutableArray alloc] init];
                NSMutableArray *messagesListArray = [[NSMutableArray alloc] init];
                
                for (PFObject *messageObject in messageObjects) {
                    [foundMessageIds addObject:[messageObject objectId]];

                    ConnectionMessageData *connectionMessage = [[ConnectionMessageData alloc] init];
                    
                    PFFile *imageFile = [messageObject objectForKey:@"image_message"];
                    connectionMessage.imageMessage = [UIImage imageWithData:[imageFile getData]];
                    connectionMessage.messageId = [messageObject objectId];
                    connectionMessage.connectionId = [messageObject valueForKey:@"connection_id"];
                    
                    [messagesListArray addObject:connectionMessage];
                }
                
                [cachedMessagesIds addObjectsFromArray:foundMessageIds];
                [[NSUserDefaults standardUserDefaults] setObject:cachedMessagesIds forKey:@"messageIdsArray"];
                
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