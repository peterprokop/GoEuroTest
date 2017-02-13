//
//  UINavigationController_StatusBarStyle.m
//  GoEuroTest
//
//  Created by Peter Prokop on 13/02/17.
//  Copyright © 2017 Prokop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (StatusBarStyle)

@end

@implementation UINavigationController (StatusBarStyle)

-(UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

-(UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

@end
