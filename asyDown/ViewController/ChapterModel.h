//
//  ChapterModel.h
//  Qian
//
//  Created by ZB on 2021/1/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChapterModel : NSObject

@property (nonatomic, assign) NSInteger free;
@property (nonatomic, assign) NSInteger studyCount;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSInteger state;//下载状态
@property (nonatomic, assign) BOOL isPlay;//播放状态

@end

NS_ASSUME_NONNULL_END
