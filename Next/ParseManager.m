//
//  ParseManager.m
//  Next
//
//  Created by Michael Parris on 5/22/14.
//  Copyright (c) 2014 CAV. All rights reserved.
//

#import "ParseManager.h"

@implementation ParseManager

- (void)getFriendsWithFilter:(NSString*)filterFriendsBy {
    __block BOOL isCheckCacheRound = YES;
    __block NSArray *cachedFriends = [[NSArray alloc] init];
    PFQuery *query = nil;
    
    if ([filterFriendsBy isEqualToString:@"All"]) {
        query = [PFUser query];
    }
    else {
        PFRelation *friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
        query = [friendsRelation query];
    }
    
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query orderByAscending:@"username"];
    BOOL cacheExists = [query hasCachedResult];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
            isCheckCacheRound = NO;
        }
        else {
            if (isCheckCacheRound) {
                NSLog(@"** CACHE ROUND ** %d Friends Found!", [objects count]);
                cachedFriends = objects;
                isCheckCacheRound = NO;
            } else {
                NSLog(@"** NETWORK ROUND ** %d Friends Found!", [objects count]);
                if (cacheExists && ![self isCacheOutOfDate:cachedFriends networkObjects:objects]) {
                    NSLog(@"** CACHE UP TO DATE. NO NEED TO REFRESH VIEW **");
                    return;
                }
            }
            if ([self.delegate respondsToSelector:@selector(updateFriends:)])
                [self.delegate updateFriends:objects];
        }
    }];
}

- (BOOL)isCacheOutOfDate:(NSArray*)objectsFromCache networkObjects:(NSArray*)objectsFromNetwork {
    NSArray *cachedObjectIds = [[NSArray alloc] initWithArray:[objectsFromCache valueForKey:@"objectId"]];
    NSArray *networkObjectIds = [[NSArray alloc] initWithArray:[objectsFromNetwork valueForKey:@"objectId"]];
    
    for (NSString *objectId in cachedObjectIds) {
        if (![networkObjectIds containsObject:objectId])
            return YES;
    }
    
    return NO;
}

- (void)removeFriend:(PFUser*)user {
    PFRelation *friendsRelation = [[PFUser currentUser] relationForKey:@"friendsRelation"];
    [friendsRelation removeObject:user];
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"%@, %@",error, [error userInfo]);
        }
    }];
}

- (void)addFriend:(PFUser*)user {
    PFRelation *friendsRelation = [[PFUser currentUser] relationForKey:@"friendsRelation"];
    [friendsRelation addObject:user];
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"%@, %@",error, [error userInfo]);
        }
    }];
}

- (void)uploadFile:(NSData*)fileData withFileName:(NSString*)fileName withFileType:(NSString*)fileType withRecipients:(NSArray*)recipients {
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                message:@"Please try sending your message again."
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        else {
            PFObject *message = [PFObject objectWithClassName:@"Messages"];
            [message setObject:file forKey:@"file"];
            [message setObject:fileType forKey:@"fileType"];
            [message setObject:recipients forKey:@"recipientIds"];
            [message setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
            [message setObject:[[PFUser currentUser] username] forKey:@"senderName"];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                        message:@"Please try sending your message again."
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
                else {
                    // Everything was successful!
                    if ([self.delegate respondsToSelector:@selector(resetView)])
                        [self.delegate resetView];
                }
            }];
        }
    }];
}


@end
