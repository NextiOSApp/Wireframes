//
//  RouletteTestingDetailViewController.h
//  RouletteTesting
//
//  Created by Michael Parris on 2/8/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouletteTestingDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
