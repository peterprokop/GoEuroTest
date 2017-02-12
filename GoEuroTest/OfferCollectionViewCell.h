//
//  OfferCollectionViewCell.h
//  GoEuroTest
//
//  Created by Peter Prokop on 12/02/17.
//  Copyright © 2017 Prokop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoEuroTest-Swift.h"

@interface OfferCollectionViewCell : UICollectionViewCell

@property IBOutlet UILabel* priceLabel;
@property IBOutlet UILabel* timesLabel;
@property IBOutlet UILabel* numberOfChangesLabel;

@property IBOutlet UIImageView* logoImageView;

- (void)updateWithModel:(TimeTableEntity *) timeTableEntity;

@end
