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

@protocol ParseManagerProtocol <NSObject>
@required
- (void)updateConnections:(NSMutableArray*)cachedConnectionList;
- (void)updateConnection:(ConnectionData*)connection;
@end


@interface ParseNetworkManager : NSObject {
}

+ (void)establishConnection;

+ (void)fetchNewConnectionsWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

- (BOOL)checkIfUserExists:(NSString*)UUID;

- (void)fetchConnectionsList:(UIView*)currentView;
- (void)getConnections:(UIView*)currentView;

- (BOOL)uploadMessage:(NSData*)imageData connection:(ConnectionData *)currentConnection forView:(UIView*)currentView;
- (BOOL)uploadVideoMessage:(NSData*)imageData recieverUUID:(NSString*)currentConnectionUUID forView:(UIView*)currentView;

- (void)deleteImageMessage:(NSString*)connection_uuid;

@property (nonatomic, strong) id<ParseManagerProtocol> delegate;

@end
