//
//  HHLiveCollectionViewController.m
//  HHLiveDome
//
//  Created by 黄华 on 2018/3/28.
//  Copyright © 2018年 huanghua. All rights reserved.
//

#import "HHLiveCollectionViewController.h"
#import "HHLiveCollectionViewCell.h"

@interface HHLiveCollectionViewController ()

@end

@implementation HHLiveCollectionViewController

static NSString * const reuseIdentifier = @"Cell_ID";

- (instancetype)init{
    return [super initWithCollectionViewLayout:[[HHLiveFlowLayout alloc] init]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerClass:[HHLiveCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self.collectionView reloadData];
}



#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell
    HHLiveCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.parentVc = self;
    cell.live = self.lives[self.currentIndex];
    cell.clickCancleLive = ^(id object) {
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
