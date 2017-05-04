//
//  LLBrowserImageView.h
//  LLPhotoBrowser
//
//  Created by liushaohua on 2017/5/4.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLBrowserImageView : UIImageView<UIGestureRecognizerDelegate>

// 进度条
@property (nonatomic,assign) CGFloat progress;

// 记录是否缩放
@property (nonatomic,assign,readonly) BOOL isScaled;

// 记录是否已经加载图片
@property (nonatomic,assign) BOOL hasLoadedImage;

// 清除缩放
- (void)eliminateScale;

// 设置图片和占位图
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

// 双击缩放比例
- (void)doubleTapToZommWithScale:(CGFloat)scale;

// 清楚
- (void)clear;


@end
