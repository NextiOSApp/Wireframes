//
//  VideoViewController.m
//  RouletteTesting
//
//  Created by Michael Parris on 2/26/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import "VideoViewController.h"
#import "NSString+FontAwesome.h"
#import "RouletteTestingMasterViewController.h"
#import "ConnectionsViewController.h"

@interface VideoViewController ()

@end

@implementation VideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    self.connectionsLabel.font = [UIFont fontWithName:@"FontAwesome" size:30];
//    self.connectionsLabel.text = [NSString awesomeIcon:FaAngleDoubleLeft];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(connectionsView:)];
    [self.connectionsLabel addGestureRecognizer:tap];
    
}

- (IBAction)connView:(id)sender {
    NSLog(@"CONNECTIONS button clicked.");
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    RouletteTestingMasterViewController *cV = (RouletteTestingMasterViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"connections1"];
//    ConnectionsViewController *cV = (ConnectionsViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"connections2"];
    [self presentViewController:cV animated:YES completion:nil];
}

- (void)connectionsView:(UITapGestureRecognizer*)recognizer {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RouletteTestingMasterViewController *cV = (RouletteTestingMasterViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"connections1"];
//    ConnectionsViewController *cV = (ConnectionsViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"connections2"];
    [self presentViewController:cV animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
