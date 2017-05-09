//
//  LLBrowserImageView.m
//  LLPhotoBrowser
//
//  Created by liushaohua on 2017/5/4.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLBrowserImageView.h"
#import "UIImageView+WebCache.h"
#import "LLPhotoBrowserConfig.h"
#import "LLWaitingView.h"


@implementation LLBrowserImageView{
    
    // 等待的进度图
    __weak LLWaitingView *_waitingView;
    // 是否检查尺寸
    BOOL _didCheckSize;
    // 缩放的ScrollV
    UIScrollView *_scroll;
    
    // 滚动的那个图片
    UIImageView *_scrollImageView;
    // 缩放的那个图片
    UIScrollView *_zoomingScroolView;
    // 缩放的图片
    UIImageView *_zoomingImageView;
    // 缩放比例
    CGFloat _totalScale;

}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 打开交互
        self.userInteractionEnabled = YES;
        
        self.contentMode = UIViewContentModeScaleAspectFit;
        // 缩放比例
        _totalScale = 1.0;
        
        
        // 捏合手势缩放图片
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomImage:)];
        pinch.delegate = self;
        [self addGestureRecognizer:pinch];
        
    }
    return self;
}


// get 方法
- (BOOL)isScaled
{
    return  1.0 != _totalScale;
}


// 布局子空间
- (void)layoutSubviews
{
    [super layoutSubviews];
    //    等待的视图在中间
    _waitingView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    
    // 获取当前图片的尺寸
    CGSize imageSize = self.image.size;
    
    // 判断图片的高度是否大于自身的高度
    if (self.bounds.size.width * (imageSize.height / imageSize.width) > self.bounds.size.height) {
        if (!_scroll) {
            
            
            UIScrollView *scroll = [[UIScrollView alloc] init];
            scroll.backgroundColor = [UIColor whiteColor];
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = self.image;
            
            _scrollImageView = imageView;
            
            [scroll addSubview:imageView];
            // 背景颜色
            scroll.backgroundColor = LLPhotoBrowserBackgrounColor;
            // 缩放的ScrollView
            _scroll = scroll;
            // 添加到当前视图
            [self addSubview:scroll];
            // 当前等待图片
            if (_waitingView) {
                // 把等待的视图添加到最前边
                [self bringSubviewToFront:_waitingView];
            }
        }
        // 设置ScrollVIew的frame
        _scroll.frame = self.bounds;
        
        // 计算图片的尺寸
        CGFloat imageViewH = self.bounds.size.width * (imageSize.height / imageSize.width);
        // 设置ScrollImageV的尺寸
        _scrollImageView.bounds = CGRectMake(0, 0, _scroll.frame.size.width, imageViewH);
        // 设置ScrollImageView的中心位置
        _scrollImageView.center = CGPointMake(_scroll.frame.size.width * 0.5, _scrollImageView.frame.size.height * 0.5);
        // 设置contentSize
        _scroll.contentSize = CGSizeMake(0, _scrollImageView.bounds.size.height);
        
    } else {
        // 否则移除
        if (_scroll) [_scroll removeFromSuperview]; // 防止旋转时适配的scrollView的影响
        
    }
    
}

// 设置进度条
- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    // 直接设置到等待图的进度条
    _waitingView.progress = progress;
    
}


// 设置图片
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    
    LLWaitingView *waiting = [[LLWaitingView alloc] init];
    waiting.bounds = CGRectMake(0, 0, 100, 100);
    waiting.mode = LLWaitingViewProgressMode;
    _waitingView = waiting;
    [self addSubview:waiting];
    
    
    __weak LLBrowserImageView *imageViewWeak = self;
    
    // 如果下载失败下次继续下载---取消黑名单
    // 下载图片回调进度
    
        
    [self sd_setImageWithPreviousCachedImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        imageViewWeak.progress = (CGFloat)receivedSize / expectedSize;
                
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        // 把等待的图片移走
        [imageViewWeak removeWaitingView];
        // 如果出错的话
        if (error) {
            
            UILabel *label = [[UILabel alloc] init];
            label.bounds = CGRectMake(0, 0, 160, 30);
            label.center = CGPointMake(imageViewWeak.bounds.size.width * 0.5, imageViewWeak.bounds.size.height * 0.5);
            label.text = @"图片加载失败";
            label.font = [UIFont systemFontOfSize:16];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
            label.layer.cornerRadius = 5;
            label.clipsToBounds = YES;
            label.textAlignment = NSTextAlignmentCenter;
            [imageViewWeak addSubview:label];
            
        } else {
            // 获取到图片了
            _scrollImageView.image = image;
            // 方便开始绘图
            [_scrollImageView setNeedsDisplay];
        }
        
    }];

    
}

// 捏合图片的方法
- (void)zoomImage:(UIPinchGestureRecognizer *)recognizer
{
    
    [self prepareForImageViewScaling];
    
    // 获取缩放因子
    CGFloat scale = recognizer.scale;
    // 获取到 缩放比例
    CGFloat temp = _totalScale + (scale - 1);
    [self setTotalScale:temp];
    // 然后重新设置scale
    recognizer.scale = 1.0;
}


- (void)setTotalScale:(CGFloat)totalScale
{
    // 最大缩放2倍 最小缩放0.5倍
    if ((_totalScale < 0.5 && totalScale < _totalScale) || (_totalScale > 2.0 && totalScale > _totalScale)) return; // 最大缩放 2倍,最小0.5倍
    
    // 然后进行缩放
    [self zoomWithScale:totalScale];
}


// 去缩放
- (void)zoomWithScale:(CGFloat)scale
{
    // 记录当前的缩放
    _totalScale = scale;
    
    // 设置缩放
    _zoomingImageView.transform = CGAffineTransformMakeScale(scale, scale);
    
    // 如果缩放大于  要判断最大的高度
    if (scale > 1) {
        // 获取宽度
        CGFloat contentW = _zoomingImageView.frame.size.width;
        // 取到最大高度
        CGFloat contentH = MAX(_zoomingImageView.frame.size.height, self.frame.size.height);
        // 缩放图片的中心店在中间
        _zoomingImageView.center = CGPointMake(contentW * 0.5, contentH * 0.5);
        // 缩放图片的尺寸
        _zoomingScroolView.contentSize = CGSizeMake(contentW, contentH);
        
        // 取到图片的偏移量
        CGPoint offset = _zoomingScroolView.contentOffset;
        // 重新这是X  整个内容的宽度减去图片的宽度*0.5  等于当前的X
        offset.x = (contentW - _zoomingScroolView.frame.size.width) * 0.5;
        //        offset.y = (contentH - _zoomingImageView.frame.size.height) * 0.5; 这个是原来就注释掉的
        // c重新赋值
        _zoomingScroolView.contentOffset = offset;
        
    } else {
        // 小于1
        _zoomingScroolView.contentSize = _zoomingScroolView.frame.size;
        _zoomingScroolView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _zoomingImageView.center = _zoomingScroolView.center;
    }
}

// 双击去缩放
- (void)doubleTapToZommWithScale:(CGFloat)scale
{
    [self prepareForImageViewScaling];
    [UIView animateWithDuration:0.5 animations:^{
        [self zoomWithScale:scale];
    } completion:^(BOOL finished) {
        if (scale == 1) {
            [self clear];
        }
    }];
}

// 准备为图片去缩放
- (void)prepareForImageViewScaling
{
    // 如果没有缩放图片
    if (!_zoomingScroolView) {
        // 创建缩放的图片父控件
        _zoomingScroolView = [[UIScrollView alloc] initWithFrame:self.bounds];
        // 背景颜色
        _zoomingScroolView.backgroundColor = LLPhotoBrowserBackgrounColor;
        // 缩放的ScrollV和自己的尺寸一样大
        _zoomingScroolView.contentSize = self.bounds.size;
        // 缩放的图片
        UIImageView *zoomingImageView = [[UIImageView alloc] initWithImage:self.image];
        CGSize imageSize = zoomingImageView.image.size;
        CGFloat imageViewH = self.bounds.size.height;
        if (imageSize.width > 0) {
            imageViewH = self.bounds.size.width * (imageSize.height / imageSize.width);
        }
        zoomingImageView.bounds = CGRectMake(0, 0, self.bounds.size.width, imageViewH);
        zoomingImageView.center = _zoomingScroolView.center;
        zoomingImageView.contentMode = UIViewContentModeScaleAspectFit;
        _zoomingImageView = zoomingImageView;
        [_zoomingScroolView addSubview:zoomingImageView];
        [self addSubview:_zoomingScroolView];
    }
}


// 去缩放图片
- (void)scaleImage:(CGFloat)scale
{
    [self prepareForImageViewScaling];
    [self setTotalScale:scale];
}


// 清除缩放
- (void)eliminateScale
{
    [self clear];
    _totalScale = 1.0;
}


- (void)clear
{
    [_zoomingScroolView removeFromSuperview];
    _zoomingScroolView = nil;
    _zoomingImageView = nil;
    
}




// 移除转圈的图片
- (void)removeWaitingView
{
    [_waitingView removeFromSuperview];
}





@end
