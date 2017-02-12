//
//  ViewController.h
//  GoEuroTest
//
//  Created by Peter Prokop on 10/02/2017.
//  Copyright © 2017 Prokop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoEuroTest-Swift.h"

typedef NS_ENUM(NSInteger, OfferType) {
    OfferTypeFlights,
    OfferTypeTrains,
    OfferTypeBuses
};

@interface OffersViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) OfferType offerType;

@end

