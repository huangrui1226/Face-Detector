//
//  ViewController.m
//  iOSTest
//
//  Created by 黄瑞 on 2017/6/9.
//  Copyright © 2017年 CoderHuang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layer;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) UIView *sessionView;
// 人脸识别
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) CIDetector *detector;
@property (nonatomic, strong) UIImageView *faceView;
@property (nonatomic, strong) UIView *leftEyeView;
@property (nonatomic, strong) UIView *rightEyeView;
@property (nonatomic, strong) UIView *mouthView;

@end

@implementation ViewController
#pragma mark - View did load
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessionView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.sessionView];
    
    self.faceView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"a"]];
    self.faceView.frame = CGRectZero;
    [self.view addSubview:self.faceView];
    
    self.leftEyeView = [[UIView alloc] init];
    self.leftEyeView.alpha = 0.4;
    self.leftEyeView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.leftEyeView];
    
    self.rightEyeView = [[UIView alloc] init];
    self.rightEyeView.alpha = 0.4;
    self.rightEyeView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.rightEyeView];

    self.mouthView = [[UIView alloc] init];
    self.mouthView.alpha = 0.4;
    self.mouthView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.mouthView];

    self.context = [CIContext context];
    self.detector = [CIDetector detectorOfType:CIDetectorTypeFace context:self.context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVCaptureSessionRuntimeErrorNotification:) name:AVCaptureSessionRuntimeErrorNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionRuntimeErrorNotification object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.session stopRunning];
    self.session = [[AVCaptureSession alloc] init];

    [self.layer removeFromSuperlayer];
    
    NSError *error;
    
    // Device
    NSArray *devices = [AVCaptureDevice devices];
    NSLog(@"devices = %@", devices);
    AVCaptureDevice *defaultDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:defaultDevice error:&error];
    [self.session addInput:input];

    // Output
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [output setSampleBufferDelegate:(id)self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    [self.session addOutput:output];
    
    [self.session startRunning];
    
    self.layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.layer.frame = self.view.bounds;
    [self.sessionView.layer addSublayer:self.layer];
}

#pragma mark - Notification method
- (void)AVCaptureSessionRuntimeErrorNotification:(NSNotification *)notice {
    printf("%s\n", __func__);
}

#pragma mark - Delegate
#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    printf("%s\n", __func__);
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *image = [[CIImage alloc] initWithCVImageBuffer:imageBuffer];
    
    CGFloat imageW = image.extent.size.width;
    CGFloat imageH = image.extent.size.height;
    
    CIFeature *feature = [[self.detector featuresInImage:image] lastObject];
    if (feature) {
        if (self.leftEyeView.frame.size.width == 0) {
            self.leftEyeView.frame = CGRectMake(0, 0, 20, 20);
        }
        if (self.rightEyeView.frame.size.width == 0) {
            self.rightEyeView.frame = CGRectMake(0, 0, 20, 20);
        }
        if (self.mouthView.frame.size.width == 0) {
            self.mouthView.frame = CGRectMake(0, 0, 20, 20);
        }
        NSLog(@"find");
        CIFaceFeature *face = (CIFaceFeature *)feature;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.faceView.frame = CGRectMake(face.bounds.origin.y / imageW * self.sessionView.frame.size.height,
                                             face.bounds.origin.x / imageH * self.sessionView.frame.size.width,
                                             face.bounds.size.width / imageH * self.sessionView.frame.size.width,
                                             face.bounds.size.height / imageW * self.sessionView.frame.size.height);
            
            self.leftEyeView.center = CGPointMake(face.leftEyePosition.y / imageW * self.sessionView.frame.size.height,
                                                  face.leftEyePosition.x / imageH * self.sessionView.frame.size.width);
            
            self.rightEyeView.center = CGPointMake(face.rightEyePosition.y / imageW * self.sessionView.frame.size.height,
                                                   face.rightEyePosition.x / imageH * self.sessionView.frame.size.width);
            
            self.mouthView.center = CGPointMake(face.mouthPosition.y / imageW * self.sessionView.frame.size.height,
                                                face.mouthPosition.x / imageH * self.sessionView.frame.size.width);
            
        });
    }
}

@end
