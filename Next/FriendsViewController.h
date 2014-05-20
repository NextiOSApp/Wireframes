//
//  FriendsViewController.h
//  Next
//
//  Created by Chris Hayes on 5/16/14.
//  Copyright (c) 2014 CAV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendsViewController : UITableViewController

@property(nonatomic, strong)PFRelation *friendsRelation;
@property(nonatomic, strong)NSArray *friends;

@end
