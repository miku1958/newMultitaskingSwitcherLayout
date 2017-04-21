//
//  newBackgroundLayout.m
//  backgroundLayout
//
//  Created by mikun on 2017/4/13.
//  Copyright © 2017年 mikun. All rights reserved.
//


#import "newMultitaskingSwitcherLayout.h"

@interface newMultitaskingSwitcherLayout()<UIGestureRecognizerDelegate>{
	CGSize _contenSize;
	CGFloat viewWidth;
	CGFloat virtualItemWidth;
	NSInteger singleSideConut;
	CGFloat ViewCenterX;
	CGFloat ViewCenterY;
	CGFloat MARGIN;
	NSInteger currentIndex;
	NSInteger touchEndIndex;
	CGFloat targetRatio;
	CGFloat middleRatio;
	//MARK: styleiOS10LessMotion替换pan手势的变量
	UIPanGestureRecognizer *oriPan;
	UIPanGestureRecognizer *replacePan;
	//MARK:	计算styleiOS10LessMotion位移的参数
	CGFloat a;
	CGFloat b;
	//MARK:	动画使用的变量
	CADisplayLink *animationLink;
	CGFloat animationCurrentTime;
	CGFloat animationTimeInterval;
	CGFloat animationBeginX;
	CGFloat animationX;
}
@property (nonatomic,assign)NSInteger cellCount;

@end


@implementation newMultitaskingSwitcherLayout
-(void)restroeOriginalPanGesture{
	if (oriPan == nil) {
		return;
	}
	[self.collectionView removeGestureRecognizer:replacePan];
	[self.collectionView addGestureRecognizer:oriPan];
	replacePan = nil;
	oriPan = nil;
	
}

-(NSInteger)cellCount{
	if (!_cellCount) {
		_cellCount = [self.collectionView numberOfItemsInSection:0];
	}
	return _cellCount;
}




-(instancetype)init{
	self = [super init];
	if (self) {
		_scrollToRightWhenShow = YES;
		_style = styleiOS10LessMotion;
		_visibleCount = 5;

		singleSideConut = (_visibleCount - 1) / 2;
		
		viewWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
		ViewCenterX = viewWidth / 2;
		
		CGFloat viewHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
		ViewCenterY = viewHeight / 2;
		
		self.itemSize = CGSizeMake(viewWidth*3/4, viewHeight*3/4);

	}
	return self;
}


-(CGFloat)getAttrCenterXWithRatio:(CGFloat)ratio{
	return a*(ratio-targetRatio)+b;
}

-(void)setStyle:(multitaskingSwitcherStyle)style{
	_style = style;
	if (style == styleiOS8) {

		self.scrollDirection = UICollectionViewScrollDirectionHorizontal;

		self.minimumLineSpacing = MARGIN/2;
		CGFloat inset = (viewWidth-self.itemSize.width)/2;
		self.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset);
	}
	_contenSize = CGSizeZero;
	
}

-(void)setItemSize:(CGSize)itemSize{
	[super setItemSize:itemSize];
	virtualItemWidth = itemSize.width/2;
	MARGIN = viewWidth / 3 - virtualItemWidth / 2;
	middleRatio = (virtualItemWidth / 2 + MARGIN- viewWidth / 2)/virtualItemWidth;
	b = itemSize.width/2;
	a = ViewCenterX*2.375/2;
	targetRatio = middleRatio- (ViewCenterX - b)/a;
	if (_style == styleiOS8) {
		self.minimumLineSpacing = MARGIN/2;
		CGFloat inset = (viewWidth-itemSize.width)/2;
		self.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset);
	}
}

- (CGSize)collectionViewContentSize {
	if (_contenSize.width == 0) {
		CGFloat width = 0;
		if (_style == styleiOS8) {
			_contenSize = [super collectionViewContentSize];
			width = _contenSize.width;
		}else{
			width = self.cellCount * virtualItemWidth + MARGIN * 4;
			_contenSize = CGSizeMake(width, [UIScreen mainScreen].bounds.size.height);

		}
		if (_scrollToRightWhenShow) {
			[self.collectionView setContentOffset:CGPointMake(width-viewWidth, 0) animated:NO];
		}
		
		
		if (_style == styleiOS10LessMotion&&oriPan == nil) {
			oriPan = self.collectionView.panGestureRecognizer;
			[self.collectionView removeGestureRecognizer:oriPan];
			replacePan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
			[self.collectionView addGestureRecognizer:replacePan];
		}else if(oriPan!= nil){
			[self.collectionView removeGestureRecognizer:replacePan];
			[self.collectionView addGestureRecognizer:oriPan];
			replacePan = nil;
			oriPan = nil;
		}
		
	}
	return _contenSize;
}

- (void)panAction:(UIPanGestureRecognizer *)pan{
	static NSInteger index;
	switch (pan.state) {
		case UIGestureRecognizerStateBegan:{
			index = currentIndex;
			break;
		}
		case UIGestureRecognizerStateChanged:{
			UICollectionView *collection = pan.view;
			CGFloat offsetX = [pan translationInView:collection].x;
			CGFloat velocityX = [pan velocityInView:collection].x;
			CGFloat currentX = collection.contentOffset.x;
			
			if ((currentX<-1)&&velocityX>0) {
				offsetX /= -currentX/5;
				collection.contentOffset = CGPointMake(currentX-offsetX, 0);
				
			}
			if (((currentX+viewWidth-1) > _contenSize.width)&&velocityX<0) {
				
				offsetX /= ((currentX+viewWidth)-_contenSize.width)/5;
				collection.contentOffset = CGPointMake(currentX-offsetX, 0);
				
			}
			if (_style ==styleiOS10LessMotion&&velocityX<0) {
				offsetX /= 3;
			}
			offsetX /= 1.7;
			collection.contentOffset = CGPointMake(currentX-offsetX, 0);
			[pan setTranslation:CGPointZero inView:collection];
			break;
		}
			
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateFailed:
		case UIGestureRecognizerStateCancelled:{
			UICollectionView *collection = pan.view;
			CGFloat currentX = collection.contentOffset.x;
			
			if (currentX<0) {
				
				[self changeOffsetXTo:0 WithDuration:0.25];

			}else if ((currentX+viewWidth) > _contenSize.width) {
				
				[self changeOffsetXTo:_contenSize.width - viewWidth WithDuration:0.25];

			}else{
				CGFloat velocityX = [pan velocityInView:collection].x;
				if (velocityX<0) {
					index += 1;
				}
				if (velocityX>0) {
					index -= 1;
				}
				[self changeOffsetXTo:virtualItemWidth * index WithDuration:0.25];
				
			}
		}
	}
	
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
	return !CGRectEqualToRect(newBounds, self.collectionView.bounds);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
	if (_style==styleiOS8) {
		return[super layoutAttributesForElementsInRect:rect];
	}
	CGFloat centerX = (self.collectionView.contentOffset.x) + viewWidth / 2;

	currentIndex = centerX / virtualItemWidth - 1;

	NSInteger minIndex = MAX(0, (currentIndex - singleSideConut));
	NSInteger maxIndex = MIN((self.cellCount - 1), (currentIndex + singleSideConut));
	NSMutableArray *array = [NSMutableArray array];
	for (NSInteger i = minIndex; i <= maxIndex; i++) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
		UICollectionViewLayoutAttributes *attributes= [self newlayoutAttributesForItemAtIndexPath:indexPath];

		[array addObject:attributes];
	}
	
	return array;
}

- (UICollectionViewLayoutAttributes *)newlayoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
	attributes.size = self.itemSize;
	NSUInteger row = indexPath.row;
	CGFloat contentOffsetX = self.collectionView.contentOffset.x;
	CGFloat screenLeft = contentOffsetX+self.itemSize.width/2;
	
	switch (_style) {
		case styleiOS10LessMotion:{
			
			CGFloat cX = contentOffsetX + viewWidth / 2 ;

			
			CGFloat attributesX = virtualItemWidth * row + virtualItemWidth / 2 + MARGIN ;

			attributes.zIndex = attributesX/virtualItemWidth;

			
			CGFloat delta = attributesX - cX;

			
			CGFloat ratio = delta / virtualItemWidth;

			
			CGFloat scale = MAX(ratio/30 + 1.05, 1);
			attributes.transform = CGAffineTransformMakeScale(scale, scale);
			
			

			if(ratio>targetRatio){
				attributes.center = CGPointMake([self getAttrCenterXWithRatio:ratio]+contentOffsetX, ViewCenterY);
			}else{
				attributes.center = CGPointMake(screenLeft, ViewCenterY);
			}
			
			break;
		}
		case styleiOS9_10:{
			CGFloat cX = (self.collectionView.contentOffset.x) + viewWidth / 2;

			CGFloat attributesX = virtualItemWidth * row + virtualItemWidth / 2 + MARGIN;
			attributes.zIndex = attributesX/virtualItemWidth;
			
			CGFloat delta = attributesX - cX;
			
			CGFloat ratio = delta / (virtualItemWidth);
			
			
			CGFloat offset =  ViewCenterX/2*pow((ratio - (middleRatio-2))/2, 3) + ViewCenterX/2;

			CGFloat centerX  = contentOffsetX + offset;
			
			CGFloat scale = ratio/50 + 1;
			attributes.transform = CGAffineTransformMakeScale(scale, scale);//x scale has something doesn`t right

			attributes.center = CGPointMake(centerX, ViewCenterY);
			
			CGFloat alpha = (2 + ratio)*1.5;
			if (alpha<0) {
				attributes.alpha = 0;
				break;
			}
			if(alpha>1){
				attributes.alpha = 1;
				break;
			}
			attributes.alpha = alpha;
			break;
		}


	}
	return attributes;
}



-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset{
	return [self targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:CGPointZero];
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
	NSInteger index = currentIndex;
	switch (_style) {
		case styleiOS10LessMotion:{
			NSInteger targetIndex = (proposedContentOffset.x +viewWidth / 3 - self.itemSize.width / 2)/virtualItemWidth+0.5;
			targetIndex>currentIndex?(index = currentIndex +1):(index = currentIndex -1);

			break;
		}
		case styleiOS9_10:{
			index= roundf((proposedContentOffset.x + viewWidth / 3 - self.itemSize.width / 2) / virtualItemWidth);
			break;
		}
		case styleiOS8:{
			CGRect lastRect;
			lastRect.origin = proposedContentOffset;
			lastRect.size = self.collectionView.frame.size;
			
			CGFloat centerX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;
			
			NSArray *array = [self layoutAttributesForElementsInRect:lastRect];
			
			CGFloat adjustOffsetX = MAXFLOAT;
			for (UICollectionViewLayoutAttributes *attrs in array) {
				if (ABS(attrs.center.x - centerX) < ABS(adjustOffsetX)) {
					adjustOffsetX = attrs.center.x - centerX;
				}
			}
			return CGPointMake(proposedContentOffset.x + adjustOffsetX, proposedContentOffset.y);
		}
	}
	proposedContentOffset.x = virtualItemWidth * index;

	return proposedContentOffset;
}

//MARK:	实现自定义的贝塞尔动画取代UIView动画解决真机上出现cell异常缩放动画
-(void)changeOffsetXTo:(CGFloat)x WithDuration:(CGFloat)time{
	animationCurrentTime = 0;
	animationTimeInterval = 1.0/(time*60);
	animationBeginX = self.collectionView.contentOffset.x;

	animationX = x;

	if(!animationLink) {
		animationLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(offsetAnimation)];
		[animationLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	}
	if(animationLink.isPaused) animationLink.paused = NO;
}

- (void)offsetAnimation{
	static CGFloat currentOffsetX = 0;
	if (animationCurrentTime == 0) {
		currentOffsetX = self.collectionView.contentOffset.x;
	}
	if (animationCurrentTime >= 1) {
		[animationLink invalidate];
		animationLink = nil;
		self.collectionView.contentOffset = CGPointMake(animationX, 0);
	}
	
	CGFloat t = animationCurrentTime;
	CGFloat tSqure = t * t;
	CGFloat tCube = t * tSqure;
	CGFloat dt = 1-t;
	CGFloat dtSqure = dt * dt;
	CGFloat dtCube = dtSqure * dt;
	
	CGFloat x =	currentOffsetX*dtCube+3*currentOffsetX*t*dtSqure+3*animationX*tSqure*(1-t)+animationX*tCube;

	self.collectionView.contentOffset = CGPointMake(x, 0);
	animationCurrentTime += animationTimeInterval;
}

@end
