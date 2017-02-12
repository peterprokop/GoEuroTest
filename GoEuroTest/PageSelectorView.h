//
//  PageSelectorView.h
//  GoEuroTest
//
//  Created by Peter Prokop on 12/02/17.
//  Copyright © 2017 Prokop. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PageSelectorView;

@protocol PageSelectorViewDelegate <NSObject>

- (void)pageSelectorView:(PageSelectorView *) pageSelectorView
           didSelectPage:(NSUInteger) page
            previousPage:(NSUInteger) previousPage;

@end



@interface PageSelectorView : UIView

@property (nonatomic, weak) id<PageSelectorViewDelegate> delegate;

- (void)setPageTitles:(NSArray<NSString *> *)titles;
- (void)setSelectedIndex:(NSUInteger)index;

@end

