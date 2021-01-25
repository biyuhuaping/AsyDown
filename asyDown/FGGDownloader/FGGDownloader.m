//
//  FGGDownloader.m
//  大文件下载(断点续传)
//
//  Created by 夏桂峰 on 15/9/21.
//  Copyright (c) 2015年 峰哥哥. All rights reserved.
//

#import "FGGDownloader.h"
#import <UIKit/UIKit.h>


/// 缓存主目录
#define HSCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"HSCache"]

/// 保存文件名
#define HSFileName(url) [url componentsSeparatedByString:@"?"].firstObject

/// 文件的存放路径（caches）
#define HSFileFullpath(url) [HSCachesDirectory stringByAppendingPathComponent:HSFileName(url)]

/// 文件的已下载长度
#define HSDownloadLength(url) [[[NSFileManager defaultManager] attributesOfItemAtPath:HSFileFullpath(url) error:nil][NSFileSize] integerValue]

/// 存储文件总长度的文件路径（caches）
#define HSTotalLengthFullpath [HSCachesDirectory stringByAppendingPathComponent:@"totalLength.plist"]



@interface FGGDownloader ()<NSURLSessionDelegate>

/// 保存所有任务(注：用下载地址md5后作为key)
@property (nonatomic, strong) NSMutableDictionary *tasks;

@property (nonatomic, strong) NSURLSessionDataTask *task;
/// 保存所有下载相关信息
@property (nonatomic, strong) NSMutableDictionary *sessionModels;

@end

@implementation FGGDownloader
{
    NSString        *_url_string;
    NSString        *_destination_path;
    NSFileHandle    *_writeHandle;
    NSURLConnection *_con;
    NSUInteger       _lastSize;
    NSUInteger       _growth;
    NSTimer         *_timer;
}

//计算一次文件大小增加部分的尺寸
- (void)getGrowthSize{
    NSUInteger size = [[[[NSFileManager defaultManager] attributesOfItemAtPath:_destination_path error:nil] objectForKey:NSFileSize] integerValue];
    _growth = size-_lastSize;
    _lastSize = size;
}

- (instancetype)init{
    if(self = [super init]){
        //每0.5秒计算一次文件大小增加部分的尺寸
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getGrowthSize) userInfo:nil repeats:YES];
    }
    return self;
}

/// 获取对象的类方法
+ (instancetype)downloader{
    return [[[self class] alloc]init];
}

/// 断点下载
/// @param urlString        下载的链接
/// @param destinationPath  下载的文件的保存路径
/// @param progressBlock    下载过程中回调的代码块，会多次调用
/// @param completion      下载完成回调的代码块
/// @param failure         下载失败的回调代码块
- (void)downloadWithUrlString:(NSString *)urlString toPath:(NSString *)destinationPath process:(ProgressBlock)progressBlock completion:(CompletionHandle)completion failure:(FailureHandle)failure{
    if(urlString && destinationPath) {
        _url_string = urlString;
        _destination_path = destinationPath;
        _progressBlock = progressBlock;
        _completion = completion;
        _failure = failure;
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        //创建缓存目录文件
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExist = [fileManager fileExistsAtPath:destinationPath];
        if(fileExist) {
            NSUInteger length = [[[fileManager attributesOfItemAtPath:destinationPath error:nil] objectForKey:NSFileSize] integerValue];
            NSString *rangeString = [NSString stringWithFormat:@"bytes=%ld-",length];
            [request setValue:rangeString forHTTPHeaderField:@"Range"];
        }
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];

        NSURLSessionConfiguration *cfg = [ NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
        [task resume];
        self.task = task;
    }
}

/// 取消下载
- (void)cancel{
    [self.task cancel];
    self.task = nil;
    if(_timer) {
        [_timer invalidate];
    }
}

/// 获取上一次的下载进度
+ (float)lastProgress:(NSString *)url{
    if(url)
        return [[NSUserDefaults standardUserDefaults]floatForKey:[NSString stringWithFormat:@"%@progress",url]];
    return 0.0;
}

/// 获取文件已下载的大小和总大小,格式为:已经下载的大小/文件总大小,如：12.00M/100.00M
+ (NSString *)filesSize:(NSString *)url{
    NSString *totalLebgthKey=[NSString stringWithFormat:@"%@totalLength",url];
    NSUserDefaults *usd = [NSUserDefaults standardUserDefaults];
    NSUInteger totalLength = [usd integerForKey:totalLebgthKey];
    if(totalLength == 0) {
        return @"0.00K/0.00K";
    }
    NSString *progressKey = [NSString stringWithFormat:@"%@progress",url];
    float progress = [[NSUserDefaults standardUserDefaults] floatForKey:progressKey];
    NSUInteger currentLength = progress*totalLength;
    
    NSString *currentSize = [self convertSize:currentLength];
    NSString *totalSize = [self convertSize:totalLength];
    return [NSString stringWithFormat:@"%@/%@",currentSize,totalSize];
}

/// 获取系统可用存储空间 , 单位：字节
- (NSUInteger)systemFreeSpace{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfFileSystemForPath:docPath error:nil];
    return [[dict objectForKey:NSFileSystemFreeSize] integerValue];
}

#pragma mark - NSURLConnection
/// 接收到响应请求
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    NSString *key = [NSString stringWithFormat:@"%@totalLength",_url_string];
    NSUserDefaults *usd = [NSUserDefaults standardUserDefaults];
    NSUInteger totalLength = [usd integerForKey:key];
    if(totalLength == 0) {
        [usd setInteger:response.expectedContentLength forKey:key];
        [usd synchronize];
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExist = [fileManager fileExistsAtPath:_destination_path];
    if(!fileExist)
        [fileManager createFileAtPath:_destination_path contents:nil attributes:nil];
    _writeHandle = [NSFileHandle fileHandleForWritingAtPath:_destination_path];
}

/// 接收到服务器返回的数据, 下载过程，会多次调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [_writeHandle seekToEndOfFile];
    
    NSUInteger freeSpace = [self systemFreeSpace];
    if(freeSpace < 1024*1024*20){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"系统可用存储空间不足20M" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:confirm];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
        //发送系统存储空间不足的通知,用户可自行注册该通知，收到通知时，暂停下载，并更新界面
        [[NSNotificationCenter defaultCenter] postNotificationName:FGGInsufficientSystemSpaceNotification object:nil userInfo:@{@"urlString":_url_string}];
        return;
    }
    
    [_writeHandle writeData:data];
    NSUInteger length = [[[[NSFileManager defaultManager] attributesOfItemAtPath:_destination_path error:nil] objectForKey:NSFileSize] integerValue];
    NSString *key = [NSString stringWithFormat:@"%@totalLength",_url_string];
    NSUInteger totalLength = [[NSUserDefaults standardUserDefaults] integerForKey:key];
    
    //计算下载进度
    float progress = (float)length/totalLength;
    
    [[NSUserDefaults standardUserDefaults]setFloat:progress forKey:[NSString stringWithFormat:@"%@progress",_url_string]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //获取文件大小，格式为：格式为:已经下载的大小/文件总大小,如：12.00M/100.00M
    NSString *sizeString = [FGGDownloader filesSize:_url_string];
    
    //发送进度改变的通知(一般情况下不需要用到，只有在触发下载与显示下载进度在不同界面的时候才会用到)
    NSDictionary *userInfo = @{@"url":_url_string,@"progress":@(progress),@"sizeString":sizeString};
    [[NSNotificationCenter defaultCenter] postNotificationName:FGGProgressDidChangeNotificaiton object:nil userInfo:userInfo];
    
    //计算网速
    NSString *speedString = @"0.00Kb/s";
    NSString *growString = [FGGDownloader convertSize:_growth*(1.0/0.1)];
    speedString = [NSString stringWithFormat:@"%@/s",growString];
    
    //回调下载过程中的代码块
    if(self.progressBlock){
        self.progressBlock(progress,sizeString,speedString);
    }
}

/// 请求完毕（成功|失败）
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    [[NSNotificationCenter defaultCenter] postNotificationName:FGGDownloadTaskDidFinishDownloadingNotification object:nil userInfo:@{@"urlString":_url_string}];
    if(_completion){
        _completion();
    }else if(_failure){ /// 下载失败
        _failure(error);
    }
}

#pragma mark -
/// 开启任务下载资源
- (void)downloadWithURL:(NSString *)url progress:(ProgressBlock)progressBlock state:(void (^)(DownloadState))stateBlock{
    if (!url) return;
    self.progressBlock = progressBlock;

    NSString *name = [url componentsSeparatedByString:@"?"].firstObject;
    name = [name stringByReplacingOccurrencesOfString:kFilePath withString:@""];
    if ([self isCompletion:name]) {
        stateBlock(DownloadStateCompleted);
        NSLog(@"----该资源已下载完成---\n%@",name);
        return;
    }
    
    // 暂停
    if ([self.tasks valueForKey:HSFileName(name)]) {
        [self handle:name];
        return;
    }
    
    // 创建缓存目录文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:HSCachesDirectory]) {
        [fileManager createDirectoryAtPath:HSCachesDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    // 创建流
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:HSFileFullpath(name) append:YES];
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", HSDownloadLength(name)];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    // 创建一个Data任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    NSUInteger taskIdentifier = arc4random() % ((arc4random() % 10000 + arc4random() % 10000));
    [task setValue:@(taskIdentifier) forKeyPath:@"taskIdentifier"];
    
    // 保存任务
    [self.tasks setValue:task forKey:HSFileName(name)];
    
    HSSessionModel *sessionModel = [[HSSessionModel alloc] init];
    sessionModel.name = name;
//    sessionModel.progressBlock = progressBlock;
    sessionModel.stateBlock = stateBlock;
    sessionModel.stream = stream;
    [self.sessionModels setValue:sessionModel forKey:@(task.taskIdentifier).stringValue];
    
    [self start:name];
}

- (void)handle:(NSString *)name{
    NSURLSessionDataTask *task = [self getTask:name];
    if (task.state == NSURLSessionTaskStateRunning) {
        [self pause:name];
    } else {
        [self start:name];
    }
}

/// 开始下载
- (void)start:(NSString *)name{
    NSURLSessionDataTask *task = [self getTask:name];
    [task resume];
    
    [self getSessionModel:task.taskIdentifier].stateBlock(DownloadStateStart);
}

/// 暂停下载
- (void)pause:(NSString *)name{
    NSURLSessionDataTask *task = [self getTask:name];
    [task suspend];
    
    [self getSessionModel:task.taskIdentifier].stateBlock(DownloadStateSuspended);
}

/// 根据url获得对应的下载任务
- (NSURLSessionDataTask *)getTask:(NSString *)name{
    return (NSURLSessionDataTask *)[self.tasks valueForKey:HSFileName(name)];
}

/// 根据url获取对应的下载信息模型
- (HSSessionModel *)getSessionModel:(NSUInteger)taskIdentifier{
    return (HSSessionModel *)[self.sessionModels valueForKey:@(taskIdentifier).stringValue];
}

/// 判断该文件是否下载完成
- (BOOL)isCompletion:(NSString *)name{
    if ([self fileTotalLength:name] && HSDownloadLength(name) == [self fileTotalLength:name]) {
        return YES;
    }
    return NO;
}

/// 查询该资源的下载进度值
- (CGFloat)progress:(NSString *)name{
    return [self fileTotalLength:name] == 0 ? 0.0 : 1.0 * HSDownloadLength(name) /  [self fileTotalLength:name];
}

/// 获取该资源总大小
- (NSInteger)fileTotalLength:(NSString *)name{
    return [[NSDictionary dictionaryWithContentsOfFile:HSTotalLengthFullpath][HSFileName(name)] integerValue];
}

/*#pragma mark - 代理
#pragma mark NSURLSessionDataDelegate
/// 接收到响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    HSSessionModel *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    
    // 打开流
    [sessionModel.stream open];

    // 获得服务器这次请求 返回数据的总长度
    NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + HSDownloadLength(sessionModel.name);
    sessionModel.totalLength = totalLength;
    
    // 存储总长度
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:HSTotalLengthFullpath];
    if (dict == nil) dict = [NSMutableDictionary dictionary];
    dict[HSFileName(sessionModel.name)] = @(totalLength);
    [dict writeToFile:HSTotalLengthFullpath atomically:YES];
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

/// 接收到服务器返回的数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    HSSessionModel *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    
    // 写入数据
    [sessionModel.stream write:data.bytes maxLength:data.length];
    
    // 下载进度
    NSUInteger receivedSize = HSDownloadLength(sessionModel.name);
    NSUInteger expectedSize = sessionModel.totalLength;
    CGFloat progress = 1.0 * receivedSize / expectedSize;
    
    sessionModel.progressBlock(receivedSize, expectedSize, progress);
}

/// 请求完毕（成功|失败）
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    HSSessionModel *sessionModel = [self getSessionModel:task.taskIdentifier];
    if (!sessionModel) return;
    
    if ([self isCompletion:sessionModel.name]) {
        // 下载完成
        sessionModel.stateBlock(DownloadStateCompleted);
    } else if (error){
        // 下载失败
        sessionModel.stateBlock(DownloadStateFailed);
    }
    
    // 关闭流
    [sessionModel.stream close];
    sessionModel.stream = nil;
    
    // 清除任务
    [self.tasks removeObjectForKey:HSFileName(sessionModel.name)];
    [self.sessionModels removeObjectForKey:@(task.taskIdentifier).stringValue];
}*/

/// 计算缓存的占用存储大小
/// @param length 文件大小
+ (NSString *)convertSize:(NSUInteger)length{
    if(length < 1024)
        return [NSString stringWithFormat:@"%ldB",(NSUInteger)length];
    else if(length >= 1024 && length < 1024*1024)
        return [NSString stringWithFormat:@"%.0fK",(float)length/1024];
    else if(length >= 1024*1024 && length < 1024*1024*1024)
        return [NSString stringWithFormat:@"%.1fM",(float)length/(1024*1024)];
    else
        return [NSString stringWithFormat:@"%.1fG",(float)length/(1024*1024*1024)];
}

- (NSMutableDictionary *)tasks{
    if (!_tasks) {
        _tasks = [NSMutableDictionary dictionary];
    }
    return _tasks;
}

- (NSMutableDictionary *)sessionModels{
    if (!_sessionModels) {
        _sessionModels = [NSMutableDictionary dictionary];
    }
    return _sessionModels;
}

@end
