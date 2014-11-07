//
//  SecondViewController.m
//  MagicCardWall
//
//  Created by Nick Parfene on 11/6/14.
//  Copyright (c) 2014 Trade Me. All rights reserved.
//

#import "HistoryViewController.h"

#import "MagicCardWallClient.h"
#import "HistoryItem.h"

@interface HistoryItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageViewGravatar;
@property (weak, nonatomic) IBOutlet UILabel *labelMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelTimestamp;


@end

@implementation HistoryItemCell

@end

#pragma mark - View Controller

@interface HistoryViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelShakeIt;

@property (strong, nonatomic) NSArray *arrayOfHistoryItems;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 120;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [[MagicCardWallClient sharedInstance] getHistoryWithCompletion:^(NSArray *arrayOfHistoryItems, NSError *error) {
        if (error) {
            NSLog(@"Error getting the history items %@", [error localizedDescription]);
        }
        else {
            NSLog(@"Got %i items", [arrayOfHistoryItems count]);
            self.arrayOfHistoryItems = arrayOfHistoryItems;
            
            [self.tableView reloadData];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrayOfHistoryItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    HistoryItem *historyItem = self.arrayOfHistoryItems[indexPath.row];
    cell.textLabel.text = historyItem.username;
    cell.detailTextLabel.text = historyItem.timestamp;
    
    return cell;
}


@end
