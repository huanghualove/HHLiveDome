//
//  HHLiveCollectionViewCell.m
//  HHLiveDome
//
//  Created by 黄华 on 2018/3/28.
//  Copyright © 2018年 huanghua. All rights reserved.
//

#import "HHLiveCollectionViewCell.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "HHLiveItem.h"
#import <AFNetworking/AFNetworking.h>

@implementation HHLiveFlowLayout

- (void)prepareLayout{
    [super prepareLayout];
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.itemSize = self.collectionView.bounds.size;
    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 0;
    
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
}
@end








@interface HHLiveCollectionViewCell()
// 直播播放器
@property (nonatomic,strong)IJKFFMoviePlayerController *moviePlayer;

@end



@implementation HHLiveCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        UIButton *captureBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [captureBut setTitle:@"取消" forState:UIControlStateNormal];
        captureBut.titleLabel.font = [UIFont systemFontOfSize:15];
        captureBut.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 50, [UIScreen mainScreen].bounds.size.height - 50, 50, 50);
        [self.contentView addSubview:captureBut];
        captureBut.backgroundColor = [UIColor greenColor];
        [captureBut addTarget:self action:@selector(cacleAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setLive:(HHLiveItem *)live{
    
    _live = live;
    
    [self plarFLV:live.flv placeHolderUrl:live.bigpic];

}


#pragma mark - private method 播放
- (void)plarFLV:(NSString *)flv placeHolderUrl:(NSString *)placeHolderUrl{
    
    if(_moviePlayer){
        [self.contentView addSubview:_moviePlayer.view];
        [_moviePlayer shutdown];
        [_moviePlayer.view removeFromSuperview];
        _moviePlayer = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }

    //拉流播放
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    [options setPlayerOptionIntValue:1 forKey:@"videotoolbox"];
    // 帧速率(fps) （可以改，确认非标准桢率会导致音画不同步，所以只能设定为15或者29.97）
    [options setPlayerOptionIntValue:29.97 forKey:@"r"];
    // -vol——设置音量大小，256为标准音量。（要设置成两倍音量时则输入512，依此类推
    [options setPlayerOptionIntValue:512 forKey:@"vol"];

    
    IJKFFMoviePlayerController *moviePlay = [[IJKFFMoviePlayerController alloc] initWithContentURLString:flv withOptions:options];
    moviePlay.view.frame = self.contentView.bounds;
    moviePlay.scalingMode = MPMovieScalingModeAspectFill;
    // 设置自动播放(必须设置为NO, 防止自动播放, 才能更好的控制直播的状态)
    moviePlay.shouldAutoplay = NO;
    moviePlay.shouldShowHudView = NO;
    [self.contentView insertSubview:moviePlay.view atIndex:0];
    //准备播放
    [moviePlay prepareToPlay];
    
    _moviePlayer  = moviePlay;
    //监听
    [self initObserver];
    
}

- (void)initObserver{
    // 监听视频是否播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinish) name:IJKMPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateDidChange) name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.moviePlayer];
}


- (void)didFinish
{
    NSLog(@"加载状态...%ld %ld %s", self.moviePlayer.loadState, self.moviePlayer.playbackState, __func__);
    // 因为网速或者其他原因导致直播stop了, 也要显示GIF
    if (self.moviePlayer.loadState & IJKMPMovieLoadStateStalled) {
        NSLog(@"导致直播加载状态...");
        return;
    }
    //    方法：
    //    1、重新获取直播地址，服务端控制是否有地址返回。
    //    2、用户http请求该地址，若请求成功表示直播未结束，否则结束
    __weak typeof(self)weakSelf = self;
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", nil];

    [mgr GET:self.live.flv parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable responseObject) {
        NSLog(@"请求成功%@, 等待继续播放", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败, 加载失败界面, 关闭播放器%@", error);
        [weakSelf.moviePlayer shutdown];
        [weakSelf.moviePlayer.view removeFromSuperview];
        weakSelf.moviePlayer = nil;
    }];

}



- (void)stateDidChange{
    if ((self.moviePlayer.loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        if (!self.moviePlayer.isPlaying) {
            [self.moviePlayer play];
        }else{
            // 如果是网络状态不好, 断开后恢复, 也需要去掉加载
        }
    }else if (self.moviePlayer.loadState & IJKMPMovieLoadStateStalled){ // 网速不佳, 自动暂停状态

    }
}

- (void)cacleAction{
   
    [_moviePlayer shutdown];
    [_moviePlayer.view removeFromSuperview];
    _moviePlayer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if(self.clickCancleLive){
        self.clickCancleLive(nil);
    }
}

@end
