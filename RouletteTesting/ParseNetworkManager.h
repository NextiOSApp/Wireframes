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
- (void)updateMessages:(NSMutableArray *)messages;
- (void)endRefresh;
@end


@interface ParseNetworkManager : NSObject {
}

+ (void)establishConnection;

- (BOOL)checkIfUserExists:(NSString*)UUID;

- (void)getConnections:(UIView*)currentView;

- (BOOL)uploadMessage:(NSData*)imageData connection:(ConnectionData *)currentConnection forView:(UIView*)currentView;
- (BOOL)uploadVideoMessage:(NSData*)imageData recieverUUID:(NSString*)currentConnectionUUID forView:(UIView*)currentView;

- (void)deleteImageMessage:(NSString*)connection_uuid;

@property (nonatomic, strong) id<ParseManagerProtocol> delegate;

@end
