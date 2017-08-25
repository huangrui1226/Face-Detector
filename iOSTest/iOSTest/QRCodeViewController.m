//
//  QRCodeViewController.m
//  FaceDetector
//
//  Created by 黄瑞 on 2017/8/25.
//  Copyright © 2017年 CoderHuang. All rights reserved.
//

#import "QRCodeViewController.h"

@interface QRCodeViewController ()
{
    NSInteger count;
}

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layer;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) UIView *sessionView;
// 二维码识别
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) CIDetector *detector;

@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessionView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.sessionView];
    
    self.context = [CIContext context];
    self.detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:self.context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVCaptureSessionRuntimeErrorNotification:) name:AVCaptureSessionRuntimeErrorNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.session stopRunning];
    
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
    
    count++;
    if (count < 32) {
        return;
    }
    count = 0;
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *image = [[CIImage alloc] initWithCVImageBuffer:imageBuffer];
    
    CIFeature *feature = [[self.detector featuresInImage:image] lastObject];
    if (feature) {
        [self.session stopRunning];
        CIQRCodeFeature *qrCode = (CIQRCodeFeature *)feature;
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:qrCode.messageString message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertVC addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        });
    }
}

@end
