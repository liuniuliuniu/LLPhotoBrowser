# LLPhotoBrowser
##仿微信的图片放大浏览

![LLPhotoBrowserAnim.gif](http://upload-images.jianshu.io/upload_images/1030171-f31f196571ddb5e6.gif?imageMogr2/auto-orient/strip)

####使用方法

```
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

后续：也可在代码中更改长按图片后弹出的LLActionSheetView 实现自定义


