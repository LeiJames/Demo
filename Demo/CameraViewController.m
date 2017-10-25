



//
//  CameraViewController.m
//  Demo
//
//  Created by Lin YiPing on 2017/10/24.
//  Copyright © 2017年 LeoFeng. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface CameraViewController ()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) AVCaptureDeviceInput *input;

@property (nonatomic, strong) AVCaptureMovieFileOutput *outPut;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;


@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self prepareUI];
}

- (void)prepareUI {
    
     _session = [[AVCaptureSession alloc] init];
    if ([_session canSetSessionPreset:AVCaptureSessionPreset1280x720] ) {
        
        _session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    AVCaptureDevice *device = [self cameraWithDirection:AVCaptureDevicePositionBack];

    _input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    if ([_session canAddInput:_input]) {
        
        [_session addInput: _input];
    }
    
    _outPut = [[AVCaptureMovieFileOutput alloc] init];
    if ([_session canAddOutput:_outPut]) {
       AVCaptureConnection *c = [_outPut connectionWithMediaType:AVMediaTypeVideo];
        [_session addOutput:_outPut];
        
        if ([c isVideoStabilizationSupported]) {
            
            c.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
    }
    
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view.layer addSublayer:_previewLayer];
    
    [_session startRunning];

    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor redColor];
    btn.bounds = CGRectMake(0, 0, 40, 40);
    btn.center = self.view.center;
    [btn setTitle:@"录制" forState: UIControlStateNormal];
    [btn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.backgroundColor = [UIColor redColor];
    btn1.frame = CGRectMake(100, 100, 40, 40);
    [btn1 setTitle:@"停止" forState: UIControlStateNormal];
    [btn1 addTarget:self action:@selector(stopAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    
    
 
}


//点击事件
- (void)clickAction:(UIButton *)btn {

        AVCaptureConnection *movieConnection = [_outPut connectionWithMediaType:AVMediaTypeVideo];
        AVCaptureVideoOrientation avcaptureOrientation = AVCaptureVideoOrientationPortrait;
        [movieConnection setVideoOrientation:avcaptureOrientation];
        [movieConnection setVideoScaleAndCropFactor:1.0];
//     NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, BOOL expandTilde)
        NSString *path = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(), @"/Documents/film.mp4"];
        NSURL *url = [NSURL fileURLWithPath:path];
        NSLog(@"%@", path);
        [_outPut startRecordingToOutputFileURL:url recordingDelegate:self];
  
    
}

- (void)stopAction {
    
    
    [_outPut stopRecording];
}


- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections {
    
    NSLog(@"开始录制");

}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {    
   
    if (CMTimeGetSeconds(output.recordedDuration) <= 1.0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频时间过短" message:nil delegate:self
                                              cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSLog(@"finish");
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        NSLog(@"%@", assetURL);
    }];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height -  60, 60, 60)];
    imageView.image = [self firstFrameWithVideoURL:outputFileURL atTime:0];
    [self.view addSubview:imageView];
}


- (AVCaptureDevice *)cameraWithDirection:(AVCaptureDevicePosition)position {
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        
        if (device.position == position) {
            
            return device;
        }
    }
      return nil;
}


#pragma mark - 视频获取帧率

- (UIImage *)firstFrameWithVideoURL:(NSURL *)url atTime:(NSTimeInterval)time{
    
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetImageGenerator *result = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
    result.appliesPreferredTrackTransform = YES;
    //第一个参数表示当前的时间，第2个表示每秒60帧
    //CMTimeMake(a,b) a当前第几帧, b每秒钟多少帧.当前播放时间a/b CMTimeMakeWithSeconds(a,b) a当前时间,b每秒钟多少帧.
    CMTime times = CMTimeMakeWithSeconds((int64_t)time, 60);
    NSError *error;
    CMTime actualTime;
    CGImageRef image = [result copyCGImageAtTime:times actualTime:&actualTime error:&error];
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    if(error){
        NSLog(@"%@", error.description);
    }
    return  img;
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
