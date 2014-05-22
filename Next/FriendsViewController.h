//
//  FriendsViewController.h
//  Next
//
//  Created by Chris Hayes on 5/16/14.
//  Copyright (c) 2014 CAV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ParseManager.h"

@interface FriendsViewController : UITableViewController <ParseManagerProtocol>

//@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic) ParseManager *parseManager;
@property (nonatomic, strong) NSArray *friends;

@end
