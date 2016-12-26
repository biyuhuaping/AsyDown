//
//  PEOViewController.m
//  PEOQ
//
//  Created by sibo on 2016/10/31.
//  Copyright © 2016年 sibozn. All rights reserved.
//

#import "PEOViewController.h"
@interface PEOViewController ()

@end
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
@implementation PEOViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    [self createTable];
    [self loadDatasource];
    [self cr:_dataSource];
}
- (void)createTable {
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, WIDTH, HEIGHT) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}
//add datasource实现直接网络加载和数据缓存
- (void)loadDatasource{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = @"http://api.sibozn.com/peo/dev/home.php?v=1";
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        //这里可以用来显示下载进度
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        _dataSource = [RootModel arrayAppmodelWithResponse:responseObject];
        [self cr:_dataSource];
        [_tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //失败
    }];
 

}
- (void)cr:(NSMutableArray *)dataList {
    self.progressArray = [NSMutableArray new];
    self.statusArray = [NSMutableArray new];
    for (NSInteger i = 0; i < 20; i++) {
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
     return _dataSource.count;


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
    self.model = _dataSource[indexPath.row];
    float progressValue = [[self.progressArray objectAtIndex:indexPath.row] floatValue];
    int downloadStauts = [[self.statusArray objectAtIndex:indexPath.row] intValue];
    [cell setDownloadProgress:progressValue WithStatus:downloadStauts with:self.model];
   // 点击下载按钮时回调的代码块
    __weak typeof(cell) weakCell=cell;
    cell.downloadBlock=^(UIButton *sender){
        NSLog(@"button  %@",sender.currentTitle);
        if([sender.currentTitle isEqualToString:@"开始"]||[sender.currentTitle isEqualToString:@"恢复"]){
            
            [sender setTitle:@"暂停" forState:UIControlStateNormal];
            //添加下载任务
            NSLog(@"downlik:%@ name:%@",self.model.downlink,self.model.name);
            [[FGGDownloadManager shredManager] downloadWithUrlString:self.model.downlink toPath:[kCachePath stringByAppendingPathComponent:self.model.name] process:^(float progress, NSString *sizeString, NSString *speedString) {
                //更新进度条的进度值
                weakCell.progressView.progress=progress;
                [self.progressArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithFloat:progress]];
                [self.statusArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInt:DownloadStatusPause]];
                NSLog(@"进度条%f",progress);
                
            } completion:^{
                [sender setTitle:@"完成" forState:UIControlStateNormal];
                sender.enabled=NO;
                [self.progressArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithFloat:0.0]];
                [self.statusArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInt:DownloadStatusComplete]];
                
            } failure:^(NSError *error) {
                [[FGGDownloadManager shredManager] cancelDownloadTask:self.model.downlink];
                [sender setTitle:@"恢复" forState:UIControlStateNormal];
                NSLog(@"错误下载");
                [self.progressArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithFloat:0.0]];
                [self.statusArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInt:DownloadStatusWaiting]];
                
            }];
        }
        else if([sender.currentTitle isEqualToString:@"暂停"])
        {
            [sender setTitle:@"恢复" forState:UIControlStateNormal];
            [[FGGDownloadManager shredManager] cancelDownloadTask:self.model.downlink];
            
        }
    };

    return cell;
    // return [cell tableView:tableView indexPath:indexPath withArray:_dataSource];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
