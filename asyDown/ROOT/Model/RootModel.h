//
//  RootModel.h
//  PEOQ
//
//  Created by sibo on 2016/11/17.
//  Copyright © 2016年 sibozn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RootModel : NSObject
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *icon;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *abstract;
@property (nonatomic,strong)NSString *topic;
@property (nonatomic,strong)NSString *Description;
@property (nonatomic,strong)NSString *downlink;
@property (nonatomic,strong)NSString *uplink;
@property (nonatomic,strong)NSString *effectlink;//1是在版的生成地址
@property (nonatomic,strong)NSString *landscape;//1横屏0是竖屏
@property (nonatomic,strong)NSString *price;
@property (nonatomic,strong)NSString *online;
@property (nonatomic,strong)NSString *feature;
@property (nonatomic,strong)NSString *rank;

@property (nonatomic)float progress;
@property (nonatomic,assign)int num; //属性设置为int类型的num

//解析feature
+ (NSMutableDictionary *)arrayAPPModelWithResponse:(NSData *)dict;
//解析effects
+ (NSMutableArray *)arrayAppmodelWithResponse:(NSData *)dict;




//Ty
/// 记录按钮的选中状态
@property (nonatomic,assign) BOOL isSelected;
/// 记录下载进度
@property (nonatomic,assign) float downloadProgress;
@end
