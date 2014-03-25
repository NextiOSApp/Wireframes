//
//  MessagesViewController.h
//  RouletteTesting
//
//  Created by Michael Parris on 3/22/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender withMessages:(NSArray*)messages;

//- (void)viewMessage:(UITapGestureRecognizer *)tapGesture;
- (IBAction)viewMessage;

@property (nonatomic) UITapGestureRecognizer *messageTapGesture;

@property (nonatomic) NSArray *messages;
@property (nonatomic) UIImage *leftImage;
@property (nonatomic) UIImage *rightImage;

@end
