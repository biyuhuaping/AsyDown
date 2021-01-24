//
//  RootTableViewCell.m
//  PEOQ
//
//  Created by sibo on 2016/11/17.
//  Copyright © 2016年 sibozn. All rights reserved.
//

#import "RootTableViewCell.h"
#import "FGGDownloadManager.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define kCachePath (NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0])

@implementation RootTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//重写初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
        [self initFrame];
    }
    return self;
}

- (void)initUI {
    _Tlabel = [[UILabel alloc]init];
    _Dlabel = [[UILabel alloc]init];
    _Xbutton = [UIButton buttonWithType:UIButtonTypeSystem];
    _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];

    [self.contentView addSubview:_Tlabel];
    [self.contentView addSubview:_Dlabel];
    [self.contentView addSubview:_Xbutton];
    [self.contentView addSubview:_progressView];
}

- (void)initFrame {
    CGFloat topSpace =10;
    CGFloat leftSpace = 10;
    _Tlabel.frame = CGRectMake(leftSpace, topSpace+1, 150, 30);
    _Tlabel.font = [UIFont systemFontOfSize:16];
    CGFloat tlableY = CGRectGetMaxY(_Tlabel.frame);
    _Dlabel.frame = CGRectMake(leftSpace, tlableY+3,WIDTH-150-70, 30);
    _Dlabel.textColor = [UIColor grayColor];
    _Dlabel.font = [UIFont systemFontOfSize:14];

    _Xbutton.frame = CGRectMake(WIDTH-60, tlableY/2, 50, 33);
    UIImage *buttonImage = [UIImage imageNamed:@"ajm.9.png"];
    [_Xbutton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [_Xbutton setBackgroundColor:[UIColor blueColor]];
    _Xbutton.layer.masksToBounds = YES;
    _Xbutton.layer.cornerRadius = 8.0;
    
    _progressView.frame = CGRectMake(160, 20, 100, 30);
    _progressView.tintColor = [UIColor redColor];
    _progressView.trackTintColor = [UIColor yellowColor];
    _progressView.progress = 0.0;
}

//把下载这件事交给model去做，model暴露状态、进度等属性。cell通过KVO监视进度
- (void)configData:(RootModel *)model{
    _rootModel = model;
    _Tlabel.text = model.name;
    _Dlabel.text = model.abstract;
    if ([model.online isEqualToString:@"0"] ){
        BOOL exist=[[NSFileManager defaultManager] fileExistsAtPath:[kCachePath stringByAppendingPathComponent:model.name]];
        if(exist){
            //获取原来的下载进度
            _progressView.progress=[[FGGDownloadManager shredManager] lastProgress:model.downlink];
            NSLog(@"进度 %f",_progressView.progress);
        }
        if(_progressView.progress==1.0){
            [_Xbutton setTitle:@"完成" forState:UIControlStateNormal];
        }
        else if(_progressView.progress>0.0){
            [_Xbutton setTitle:@"恢复" forState:UIControlStateNormal];
        }
        else{
            [_Xbutton setTitle:@"开始" forState:UIControlStateNormal];
        }
            _Xbutton.tag = 101;
    }else {
         [_Xbutton setTitle:@"在线" forState:UIControlStateNormal];
    }

    [_Xbutton addTarget:self action:@selector(xubuttonAction:) forControlEvents:UIControlEventTouchUpInside];
}

//http://files.cnblogs.com/ios8/WeixinDeom.zip 记得把_downlinkStr值传过去要
//withStr传的是一类图片的id
- (void)xubuttonAction:(UIButton *)button {
    if (button.tag == 101) {
        if(self.downloadBlock)
            self.downloadBlock(button);
    }else {
        NSLog(@"点击了在线");
    }
}

- (void)setDataList:(NSArray *)dataList {
    self.progressArray = [NSMutableArray new];
    self.statusArray = [NSMutableArray new];
    for (NSInteger i = 0; i < 20; i++) {
        [_progressArray addObject:[NSNumber numberWithFloat:0.0]];
        [_statusArray addObject:[NSNumber numberWithInt:DownloadStatusLoading]];
    }
}

- (RootTableViewCell *)tableView:(UITableView *)tableView
                   indexPath:(NSIndexPath *)indexPath withArray:(NSMutableArray *)dataSource{
        static NSString *cellID = @"cellID";
        RootTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[RootTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
    NSLog(@"indezx %ld",(long)indexPath.row);
        RootModel *model = [RootModel new];
        model = dataSource[indexPath.row];
        float progressValue = [[self.progressArray objectAtIndex:indexPath.row] floatValue];
        int downloadStauts = [[self.statusArray objectAtIndex:indexPath.row] intValue];
        [cell setDownloadProgress:progressValue WithStatus:downloadStauts with:model];
       // 点击下载按钮时回调的代码块
        __weak typeof(cell) weakCell=cell;
        cell.downloadBlock=^(UIButton *sender){
            NSLog(@"button  %@",sender.currentTitle);
            if([sender.currentTitle isEqualToString:@"开始"]||[sender.currentTitle isEqualToString:@"恢复"]){
    
                [sender setTitle:@"暂停" forState:UIControlStateNormal];
                //添加下载任务
                NSLog(@"downlik:%@ name:%@",model.downlink,model.name);
                [[FGGDownloadManager shredManager] downloadWithUrlString:model.downlink toPath:[kCachePath stringByAppendingPathComponent:model.name] process:^(float progress, NSString *sizeString, NSString *speedString) {
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
                    [[FGGDownloadManager shredManager] cancelDownloadTask:model.downlink];
                    [sender setTitle:@"恢复" forState:UIControlStateNormal];
                    NSLog(@"错误下载");
                    [self.progressArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithFloat:0.0]];
                    [self.statusArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInt:DownloadStatusWaiting]];
                }];
            }
            else if([sender.currentTitle isEqualToString:@"暂停"])
            {
                [sender setTitle:@"恢复" forState:UIControlStateNormal];
                [[FGGDownloadManager shredManager] cancelDownloadTask:model.downlink];
                [self.progressArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithFloat:0.0]];
                [self.statusArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInt:DownloadStatusWaiting]];
            }
        };
        return cell;
}

/////////
- (void)setDownloadProgress:(float)progress WithStatus:(DownloadStatus)downloadStatus with:(RootModel *)model{
    _Tlabel.text = model.name;
    _Dlabel.text = model.abstract;
    if ([model.online isEqualToString:@"0"] ){
        _downloadStatus = downloadStatus;
        if (_downloadStatus == DownloadStatusLoading) {
            [_Xbutton setTitle:@"开始" forState:UIControlStateNormal];
        }else if(_downloadStatus == DownloadStatusPause) {
            [_Xbutton setTitle:@"暂停" forState:UIControlStateNormal];
        }else if(_downloadStatus == DownloadStatusWaiting) {
            [_Xbutton setTitle:@"恢复" forState:UIControlStateNormal];
        }else if(_downloadStatus == DownloadStatusComplete){
            [_Xbutton setTitle:@"完成" forState:UIControlStateNormal];
        }
        _Xbutton.tag = 101;
    }else {
        [_Xbutton setTitle:@"在线" forState:UIControlStateNormal];
    }
    [_Xbutton addTarget:self action:@selector(xubuttonAction:) forControlEvents:UIControlEventTouchUpInside];
    //进度条
    self.progressView.progress = progress / 100;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
