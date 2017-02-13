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

@interface HomeViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate, PageSelectorViewDelegate>

@property (nonatomic, weak) IBOutlet PageSelectorView* pageSelectorView;
@property (nonatomic, weak) UIPageViewController* pageViewController;

@end

@implementation HomeViewController {
    NSArray<UIViewController *>* _viewControllers;
}

- (void)loadView {
    [super loadView];
    
    OffersViewController* flightsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OffersViewController"];
    flightsViewController.offerType = OfferTypeFlights;

    OffersViewController* trainsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OffersViewController"];
    trainsViewController.offerType = OfferTypeTrains;
    
    OffersViewController* busesViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OffersViewController"];
    busesViewController.offerType = OfferTypeBuses;
    
    _viewControllers = @[flightsViewController, trainsViewController, busesViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pageSelectorView.delegate = self;
    [_pageSelectorView setPageTitles: @[@"Flights", @"Trains", @"Buses"]];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual: @"EmbedPageViewController"]) {
        
        _pageViewController = segue.destinationViewController;
        
        [_pageViewController setViewControllers:@[_viewControllers[0]]
                                     direction:UIPageViewControllerNavigationDirectionForward
                                      animated:NO
                                    completion:nil];
        
        _pageViewController.dataSource = self;
        _pageViewController.delegate = self;
    }
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        NSUInteger index = [_viewControllers indexOfObject:pageViewController.viewControllers[0]];
        
        if (index != NSNotFound) {
            [_pageSelectorView setSelectedIndex: index];
        }
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [_viewControllers indexOfObject:viewController];
    
    if (index != NSNotFound && index < _viewControllers.count - 1) {
        return _viewControllers[index + 1];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [_viewControllers indexOfObject:viewController];
    
    if (index != NSNotFound && index > 0) {
        return _viewControllers[index - 1];
    }
    
    return nil;
}

#pragma mark - PageSelectorViewDelegate

- (void)pageSelectorView:(PageSelectorView *)pageSelectorView didSelectPage:(NSUInteger) page previousPage:(NSUInteger) previousPage {
    
    UIPageViewControllerNavigationDirection direction =
        page > previousPage ?
        UIPageViewControllerNavigationDirectionForward
        : UIPageViewControllerNavigationDirectionReverse;
    
    [_pageViewController setViewControllers:@[_viewControllers[page]]
                                  direction:direction
                                   animated:YES
                                 completion:nil];
}

@end
