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

typedef enum {
	CardStackNavigationTransitionTypePush,
	CardStackNavigationTransitionTypePop,
} CardStackNavigationTransitionType;

@interface CardStackNavigationController ()

@end

@implementation CardStackNavigationController
@dynamic topViewController;
@dynamic backViewController;
@dynamic rootViewController;

- (void)dealloc {
	[_viewControllers release];
	[super dealloc];
}

- (id)initWithRootViewController:(UIViewController *)viewController {
	if ((self = [super init])) {
		_viewControllers = [[NSMutableArray alloc] initWithObjects:viewController, nil];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.clipsToBounds = YES;
	
	if ([_viewControllers count]) {
		[self transition:CardStackNavigationTransitionTypePush fromViewController:nil toViewController:[_viewControllers lastObject] animated:NO completion:nil];
	}
}

#pragma mark - Dynamic Getters

- (UIViewController *)topViewController {
	return [_viewControllers lastObject];
}

- (UIViewController *)backViewController {
	NSInteger count = [_viewControllers count];
	if (count >= 2) {
		return [_viewControllers objectAtIndex:count - 2];
	}
	return nil;
}

- (UIViewController *)rootViewController {
	if ([_viewControllers count]) {
		return [_viewControllers objectAtIndex:0];
	}
	return nil;
}

#pragma mark - Set View Controllers

- (void)setViewControllers:(NSArray *)viewControllers {
	[self setViewControllers:viewControllers animated:NO completion:nil];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated completion:(void (^)())completion {
	UIViewController *topViewController = [self.topViewController retain];
	UIViewController *newTopViewController = [viewControllers lastObject];
	
	CardStackNavigationTransitionType transitionType = ([_viewControllers indexOfObject:newTopViewController] != NSNotFound ? CardStackNavigationTransitionTypePop : CardStackNavigationTransitionTypePush);
	[self transition:transitionType fromViewController:topViewController toViewController:newTopViewController animated:animated completion:^(){
		[_viewControllers release];
		_viewControllers = [[NSMutableArray alloc] initWithArray:viewControllers];
		
		[topViewController release];
		
		if (completion) {
			completion();
		}
	}];
}

#pragma mark - Public Navigation Methods

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)())completion {
	UIViewController *backgroundViewController = self.topViewController;
	
	// Add to view controllers array
	[_viewControllers addObject:viewController];
	
	// Transition
	[self transition:CardStackNavigationTransitionTypePush fromViewController:backgroundViewController toViewController:viewController animated:animated completion:completion];
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
	
	// Transition
	[self transition:CardStackNavigationTransitionTypePop fromViewController:foregroundViewController toViewController:viewController animated:animated completion:^(){
		[foregroundViewController release];
		
		if (completion) {
			completion();
		}
	}];
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

#pragma mark - Transitioning (Handling all lifecycle and animation logic)

- (void)transition:(CardStackNavigationTransitionType)transitionType fromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController animated:(BOOL) animated completion:(void (^)())completion {
	[self handlePreAnimationLifecycleTransitioningFromViewController:fromViewController toViewController:toViewController];
	[self handleViewTransitionType:transitionType fromViewController:fromViewController toViewController:toViewController animated:animated completion:^(){
		[self handlePostAnimationLifecycleTransitioningFromViewController:fromViewController toViewController:toViewController];
		
		if (completion) {
			completion();
		}
	}];
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

#pragma mark - View/Animation Handling During Transition

- (void)handleViewTransitionType:(CardStackNavigationTransitionType)transitionType fromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController animated:(BOOL)animated completion:(void (^)())completion {
	void (^transitionCompletionBlock)() = ^(){
		[fromViewController.view removeFromSuperview];
		
		if (completion) {
			completion();
		}
	};
	
	if (animated) {
		CGRect toViewControllerFrame = toViewController.view.frame;
		CGRect fromViewControllerFrame = fromViewController.view.frame;
		NSTimeInterval animationDuration = 0.0;
		UIViewAnimationOptions animationOptions = 0;
		
		if (transitionType == CardStackNavigationTransitionTypePush) {
			// Adjust frame of toViewController by setting it off screen to the right
			toViewControllerFrame.origin.x = self.view.bounds.size.width;
			toViewController.view.frame = toViewControllerFrame;
			
			// Add toViewController's view on screen
			[self.view addSubview:toViewController.view];
			
			// Set up fromViewController's view to end up slightly off screen to the left after the animation
			fromViewControllerFrame.origin.x = -40.0;
			
			// Set animation options
			animationDuration = DURATION_PUSH;
			animationOptions = UIViewAnimationOptionCurveEaseInOut;
			
		} else if (transitionType == CardStackNavigationTransitionTypePop) {
			// Adjust the frame of toViewController to be slightly off screen to the left
			toViewControllerFrame.origin.x = -40.0;
			toViewController.view.frame = toViewControllerFrame;
			
			// Add the view of the toViewController behind the fromViewController's view so it is revealed duration the animation
			[self.view insertSubview:toViewController.view belowSubview:fromViewController.view];
			
			// Adjust frame of fromViewController's view so it ends up off screen to the right
			fromViewControllerFrame.origin.x = self.view.bounds.size.width;
			
			// Set animation options
			animationDuration = DURATION_POP;
			animationOptions = UIViewAnimationOptionCurveEaseOut;
		}
		
		// Animate the soon-to-be top view controller to be at 0
		toViewControllerFrame.origin.x = 0.0;
		
		[UIView animateWithDuration:animationDuration delay:0.0 options:animationOptions animations:^{
			fromViewController.view.frame = fromViewControllerFrame;
			toViewController.view.frame = toViewControllerFrame;
		} completion:^(BOOL finished) {
			transitionCompletionBlock();
		}];
		
	} else {
		toViewController.view.frame = self.view.bounds;
		[self.view addSubview:toViewController.view];
		
		transitionCompletionBlock();
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
