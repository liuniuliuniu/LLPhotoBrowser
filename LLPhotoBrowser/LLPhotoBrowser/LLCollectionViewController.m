//
//  LLCollectionViewController.m
//  LLPhotoBrowser
//
//  Created by liushaohua on 2017/5/5.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLCollectionViewController.h"
#import "LLPhotoCell.h"
#import "LLPhotoBrowser.h"
#import "UIImageView+WebCache.h"

static NSString * const reuseIdentifier = @"CellID";
@interface LLCollectionViewController ()<LLPhotoBrowserDelegate>

@property(nonatomic, strong)NSArray *photoArr;

@end

@implementation LLCollectionViewController


//    初始化布局 重新设置layout
- (instancetype)init{
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
//    CGFloat  screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake((screenWidth - 50)/3, (screenWidth - 50)/3 * 1.5);
    
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 7.5;

    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    return [super initWithCollectionViewLayout:flowLayout];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[LLPhotoCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.photoArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LLPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [cell.bigImgV sd_setImageWithURL:_photoArr[indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // 1 初始化
    LLPhotoBrowser *photoBrowser = [[LLPhotoBrowser alloc]init];
    // 2 设置代理
    photoBrowser.delegate = self;
    // 3 设置当前图片
    photoBrowser.currentImageIndex = indexPath.item;
    // 4 设置图片的个数
    photoBrowser.imageCount = self.photoArr.count;
    // 5 设置图片的容器
    photoBrowser.sourceImagesContainerView = self.collectionView;
    // 6 展示
    [photoBrowser show];

}

// 代理方法 返回图片URL
- (NSURL *)photoBrowser:(LLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    
    NSURL *url = [NSURL URLWithString:self.photoArr[index]];
    
    return url;
}
// 代理方法返回缩略图
- (UIImage *)photoBrowser:(LLPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    LLPhotoCell *cell = (LLPhotoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    return cell.bigImgV.image;
    
}


// 返回每一组item的列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
// 组的内边距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10,10 ,10 , 10);
}


- (NSArray *)photoArr{
    if (!_photoArr) {
        _photoArr = @[@"http://ww2.sinaimg.cn/mw690/e67669aagw1fa6gynybcsj20iz0sgwhk.jpg",
                      @"http://ww2.sinaimg.cn/mw690/e67669aagw1fbfr3ryrt2j21kw2dc4eo.jpg",
                      @"http://wx4.sinaimg.cn/mw690/63e6fd01ly1fe2iqm8d2wj20qo11cn5d.jpg",
                      @"http://ww4.sinaimg.cn/bmiddle/6a15cf5aly1fewww17l6rj20qo0yatfc.jpg",
                      @"http://wx3.sinaimg.cn/mw690/b024b1c1ly1feg7x4lu0cg20dw07te85.gif",
                      @"http://ww3.sinaimg.cn/bmiddle/c45009afgy1ff9r1z9nsgj20qo3abhcj.jpg"];
    }
    return _photoArr;
}




@end
