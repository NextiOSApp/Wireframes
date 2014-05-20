//
//  ImageViewController.h
//  Next
//
//  Created by Chris Hayes on 5/18/14.
//  Copyright (c) 2014 CAV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "InboxViewController.h"

@interface ImageViewController : UIViewController

@property (nonatomic, strong)PFObject *message;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
