//
//  PhotoHelper.m
//  DemoAssetsLibrary
//
//  Created by zhangshaoyu on 15/4/15.
//  Copyright (c) 2015年 zhangshaoyu. All rights reserved.
//

#import "PhotoHelper.h"
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoHelper ()

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@property (nonatomic, strong) NSMutableArray *imageResults;
@property (nonatomic, copy) void (^startBlock)(void);
@property (nonatomic, copy) void (^successBlock)(NSArray *imageSuccess);
@property (nonatomic, copy) void (^errorBlock)(void);

@end

@implementation PhotoHelper

- (id)init
{
    self = [super init];
    if (self)
    {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        self.imageResults = [[NSMutableArray alloc] init];
    }
    
    return self;
}

// 清空原有图片
- (void)removeImage
{
    if (self.imageResults && 0 != self.imageResults.count)
    {
        [self.imageResults removeAllObjects];
    }
}

// 第一张图片
- (void)GetImageFirst:(void(^)(NSArray *images))success error:(void(^)(void))error
{
    [self removeImage];
    
    self.successBlock = [success copy];
    self.errorBlock = [error copy];
    
    __weak PhotoHelper *weakSelf = self;
    
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dispatchQueue, ^(void) {
        
        // 遍历所有相册
        [weakSelf.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                          usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                              
                                              // 遍历每个相册中的项ALAsset
                                              [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index,BOOL *stop) {
                                                  
                                                  __block BOOL foundThePhoto = NO;
                                                  if (foundThePhoto)
                                                  {
                                                      *stop = YES;
                                                  }
                                                  
                                                  // ALAsset的类型
                                                  NSString *assetType = [result valueForProperty:ALAssetPropertyType];
                                                  if ([assetType isEqualToString:ALAssetTypePhoto])
                                                  {
                                                      foundThePhoto = YES;
                                                      *stop = YES;
                                                      ALAssetRepresentation *assetRepresentation = [result defaultRepresentation];
                                                      CGFloat imageScale = [assetRepresentation scale];
                                                      UIImageOrientation imageOrientation = (UIImageOrientation)[assetRepresentation orientation];
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                          CGImageRef imageReference = [assetRepresentation fullResolutionImage];
                                                          // 对找到的图片进行操作
                                                          UIImage *image = [[UIImage alloc] initWithCGImage:imageReference scale:imageScale orientation:imageOrientation];
                                                          if (image)
                                                          {
                                                              // 获取到第一张图片
                                                              [weakSelf.imageResults addObject:image];
                                                              if (weakSelf.successBlock)
                                                              {
                                                                  weakSelf.successBlock(weakSelf.imageResults);
                                                              }
                                                          }
                                                          else
                                                          {
                                                              if (weakSelf.errorBlock)
                                                              {
                                                                  weakSelf.errorBlock();
                                                              }
                                                          }
                                                      });
                                                  }
                                              }];
                                          }
                                        failureBlock:^(NSError *error) {
                                            if (weakSelf.errorBlock)
                                            {
                                                weakSelf.errorBlock();
                                            }
                                        }];
        
    });
}

/// 最后一张图片
- (void)GetImagelast:(void(^)(NSArray *images))success error:(void(^)(void))error
{
    [self removeImage];
    
    self.successBlock = [success copy];
    self.errorBlock = [error copy];
    
    __weak PhotoHelper *weakSelf = self;
    
    __block NSString *assetPropertyType = ALAssetTypePhoto;
    __block NSMutableArray *assets = [[NSMutableArray alloc] init];
    
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
    {
        if (!group)
        {
            if (weakSelf.errorBlock)
            {
                weakSelf.errorBlock();
            }
            return;
        }
        *stop = YES;
        
        __block int num = 0;
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
         {
             if (!result)
             {
                 if (weakSelf.errorBlock)
                 {
                     weakSelf.errorBlock();
                 }
                 return;
             }
             
             __block ALAsset *assetResult = result;
             num++;
             NSInteger numberOf = [group numberOfAssets];
             
             NSString *al_assetPropertyType = [assetResult valueForProperty:ALAssetPropertyType];
             if ([al_assetPropertyType isEqualToString:assetPropertyType])
             {
                 [assets addObject:assetResult];
             }
             
             if (num == numberOf)
             {
                 UIImage *image = [UIImage imageWithCGImage:[[assets lastObject] thumbnail]];
                 if (image)
                 {
                     // 获取到第一张图片
                     [weakSelf.imageResults addObject:image];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (weakSelf.successBlock)
                         {
                             weakSelf.successBlock(weakSelf.imageResults);
                         }
                     });
                 }
             }
         }];
    };
    
    // Group Enumerator Failure Block
    void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (weakSelf.errorBlock)
            {
                weakSelf.errorBlock();
            }
        });
    };
    
    // Enumerate Albums
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                      usingBlock:assetGroupEnumerator
                                    failureBlock:assetGroupEnumberatorFailure];
}

/// 最后一张图片，方法2
- (void)GetImagelastSec:(void(^)(NSArray *images))success error:(void(^)(void))error
{
    [self removeImage];
    
    self.successBlock = [success copy];
    self.errorBlock = [error copy];
    
    __weak PhotoHelper *weakSelf = self;

    // Block called for every asset selected
    void (^selectionBlock)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *asset, NSUInteger index, BOOL *innerStop) {
        // The end of the enumeration is signaled by asset == nil.
        if (!asset)
        {
            if (weakSelf.errorBlock)
            {
                weakSelf.errorBlock();
            }
            return;
        }
        
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        // Retrieve the image orientation from the ALAsset
        UIImageOrientation orientation = UIImageOrientationUp;
        NSNumber *orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
        if (orientationValue)
        {
            orientation = [orientationValue intValue];
        }
        
        CGFloat scale  = 1.0;
        UIImage *image = [UIImage imageWithCGImage:[representation fullResolutionImage] scale:scale orientation:orientation];
        if (image)
        {
            // 获取到第一张图片
            [weakSelf.imageResults addObject:image];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.successBlock)
                {
                    weakSelf.successBlock(weakSelf.imageResults);
                }
            });
        }
    };
    
    // Block called when enumerating asset groups
    void (^enumerationBlock)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
    {
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // Get the photo at the last index
        NSUInteger index              = [group numberOfAssets] - 1;
        NSIndexSet *lastPhotoIndexSet = [NSIndexSet indexSetWithIndex:index];
        [group enumerateAssetsAtIndexes:lastPhotoIndexSet options:0 usingBlock:selectionBlock];
    };
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:enumerationBlock
                         failureBlock:^(NSError *error) {
                             // handle error
                             if (weakSelf.errorBlock)
                             {
                                 weakSelf.errorBlock();
                             }
                         }];
}

/// 所有图片
- (void)GetImageAll:(void(^)(NSArray *images))success error:(void(^)(void))error
{
    [self removeImage];
    
//    self.successBlock = [success copy];
//    self.errorBlock = [error copy];
//    
//    __weak PhotoHelper *weakSelf = self;
}

////////////////////////////////////////////////////////////////////////////////////

/// 获取n张相片（0时为全部），最新的或最早的
- (void)GetImagesWithNum:(NSInteger)count latest:(BOOL)latest start:(void(^)(void))start success:(void(^)(NSArray *images))success error:(void(^)(void))error
{
    [self removeImage];
    
    NSInteger imageCount = count;
    BOOL islatest = latest;
    
    self.startBlock = [start copy];
    self.successBlock = [success copy];
    self.errorBlock = [error copy];
    
    __weak PhotoHelper *weakSelf = self;
    
    __block NSString *assetPropertyType = ALAssetTypePhoto;
    __block NSMutableArray *assets = [[NSMutableArray alloc] init];
    
    if (self.startBlock)
    {
        self.startBlock();
    }
    
    /*
     void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
     {
     if (!group)
     {
     return;
     }
     *stop = YES;
     
     __block int num = 0;
     [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
     {
     if (!result)
     {
     return;
     }
     
     __block ALAsset *assetResult = result;
     num++;
     NSInteger numberOf = [group numberOfAssets];
     
     NSString *al_assetPropertyType = [assetResult valueForProperty:ALAssetPropertyType];
     if ([al_assetPropertyType isEqualToString:assetPropertyType])
     {
     [assets addObject:assetResult];
     }
     
     if (num == numberOf)
     {
     if (0 == imageCount)
     {
     [weakSelf GetImageAll:assets];
     }
     else
     {
     [weakSelf GetImagelastest:islatest num:imageCount images:assets];
     }
     }
     }];
     };
     
     // Group Enumerator Failure Block
     void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     NSLog(@"error failure");
     
     if (weakSelf.errorBlock)
     {
     weakSelf.errorBlock();
     }
     });
     };
     
     // Enumerate Albums
     [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
     usingBlock:assetGroupEnumerator
     failureBlock:assetGroupEnumberatorFailure];
     */
    
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dispatchQueue, ^(void) {
        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
        {
            if (!group)
            {
                return;
            }
            *stop = YES;
            
            __block int num = 0;
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
             {
                 if (!result)
                 {
                     return;
                 }
                 
                 __block ALAsset *assetResult = result;
                 num++;
                 NSInteger numberOf = [group numberOfAssets];
                 
                 NSString *al_assetPropertyType = [assetResult valueForProperty:ALAssetPropertyType];
                 if ([al_assetPropertyType isEqualToString:assetPropertyType])
                 {
                     [assets addObject:assetResult];
                 }
                 
                 if (num == numberOf)
                 {
                     if (0 == imageCount)
                     {
                         [weakSelf GetImageAll:assets];
                     }
                     else
                     {
                         [weakSelf GetImagelastest:islatest num:imageCount images:assets];
                     }
                 }
             }];
        };
        
        // Group Enumerator Failure Block
        void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSLog(@"error failure");
                
                if (weakSelf.errorBlock)
                {
                    weakSelf.errorBlock();
                }
            });
        };
        
        // Enumerate Albums
        [weakSelf.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                          usingBlock:assetGroupEnumerator
                                        failureBlock:assetGroupEnumberatorFailure];
    });
}

// 获取所有相片
- (void)GetImageAll:(NSArray *)array
{
    for (ALAsset *assetResult in array)
    {
//        CGImageRef imageRef = [assetResult thumbnail]; // 缩略图
        CGImageRef imageRef = [[assetResult defaultRepresentation] fullScreenImage]; // 原图
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        if (image)
        {
            // 获取到第一张图片
            [self.imageResults addObject:image];
        }
    }
    
    __weak PhotoHelper *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.successBlock)
        {
            weakSelf.successBlock(weakSelf.imageResults);
        }
    });
}

// 获取最新的，或最早的
- (void)GetImagelastest:(BOOL)latest num:(NSInteger)count images:(NSArray *)array
{
    if (!array || 0 == array.count)
    {
        return;
    }
    
    __weak PhotoHelper *weakSelf = self;
    
    NSMutableArray *images = [[NSMutableArray alloc] initWithArray:array];
    NSInteger realCount = images.count; // 实际图片数量
    NSInteger limitCount = (realCount < count ? realCount : count); // 实际限制图片数量
    
    if (latest)
    {
        for (int i = 0; i < limitCount; i++)
        {
            ALAsset *assetResult = [images lastObject];
//            CGImageRef imageRef = [assetResult thumbnail]; // 缩略图
            CGImageRef imageRef = [[assetResult defaultRepresentation] fullScreenImage]; // 原图
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            if (image)
            {
                // 获取到第一张图片
                [self.imageResults addObject:image];
            }
            [images removeLastObject];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.successBlock)
            {
                weakSelf.successBlock(weakSelf.imageResults);
            }
        });
    }
    else
    {
        for (int i = 0; i < limitCount; i++)
        {
            ALAsset *assetResult = [images objectAtIndex:i];
//            CGImageRef imageRef = [assetResult thumbnail]; // 缩略图
            CGImageRef imageRef = [[assetResult defaultRepresentation] fullScreenImage]; // 原图
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            if (image)
            {
                // 获取到第一张图片
                [self.imageResults addObject:image];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.successBlock)
            {
                weakSelf.successBlock(weakSelf.imageResults);
            }
        });
    }
}

////////////////////////////////////////////////////////////////////////////////////

/*
 调用系统相册、相机发现是英文的系统相簿界面后标题显示“photos”，但是手机语言已经设置显示中文，纠结半天，最终在info.plist设置解决问题
 info.plist里面添加Localized resources can be mixed YES
 表示是否允许应用程序获取框架库内语言。
 */

@end
