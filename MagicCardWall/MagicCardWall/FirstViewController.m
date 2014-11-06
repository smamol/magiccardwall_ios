//
//  FirstViewController.m
//  MagicCardWall
//
//  Created by Nick Parfene on 11/6/14.
//  Copyright (c) 2014 Trade Me. All rights reserved.
//

@import AVFoundation;
@import AudioToolbox;

#import "FirstViewController.h"

#import "Lockbox.h"
#import "MagicCardWallClient.h"

@interface FirstViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property SystemSoundID scanSound;

@property (weak, nonatomic) IBOutlet UILabel *labelQRCodeResult;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Should I log in?

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[Lockbox stringForKey:@"Token"] length] <= 0) {
        // force login
        [self performSegueWithIdentifier:@"login" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchedButtonScan:(UIButton *)sender {
    NSLog(@"Touched button scan");
    
    [self scanQRCode];
}

- (void)scanQRCode {
    self.captureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (input) {
        [self.captureSession addInput:input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:metadataOutput];
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.frame = self.view.layer.bounds;
    [self.view.layer addSublayer:self.previewLayer];
    
    [self.captureSession startRunning];
}

- (void)viewWillLayoutSubviews {
    self.previewLayer.frame = self.view.bounds;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    NSString *QRCode = nil;
    for (AVMetadataObject *metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            // This will never happen; nobody has ever scanned a QR code... ever
            QRCode = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            break;
        }
    }
    
    NSLog(@"QR Code: %@", QRCode);
    self.labelQRCodeResult.text = QRCode;
    
    [self.previewLayer removeFromSuperlayer];
    [self.captureSession stopRunning];
    
    [[MagicCardWallClient sharedInstance] incrementStateForTask:QRCode undo:NO completion:^(BOOL success, NSError *error) {
        if (success) {
            [self playScanSound];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //-- start again after a couple of second (long enough to show the scan result)
                [self.captureSession startRunning];
                [self.view.layer addSublayer:self.previewLayer];
            });
        }
        else {
            [self playErrorSound];
        }
    }];
    
}

- (void)playScanSound {
    NSString *scanSoundPath = [[NSBundle mainBundle] pathForResource:@"scan_sound" ofType:@"wav"];
    NSURL *pewPewURL = [NSURL fileURLWithPath:scanSoundPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &_scanSound);
    AudioServicesPlaySystemSound(self.scanSound);
}

- (void)playErrorSound {
    NSString *scanSoundPath = [[NSBundle mainBundle] pathForResource:@"error_sound" ofType:@"wav"];
    NSURL *pewPewURL = [NSURL fileURLWithPath:scanSoundPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &_scanSound);
    AudioServicesPlaySystemSound(self.scanSound);
}



@end
