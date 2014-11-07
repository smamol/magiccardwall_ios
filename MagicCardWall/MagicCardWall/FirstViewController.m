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

@property (weak, nonatomic) IBOutlet UIImageView *imageViewCornerBottomRight;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCornerBottomLeft;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCornerTopRight;


@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) NSString *lastReadQRCode;

@property SystemSoundID scanSound;

@property (weak, nonatomic) IBOutlet UILabel *labelQRCodeResult;
@property (weak, nonatomic) IBOutlet UIView *viewViewFinderContainer;
@property (weak, nonatomic) IBOutlet UIView *viewStatusContainer;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewStatus;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Should I log in?
    
    CGAffineTransform topRightTransform =CGAffineTransformMakeRotation(M_PI/2);
    self.imageViewCornerTopRight.transform = topRightTransform;
    
    CGAffineTransform bottomLeftTransform =CGAffineTransformMakeRotation(-M_PI/2);
    self.imageViewCornerBottomLeft.transform = bottomLeftTransform;
    
    CGAffineTransform bottomRightTransform =CGAffineTransformMakeRotation(-M_PI);
    self.imageViewCornerBottomRight.transform = bottomRightTransform;
    
    [Lockbox setString:@"" forKey:@"Token"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self becomeFirstResponder];
    
    if ([[Lockbox stringForKey:@"Token"] length] <= 0) {
        // force login
        [self performSegueWithIdentifier:@"login" sender:self];
    }
    else {
        [self scanQRCode];
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
    
    [self.view bringSubviewToFront:self.viewStatusContainer];
    [self.view bringSubviewToFront:self.viewViewFinderContainer];
    
    [self startScanning];
}

- (void)startScanning {
    [self.captureSession startRunning];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.viewViewFinderContainer.alpha = 1.0f;
    }];
}

- (void)stopScanning {
    [self.captureSession stopRunning];
}

#pragma mark - Shaky shaky
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    //    [self stopScanning];
    
    if (motion == UIEventSubtypeMotionShake) {
        
        if ([self.lastReadQRCode length] > 0) {
            [UIView animateWithDuration:0.2f animations:^{
                self.viewStatusContainer.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [[MagicCardWallClient sharedInstance] incrementStateForTask:self.lastReadQRCode undo:YES completion:^(BOOL success, NSError *error) {
                    if (success) {
                        self.labelStatus.text = [NSString stringWithFormat:@"Your task (%@) has been moved back successfully.", self.lastReadQRCode];
                        self.imageViewStatus.image = [[UIImage imageNamed:@"undo.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        [UIView animateWithDuration:0.2f animations:^{
                            self.viewStatusContainer.alpha = 1.0f;
                        }];
                        
                        [self playUndoSound];
                    }
                    else {
                        [self playErrorSound];
                    }
                }];
            }];
        }
        
//        self.labelQRCodeResult.text = @"Attempting to undo";
    }
}

#pragma mark - Rotation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self updatePreviewLayerForOrientation:toInterfaceOrientation];
    [CATransaction commit];
}

- (void)updatePreviewLayerForOrientation:(UIInterfaceOrientation)interfaceOrientation {
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            [self.previewLayer setAffineTransform:CGAffineTransformMakeRotation(0)];
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            [self.previewLayer setAffineTransform:CGAffineTransformMakeRotation(M_PI/2)];
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            [self.previewLayer setAffineTransform:CGAffineTransformMakeRotation(-M_PI/2)];
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            [self.previewLayer setAffineTransform:CGAffineTransformMakeRotation(M_PI)];
            break;
            
        default:
            break;
    }
    
    self.previewLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
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
    self.lastReadQRCode = QRCode;
    self.labelQRCodeResult.text = QRCode;
    
    [self stopScanning];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.viewStatusContainer.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [[MagicCardWallClient sharedInstance] incrementStateForTask:QRCode undo:NO completion:^(BOOL success, NSError *error) {
            if (success) {
                self.labelStatus.text = [NSString stringWithFormat:@"Your task (%@) has been moved forward successfully.", QRCode];
                self.imageViewStatus.image = [[UIImage imageNamed:@"tick.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                self.imageViewStatus.tintColor = [UIColor whiteColor];
                [UIView animateWithDuration:0.2f animations:^{
                    self.viewStatusContainer.alpha = 1.0f;
                }];
                
                [self playScanSound];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //-- start again after a couple of second (long enough to show the scan result)
                    [self startScanning];
                });
            }
            else {
                [self playErrorSound];
                [self startScanning];
            }
        }];
    }];
}

#pragma mark - Sound playing
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

- (void)playUndoSound {
    NSString *scanSoundPath = [[NSBundle mainBundle] pathForResource:@"undo_sound" ofType:@"wav"];
    NSURL *pewPewURL = [NSURL fileURLWithPath:scanSoundPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &_scanSound);
    AudioServicesPlaySystemSound(self.scanSound);
}


@end
