//
//  SYLibraryPhoto.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 15/4/15.
//  Copyright (c) 2015年 zhangshaoyu. All rights reserved.
//  从图库获取图片

#import <Foundation/Foundation.h>

@interface SYLibraryPhoto : NSObject

/// 第一张图片
- (void)GetImageFirst:(void(^)(NSArray *images))success error:(void(^)(void))error;

/// 最后一张图片，方法1
- (void)GetImagelast:(void(^)(NSArray *images))success error:(void(^)(void))error;

/// 最后一张图片，方法2
- (void)GetImagelastSec:(void(^)(NSArray *images))success error:(void(^)(void))error;

/// 所有图片
- (void)GetImageAll:(void(^)(NSArray *images))success error:(void(^)(void))error;

/// 获取n张相片（0时为全部），最新的或最早的
- (void)GetImagesWithNum:(NSInteger)count latest:(BOOL)latest start:(void(^)(void))start success:(void(^)(NSArray *images))success error:(void(^)(void))error;

@end

/*
 1 添加 AssetsLibrary.framework
 2 #import <AssetsLibrary/AssetsLibrary.h>
 
 */