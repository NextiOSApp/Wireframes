//
//  ConnectionsViewController.h
//  RouletteTesting
//
//  Created by Michael Parris on 2/26/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionGalleryCell.h"

@interface ConnectionsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSMutableArray *dataArray;

//@property (nonatomic, weak) IBOutlet ConnectionGalleryCell *collectionCell;

@end
