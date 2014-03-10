//
//  ConnectionGalleryCell.h
//  RouletteTesting
//
//  Created by Michael Parris on 3/3/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectionGalleryCell : UICollectionViewCell

@property (nonatomic, strong) NSString *imageName;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;


- (void)updateCell;

@end
