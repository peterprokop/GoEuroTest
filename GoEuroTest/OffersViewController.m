//
//  ViewController.m
//  GoEuroTest
//
//  Created by Peter Prokop on 10/02/2017.
//  Copyright © 2017 Prokop. All rights reserved.
//

#import "OffersViewController.h"
#import "OfferCollectionViewCell.h"


@interface OffersViewController () {
    NSArray<TimeTableEntity *>* _flights;
}

@property IBOutlet UICollectionView* collectionView;


@end



@implementation OffersViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    switch (_offerType) {
        case OfferTypeFlights: {
            [[Services defaultTimeTableService] getFlightTimeTableWithCompletion:
             ^(NSArray<TimeTableEntity *> * _Nullable timeTable, NSError * _Nullable error) {
                 
                 _flights = timeTable;
                 [_collectionView reloadData];
             }];
            break;
        }
        case OfferTypeTrains: {
            [[Services defaultTimeTableService] getTrainTimeTableWithCompletion:
             ^(NSArray<TimeTableEntity *> * _Nullable timeTable, NSError * _Nullable error) {
                 _flights = timeTable;
                 [_collectionView reloadData];
             }];
            break;
        }
        case OfferTypeBuses: {
            [[Services defaultTimeTableService] getBusTimeTableWithCompletion:
             ^(NSArray<TimeTableEntity *> * _Nullable timeTable, NSError * _Nullable error) {
                 _flights = timeTable;
                 [_collectionView reloadData];
             }];
            break;
        }
        default:
            break;
    }
    
    

    
    

}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _flights.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    OfferCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OfferCollectionViewCell" forIndexPath:indexPath];
    
    TimeTableEntity* model = _flights[indexPath.row];
    [cell updateWithModel:model];
    
    return cell;
    
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath");
}

@end
