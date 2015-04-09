//
//  ViewController.m
//  testDispatch2
//
//  Created by Jianfei Wang on 15-4-7.
//  Copyright (c) 2015年 Sina. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic) UIImageView *imgvTop;
@property (nonatomic) UIImageView *imgvMid;
@property (nonatomic) UIImageView *imgvBottom;

@property (nonatomic, retain) NSMutableArray *datas;

@end

@implementation ViewController

// other image
//        UIImage *temp = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://i0.sinaimg.cn/photo/2/2013-06-17/U11472P1505T2D2F62DT20150407090929.jpg"]]];
//        UIImage *tempMid = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.sinaimg.cn/dy/slidenews/1_img/2015_15/2841_561292_262960.jpg"]]];
//        UIImage *tempBottom = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.sinaimg.cn/dy/slidenews/1_img/2015_15/2841_561295_107216.jpg"]]];


- (void)testQueue
{
    
    dispatch_queue_t queue = dispatch_queue_create("hello", DISPATCH_QUEUE_SERIAL);
    
    dispatch_queue_t queue2 = dispatch_queue_create("hello2", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        
        UIImage *temp = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://ddragon.leagueoflegends.com/cdn/img/champion/loading/Karma_0.jpg"]]];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.imgvTop.image = temp;
        });
    });
    
    dispatch_async(queue2, ^{
        
        UIImage *tempMid = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://ddragon.leagueoflegends.com/cdn/img/champion/loading/Lulu_0.jpg"]]];
        NSLog(@"66%%");
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.imgvMid.image = tempMid;
        });
    });

    dispatch_async(queue, ^{
        
        UIImage *tempBottom = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://ddragon.leagueoflegends.com/cdn/img/champion/loading/Nasus_0.jpg"]]];
        NSLog(@"100%%");
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.imgvBottom.image = tempBottom;
        });
    });

}

dispatch_queue_t queue;

-(void)testGroup
{
    dispatch_group_t group = dispatch_group_create();
    
    queue = dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT);
    
    dispatch_group_async(group, queue, ^{
        
        UIImage *temp = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://ddragon.leagueoflegends.com/cdn/img/champion/loading/Karma_0.jpg"]]];
        NSLog(@"33%%, %p", [NSThread currentThread]);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.imgvTop.image = temp;
        });
    });
    dispatch_group_async(group, queue, ^{
        
        UIImage *tempMid = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://ddragon.leagueoflegends.com/cdn/img/champion/loading/Lulu_0.jpg"]]];
        NSLog(@"66%%, %p", [NSThread currentThread]);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.imgvMid.image = tempMid;
        });
    });

    dispatch_group_async(group, queue, ^{
        
        UIImage *tempBottom = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://ddragon.leagueoflegends.com/cdn/img/champion/loading/Nasus_0.jpg"]]];
        NSLog(@"100%%, %p", [NSThread currentThread]);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.imgvBottom.image = tempBottom;
        });
    });

    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"Dispatch group notified!");
    });
}


- (void)testBarrier
{
    dispatch_queue_t insertQ = dispatch_queue_create("insert", DISPATCH_QUEUE_SERIAL);
    
    dispatch_queue_t readQ = dispatch_queue_create("read", DISPATCH_QUEUE_SERIAL);
    
    self.datas = [NSMutableArray array];
    for (int i=0; i<10000; i++) {
        [self.datas addObject:@(i)];
    }
    
    NSString *lock = @"x";
    NSLock *lockX = [NSLock new];
    
    dispatch_async(insertQ, ^{
        @synchronized(lock) {
//        [lockX lock];
            for (int i=0; i<10000; i++) {
                [_datas insertObject:@(i) atIndex:i];
                NSLog(@"insert %d", i);
            }
        }
//        [lockX unlock];
    });
    
    dispatch_async(readQ, ^{
         @synchronized(lock) {
//        [lockX lock];
            for (int i=0; i<[_datas count]; i++) {
                [_datas objectAtIndex:i];
                //[nb description];
                NSLog(@"read %d, count: %d", i, [_datas count]);
            }
//        [lockX unlock];
        }
    });
}

- (void)testSync
{
    dispatch_queue_t insertQ = dispatch_queue_create("insert", DISPATCH_QUEUE_SERIAL);
    
    dispatch_queue_t readQ = dispatch_queue_create("read", DISPATCH_QUEUE_SERIAL);
    
    self.datas = [NSMutableArray array];
    for (int i=0; i<10000; i++) {
        [self.datas addObject:@(i)];
    }
    
    
    
    dispatch_async(insertQ, ^{
        //@synchronized(self) {
        
            for (int i=0; i<10000; i++) {
                [_datas insertObject:@(i) atIndex:i];
                NSLog(@"insert %d, thread: %p", i, [NSThread currentThread]);
                NSLog(@"insert :%p",_datas);
            }
        //}
    });
    
    dispatch_async(readQ, ^{
        //@synchronized(self) {
            for (int i=0; i<10000; i++) {
                //[_datas objectAtIndex:i];
                [_datas insertObject:@(i) atIndex:i];
                NSLog(@"read %d, thread: %p", i, [NSThread currentThread]);
                NSLog(@" read %p",_datas);

            }
        //}
    });
}

char text[8] = "abcdefg";

- (void)testCArray
{
    dispatch_queue_t insertQ = dispatch_queue_create("insert", DISPATCH_QUEUE_SERIAL);
    
    dispatch_queue_t readQ = dispatch_queue_create("read", DISPATCH_QUEUE_SERIAL);
    
    
    dispatch_async(insertQ, ^{
        
        for (int i=0; i<10000; i++) {
            text[0] = 'c';
            NSLog(@"insert %c, thread: %p, %s", i, [NSThread currentThread], text);
        }
    });
    
    dispatch_async(readQ, ^{
        for (int i=0; i<10000; i++) {
            text[0] = 'd';
            NSLog(@"read %c, thread: %p", text[0], [NSThread currentThread]);
        }
    });
}



-(void)test
{
//    [self testQueue];
    [self testGroup];
//    [self testBarrier];
//    [self testSync];
//    [self testCArray];
}

-(void)pause
{
    dispatch_suspend(queue);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 20, 100, 100);
    [self.view addSubview:btn];
    [btn setImage:[UIImage imageNamed:@"a.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 120, 100, 100);
    [self.view addSubview:btn];
    [btn setBackgroundImage:[UIImage imageNamed:@"a.png"] forState:UIControlStateNormal];
    [btn setTitle:@"pause" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];

    
    self.imgvTop = [[UIImageView alloc] initWithFrame:CGRectMake(100, 20, 100, 100)];
    [self.view addSubview:self.imgvTop];
    
    self.imgvMid = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100 + 20 + 10, 100, 100)];
    [self.view addSubview:self.imgvMid];

    self.imgvBottom = [[UIImageView alloc] initWithFrame:CGRectMake(100, 200 + 20 + 20, 100, 100)];
    [self.view addSubview:self.imgvBottom];
}

@end
