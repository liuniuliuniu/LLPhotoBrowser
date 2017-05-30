//
//  LLPhotoBrowser.m
//  LLPhotoBrowser
//
//  Created by liushaohua on 2017/5/4.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLPhotoBrowser.h"
#import "UIImageView+WebCache.h"

#import "LLBrowserImageView.h"

#import "LLActionSheetView.h"

//在config中配置相关样式
#import "LLPhotoBrowserConfig.h"

@interface LLPhotoBrowser ()<UIScrollViewDelegate,LLActionSheetDelegate>

@end

@implementation LLPhotoBrowser
{//  用于滚动的ScrollVIew
    UIScrollView *_scrollView;
    // 是否展示第一个VIew
    BOOL _hasShowedFistView;
    
    UIPageControl *_pageControll;
    
    // 指示View
    UIActivityIndicatorView *_indicatorView;
    // 将要消失
    BOOL _willDisappear;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 背景颜色
        self.backgroundColor = LLPhotoBrowserBackgrounColor;
    }
    return self;
}


// 确定添加到父View中
- (void)didMoveToSuperview
{
    
    [self setupScrollView];
    
    [self setupToolbars];
}

- (void)dealloc
{
    [[UIApplication sharedApplication].keyWindow removeObserver:self forKeyPath:@"frame"];
}


// 工具类
- (void)setupToolbars
{
    
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = self.imageCount;
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
    pageControl.userInteractionEnabled = NO;
    _pageControll = pageControl;
    [self addSubview:pageControl];
    
}

// 保存图片
- (void)saveImage
{
    
    int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    UIImageView *currentImageView = _scrollView.subviews[index];
    
    // 一定记得在info.plist 中打开相机权限 否则会闪退
    UIImageWriteToSavedPhotosAlbum(currentImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}

// 保存图片的方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{

    
    [_indicatorView removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.bounds = CGRectMake(0, 0, 150, 44);
    label.center = self.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:17];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    if (error) {
        label.text = LLPhotoBrowserSaveImageFailText;
    }   else {
        label.text = LLPhotoBrowserSaveImageSuccessText;
    }
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}



// 设置SCrollView
- (void)setupScrollView
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    
    [self addSubview:_scrollView];
    
    for (int i = 0; i < self.imageCount; i++) {
        
        // 在ScrollView上添加图片
        LLBrowserImageView *imageView = [[LLBrowserImageView alloc] init];
        // 图片的Tag
        imageView.tag = i;
        
        // 单击图片
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoClick:)];
        
        
        // 双击放大图片
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDoubleTaped:)];
        
        // 长按保存图片
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewLongPressAction:)];
        
        doubleTap.numberOfTapsRequired = 2;
        
        //        如果doubleTapGesture识别出双击事件，则singleTapGesture不会有任何动作。   也就是为了避免冲突
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        
        
        [imageView addGestureRecognizer:singleTap];
        [imageView addGestureRecognizer:doubleTap];
        [imageView addGestureRecognizer:longPress];
        [_scrollView addSubview:imageView];
    }
    
    // 加载图片
    [self setupImageOfImageViewForIndex:self.currentImageIndex];
    
}


// 加载图片
- (void)setupImageOfImageViewForIndex:(NSInteger)index
{
    // 通过Index来确定ScrollView的视图
    LLBrowserImageView *imageView = _scrollView.subviews[index];
    // 确定当前的指标
    self.currentImageIndex = index;
    
    // 如果图片已经加载好了  就返回
    if (imageView.hasLoadedImage) return;
    // 如果返回来了高质量的图片的话
    if ([self highQualityImageURLForIndex:index]) {
        // 就直接拿到图案品
        [imageView setImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
    } else {
        // 否则就展示占位图
        imageView.image = [self placeholderImageForIndex:index];
    }
    // 记录图片已经加载好了
    imageView.hasLoadedImage = YES;
}


// 单击图片
- (void)photoClick:(UITapGestureRecognizer *)recognizer
{
    // ScrollV隐藏
    _scrollView.hidden = YES;
    _willDisappear = YES;
    
    
    // 获取到当前的点击图片
    LLBrowserImageView *currentImageView = (LLBrowserImageView *)recognizer.view;
    // 记录了当前的图片的index
    NSInteger currentIndex = currentImageView.tag;
    
    
    
    UIView *sourceView = nil;
    // 如果是CollectionView的话
    if ([self.sourceImagesContainerView isKindOfClass:UICollectionView.class]) {
        
        UICollectionView *view = (UICollectionView *)self.sourceImagesContainerView;
        
        NSIndexPath *path = [NSIndexPath indexPathForItem:currentIndex inSection:0];
        
        // 获取到VIew
        sourceView = [view cellForItemAtIndexPath:path];
    }else {
        
        sourceView = self.sourceImagesContainerView.subviews[currentIndex];
    }
    
    
    // 取到图片回归原始地方的Frame
    CGRect targetTemp = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    
    tempView.contentMode = sourceView.contentMode;
    tempView.clipsToBounds = YES;
    tempView.image = currentImageView.image;
    
    // 获取到图片的高度
    CGFloat h = (self.bounds.size.width / currentImageView.image.size.width) * currentImageView.image.size.height;
    
    
    if (!currentImageView.image) { // 防止 因imageview的image加载失败 导致 崩溃
        h = self.bounds.size.height;
    }
    
    
    tempView.bounds = CGRectMake(0, 0, self.bounds.size.width, h);
    tempView.center = self.center;
    
    [self addSubview:tempView];
    
    // 进行动画缩小View
    [UIView animateWithDuration:LLPhotoBrowserHideImageAnimationDuration animations:^{
        tempView.frame = targetTemp;
        self.backgroundColor = [UIColor clearColor];
        _pageControll.alpha = 0.1;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


// 双击图片 去缩放
- (void)imageViewDoubleTaped:(UITapGestureRecognizer *)recognizer
{
    // 获取的点击的VIew
    LLBrowserImageView *imageView = (LLBrowserImageView *)recognizer.view;
    
    // 缩放指数
    CGFloat scale;
    // 如果缩放了
    if (imageView.isScaled) {
        scale = 1.0;
    } else {
        scale = 2.0;
    }
    
    LLBrowserImageView *view = (LLBrowserImageView *)recognizer.view;
    [view doubleTapToZommWithScale:scale];
}

- (void)imageViewLongPressAction:(UIPanGestureRecognizer *)recognizer{
    
    if (recognizer.state != UIGestureRecognizerStateEnded) {
        
        // 此处可以自定义 
        NSArray *arr = @[@"保存图片"];
     
        LLActionSheetView *sheetV = [[LLActionSheetView alloc]initWithTitleArray:arr andShowCancel:YES];
        sheetV.delegate = self;
        // block回调
//        sheetV.ClickIndex = ^(NSInteger index) {
//            
//            switch (index) {
//                case 0:
//                {
//                    NSLog(@"取消");
//                }
//                    break;
//                case 1:
//                {
//                    [self saveImage];
//                }
//                    break;
//                default:
//                    break;
//            }
//        };
        [self addSubview:sheetV];
    }
}

// 也支持代理
- (void)actionSheetView:(LLActionSheetView *)actionSheetView clickButtonAtIndex:(NSInteger )buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"取消");
        }
            break;
        case 1:
        {
            [self saveImage];
        }
            break;
        default:
            break;
    }

}



//1.直接调用[self setNeedsLayout];（这个在上面苹果官方文档里有说明）
//2.addSubview的时候。
//3.当view的size发生改变的时候。
//4.滑动UIScrollView的时候。
//5.旋转Screen会触发父UIView上的layoutSubviews事件。
//注意:当view的size的值为0的时候，addSubview也不会调用layoutSubviews。当要给这个view添加子控件的时候不管他的size有没有值都会调用


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 获取到自己的bounds
    CGRect rect = self.bounds;
    rect.size.width += LLPhotoBrowserImageViewMargin * 2;
    
    _scrollView.bounds = rect;
    _scrollView.center = self.center;
    
    CGFloat y = 0;
    CGFloat w = _scrollView.frame.size.width - LLPhotoBrowserImageViewMargin * 2;
    CGFloat h = _scrollView.frame.size.height;
    
    // 布局ScrollView子空间的frame
    [_scrollView.subviews enumerateObjectsUsingBlock:^(LLBrowserImageView *obj, NSUInteger idx, BOOL *stop) {
        CGFloat x = LLPhotoBrowserImageViewMargin + idx * (LLPhotoBrowserImageViewMargin * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
    }];
    
    // ScrollView的内容尺寸
    _scrollView.contentSize = CGSizeMake(_scrollView.subviews.count * _scrollView.frame.size.width, 0);
    
    // 内容的偏移量  意思就是点击中间图片的话 直接就展示到中间的位置了
    _scrollView.contentOffset = CGPointMake(self.currentImageIndex * _scrollView.frame.size.width, 0);
    
    //是否已经展示了中间的图片了
    if (!_hasShowedFistView) {
        
        [self showFirstImage];
    }
    
    _pageControll.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds
                                       .size.height - 50);
    
}


// 展示的方法
- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.frame = window.bounds;
    // 监听自己的Frame
    [window addObserver:self forKeyPath:@"frame" options:0 context:nil];
    [window addSubview:self];
    
}


// KVO的代理方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIView *)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"frame"]) {
        self.frame = object.bounds;
        
        LLBrowserImageView *currentImageView = _scrollView.subviews[_currentImageIndex];
        if ([currentImageView isKindOfClass:[LLBrowserImageView class]]) {
            [currentImageView clear];
        }
    }
}


// 展示第一张图片
- (void)showFirstImage
{
    
    UIView *sourceView = nil;
    
    //
    if ([self.sourceImagesContainerView isKindOfClass:UICollectionView.class]) {
        UICollectionView *view = (UICollectionView *)self.sourceImagesContainerView;
        NSIndexPath *path = [NSIndexPath indexPathForItem:self.currentImageIndex inSection:0];
        sourceView = [view cellForItemAtIndexPath:path];
    }else {
        
        
        
        sourceView = self.sourceImagesContainerView.subviews[self.currentImageIndex];
        
    }
    
    
    CGRect rect = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.image = [self placeholderImageForIndex:self.currentImageIndex];
    
    [self addSubview:tempView];
    
    CGRect targetTemp = [_scrollView.subviews[self.currentImageIndex] bounds];
    
    tempView.frame = rect;
    tempView.contentMode = [_scrollView.subviews[self.currentImageIndex] contentMode];
    _scrollView.hidden = YES;
    
    [UIView animateWithDuration:LLPhotoBrowserShowImageAnimationDuration animations:^{
        tempView.center = self.center;
        tempView.bounds = (CGRect){CGPointZero, targetTemp.size};
    } completion:^(BOOL finished) {
        _hasShowedFistView = YES;
        [tempView removeFromSuperview];
        _scrollView.hidden = NO;
    }];
}



// 占位图片
- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.delegate photoBrowser:self placeholderImageForIndex:index];
    }
    return nil;
}

- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageURLForIndex:index];
    }
    return nil;
}



#pragma mark - scrollview代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    int index = (scrollView.contentOffset.x + _scrollView.bounds.size.width * 0.5) / _scrollView.bounds.size.width;
    
    // 有过缩放的图片在拖动一定距离后清除缩放
    CGFloat margin = 150;
    CGFloat x = scrollView.contentOffset.x;
    if ((x - index * self.bounds.size.width) > margin || (x - index * self.bounds.size.width) < - margin) {
        LLBrowserImageView *imageView = _scrollView.subviews[index];
        if (imageView.isScaled) {
            [UIView animateWithDuration:0.5 animations:^{
                imageView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [imageView eliminateScale];
            }];
        }
    }
    
    
    if (!_willDisappear) {
        _pageControll.currentPage = index;
    }
    // 拖动后展示下一张图片
    [self setupImageOfImageViewForIndex:index];
}


@end
