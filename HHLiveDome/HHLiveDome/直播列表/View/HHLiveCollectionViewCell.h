//
//  HHLiveCollectionViewCell.h
//  HHLiveDome
//
//  Created by 黄华 on 2018/3/28.
//  Copyright © 2018年 huanghua. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HHLiveItem;

@interface HHLiveFlowLayout : UICollectionViewFlowLayout

@end




@interface HHLiveCollectionViewCell : UICollectionViewCell
/** 直播 */
@property (nonatomic, strong) HHLiveItem *live;
/** 父控制器 */
@property (nonatomic, weak) UIViewController *parentVc;

@property (nonatomic, copy) void (^clickCancleLive)(id object);

@end
