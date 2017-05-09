//
//  LLPhotoBrowserConfig.h
//  LLPhotoBrowser
//
//  Created by liushaohua on 2017/5/4.
//  Copyright © 2017年 liushaohua. All rights reserved.
//


typedef enum {
    LLWaitingViewModeLoopDiagram, // 环形
    LLWaitingViewModePieDiagram // 饼型
} LLWaitingViewMode;

// 图片保存成功提示文字
#define LLPhotoBrowserSaveImageSuccessText @"保存成功";

// 图片保存失败提示文字
#define LLPhotoBrowserSaveImageFailText @"保存失败";

// browser背景颜色
#define LLPhotoBrowserBackgrounColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.95]

// browser中图片间的margin
#define LLPhotoBrowserImageViewMargin 10

// browser中显示图片动画时长
#define LLPhotoBrowserShowImageAnimationDuration 0.4f

// browser中显示图片动画时长
#define LLPhotoBrowserHideImageAnimationDuration 0.4f

// 图片下载进度指示进度显示样式（SDWaitingViewModeLoopDiagram 环形，SDWaitingViewModePieDiagram 饼型）
#define LLWaitingViewProgressMode LLWaitingViewModeLoopDiagram

// 图片下载进度指示器背景色
#define LLWaitingViewBackgroundColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]

// 图片下载进度指示器内部控件间的间距
#define LLWaitingViewItemMargin 10

// 判读系统版本
#define IOS10_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
