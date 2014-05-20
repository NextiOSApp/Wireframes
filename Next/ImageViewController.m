//
//  ImageViewController.m
//  Next
//
//  Created by Chris Hayes on 5/18/14.
//  Copyright (c) 2014 CAV. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFFile *imageFile = [self.message objectForKey:@"file"];
    NSURL *imageFileURL = [[NSURL alloc] initWithString:imageFile.url];
    NSData *imageData = [NSData dataWithContentsOfURL:imageFileURL];
    self.imageView.image = [UIImage imageWithData:imageData];
    NSString *senderName = [self.message objectForKey:@"senderName"];
    NSString *title = [NSString stringWithFormat:@"Sent from %@", senderName];
    self.navigationItem.title = title;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self respondsToSelector:@selector(timeOut)]) // Used for switching between selectors
    {
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
    }
    else
    {
        NSLog(@"Error: Selector Missing!");
    }

}

#pragma mark - Helper Methods

- (void) timeOut
{
    [self.navigationController popViewControllerAnimated:YES];
    
}








@end
