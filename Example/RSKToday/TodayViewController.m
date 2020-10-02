//
//  TodayViewController.m
//  RSKToday
//
//  Created by bob on 2020/10/2.
//  Copyright © 2020 rangers. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#import <FuckKit/FKNotification.h>
#import <FuckKit/NSFileManager+FK.h>

@interface TodayViewController () <NCWidgetProviding>

@property (strong, nonatomic) FKNotification *notification;


@end

@implementation TodayViewController

/// last
- (void)dealloc {
    [self.notification stop];
}

/// Notification and init fail to log
/// 1.0
- (void)loadView {
    [super loadView];
}

/// 2.0
- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button0 = [[UIButton alloc] initWithFrame:CGRectMake(150, 50, 140, 44)];
    [button0 addTarget:self action:@selector(fileButtontClick) forControlEvents:UIControlEventTouchUpInside];
    [button0 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button0 setTitle:@"post" forState:UIControlStateNormal];
    [button0.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    button0.backgroundColor = [UIColor grayColor];
    [self.view addSubview:button0];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 50, 140, 44)];
    [button1 addTarget:self action:@selector(didButtontClick) forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button1 setTitle:@"did" forState:UIControlStateNormal];
    [button1.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    button1.backgroundColor = [UIColor grayColor];
    [self.view addSubview:button1];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(150, 0, 140, 44)];
    [button2 addTarget:self action:@selector(impressionButtontClick) forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button2 setTitle:@"impression" forState:UIControlStateNormal];
    [button2.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    button2.backgroundColor = [UIColor grayColor];
    [self.view addSubview:button2];
    
    
    UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 140, 44)];
    [button3 addTarget:self action:@selector(eventButtontClick) forControlEvents:UIControlEventTouchUpInside];
    [button3 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button3 setTitle:@"event v3" forState:UIControlStateNormal];
    [button3.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    button3.backgroundColor = [UIColor grayColor];
    [self.view addSubview:button3];
}

/// 5.0
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

/// 6.0
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

/// 7.0
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

/// 8.0
- (void)viewDidDisappear:(BOOL)animated {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // do some thing Async
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(40 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // then back to dispatch on main queue
            NSLog(@"Time - %.2f, %@",CFAbsoluteTimeGetCurrent(), self);
        });
    });
}

/// 4.0
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    completionHandler(NCUpdateResultNewData);
}

- (void)fileButtontClick {
    if (self.notification == nil) {
        NSURL *path = [[NSFileManager defaultManager] fk_pathForNotificationFile:@"data.lock" group:@"group.bobcat.test"];
        self.notification = [FKNotification sharedInstance];
        [self.notification startWithLockFilePath:path];
        [self.notification addObserverForName:@"Shared"
                                    withBlock:^(NSDictionary * userInfo) {
            NSLog(@"today receives notification from app: %@",userInfo);
        }];
    }
    [self.notification postNotification:@"Shared"
                               userInfo:@{@"from":@"today"}
                             completion:^{
        NSLog(@"today post notification to app");
    }];
    
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    NSString *identifier = @"test";
    CFStringRef str = (__bridge CFStringRef)identifier;
    CFNotificationCenterPostNotification(center, str, NULL, NULL, YES);
}

- (void)eventButtontClick {
    
}

- (void)impressionButtontClick {
    
}

- (void)didButtontClick {
    
}

/// 3.0
- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
}

@end
