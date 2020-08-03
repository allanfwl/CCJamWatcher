//
//  CCJamWatcher.m
//  CCKit
//
//  Created by 冯文林  on 2020/7/31.
//  Copyright © 2020 com.allan. All rights reserved.
//

#import "CCJamWatcher.h"
#import "BSBacktraceLogger.h"

static CCJamWatcher *shareInstance;

@implementation CCJamWatcher
{
    CFRunLoopObserverRef observer;
    dispatch_semaphore_t semaphore;
    CFRunLoopActivity activity;
    BOOL observering;
    CFAbsoluteTime lastReportAtTime;
}

/**
 单例相关
 */
+(instancetype)shareInstance {
    if (!shareInstance) {
        shareInstance = [[self alloc] init];
    }
    return shareInstance;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [super allocWithZone:zone];
    });
    return shareInstance;
}
-(id)copyWithZone:(NSZone *)zone
{
    return shareInstance;
}
-(instancetype)init {
    if (self = [super init]) {
        _jamTime = 150;
        _jamReportTimeInterval = 0;
    }
    return self;
}

-(void)start {
    [self observerOn];
    [self createWatchingThread];
}

-(void)stop {
    [self observerOff];
}

/**
 监听mainRunLoop
 */
-(void)observerOn {
    if (observering) return;
    
    CFRunLoopObserverContext context = {
        0,
        (__bridge void*)self,
        &CFRetain,
        &CFRelease,
        NULL
    };
    CFRunLoopObserverRef observer =
    CFRunLoopObserverCreate(
                            kCFAllocatorDefault,
                            kCFRunLoopAllActivities,
                            YES,
                            0,
                            &runLoopObserverCallBack,
                            &context
                            );
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    CFRelease(observer);
    self->observer = observer;
    semaphore = dispatch_semaphore_create(0);
    observering = YES;
}

-(void)observerOff {
    if (observering) {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), self->observer, kCFRunLoopCommonModes);
        self->observer = NULL;
        observering = NO;
    }
}

/**
 创建一个子线程持续监控
 */
- (void)createWatchingThread {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int timeoutCount = 0;
        while (self->observering) {

            long timeout = dispatch_semaphore_wait(self->semaphore, dispatch_time(DISPATCH_TIME_NOW, self->_jamTime/3*NSEC_PER_MSEC));
            
            if (timeout) {
                if (self->activity==kCFRunLoopBeforeSources
                    || self->activity==kCFRunLoopAfterWaiting) { /* 停留在这两个状态 */
                    
                    if (++timeoutCount<3) continue; /* 并且信号wait连续3次超时 */
                    
                    CFAbsoluteTime t = CFAbsoluteTimeGetCurrent();
                    if (t-self->lastReportAtTime > self->_jamReportTimeInterval) {
                        self->lastReportAtTime = t;
                        if (self->_jamHandler != NULL) {
                            self->_jamHandler([BSBacktraceLogger bs_backtraceOfMainThread]);
                        }
                    }
                    
                }
            }
            timeoutCount = 0;
        }
    });
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    CCJamWatcher *object = (__bridge CCJamWatcher*)info;
    // 记录state
    object->activity = activity;
    // 发出信号
    dispatch_semaphore_signal(object->semaphore);
}



@end
