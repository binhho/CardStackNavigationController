CardStackNavigationController
=============================

CardStackNavigationController is a custom navigation controller/container (but not a subclass of UINavigationController) whose transitions have a similar feel to iOS 7's navigation controller transitions. Its usage is quite similar as you can see below!

Usage
-----

```objective-c
// Create a root view controller
TestViewController *testViewController = [[TestViewController alloc] init];

// Create a card stack navigation controller with the root view controller
CardStackNavigationController *navCon = [[CardStackNavigationController alloc] initWithRootViewController:testViewController];

// Add the card stack navigation controller's view to any view
[self.view addSubview navCon.view];

// Push a new view controller
UIViewController *viewController = [[UIViewController alloc] init];

// The card stack navigation controller is accessible via the 'cardStackNavigationController' property of UIViewController
[testViewController.cardStackNavigationController pushViewController:viewController animated:YES completion:nil];

[viewController release];
[testViewController release];
```
