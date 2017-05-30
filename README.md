# LLPhotoBrowser
本人简书地址有任何疑问可简书留言 尽可能的帮助每一个开发人员😃😃😃

http://www.jianshu.com/p/58e8b04fc4b7

##仿微信的图片放大浏览

[LLPhotoBrowserAnim.gif](http://upload-images.jianshu.io/upload_images/1030171-ab1eef55e80bd10f.gif?imageMogr2/auto-orient/strip)

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

// 代理方法返回缩略图
- (UIImage *)photoBrowser:(LLPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    LLPhotoCell *cell = (LLPhotoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    return cell.bigImgV.image;
    
}
```


后续：也可在代码中更改长按图片后弹出的LLActionSheetView 实现自定义


