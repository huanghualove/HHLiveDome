//
//  HHCaptureViewController.m
//  HHLiveDome
//
//  Created by 黄华 on 2018/3/28.
//  Copyright © 2018年 huanghua. All rights reserved.
//

#import "HHCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "LFLiveKit.h"

#define kWidth  [UIScreen mainScreen].bounds.size.width

@interface HHCaptureViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,LFLiveSessionDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *currentVideoDeviceInput;
@property (nonatomic, weak)   UIImageView *focusCursorImageView;
@property (nonatomic, weak)   AVCaptureVideoPreviewLayer *previedLayer;
@property (nonatomic, weak)   AVCaptureConnection *videoConnection;

@property (nonatomic, weak) UIView *livingPreView;
@property (nonatomic, strong) LFLiveSession *session;
@end

@implementation HHCaptureViewController

/**
聚焦视图
*/
- (UIImageView *)focusCursorImageView{
    if(!_focusCursorImageView){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"focus"]];
        _focusCursorImageView = imageView;
        [self.view addSubview:_focusCursorImageView];
    }
    return _focusCursorImageView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"采集视频";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *captureBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [captureBut setTitle:@"切换摄像头" forState:UIControlStateNormal];
    captureBut.titleLabel.font = [UIFont systemFontOfSize:15];
    captureBut.frame = CGRectMake(kWidth - 100, 64, 100, 50);
    [self.view addSubview:captureBut];
    captureBut.backgroundColor = [UIColor greenColor];
    [captureBut addTarget:self action:@selector(changDevicePosition:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *beautifulBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [beautifulBut setTitle:@"开启美颜功能" forState:UIControlStateNormal];
    beautifulBut.titleLabel.font = [UIFont systemFontOfSize:15];
    beautifulBut.frame = CGRectMake(0, 64, 100, 50);
    [self.view addSubview:beautifulBut];
    beautifulBut.backgroundColor = [UIColor greenColor];
    [beautifulBut addTarget:self action:@selector(beautiful:) forControlEvents:UIControlEventTouchUpInside];
    
    //配置摄像头捕捉采集图像
    //[self setUpCaputureVideo];
    
    [self setUpSubview];
}

- (UIView *)livingPreView
{
    if (!_livingPreView) {
        UIView *livingPreView = [[UIView alloc] initWithFrame:self.view.bounds];
        livingPreView.backgroundColor = [UIColor clearColor];
        livingPreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:livingPreView atIndex:0];
        _livingPreView = livingPreView;
    }
    return _livingPreView;
}


- (LFLiveSession*)session{
    if(!_session){
        /***   默认分辨率368 ＊ 640  音频：44.1 iphone6以上48  双声道  方向竖屏 ***/
//        _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfigurationForQuality:LFLiveVideoQuality_Medium2] liveType:LFLiveRTMP];
        
        _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfigurationForQuality:LFLiveVideoQuality_Medium2]];
        
        /**    自己定制高质量音频128K 分辨率设置为720*1280 方向竖屏 */
        /*
         LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
         audioConfiguration.numberOfChannels = 2;
         audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
         audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
         
         LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
         videoConfiguration.videoSize = CGSizeMake(720, 1280);
         videoConfiguration.videoBitRate = 800*1024;
         videoConfiguration.videoMaxBitRate = 1000*1024;
         videoConfiguration.videoMinBitRate = 500*1024;
         videoConfiguration.videoFrameRate = 15;
         videoConfiguration.videoMaxKeyframeInterval = 30;
         videoConfiguration.orientation = UIInterfaceOrientationPortrait;
         videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
         
         _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration liveType:LFLiveRTMP];
         */
        // 设置代理
        _session.delegate = self;
        _session.running = YES;
        _session.preView = self.livingPreView;
    }
    return _session;
}



- (void)setUpSubview{
    // 默认开启后置摄像头
    self.session.captureDevicePosition = AVCaptureDevicePositionBack;
    
    //self.session.beautyFace = YES;
}

- (void)beautiful:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    // 默认是开启了美颜功能的
    self.session.beautyFace = !self.session.beautyFace;
}



- (void)changDevicePosition:(UIButton *)sender {
    
    AVCaptureDevicePosition devicePositon = self.session.captureDevicePosition;
    self.session.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    NSLog(@"切换摄像头");
}













/**
 采集视频
 */
- (void)setUpCaputureVideo{
   
    // 1.创建捕获会话,必须要强引用，否则会被释放
    AVCaptureSession *captureSesstion = [[AVCaptureSession alloc] init];
    _captureSession = captureSesstion;
    
    // 2.获取摄像头设备，设置后置摄像头
    AVCaptureDevice *videoDevice = [self getVideoDevice:AVCaptureDevicePositionBack];
    
    // 3.获取声音设备
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    // 4.创建对应视频设备输入对象
    NSError *error = nil;
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    _currentVideoDeviceInput = videoDeviceInput;
    
    //5.创建对应音频设备输入对象
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    
    // 6.添加到会话中   注意“最好要判断是否能添加输入，会话不能添加空的
    //6.1 添加视频
    if([captureSesstion canAddInput:videoDeviceInput]){
        [captureSesstion addInput:videoDeviceInput];
    }
    // 6.2 添加音频
    if([captureSesstion canAddInput:audioDeviceInput]){
        [captureSesstion addInput:audioDeviceInput];
    }
    
    // 7.获取视频数据输出设备
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];;
    // 7.1 设置代理，捕获视频样品数据
    // 注意：队列必须是串行队列，才能获取到数据，而且不能为空
    dispatch_queue_t videoQueue = dispatch_queue_create("videoQueue", DISPATCH_QUEUE_SERIAL);
    [videoOutput setSampleBufferDelegate:self queue:videoQueue];
    if([captureSesstion canAddOutput:videoOutput]){
        [captureSesstion addOutput:videoOutput];
    }
    
    // 8.获取音频数据输出设备
    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];;
    dispatch_queue_t audioQueue = dispatch_queue_create("audioQueue", DISPATCH_QUEUE_SERIAL);
    [audioOutput setSampleBufferDelegate:self queue:audioQueue];
    if([captureSesstion canAddOutput:audioOutput]){
        [captureSesstion addOutput:audioOutput];
    }
    
    // 9.获取视频输入与输出连接，用于分辨音视频数据
    _videoConnection = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
    
    
    // 10.添加视频预览图层
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSesstion];
    previewLayer.frame = [UIScreen mainScreen].bounds;
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    _previedLayer = previewLayer;
    
    //11.启动会话
    [captureSesstion startRunning];
    
}


// 指定摄像头方向获取摄像头
- (AVCaptureDevice *)getVideoDevice:(AVCaptureDevicePosition)position{
    NSArray *arrays = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in arrays) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}




#pragma mark  - - AVCaptureVideoDataOutputSampleBufferDelegate
// 获取输入设备数据，有可能是音频有可能是视频
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if (_videoConnection == connection) {
        NSLog(@"采集到视频数据");
    } else {
        NSLog(@"采集到音频数据");
    }
}



// 切换摄像头
- (void)changeCapture:(UIButton *)sender {
    
    // 获取当前设备方向
    AVCaptureDevicePosition currentPosition = _currentVideoDeviceInput.device.position;
    
    // 获取需要改变的方向
    AVCaptureDevicePosition changePosition = currentPosition == AVCaptureDevicePositionFront ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    
    // 获取改变的摄像头设备
    AVCaptureDevice *changDevice = [self getVideoDevice:changePosition];
    
    // 获取改变的摄像头输入设备
    AVCaptureDeviceInput *changInput = [AVCaptureDeviceInput deviceInputWithDevice:changDevice error:nil];
    
    // 移除之前摄像头输入设备
    [_captureSession removeInput:_currentVideoDeviceInput];
    
    // 添加新的摄像头输入设备
    [_captureSession addInput:changInput];
    
    // 记录当前摄像头输入设备
    _currentVideoDeviceInput = changInput;
}

// 点击屏幕，出现聚焦视图
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    // 获取点击位置
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self.view];
    
    // 把当前位置转换为摄像头点上的位置
    CGPoint cameraPoint = [_previedLayer captureDevicePointOfInterestForPoint:point];
    
    // 设置聚焦点光标位置
    [self setFocusCurrentsorWithPoint:point];
    
    // 设置聚焦
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}


/**
 设置聚焦光标位置
 */
- (void)setFocusCurrentsorWithPoint:(CGPoint)point{
    
    self.focusCursorImageView.center = point;
    self.focusCursorImageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursorImageView.alpha = 1.0;
    [UIView animateWithDuration:1.5 animations:^{
        self.focusCursorImageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursorImageView.alpha = 0.0;
    }];
}


/**
 设置聚焦
 */

-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    
    AVCaptureDevice *device = _currentVideoDeviceInput.device;
    
    // 锁定配置
    [device lockForConfiguration:nil];
    
    
    // 设置聚焦
    if([device isFocusModeSupported:focusMode]){
        [device setFocusMode:focusMode];
    }
    
    if([device isFocusPointOfInterestSupported]){
        [device setFocusPointOfInterest:point];
    }
    
    
    // 设置曝光
    if([device isExposureModeSupported:exposureMode]){
        [device setExposureMode:exposureMode];
    }
    
    if([device isFocusPointOfInterestSupported]){
        [device setExposurePointOfInterest:point];
    }
    

    // 解锁配置
    [device unlockForConfiguration];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
