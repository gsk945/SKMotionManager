//
//  SKMotionManager.h
//  CoreMotionTest
//
//  Created by gsk on 2023/10/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKMotionManager : NSObject

/// 翻转次数
@property (nonatomic,assign)int reversalCount;

+ (instancetype)share;

/// 开始监听
/// - Parameter finishBlock: 回调
- (void)startHandling:(void(^)(void))finishBlock;

/// 结束监听
- (void)stopHandling;

@end

NS_ASSUME_NONNULL_END
