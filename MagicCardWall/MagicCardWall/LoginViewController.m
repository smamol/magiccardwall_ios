//
//  LoginViewController.m
//  MagicCardWall
//
//  Created by Nick Parfene on 11/6/14.
//  Copyright (c) 2014 Trade Me. All rights reserved.
//

#import "LoginViewController.h"

#import "MagicCardWallClient.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;


@end

@implementation LoginViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"Login requested");
}


- (IBAction)touchedButtonLogin:(UIButton *)sender {
    
    MagicCardWallClient *client = [[MagicCardWallClient sharedInstance]];
    [client loginWithUsername:self.textFieldUsername.text password:self.textFieldPassword.text completion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"LOGGED IN!");
            [self dismissViewControllerAnimated:YES completion:^{
                NSLog(@"Dismissed");
            }];
        }
        else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];

}

@end
