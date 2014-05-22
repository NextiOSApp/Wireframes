//
//  ParseManager.h
//  Next
//
//  Created by Michael Parris on 5/22/14.
//  Copyright (c) 2014 CAV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@protocol ParseManagerProtocol <NSObject>

@optional
- (void)updateFriends:(NSArray*)foundFriends;
- (void)resetView;
@end

@interface ParseManager : NSObject

- (void)getFriendsWithFilter:(NSString*)filterFriendsBy;
- (BOOL)isCacheOutOfDate:(NSArray*)objectsFromCache networkObjects:(NSArray*)objectsFromNetwork;
- (void)removeFriend:(PFUser*)user;
- (void)addFriend:(PFUser*)user;
- (void)uploadFile:(NSData*)fileData withFileName:(NSString*)fileName withFileType:(NSString*)fileType withRecipients:(NSArray*)recipients;

@property (nonatomic, strong) id<ParseManagerProtocol> delegate;

@end
