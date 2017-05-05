//
//  LLPhotoBrowser.h
//  LLPhotoBrowser
//
//  Created by liushaohua on 2017/5/4.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import <UIKit/UIKit.h>


@class LLPhotoBrowser;

@protocol LLPhotoBrowserDelegate <NSObject>

@required

// 返回占位图
- (UIImage *)photoBrowser:(LLPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index;

@optional

- (NSURL *)photoBrowser:(LLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index;

@end


@interface LLPhotoBrowser : UIView

// 容器
@property (nonatomic, weak) UIView *sourceImagesContainerView;
// 当前图片的index
@property (nonatomic, assign) NSInteger currentImageIndex;
// 图片的个数
@property (nonatomic, assign) NSInteger imageCount;

@property (nonatomic, weak) id<LLPhotoBrowserDelegate> delegate;
// 此方法展示
- (void)show;


@end
