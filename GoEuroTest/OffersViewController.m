//
//  ViewController.m
//  GoEuroTest
//
//  Created by Peter Prokop on 10/02/2017.
//  Copyright © 2017 Prokop. All rights reserved.
//

#import "OffersViewController.h"
#import "OfferCollectionViewCell.h"


@interface OffersViewController ()<UICollectionViewDelegateFlowLayout> {
    NSArray<TimeTableEntity *>* _offers;
}

@property IBOutlet UICollectionView* collectionView;


@end



@implementation OffersViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _offerSorting = OfferSortingDeparture;
    
    // This might seem repetetive now, but those methods can have different return data
    switch (_offerType) {
        case OfferTypeFlights: {
            [[Services defaultTimeTableService] getFlightTimeTableWithCompletion:
             ^(NSArray<TimeTableEntity *> * _Nullable timeTable, NSError * _Nullable error) {                 
                 [self handleTimeTable:timeTable error:error];
             }];
            break;
        }
        case OfferTypeTrains: {
            [[Services defaultTimeTableService] getTrainTimeTableWithCompletion:
             ^(NSArray<TimeTableEntity *> * _Nullable timeTable, NSError * _Nullable error) {
                 [self handleTimeTable:timeTable error:error];
             }];
            break;
        }
        case OfferTypeBuses: {
            [[Services defaultTimeTableService] getBusTimeTableWithCompletion:
             ^(NSArray<TimeTableEntity *> * _Nullable timeTable, NSError * _Nullable error) {
                 [self handleTimeTable:timeTable error:error];
             }];
            break;
        }
        default:
            break;
    }

}

- (void)handleTimeTable:(NSArray<TimeTableEntity *>*) timeTable error:(NSError*) error {
    if (error != nil) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Please try again later"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:action];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }    
    
    _offers = timeTable;
    [self sortOffers];
}

- (void)sortOffers {
    _offers = [_offers sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        TimeTableEntity* offer1 = obj1;
        TimeTableEntity* offer2 = obj2;
        
        switch (_offerSorting) {
            case OfferSortingDeparture:
                if (offer2.departureTimestamp > offer1.departureTimestamp) {
                    return NSOrderedAscending;
                } else if (offer2.departureTimestamp == offer1.departureTimestamp) {
                    return NSOrderedSame;
                }
                return NSOrderedDescending;
                
                break;
            
            case OfferSortingArrival:
                if (offer2.arrivalTimestamp > offer1.arrivalTimestamp) {
                    return NSOrderedAscending;
                } else if (offer2.arrivalTimestamp == offer1.arrivalTimestamp) {
                    return NSOrderedSame;
                }
                return NSOrderedDescending;
                
                break;
            
            case OfferSortingDuration:
                if (offer2.durationInMinutes > offer1.durationInMinutes) {
                    return NSOrderedAscending;
                } else if (offer2.durationInMinutes == offer1.durationInMinutes) {
                    return NSOrderedSame;
                }
                return NSOrderedDescending;
                
                break;

        }

    }];
    
    [_collectionView reloadData];
}

#pragma mark Actinons

- (IBAction)sortingButtonTapped {
    
    UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle: @"Sort by"
                                        message: nil
                                 preferredStyle: UIAlertControllerStyleActionSheet];
    
    UIAlertAction* sortingDeparture = [UIAlertAction actionWithTitle:@"Departure"
                                                               style:(UIAlertActionStyleDefault)
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 self.offerSorting = OfferSortingDeparture;
                                                                 [self sortOffers];
                                                             }];
    
    UIAlertAction* sortingArrival = [UIAlertAction actionWithTitle:@"Arrival"
                                                               style:(UIAlertActionStyleDefault)
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 self.offerSorting = OfferSortingArrival;
                                                                 [self sortOffers];
                                                             }];
    
    UIAlertAction* sortingDuration = [UIAlertAction actionWithTitle:@"Duration"
                                                             style:(UIAlertActionStyleDefault)
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               self.offerSorting = OfferSortingDuration;
                                                               [self sortOffers];
                                                           }];
    [actionSheet addAction:sortingDeparture];
    [actionSheet addAction:sortingArrival];
    [actionSheet addAction:sortingDuration];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _offers.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    OfferCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OfferCollectionViewCell" forIndexPath:indexPath];
    
    TimeTableEntity* model = _offers[indexPath.row];
    [cell updateWithModel:model];
    
    return cell;
    
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"Not implemented yet!"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(self.view.bounds.size.width, 90);
}

@end
