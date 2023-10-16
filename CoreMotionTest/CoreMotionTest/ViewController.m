//
//  ViewController.m
//  CoreMotionTest
//
//  Created by gsk on 2023/10/16.
//

#import "ViewController.h"
#import "SKMotionManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[SKMotionManager share] setReversalCount:4];
    [[SKMotionManager share] startHandling:^{
        NSLog(@"翻转已完成");
    }];
}


@end
