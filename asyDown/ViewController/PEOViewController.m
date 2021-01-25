//
//  PEOViewController.m
//  PEOQ
//
//  Created by sibo on 2016/10/31.
//  Copyright © 2016年 sibozn. All rights reserved.
//

#import "PEOViewController.h"
#import "YYModel.h"

#define kServiceUrl @"http://app.mkwhat.com/"


@interface PEOViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) ChapterModel *cpModel;

@end

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@implementation PEOViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    [self loadDatasource];
//    [self cr:_dataSource];
    [self getQueryClassById];
}

#pragma mark - net
//add datasource实现直接网络加载和数据缓存
- (void)loadDatasource{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = @"http://api.sibozn.com/peo/dev/home.php?v=1";
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:url parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        //这里可以用来显示下载进度
        NSLog(@"下载进度----: %@", downloadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        _dataSource = [RootModel arrayAppmodelWithResponse:responseObject];
        [self cr:_dataSource];
        [_tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //失败
        NSLog(@"下载失败：%@", error);
    }];
}

//课程列表
- (void)getQueryClassById{
    NSString *ua = @"1{|}12.1.4{|}1.0.6{|}iOS{|}36E8A701-B4C9-4540-A337-E0C8E28AEC18{|}1{|}qianls1{|}";
    NSString *UserAgent = @"ren ren wen qian-cai shang zi xun/1.0.6 (iPhone; iOS 12.1.4; Scale/3.00)";
    NSString *language = @"zh-Hans-CN;q=1, en-CN;q=0.9";
    
    NSDictionary *headerDic = @{
        @"ua":ua,
        @"User-Agent":UserAgent,
        @"Accept-Language":language,
        @"Authorization":@"6ee0af0b331a408cbe72b3ee2f39f123",
    };
    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kServiceUrl]];

    NSString *url = @"content/queryClassById";
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager GET:url parameters:@{@"id":@"36", @"uuid":@"395A158E-5DF6-4AF0-A759-9E097A13BE87"} headers:headerDic progress:^(NSProgress * _Nonnull downloadProgress) {
        //这里可以用来显示下载进度
        NSLog(@"下载进度----: %@", downloadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [NSArray yy_modelArrayWithClass:ChapterModel.class json:responseObject[@"data"][@"chapter"]];
        NSLog(@"%@",array);
        self.dataArray = [NSMutableArray arrayWithArray:array];
        [self cr:self.dataArray];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //失败
        NSLog(@"下载失败：%@", error);
    }];
}

- (void)cr:(NSMutableArray *)dataList {
    self.progressArray = [NSMutableArray new];
    self.statusArray = [NSMutableArray new];
    for (NSInteger i = 0; i < dataList.count; i++) {
        NSLog(@"%ld",i);
        [_progressArray addObject:[NSNumber numberWithFloat:0.0]];
        [_statusArray addObject:[NSNumber numberWithInt:DownloadStatusLoading]];
    }
}

#pragma UItableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    RootTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[RootTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    self.cpModel = self.dataArray[indexPath.row];
    float progressValue = [[self.progressArray objectAtIndex:indexPath.row] floatValue];
    int downloadStauts = [[self.statusArray objectAtIndex:indexPath.row] intValue];
    [cell setDownloadProgress:progressValue WithStatus:downloadStauts with:self.cpModel];
    
   // 点击下载按钮时回调的代码块
    __weak typeof(cell) weakCell = cell;
    cell.downloadBlock = ^(UIButton *sender){
        NSLog(@"button  %@",sender.currentTitle);
        if([sender.currentTitle isEqualToString:@"开始"]||[sender.currentTitle isEqualToString:@"恢复"]){
            [sender setTitle:@"暂停" forState:UIControlStateNormal];
            //添加下载任务
            NSLog(@"downlik:%@ name:%@",self.cpModel.url,self.cpModel.title);
            [[FGGDownloadManager shredManager] downloadWithUrlString:self.cpModel.url toPath:[kCachePath stringByAppendingPathComponent:self.cpModel.title] process:^(float progress, NSString *sizeString, NSString *speedString) {
                
                //更新进度条的进度值
                weakCell.progressView.progress = progress;
                [self.progressArray replaceObjectAtIndex:indexPath.row withObject:@(progress)];
                [self.statusArray replaceObjectAtIndex:indexPath.row withObject:@(DownloadStatusPause)];
                NSLog(@"进度条%f",progress);
                
            } completion:^{
                [sender setTitle:@"完成" forState:UIControlStateNormal];
                sender.enabled = NO;
                [self.progressArray replaceObjectAtIndex:indexPath.row withObject:@(0.0)];
                [self.statusArray replaceObjectAtIndex:indexPath.row withObject:@(DownloadStatusComplete)];
                
            } failure:^(NSError *error) {
                [[FGGDownloadManager shredManager] cancelDownloadTask:self.cpModel.url];
                [sender setTitle:@"恢复" forState:UIControlStateNormal];
                NSLog(@"错误下载");
                [self.progressArray replaceObjectAtIndex:indexPath.row withObject:@(0.0)];
                [self.statusArray replaceObjectAtIndex:indexPath.row withObject:@(DownloadStatusWaiting)];
            }];
        }
        else if([sender.currentTitle isEqualToString:@"暂停"]){
            [sender setTitle:@"恢复" forState:UIControlStateNormal];
            [[FGGDownloadManager shredManager] cancelDownloadTask:self.cpModel.url];
        }
    };

    return cell;
    // return [cell tableView:tableView indexPath:indexPath withArray:_dataSource];
}

@end
