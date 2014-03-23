//
//  VideoViewController.h
//  RouletteTesting
//
//  Created by Michael Parris on 2/26/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoViewController : UIViewController

@property (nonatomic) IBOutlet UILabel *connectionsLabel;

- (IBAction)connView:(id)sender;
- (void)newConnection;

@end
