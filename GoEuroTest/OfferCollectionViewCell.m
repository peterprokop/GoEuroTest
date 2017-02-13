//
//  OfferCollectionViewCell.m
//  GoEuroTest
//
//  Created by Peter Prokop on 12/02/17.
//  Copyright © 2017 Prokop. All rights reserved.
//

#import "OfferCollectionViewCell.h"
#import <SDWebImage/SDWebImage.h>
#import "Formatters.h"
#import "Config.h"

@implementation OfferCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _separator.backgroundColor = kBlueColor;
    _separator.alpha = .5f;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_logoImageView sd_cancelCurrentImageLoad];
}

- (void)updateWithModel:(TimeTableEntity *) timeTableEntity {
    
    _priceLabel.text = [[Formatters currency] stringFromNumber:[NSNumber numberWithDouble:timeTableEntity.priceInEuros]];
    _timesLabel.text = [NSString stringWithFormat:@"%@ - %@ (%@)",
                        timeTableEntity.departureTime,
                        timeTableEntity.arrivalTime,
                        timeTableEntity.durationDescription
    ];

    _numberOfChangesLabel.text = [timeTableEntity numberOfStopsDescription];

    NSURL* logoURL = [timeTableEntity providerLogoURLForSize:63];
    [_logoImageView sd_setImageWithURL: logoURL];
}

@end
