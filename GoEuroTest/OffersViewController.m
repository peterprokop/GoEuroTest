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

    switch (_offerType) {
        case OfferTypeFlights: {
            [[Services defaultTimeTableService] getFlightTimeTableWithCompletion:
             ^(NSArray<TimeTableEntity *> * _Nullable timeTable, NSError * _Nullable error) {
                 
                 _offers = timeTable;
                 [_collectionView reloadData];
             }];
            break;
        }
        case OfferTypeTrains: {
            [[Services defaultTimeTableService] getTrainTimeTableWithCompletion:
             ^(NSArray<TimeTableEntity *> * _Nullable timeTable, NSError * _Nullable error) {
                 _offers = timeTable;
                 [_collectionView reloadData];
             }];
            break;
        }
        case OfferTypeBuses: {
            [[Services defaultTimeTableService] getBusTimeTableWithCompletion:
             ^(NSArray<TimeTableEntity *> * _Nullable timeTable, NSError * _Nullable error) {
                 _offers = timeTable;
                 [_collectionView reloadData];
             }];
            break;
        }
        default:
            break;
    }
  
    
    //UICollectionViewLayout* layout = _collectionView.collectionViewLayout;
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
