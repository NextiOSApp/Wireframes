//
//  ConnectionData.h
//  RouletteTesting
//
//  Created by Michael Parris on 2/10/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConnectionMessageData.h"

@interface ConnectionData : NSObject<NSCoding>

@property (nonatomic) NSString *connectionName;
@property (nonatomic) NSString *connectionUUID;
@property (nonatomic) NSString *connectionId;
@property (nonatomic) NSString *connectionNumber;
@property (nonatomic) NSString *myNumber;
@property (nonatomic) BOOL hasMessages;
@property (nonatomic) NSInteger rowNumber;

@property (nonatomic) NSArray *messagesArray;

@end
