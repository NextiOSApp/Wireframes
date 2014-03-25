//
//  MessagesViewController.m
//  RouletteTesting
//
//  Created by Michael Parris on 3/22/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import "MessagesViewController.h"
#import "ConnectionMessageData.h"
#import "ParseNetworkManager.h";

@interface MessagesViewController ()

@end

@implementation MessagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender withMessages:(NSArray *)messages {
//    [super prepareForSegue:segue sender:sender];
//    
//    self.messages = messages;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    self.messageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewMessage:)];
}

- (IBAction)viewMessage {
    int x= 11;
}

- (void)dismissMessage {
    ParseNetworkManager *parseManager = [[ParseNetworkManager alloc] init];
    [parseManager deleteImageMessage:@""];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    float rows = ceil(((float)[self.messages count] / 2.0));
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    if ([self.messages count] <= indexPath.row)
        return cell;
    
    int cellRow = [indexPath row] * 2;
    
    self.leftImage = [(ConnectionMessageData*)[self.messages objectAtIndex:cellRow] imageMessage];
    UIImageView *image1 = (UIImageView*)[cell viewWithTag:50];
//    [image1 addGestureRecognizer:self.messageTapGesture];
    [image1 setImage:self.leftImage];
    
    if (cellRow + 1 < [self.messages count]) {
        self.rightImage = [(ConnectionMessageData*)[self.messages objectAtIndex:(cellRow+1)] imageMessage];
        UIImageView *image2 = (UIImageView*)[cell viewWithTag:51];
//        [image2 addGestureRecognizer:self.messageTapGesture];
        [image2 setImage:self.rightImage];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
