//
//  SKMotionManager.m
//  CoreMotionTest
//
//  Created by gsk on 2023/10/16.
//

#import "SKMotionManager.h"
#import <CoreMotion/CoreMotion.h>
@interface SKMotionManager()
@property (nonatomic,strong)CMMotionManager *manager;
@property (nonatomic,assign)double rX;
@property (nonatomic,assign)double rY;
@property (nonatomic,assign)double aZ;

@property (nonatomic,assign)void(^finishBlock)(void);
@end

@implementation SKMotionManager

/// 感应器更新频率（每0.1s刷新一次）
static const NSTimeInterval SKUpdateInterval = 0.1;

/*
 判断是否到达所设定的速度；这边我把速度制定为3.5，这是一个很小的速度，也就是说稍微转一下设备就判断到达设定的速度；
 */
static const double SKMaxRotationRate = 3.5;

/*
 如果z小于0，则说明屏幕朝上，大于0屏幕朝下；假如屏幕完朝下，那么z的值在0.98~0.99左右；我这边把值设置在0.85，也就是说屏幕不用苛刻地完全朝下，也能监测到；
 */
static const double SKYGrativy = 0.85;

+ (instancetype)share{
    static SKMotionManager *share;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [SKMotionManager new];
        share.reversalCount = 2;
    });
    return share;
}

- (void)startHandling:(void(^)(void))finishBlock{
    self.finishBlock = finishBlock;
    if (!self.manager) {
        self.manager = [[CMMotionManager alloc] init];
    }
    if (self.manager.deviceMotionAvailable) {
        [self pushApproach];
    } else {
        NSLog(@"感应器不允许使用");
    }
}

- (void)pushApproach {
    SKMotionManager *__weak weakSelf = self;
    int __block count = 0;
    self.manager.deviceMotionUpdateInterval = SKUpdateInterval;
    [self.manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        CMRotationRate rotationRate = motion.rotationRate;
        weakSelf.rX = rotationRate.x;
        weakSelf.rY = rotationRate.y;
        
        CMAcceleration accrleration = motion.gravity;
        weakSelf.aZ = accrleration.z;
        
        if (weakSelf.isAchieveRotationRate && weakSelf.isFaceDown) {
            count ++;
            if(count == weakSelf.reversalCount){
                if(weakSelf.finishBlock){
                    weakSelf.finishBlock();
                }
                [[SKMotionManager share] stopHandling];
            }
            
        }
     }];
}

- (void)stopHandling {
    if (!self.manager) {
        return;
    }
    if (self.manager.deviceMotionActive) {
        [self.manager stopDeviceMotionUpdates];
    }
}

/// 判断是否到达所设定的速度
- (BOOL)isAchieveRotationRate {
    if (self.rX >= SKMaxRotationRate || self.rX <= - SKMaxRotationRate) {
        return YES;
    }
    if (self.rY >= SKMaxRotationRate || self.rY <= - SKMaxRotationRate) {
        return YES;
    }
    return NO;
}

- (BOOL)isFaceDown {
    if (self.aZ >= SKYGrativy) {
        return YES;
    }
    return NO;
}

@end
