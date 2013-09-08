//
//  AnotherTestViewController.m
//  CardStackNavigationController
//
//  Created by William Chang on 2013-09-08.
//  Copyright (c) 2013 William Chang. All rights reserved.
//

#import "AnotherTestViewController.h"
#import "TestViewController.h"

@interface AnotherTestViewController ()

@end

@implementation AnotherTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (void)viewDidLoad {
//    [super viewDidLoad];
//	NSLog(@"%@ view did load", self);
//}
//
//- (void)viewWillAppear:(BOOL)animated {
//	[super viewWillAppear:animated];
//	NSLog(@"%@ view will appear", self);
//}
//
//- (void)viewDidAppear:(BOOL)animated {
//	[super viewDidAppear:animated];
//	NSLog(@"%@ view did appear", self);
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//	[super viewWillDisappear:animated];
//	NSLog(@"%@ view will disappear", self);
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//	[super viewDidDisappear:animated];
//	NSLog(@"%@ view did disappear", self);
//}

- (IBAction)push:(id)sender {
	TestViewController *testViewController = [[TestViewController alloc] init];
	[self.cardStackNavigationController pushViewController:testViewController animated:YES completion:nil];
	[testViewController release];
}

- (IBAction)pop:(id)sender {
	[self.cardStackNavigationController popViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
