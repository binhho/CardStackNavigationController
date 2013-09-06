//
//  TestViewController.m
//  CardStackNavigationController
//
//  Created by William Chang on 2013-09-05.
//  Copyright (c) 2013 William Chang. All rights reserved.
//

#import "TestViewController.h"
#import "CardStackNavigationController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - Actions

- (IBAction)next:(id)sender {
	TestViewController *vc = [[TestViewController alloc] init];
	[self.cardStackNavigationController pushViewController:vc animated:YES completion:nil];
	[vc release];
}

- (IBAction)back:(id)sender {
	[self.cardStackNavigationController popViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
