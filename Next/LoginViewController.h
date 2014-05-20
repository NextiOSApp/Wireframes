//
//  LoginViewController.h
//  Next
//
//  Created by Chris Hayes on 5/16/14.
//  Copyright (c) 2014 CAV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)login:(id)sender;

@end
