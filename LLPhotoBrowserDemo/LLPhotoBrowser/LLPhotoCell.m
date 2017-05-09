//
//  LLPhotoCell.m
//  LLPhotoBrowser
//
//  Created by liushaohua on 2017/5/5.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLPhotoCell.h"

@implementation LLPhotoCell

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    UIImageView *bigImgV = [UIImageView new];
    bigImgV.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:bigImgV];
    bigImgV.frame = self.bounds;

    self.bigImgV = bigImgV;

}
@end
