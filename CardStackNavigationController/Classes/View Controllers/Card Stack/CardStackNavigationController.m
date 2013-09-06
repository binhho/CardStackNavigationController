//
//  CardStackNavigationControllerViewController.m
//  CardStackNavigationController
//
//  Created by William Chang on 2013-09-05.
//  Copyright (c) 2013 William Chang. All rights reserved.
//

#import "CardStackNavigationController.h"

#define DURATION_PUSH 0.4
#define DURATION_POP 0.3

@interface CardStackNavigationController ()

@end

@implementation CardStackNavigationController
@dynamic topViewController;

- (void)dealloc {
	[_rootViewController release];
	[_viewControllers release];
	[super dealloc];
}

- (id)initWithRootViewController:(UIViewController *)viewController {
	if ((self = [super init])) {
		_rootViewController = [viewController retain];
		_viewControllers = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.clipsToBounds = YES;
	
	if (_rootViewController) {
		[self pushViewController:_rootViewController animated:NO completion:nil];
	}
}

#pragma mark - Top View Controller

- (UIViewController *)topViewController {
	return [_viewControllers lastObject];
}

#pragma mark - Navigation

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)())completion {
	// Remove previous top view controller as current
	UIViewController *backgroundViewController = self.topViewController;
	[backgroundViewController willMoveToParentViewController:nil];
	[backgroundViewController removeFromParentViewController];
	[backgroundViewController didMoveToParentViewController:nil];
	
	// Add to view controllers array
	[_viewControllers addObject:viewController];
	
	// Add as a child
	[self addChildViewController:viewController];
	
	if (animated) {
		// Adjust frame to be out of view
		CGRect foregroundFrame = viewController.view.frame;
		foregroundFrame.size = self.view.bounds.size;
		foregroundFrame.origin = CGPointMake(self.view.bounds.size.width, 0.0);
		viewController.view.frame = foregroundFrame;
		
		CGRect backgroundFrame = backgroundViewController.view.frame;
		backgroundFrame.origin.x = -40.0;
		
		// Add subview
		[self.view addSubview:viewController.view];
		[viewController didMoveToParentViewController:self];
		
		// Animate
		foregroundFrame.origin = CGPointZero;
		[UIView animateWithDuration:DURATION_PUSH delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			viewController.view.frame = foregroundFrame;
			backgroundViewController.view.frame = backgroundFrame;
		} completion:^(BOOL finished) {
			if (completion) {
				completion();
			}
		}];
	} else {
		// Adjust frame to be 0
		viewController.view.frame = self.view.bounds;
		
		// Add subview
		[self.view addSubview:viewController.view];
		[viewController didMoveToParentViewController:self];
	}
}

- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)())completion {
	if (viewController == self.topViewController) {
		return;
	}
	
	// Retain top view controller so we still have a valid reference to it
	UIViewController *foregroundViewController = [self.topViewController retain];
	
	// Pop all view controllers until we reach the desired one
	NSArray *viewControllersCopy = [[NSArray alloc] initWithArray:_viewControllers];
	for (int i = [viewControllersCopy count] - 1; i >= 0; i--) {
		UIViewController *vc = [viewControllersCopy objectAtIndex:i];
		if (vc != viewController) {
			[_viewControllers removeObject:vc];
		} else {
			break;
		}
	}
	[viewControllersCopy release];
	
	// Remove from parent
	[foregroundViewController willMoveToParentViewController:nil];
	[foregroundViewController removeFromParentViewController];
	[foregroundViewController didMoveToParentViewController:nil];
	
	void (^popCompletionBlock)() = ^() {
		[foregroundViewController.view removeFromSuperview];
		
		[self addChildViewController:viewController];
		[viewController didMoveToParentViewController:self];
		
		[foregroundViewController release];
		
		if (completion) {
			completion();
		}
	};
	
	if (animated) {
		CGRect foregroundFrame = foregroundViewController.view.frame;
		foregroundFrame.origin.x = self.view.bounds.size.width;
		
		CGRect backgroundFrame = viewController.view.frame;
		backgroundFrame.origin.x = -40.0;
		viewController.view.frame = backgroundFrame;
		backgroundFrame.origin.x = 0.0;
		
		[UIView animateWithDuration:DURATION_POP delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			foregroundViewController.view.frame = foregroundFrame;
			viewController.view.frame = backgroundFrame;
		} completion:^(BOOL finished) {
			popCompletionBlock();
		}];
	} else {
		popCompletionBlock();
	}
}

- (void)popViewControllerAnimated:(BOOL)animated completion:(void (^)())completion {
	NSInteger count = [_viewControllers count];
	if (count > 1) {
		UIViewController *secondLastViewController = [_viewControllers objectAtIndex:count - 2];
		[self popToViewController:secondLastViewController animated:animated completion:completion];
	}
}

- (void)popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)())completion {
	if ([_viewControllers count] > 1) {
		[self popToViewController:[_viewControllers objectAtIndex:0] animated:animated completion:completion];
	}
}

@end

@implementation UIViewController(CardStackNavigation)
@dynamic cardStackNavigationController;

- (CardStackNavigationController *)cardStackNavigationController {
	if ([self.parentViewController isKindOfClass:[CardStackNavigationController class]]) {
		return (CardStackNavigationController *)self.parentViewController;
	}
	return nil;
}

@end
