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
#import "ChapterModel.h"

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

@property (nonatomic,weak) id <BookCellDelegate> delegate;
@property (nonatomic, strong) UILabel *Tlabel;
@property (nonatomic, strong) UILabel *Dlabel;
@property (nonatomic, strong) UIButton *Xbutton;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) RootModel *rootModel;
@property (nonatomic, copy)void (^downloadBlock)(UIButton *sender);

@property (nonatomic, strong) NSMutableArray *progressArray;
@property (nonatomic, strong) NSMutableArray *statusArray;
@property (nonatomic, strong) NSArray *dataList;
@property (nonatomic, assign) DownloadStatus downloadStatus;

@property (strong, nonatomic) ChapterModel *model;

- (void)configData:(RootModel *)model;
//- (void)setDownloadProgress:(float)progress WithStatus:(DownloadStatus)downloadStatus with:(RootModel *)model;
- (void)setDownloadProgress:(float)progress WithStatus:(DownloadStatus)downloadStatus with:(ChapterModel *)model;

//+ (RootTableViewCell *)tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath withArray:(NSMutableArray *)dataSource;


//- (RootTableViewCell *)tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath withArray:(NSMutableArray *)dataSource;

@end
