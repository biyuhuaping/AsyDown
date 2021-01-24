//
//  RootModel.h
//  PEOQ
//
//  Created by sibo on 2016/11/17.
//  Copyright © 2016年 sibozn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RootModel : NSObject
@property (copy, nonatomic) NSString *id;
@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *abstract;
@property (copy, nonatomic) NSString *topic;
@property (copy, nonatomic) NSString *Description;
@property (copy, nonatomic) NSString *downlink;
@property (copy, nonatomic) NSString *uplink;
@property (copy, nonatomic) NSString *effectlink;//1是在版的生成地址
@property (copy, nonatomic) NSString *landscape;//1横屏0是竖屏
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *online;
@property (copy, nonatomic) NSString *feature;
@property (copy, nonatomic) NSString *rank;

@property (nonatomic, assign) float progress;
@property (nonatomic, assign) int num; //属性设置为int类型的num

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
