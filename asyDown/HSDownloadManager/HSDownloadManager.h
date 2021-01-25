//
//  HSDownloadManager.h
//  HSDownloadManagerExample
//
//  Created by hans on 15/8/4.
//  Copyright © 2015年 hans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSSessionModel.h"

@interface HSDownloadManager : NSObject

/// 单例
/// @return 返回单例对象
+ (instancetype)sharedInstance;

/// 开启任务下载资源
/// @param url           下载地址
/// @param progressBlock 回调下载进度
/// @param stateBlock    下载状态
- (void)download:(NSString *)url progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))progressBlock state:(void(^)(DownloadState state))stateBlock;

/// 查询该资源的下载进度值
/// @param name 文件名称
/// @return 返回下载进度值
- (CGFloat)progress:(NSString *)name;

/// 获取该资源总大小
/// @param name 文件名称
/// @return 资源总大小
- (NSInteger)fileTotalLength:(NSString *)name;

/// 判断该资源是否下载完成
/// @param name 文件名称
/// @return YES: 完成
- (BOOL)isCompletion:(NSString *)name;

/// 查询该资源
/// @param name 文件名称
- (NSString *)queryFile:(NSString *)name;

/// 删除该资源
/// @param name 文件名称
- (void)deleteFile:(NSString *)name;

/// 清空所有下载资源
- (void)deleteAllFile;

@end
