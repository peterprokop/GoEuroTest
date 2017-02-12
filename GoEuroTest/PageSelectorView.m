//
//  PageSelectorView.m
//  GoEuroTest
//
//  Created by Peter Prokop on 12/02/17.
//  Copyright © 2017 Prokop. All rights reserved.
//

#import "PageSelectorView.h"
#import <pop/POP.h>

@implementation PageSelectorView {
    NSMutableArray<UIButton *>* _buttons;
    NSUInteger _selectedIndex;
    UIView* _selectedMarker;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor colorWithRed:17/255. green:99/255. blue:162/255. alpha:1.0];
    
    _selectedMarker = [[UIView alloc] initWithFrame:CGRectZero];
    _selectedMarker.backgroundColor = [UIColor whiteColor];
    [self addSubview:_selectedMarker];
}

- (void)setPageTitles:(NSArray<NSString *> *)titles {
    for (UIButton* button in _buttons) {
        [button removeFromSuperview];
    }
    
    _selectedIndex = 0;
    _buttons = [NSMutableArray new];
   
    NSUInteger index = 0;
    for (NSString* title in titles) {
        UIButton* button = [UIButton buttonWithType: UIButtonTypeSystem];
        button.tag = index;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(buttonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
        
        [_buttons addObject:button];
        [self addSubview:button];
        index++;
    }
    
    [self layoutSubviews];
}

- (void)layoutSubviews {
    CGFloat distance = self.bounds.size.width / (_buttons.count + 1);
    CGFloat centerY = self.bounds.size.height / 2;
    
    NSUInteger index = 0;
    for (UIButton* button in _buttons) {
        [button sizeToFit];
        button.center = CGPointMake( (index + 1) * distance, centerY);
        index++;
    }
    
    if (![[_selectedMarker pop_animationKeys] containsObject:@"frame"]) {
        [self updateSelectionMarker: NO];
    }
}

- (void)updateSelectionMarker:(BOOL)animated {
    UIButton* button = _buttons[_selectedIndex];
    CGFloat minX = CGRectGetMinX(button.frame);
    CGFloat maxY = CGRectGetMaxY(button.frame);
    CGFloat width = button.frame.size.width;
    CGRect markerFrame = CGRectMake(minX, maxY - 1, width, 1);
    
    if (animated) {
        POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];;
        
        anim.dynamicsTension = 10.f;
        anim.dynamicsFriction = 1.f;
        anim.springBounciness = 12.f;
        
        anim.toValue = [NSValue valueWithCGRect:markerFrame];
        [_selectedMarker pop_addAnimation:anim forKey:@"frame"];
    } else {
        _selectedMarker.frame = markerFrame;
    }
}

- (void)setSelectedIndex:(NSUInteger)index {
    _selectedIndex = index;
    
    [self updateSelectionMarker: YES];
}

#pragma mark Actions

- (void)buttonTapped:(UIButton *)sender {
    if (_selectedIndex == sender.tag) {
        return;
    }
    
    NSUInteger previousPage = _selectedIndex;
    _selectedIndex = sender.tag;
    
    [self updateSelectionMarker: YES];
    
    [_delegate pageSelectorView: self
                  didSelectPage: _selectedIndex
                   previousPage: previousPage];
}

@end
