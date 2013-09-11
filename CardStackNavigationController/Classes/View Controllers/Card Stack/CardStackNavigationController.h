//
//  CardStackNavigationControllerViewController.h
//  CardStackNavigationController
//
//  Created by William Chang on 2013-09-05.
//  Copyright (c) 2013 William Chang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardStackNavigationController : UIViewController {
	UIView *_darkFadeView;
	NSMutableArray *_viewControllers;
}

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, readonly) UIViewController *topViewController;
@property (nonatomic, readonly) UIViewController *backViewController; // Returns the second last view controller
@property (nonatomic, readonly) UIViewController *rootViewController;

- (id)initWithRootViewController:(UIViewController *)viewController;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)())completion;
- (void)popViewControllerAnimated:(BOOL)animated completion:(void (^)())completion;
- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)())completion;
- (void)popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)())completion;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated completion:(void (^)())completion;

@end

@interface UIViewController(CardStackNavigation)

@property (nonatomic, readonly) CardStackNavigationController *cardStackNavigationController;

@end
