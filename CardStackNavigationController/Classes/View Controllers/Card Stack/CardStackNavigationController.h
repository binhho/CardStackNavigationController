//
//  CardStackNavigationControllerViewController.h
//  CardStackNavigationController
//
//  Created by William Chang on 2013-09-05.
//  Copyright (c) 2013 William Chang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardStackNavigationController : UIViewController {
	UIViewController *_rootViewController;
	NSMutableArray *_viewControllers;
}

@property (nonatomic, readonly) NSArray *viewControllers;
@property (nonatomic, readonly) UIViewController *topViewController;

- (id)initWithRootViewController:(UIViewController *)viewController;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)())completion;
- (void)popViewControllerAnimated:(BOOL)animated completion:(void (^)())completion;
- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)())completion;
- (void)popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)())completion;

@end

@interface UIViewController(CardStackNavigation)

- (CardStackNavigationController *)cardStackNavigationController;

@end
