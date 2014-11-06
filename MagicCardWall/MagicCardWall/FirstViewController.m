//
//  FirstViewController.m
//  MagicCardWall
//
//  Created by Nick Parfene on 11/6/14.
//  Copyright (c) 2014 Trade Me. All rights reserved.
//

@import AVFoundation;

#import "FirstViewController.h"

@interface FirstViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong) AVCaptureSession *captureSession;
@property (strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (weak, nonatomic) IBOutlet UILabel *labelQRCodeResult;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
}


@end
