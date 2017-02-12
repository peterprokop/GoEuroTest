//
//  OfferCollectionViewCell.m
//  GoEuroTest
//
//  Created by Peter Prokop on 12/02/17.
//  Copyright © 2017 Prokop. All rights reserved.
//

#import "OfferCollectionViewCell.h"
#import <SDWebImage/SDWebImage.h>

@implementation OfferCollectionViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_logoImageView sd_cancelCurrentImageLoad];
}

- (void)updateWithModel:(TimeTableEntity *) timeTableEntity {
    _priceLabel.text = [NSString stringWithFormat:@"%f", timeTableEntity.priceInEuros];
    _timesLabel.text = timeTableEntity.departureTime;
    _numberOfChangesLabel.text = [NSString stringWithFormat:@"%ld", (long)timeTableEntity.numberOfStops];

    NSURL* logoURL = [timeTableEntity providerLogoURLForSize:63];
    [_logoImageView sd_setImageWithURL: logoURL];
}

@end
