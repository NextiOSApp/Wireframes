//
//  EditFriendsViewController.h
//  Next
//
//  Created by Chris Hayes on 5/16/14.
//  Copyright (c) 2014 CAV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface EditFriendsViewController : UITableViewController

@property(nonatomic,strong)NSArray *allUsers;
@property(nonatomic, strong)PFUser *currentUser;
@property(nonatomic, strong)NSMutableArray *friends;

-(BOOL)isFriend: (PFUser *)user;

@end
