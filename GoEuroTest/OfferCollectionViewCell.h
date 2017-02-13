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

@property (nonatomic, weak) IBOutlet UILabel* priceLabel;
@property (nonatomic, weak) IBOutlet UILabel* timesLabel;
@property (nonatomic, weak) IBOutlet UILabel* numberOfChangesLabel;

@property (nonatomic, weak) IBOutlet UIImageView* logoImageView;

@property (nonatomic, weak) IBOutlet UIView* separator;

- (void)updateWithModel:(TimeTableEntity *) timeTableEntity;

@end
