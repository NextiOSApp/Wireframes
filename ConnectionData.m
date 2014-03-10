//
//  ConnectionData.m
//  RouletteTesting
//
//  Created by Michael Parris on 2/10/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import "ConnectionData.h"

@implementation ConnectionData

- (id)initWithCoder:(NSCoder *)coder {
    if(self = [super init]) {
        self.connectionName = [coder decodeObjectForKey:@"connectionName"];
        self.connectionUUID = [coder decodeObjectForKey:@"connectionUUID"];
        self.connectionId = [coder decodeObjectForKey:@"connectionId"];
        self.messagesArray = [coder decodeObjectForKey:@"messagesArray"];
        
        return self;
    }
    return nil;
}

- (void) encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject:_connectionName forKey:@"connectionName"];
    [coder encodeObject:_connectionUUID forKey:@"connectionUUID"];
    [coder encodeObject:_connectionId forKey:@"connectionId"];
    [coder encodeObject:_messagesArray forKey:@"messagesArray"];
}
    
@end
