//
//  ConnectionMessageData.m
//  RouletteTesting
//
//  Created by Michael Parris on 3/9/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import "ConnectionMessageData.h"

@implementation ConnectionMessageData

- (id)initWithCoder:(NSCoder *)coder {
    if(self = [super init]) {
        self.messageId = [coder decodeObjectForKey:@"messageId"];
        self.connectionId = [coder decodeObjectForKey:@"connectionId"];
        self.imageMessageLocation = [coder decodeObjectForKey:@"imageMessageLocation"];
        self.imageMessage = [coder decodeObjectForKey:@"imageMessage"];
        self.videoMessage = [coder decodeObjectForKey:@"videoMessage"];
        
        return self;
    }
    return nil;
}

- (void) encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject:_messageId forKey:@"messageId"];
    [coder encodeObject:_connectionId forKey:@"connectionId"];
    [coder encodeObject:_imageMessageLocation forKey:@"imageMessageLocation"];
    [coder encodeObject:_imageMessage forKey:@"imageMessage"];
    [coder encodeObject:_videoMessage forKey:@"videoMessage"];
}


@end
