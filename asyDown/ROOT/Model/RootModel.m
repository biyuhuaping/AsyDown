//
//  RootModel.m
//  PEOQ
//
//  Created by sibo on 2016/11/17.
//  Copyright © 2016年 sibozn. All rights reserved.
//

#import "RootModel.h"

@implementation RootModel
@synthesize progress;
@synthesize num;
//解析主页数据的feature
+ (NSMutableDictionary *)arrayAPPModelWithResponse:(NSData *)dict{
    NSMutableArray *topArray = [[NSMutableArray alloc]init];
    NSMutableArray *hotArray = [[NSMutableArray alloc]init];
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc]init];
    NSDictionary *dictt = [NSJSONSerialization JSONObjectWithData:dict options:NSJSONReadingMutableContainers error:nil];
    NSDictionary *dictF = dictt[@"feature"];
    NSArray *farray = [dictF allValues];
    for (NSDictionary *dict in farray) {
        RootModel *model = [[RootModel alloc]init];
        model.id = dict[@"id"];
        model.icon = dict[@"icon"];
        model.name = dict[@"name"];
        model.abstract = dict[@"abstract"];
        model.topic = dict[@"topic"];
        model.Description = dict[@"description"];
        model.downlink = dict[@"downlink"];
        model.uplink = dict[@"uplink"];
        model.effectlink = dict[@"effectlink"];
        model.landscape = dict[@"landscape"];
        model.price = dict[@"price"];
        model.online = dict[@"online"];
        model.feature = dict[@"feature"];
        model.rank = dict[@"rank"];
        if ([model.feature isEqualToString:@"1"]) {
            [topArray addObject:model];
        }else if ([model.feature isEqualToString:@"2"]){
            [hotArray addObject:model];
        }else {
            [newArray addObject:model];
        }
    }
    [resultDict setValue:topArray forKey:@"top"];
    [resultDict setValue:hotArray forKey:@"hot"];
    [resultDict setValue:newArray forKey:@"new"];
    
    return resultDict;
}
+ (NSMutableArray *)arrayAppmodelWithResponse:(NSData *)dict {
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSDictionary *dictt = [NSJSONSerialization JSONObjectWithData:dict options:NSJSONReadingMutableContainers error:nil];
    NSDictionary *dictF = dictt[@"effects"];
    NSArray *farray = [dictF allValues];
    for (NSDictionary *dict in farray) {
        RootModel *model = [[RootModel alloc]init];
        model.id = dict[@"id"];
        model.icon = dict[@"icon"];
        model.name = dict[@"name"];
        model.abstract = dict[@"abstract"];
        model.topic = dict[@"topic"];
        model.Description = dict[@"description"];
        model.downlink = dict[@"downlink"];
        model.uplink = dict[@"uplink"];
        model.effectlink = dict[@"effectlink"];
        model.landscape = dict[@"landscape"];
        model.price = dict[@"price"];
        model.online = dict[@"online"];
        model.feature = dict[@"feature"];
        model.rank = dict[@"rank"];
        [resultArray addObject:model];
    }
    return resultArray;
}
@end
