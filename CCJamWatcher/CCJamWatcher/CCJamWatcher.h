//
//  CCJamWatcher.h
//  CCKit
//
//  Created by 冯文林  on 2020/7/31.
//  Copyright © 2020 com.allan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^JamHandler)(NSString *callTree);

@interface CCJamWatcher : NSObject

/**
 * 设置多少ms认定为卡顿。默认150ms
 *
 * @note 一般超过100ms（~300ms），用户感到卡顿
 */
@property(nonatomic, assign) float jamTime;

/**
 * 卡顿报告回调
 */
@property(nonatomic, strong) JamHandler jamHandler;

/**
 * 卡顿报告时间间隔。设置隔多久才会报告下一次。默认无限制
 */
@property(nonatomic, assign) float jamReportTimeInterval;

/**
 * 获取单例
 */
+(instancetype)shareInstance;

/**
 * 开始主线程卡顿监控
 */
-(void)start;

/**
 * 停止主线程卡顿监控
 */
-(void)stop;

@end

NS_ASSUME_NONNULL_END
