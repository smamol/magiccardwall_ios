//
//  SecondViewController.m
//  MagicCardWall
//
//  Created by Nick Parfene on 11/6/14.
//  Copyright (c) 2014 Trade Me. All rights reserved.
//

#import "SecondViewController.h"

#import "MagicCardWallClient.h"

@interface SecondViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelShakeIt;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        self.labelShakeIt.text = @"I Shook It!";
        
        MagicCardWallClient *client = [[MagicCardWallClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://tmlt218.trademe.local"]];
        [client loginWithUsername:@"scook" password:@"Masmall6" completion:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"LOGGED IN!");
            }
            else {
                NSLog(error.localizedDescription);
            }
        }];
    }
}



@end
