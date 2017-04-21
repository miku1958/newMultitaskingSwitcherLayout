//
//  newMultitaskingSwitcherLayout.h
//  backgroundLayout
//
//  Created by mikun on 2017/4/13.
//  Copyright © 2017年 mikun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, multitaskingSwitcherStyle) {
	styleiOS8				=0,
	styleiOS9_10			=1,
	styleiOS10LessMotion	=2
};

@interface newMultitaskingSwitcherLayout : UICollectionViewFlowLayout

/** 超出屏幕的都不会显示*/
@property (nonatomic) NSInteger visibleCount;
@property (nonatomic,assign) multitaskingSwitcherStyle style;
@property (nonatomic,assign)BOOL scrollToRightWhenShow;
/** collectionView如果要setCollectionViewLayout的话最好运行一下这个方法*/
- (void)restoreOriginalPanGesture;
- (UICollectionViewLayoutAttributes *)newlayoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
@end
