//
//  LLBrowserImageView.h
//  LLPhotoBrowser
//
//  Created by liushaohua on 2017/5/4.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLBrowserImageView : UIImageView<UIGestureRecognizerDelegate>

@property (nonatomic,assign) CGFloat progress;
@property (nonatomic,assign,readonly) BOOL isScaled;
@property (nonatomic,assign) BOOL hasLoadedImage;
- (void)eliminateScale;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void)doubleTapToZommWithScale:(CGFloat)scale;
- (void)clear;


@end
