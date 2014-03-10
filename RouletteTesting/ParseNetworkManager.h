//
//  ParseNetworkManager.h
//  RouletteTesting
//
//  Created by Michael Parris on 2/26/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "ConnectionData.h"

// Make part of singleton class!

@protocol ParseManagerProtocol <NSObject>
@required
- (void)updateConnections:(NSMutableArray*)cachedConnectionList;
- (void)updateConnectionMessages:(NSMutableArray *)messageList;
//- (void)loadCachedConnectionList:(NSMutableArray*)cachedConnectionList;
//- (void)dataRetrieved:(NSMutableArray*)cachedConnectionList;
@end


@interface ParseNetworkManager : NSObject {
//    id<ParseManagerProtocol> delegate;
}

+ (void)establishConnection;

- (BOOL)changedList:(NSMutableArray *)newConnections currentList:(NSMutableArray *)oldConnections;

- (BOOL)checkIfUserExists:(NSString*)UUID;
- (BOOL)authenticateUser:(NSString*)UUID;

- (void)fetchConnectionsList:(UIView*)currentView;
- (void)getConnections:(UIView*)currentView;
- (NSString*)fetchConnectionObjectId:(NSString*)currentUserUUID currentConnectionUUID:(NSString*)connectionUUID;

- (BOOL)uploadMessage:(NSData*)imageData connection:(ConnectionData *)currentConnection forView:(UIView*)currentView;
- (void)uploadImageMessage:(NSData*)imageData parseConnectionObject:(NSString*)objectId;
- (BOOL)uploadVideoMessage:(NSData*)imageData recieverUUID:(NSString*)currentConnectionUUID forView:(UIView*)currentView;

- (void)deleteImageMessage:(NSString*)connection_uuid;

@property (nonatomic, strong) id<ParseManagerProtocol> delegate;

@end
