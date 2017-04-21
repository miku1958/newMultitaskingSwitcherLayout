//
//  ViewController.m
//  backgroundLayout
//
//  Created by mikun on 2017/4/13.
//  Copyright © 2017年 mikun. All rights reserved.
//

#import "ViewController.h"
#import "NewMacro.h"
#import "newMultitaskingSwitcherLayout.h"
#import "CollectionViewCell.h"
#define CollectionCellID @"collection"
@interface ViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property (nonatomic,strong)UICollectionView *collection;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	newMultitaskingSwitcherLayout *flow = [[newMultitaskingSwitcherLayout alloc]init];
	flow.style = styleiOS8;
	_collection = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flow];
	[_collection registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:CollectionCellID];
	_collection.delegate = self;
	_collection.dataSource = self;
	[self.view addSubview:_collection];
	_collection.alwaysBounceHorizontal = YES;
	
	_collection.backgroundColor = newColor(255, 255, 255);

	
}




- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
	//某组一共多少个小格子
	return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	// 1.从缓存池获得对应行的cell（在viewDidLoad注册后会自动创建）
	CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionCellID forIndexPath:indexPath];
	NSString *img = [NSString stringWithFormat:@"%d",indexPath.row%2];
	cell.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:img]];
	
	
	return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionCellID forIndexPath:indexPath];
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
	newLog(@"%@",cell);
}

//-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//	return CGSizeMake(newScreenWidth*0.5, newScreenHeight*0.5);
//}

@end
