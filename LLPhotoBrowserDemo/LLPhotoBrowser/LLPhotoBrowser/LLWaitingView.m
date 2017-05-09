//
//  LLWaitingView.m
//  LLPhotoBrowser
//
//  Created by liushaohua on 2017/5/4.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLWaitingView.h"
#import "LLPhotoBrowserConfig.h"

@implementation LLWaitingView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = LLWaitingViewBackgroundColor;
        
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        
        // 环形的等待条
        self.mode = LLWaitingViewModeLoopDiagram;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [self setNeedsDisplay];
        
        if (progress >= 1) {
            [self removeFromSuperview];
        }
        
    });
}


- (void)drawRect:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    [[UIColor whiteColor] set];
    
    switch (self.mode) {
            // 饼状
        case LLWaitingViewModeLoopDiagram:
        {
            CGFloat radius = MIN(rect.size.width * 0.5, rect.size.height * 0.5) - LLWaitingViewItemMargin;
            
            CGFloat w = radius * 2 + LLWaitingViewItemMargin;
            CGFloat h = w;
            CGFloat x = (rect.size.width - w) * 0.5;
            CGFloat y = (rect.size.height - h) * 0.5;
            CGContextAddEllipseInRect(ctx, CGRectMake(x, y, w, h));
            CGContextFillPath(ctx);
            
            [LLWaitingViewBackgroundColor set];
            CGContextMoveToPoint(ctx, xCenter, yCenter);
            CGContextAddLineToPoint(ctx, xCenter, 0);
            CGFloat to = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.001; // 初始值
            CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 1);
            CGContextClosePath(ctx);
            
            CGContextFillPath(ctx);
        }
            break;
            // 环形
        default:
        {
            CGContextSetLineWidth(ctx, 15);
            CGContextSetLineCap(ctx, kCGLineCapRound);
            CGFloat to = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.05; // 初始值0.05
            CGFloat radius = MIN(rect.size.width, rect.size.height) * 0.5 - LLWaitingViewItemMargin;
            CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 0);
            CGContextStrokePath(ctx);
        }
            break;
    }

}

@end
