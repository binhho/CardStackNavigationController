//
//  TestViewController.m
//  CardStackNavigationController
//
//  Created by William Chang on 2013-09-05.
//  Copyright (c) 2013 William Chang. All rights reserved.
//

#import "TestViewController.h"
#import "CardStackNavigationController.h"
#import "AnotherTestViewController.h"

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

#pragma mark - Actions

- (IBAction)next:(id)sender {
	TestViewController *vc = [[TestViewController alloc] init];
	[self.cardStackNavigationController pushViewController:vc animated:YES completion:nil];
	[vc release];
}

- (IBAction)back:(id)sender {
	[self.cardStackNavigationController popViewControllerAnimated:YES completion:nil];
}

- (IBAction)setViewControllersAnimated:(id)sender {
	AnotherTestViewController *anotherViewController = [[AnotherTestViewController alloc] init];
	AnotherTestViewController *anotherViewController2 = [[AnotherTestViewController alloc] init];
	AnotherTestViewController *anotherViewController3 = [[AnotherTestViewController alloc] init];
	
	[self.cardStackNavigationController setViewControllers:@[anotherViewController, anotherViewController2, anotherViewController3] animated:YES completion:nil];
	
	[anotherViewController release];
	[anotherViewController2 release];
	[anotherViewController3 release];
}

- (IBAction)setViewControllersAnimatedWithExistingViewController:(id)sender {
	if ([self.cardStackNavigationController.viewControllers count]) {
		AnotherTestViewController *anotherViewController2 = [[AnotherTestViewController alloc] init];
		AnotherTestViewController *anotherViewController3 = [[AnotherTestViewController alloc] init];
		
		[self.cardStackNavigationController setViewControllers:@[anotherViewController2, anotherViewController3, [self.cardStackNavigationController.viewControllers objectAtIndex:0]] animated:YES completion:nil];
		
		[anotherViewController2 release];
		[anotherViewController3 release];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
