//
//  Formatters.m
//  GoEuroTest
//
//  Created by Peter Prokop on 13/02/17.
//  Copyright © 2017 Prokop. All rights reserved.
//

#import "Formatters.h"

@implementation Formatters

+ (NSNumberFormatter*)currency {
    static NSNumberFormatter* _currency;
    
    if (_currency != nil) {
        return _currency;
    }
    
    _currency = [NSNumberFormatter new];
    _currency.numberStyle = NSNumberFormatterCurrencyStyle;
    _currency.maximumFractionDigits = 2;
    _currency.locale = [NSLocale localeWithLocaleIdentifier:@"de-DE"];
    
    return _currency;
}

@end
