//
//  HomeViewController.m
//  GoEuroTest
//
//  Created by Peter Prokop on 12/02/17.
//  Copyright © 2017 Prokop. All rights reserved.
//

#import "HomeViewController.h"
#import "OffersViewController.h"
#import "PageSelectorView.h"

@interface HomeViewController ()<UIPageViewControllerDataSource>

@property IBOutlet PageSelectorView* pageSelectorView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_pageSelectorView setPageTitles: @[@"Flights", @"Trains", @"Buses"]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual: @"EmbedPageViewController"]) {
        
        UIPageViewController* pageViewController = segue.destinationViewController;
        
        OffersViewController* offersViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OffersViewController"];
        
        [pageViewController setViewControllers:@[offersViewController]
                                     direction:UIPageViewControllerNavigationDirectionForward
                                      animated:NO
                                    completion:nil];
        
        pageViewController.dataSource = self;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OffersViewController"];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OffersViewController"];
}

@end
