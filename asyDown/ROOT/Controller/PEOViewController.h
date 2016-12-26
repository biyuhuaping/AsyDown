//
//  PEOViewController.h
//  PEOQ
//
//  Created by sibo on 2016/10/31.
//  Copyright © 2016年 sibozn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootModel.h"
#import "RootTableViewCell.h"
#import "AFNetworking.h"
#import "FGGDownloadManager.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define kCachePath (NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0])
@interface PEOViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
 

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,strong)NSMutableArray *HdataSource;
@property (nonatomic,strong)NSMutableArray *NdataSource;


@property (nonatomic,strong)NSMutableArray *progressArray;
@property (nonatomic,strong)NSMutableArray *statusArray;

@property (nonatomic,strong)RootModel *model;
@end
