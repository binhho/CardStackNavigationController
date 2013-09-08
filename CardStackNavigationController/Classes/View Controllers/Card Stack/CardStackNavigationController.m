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

#pragma mark - Getters/Setters

- (UIViewController *)topViewController {
	return [_viewControllers lastObject];
}

- (void)setViewControllers:(NSArray *)viewControllers {
	[self setViewControllers:viewControllers animated:NO completion:nil];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated completion:(void (^)())completion {
	UIViewController *topViewController = [self.topViewController retain];
	UIViewController *newTopViewController = [viewControllers lastObject];
	
	void (^setViewControllersCompletionBlock)() = ^(){
		[self handlePostAnimationLifecycleTransitioningFromViewController:topViewController toViewController:newTopViewController];
		
		[_viewControllers release];
		_viewControllers = [[NSMutableArray alloc] initWithArray:viewControllers];
		
		[topViewController release];
		
		if (completion) {
			completion();
		}
	};
	
	[self handlePreAnimationLifecycleTransitioningFromViewController:topViewController toViewController:newTopViewController];
	
	if (animated) {
		// If the new top view controller is in the current array, then transition as if we're popping
		if ([_viewControllers indexOfObject:newTopViewController] != NSNotFound) {
			// "Popping" from topViewController to newTopViewController
			[self animatePoppingTransitionFromViewController:topViewController toViewController:newTopViewController completion:setViewControllersCompletionBlock];
		} else {
			// If the new top view controler is NOT in the current array, then transition as if we're pushing
			[self animatedPushingTransitionFromViewController:topViewController toViewController:newTopViewController completion:setViewControllersCompletionBlock];
		}
	} else {
		newTopViewController.view.frame = self.view.bounds;
		[self.view addSubview:newTopViewController.view];
		[topViewController.view removeFromSuperview];
		
		setViewControllersCompletionBlock();
	}
}

#pragma mark - Navigation

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)())completion {
	UIViewController *backgroundViewController = self.topViewController;
	
	// Add to view controllers array
	[_viewControllers addObject:viewController];
	
	// Separate animation and lifecycle logic by creating pre and post view/animation logic blocks
	[self handlePreAnimationLifecycleTransitioningFromViewController:backgroundViewController toViewController:viewController];
	
	if (animated) {
		[self animatedPushingTransitionFromViewController:backgroundViewController toViewController:viewController completion:^(){
			[self handlePostAnimationLifecycleTransitioningFromViewController:backgroundViewController toViewController:viewController];
		}];
	} else {
		viewController.view.frame = self.view.bounds;
		[self.view addSubview:viewController.view];
		
		[backgroundViewController.view removeFromSuperview];
		
		[self handlePostAnimationLifecycleTransitioningFromViewController:backgroundViewController toViewController:viewController];
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
	
	// Separate animation and lifecycle logic by creating pre and post view/animation logic blocks	
	[self handlePreAnimationLifecycleTransitioningFromViewController:foregroundViewController toViewController:viewController];
	
	void (^postAnimationLifecycleHandlerBlock)() = ^(){		
		[self handlePostAnimationLifecycleTransitioningFromViewController:foregroundViewController toViewController:viewController];
		[foregroundViewController release];
	};

	if (animated) {
		[self animatePoppingTransitionFromViewController:foregroundViewController toViewController:viewController completion:postAnimationLifecycleHandlerBlock];
	} else {
		viewController.view.frame = self.view.bounds;
		[self.view addSubview:viewController.view];
		
		[foregroundViewController.view removeFromSuperview];
		
		postAnimationLifecycleHandlerBlock();
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

#pragma mark - Pre and Post Animation Lifecycle Methods

- (void)handlePreAnimationLifecycleTransitioningFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController {
	[fromViewController willMoveToParentViewController:nil];
	[self addChildViewController:toViewController];
}

- (void)handlePostAnimationLifecycleTransitioningFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController {
	[toViewController didMoveToParentViewController:self];
	[fromViewController removeFromParentViewController];
	[fromViewController didMoveToParentViewController:nil];
}

#pragma mark - Transitioning

- (void)animatedPushingTransitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController completion:(void (^)())completion {
	// Adjust frame of toViewController by setting it off screen to the right
	CGRect toViewControllerFrame = toViewController.view.frame;
	toViewControllerFrame.origin.x = self.view.bounds.size.width;
	toViewController.view.frame = toViewControllerFrame;
	toViewControllerFrame.origin.x = 0.0;
	
	// Add toViewController's view as a subview
	[self.view addSubview:toViewController.view];
	
	// Set up fromViewController's view to end up slightly off screen to the left after the animation
	CGRect fromViewControllerFrame = fromViewController.view.frame;
	fromViewControllerFrame.origin.x = -40.0;
	
	// Animate toViewController's view to slide in from the right and fromViewController's view to shift over to the left slightly off screen
	[UIView animateWithDuration:DURATION_PUSH delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		toViewController.view.frame = toViewControllerFrame;
		fromViewController.view.frame = fromViewControllerFrame;
	} completion:^(BOOL finished) {
		[fromViewController.view removeFromSuperview];
		
		if (completion) {
			completion();
		}
	}];
}

- (void)animatePoppingTransitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController completion:(void (^)())completion {
	// Adjust the frame of toViewController to be very slightly off screen and to end up at 0.0 after animation
	CGRect toViewControllerFrame = toViewController.view.frame;
	toViewControllerFrame.origin.x = -40.0;
	toViewController.view.frame = toViewControllerFrame;
	toViewControllerFrame.origin.x = 0.0;
	
	// Add the view of the toViewController behind the fromViewController
	[self.view insertSubview:toViewController.view belowSubview:fromViewController.view];
	
	// Adjust frame of fromViewController that will be animated
	CGRect fromViewControllerFrame = fromViewController.view.frame;
	fromViewControllerFrame.origin.x = self.view.bounds.size.width;
	
	// Animate frame of fromViewController to slide off screen
	[UIView animateWithDuration:DURATION_POP delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		fromViewController.view.frame = fromViewControllerFrame;
		toViewController.view.frame = toViewControllerFrame;
	} completion:^(BOOL finished) {
		[fromViewController.view removeFromSuperview];
		
		if (completion) {
			completion();
		}
	}];
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
