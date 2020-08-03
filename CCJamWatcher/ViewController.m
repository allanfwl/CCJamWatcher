//
//  ViewController.m
//  CCJamWatcher
//
//  Created by 冯文林  on 2020/8/3.
//  Copyright © 2020 com.allan. All rights reserved.
//

#import "ViewController.h"
#import "CCJamWatcher.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [CCJamWatcher shareInstance].jamReportTimeInterval = 0.5; // 设置多久时间报告一次
    [CCJamWatcher shareInstance].jamHandler = ^(NSString *callTree) {
        // 在这可以写日志
        NSLog(@"主线程发生卡顿。当前调用栈：\n%@", callTree);
    };
    [[CCJamWatcher shareInstance] start];
    
    /**
     * 因为CCJamWatcher是监听主线程runloop状态的，所以下一轮runloop才能监听到
     *
     * 为了方便测试把代码丢到下一轮loop
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        
        const static int count = 5000;
        NSMutableArray *arr= [@[] mutableCopy];
        for (int i = 0; i < count; i++) {
            arr[i] = @(arc4random() % (count+1)); /* 随机数据 */
        }
        
        NSLog(@"排序开始");
        
        [self bubbleSort:arr comparator:^int(id obj1, id obj2) {
            return ((NSNumber *)obj1).intValue-((NSNumber *)obj2).intValue;
        }];
        
        NSLog(@"排序完成了");
        
    });

}

/**
 用时间复杂度高的冒泡排序测试
 */
-(void)bubbleSort:(NSMutableArray *)arr comparator:(int(^)(id obj1, id obj2))compare
{
    int length = (int)arr.count;
    for (int j = 0; j<length-1; j++) {
        for (int i = 0; i<length-1-j; i++) {
            if (compare(arr[i],arr[i+1])>0) {
                id t_ptr = arr[i];
                arr[i] = arr[i+1];
                arr[i+1] = t_ptr;
            }
        }
    }
}

@end
