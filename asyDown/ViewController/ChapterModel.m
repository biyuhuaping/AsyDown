//
//  ChapterModel.m
//  Qian
//
//  Created by ZB on 2021/1/21.
//

#import "ChapterModel.h"

@implementation ChapterModel

- (void)setUrl:(NSString *)url{
    _url = [kFilePath stringByAppendingString:url];
}

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper{
    return @{@"ID":@"id"};
}

@end
