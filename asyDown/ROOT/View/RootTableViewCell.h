//
//  RootTableViewCell.h
//  PEOQ
//
//  Created by sibo on 2016/11/17.
//  Copyright © 2016年 sibozn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootModel.h"
#import "FGGDownloader.h"
@class RootTableViewCell;

typedef enum : NSUInteger {
    DownloadStatusLoading,//开始下载
    DownloadStatusPause,//暂停
    DownloadStatusWaiting,//恢复
    DownloadStatusComplete,//完成
}DownloadStatus;
@protocol BookCellDelegate <NSObject>

- (void)downloadBtnClick:(RootTableViewCell *)cell;

@end
@interface RootTableViewCell : UITableViewCell
@property (nonatomic,strong)UILabel *Tlabel;
@property (nonatomic,strong)UILabel *Dlabel;
@property (nonatomic,strong)UIButton *Xbutton;
@property (nonatomic,strong)UIProgressView *progressView;
@property (nonatomic,strong)RootModel *rootModel;
@property(nonatomic,copy)void (^downloadBlock)(UIButton *sender);
- (void)configData:(RootModel *)model;
+ (RootTableViewCell *)tableView:(UITableView *)tableView
                       indexPath:(NSIndexPath *)indexPath withArray:(NSMutableArray *)dataSource;



@property(nonatomic, assign) DownloadStatus downloadStatus;
-(void)setDownloadProgress:(float)progress WithStatus:(DownloadStatus)downloadStatus with:(RootModel *)model;


@property (nonatomic,strong)NSMutableArray *progressArray;
@property (nonatomic,strong)NSMutableArray *statusArray;
@property (nonatomic, strong) NSArray *dataList;
- (RootTableViewCell *)tableView:(UITableView *)tableView
                       indexPath:(NSIndexPath *)indexPath withArray:(NSMutableArray *)dataSource;

//Ty
/// 代理属性
@property (nonatomic,weak) id <BookCellDelegate> delegate;
@end
