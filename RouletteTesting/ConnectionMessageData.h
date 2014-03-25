//
//  ConnectionMessageData.h
//  RouletteTesting
//
//  Created by Michael Parris on 3/9/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionMessageData : NSObject <NSCoding>

@property (nonatomic) NSString *messageId;
@property (nonatomic) NSString *connectionId;
@property (nonatomic) UIImage *imageMessage;
@property (nonatomic) UIImage *videoMessage;


@end
