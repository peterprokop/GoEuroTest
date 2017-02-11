//
//  ViewController.m
//  GoEuroTest
//
//  Created by Peter Prokop on 10/02/2017.
//  Copyright © 2017 Prokop. All rights reserved.
//

#import "MainViewController.h"
#import "GoEuroTest-Swift.h"

@interface MainViewController ()

@end



@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[Services defaultTimeTableService] getFlightTimeTableWithCompletion:
        ^(NSArray<TimeTableEntity *> * _Nullable timeTable, NSError * _Nullable error) {
            
            for (TimeTableEntity* entity in timeTable) {
                NSLog(@"%@", [entity providerLogoURLForSize:63]);
            }
    }];

    [[Services defaultTimeTableService] getTrainTimeTableWithCompletion:
     ^(NSArray<TimeTableEntity *> * _Nullable timeTable, NSError * _Nullable error) {
         
         for (TimeTableEntity* entity in timeTable) {
             NSLog(@"%@", [entity providerLogoURLForSize:63]);
         }
     }];
    
    [[Services defaultTimeTableService] getBusTimeTableWithCompletion:
     ^(NSArray<TimeTableEntity *> * _Nullable timeTable, NSError * _Nullable error) {
         
         for (TimeTableEntity* entity in timeTable) {
             NSLog(@"%@", [entity providerLogoURLForSize:63]);
         }
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
