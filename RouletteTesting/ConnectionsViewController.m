//
//  ConnectionsViewController.m
//  RouletteTesting
//
//  Created by Michael Parris on 2/26/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import "ConnectionsViewController.h"

@interface ConnectionsViewController ()

@end

@implementation ConnectionsViewController

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
    
    self.dataArray = [[NSMutableArray alloc] init];
    [self loadImages];
    [self setupConnectionView];
}

- (void)loadImages {
//    NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Assets"];
//    self.dataArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath error:NULL];
    
    UIImage *image0 = [UIImage imageNamed:@"0.jpg"];
    UIImage *image1 = [UIImage imageNamed:@"1.jpg"];
    UIImage *image2 = [UIImage imageNamed:@"2.jpg"];
    UIImage *image3 = [UIImage imageNamed:@"3.jpg"];
    UIImage *image4 = [UIImage imageNamed:@"4.jpg"];
    
    [self.dataArray addObject:image0];
    [self.dataArray addObject:image1];
    [self.dataArray addObject:image2];
    [self.dataArray addObject:image3];
    [self.dataArray addObject:image4];
}

- (void)setupConnectionView {
//    [self.collectionView registerClass:[ConnectionGalleryCell class] forCellWithReuseIdentifier:@"MyCell"];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    // Cell Spacing
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    
    // Snap effect
    [self.collectionView setPagingEnabled:YES];
    
    [self.collectionView setCollectionViewLayout:flowLayout];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ConnectionGalleryCell *cell = (ConnectionGalleryCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"MyCell" forIndexPath:indexPath];
    
    cell.imageView.image = [self.dataArray objectAtIndex:[indexPath row]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(320, 548);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
