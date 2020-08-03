# CCJamWatcher
支持对主线程的实时卡顿监控，获取主线程当前的调用栈



## 说明

这里获取线程调用栈用是的[BSBacktraceLogger](https://github.com/bestswifter/BSBacktraceLogger)，感谢这位作者的代码，觉得不错的就给个star吧 ～



## 使用

```objective-c
[CCJamWatcher shareInstance].jamHandler = ^(NSString *callTree) {
    NSLog(@"主线程发生卡顿。当前调用栈：\n%@", callTree);
};
[[CCJamWatcher shareInstance] start];
```



## 其它

设置报告卡顿的时间间距。即隔多久回调jamHandler一次：

```objective-c
[CCJamWatcher shareInstance].jamReportTimeInterval = 0.5; /* 默认无限制 */
```

设置卡多久认定为卡顿：

```objective-c
[CCJamWatcher shareInstance].jamTime = 150; /* 默认150ms */
```

停止监控：

```objective-c
[[CCJamWatcher shareInstance] stop];
```



最后补充一点是，这个库原理是基于监听主线程runloop状态去实现的。

因此在下一轮runloop之前执行的代码都无法监控到。这也是为什么我会在demo中把卡顿代码丢到主线程队列里。
