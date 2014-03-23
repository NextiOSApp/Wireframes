//
//  ConnectionCell.h
//  RouletteTesting
//
//  Created by Michael Parris on 3/21/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectionCell : UITableViewCell

@property (nonatomic) IBOutlet UILabel *connectionNameLabel;
@property (nonatomic) IBOutlet UILabel *messageCountLabel;

@property (nonatomic) NSString *connectionId;

@end
