//
//  ASFlightDetailsViewController.h
//  AirShow2013
//
//  Created by Sergey Nestertsev on 30.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASFlightDetailsViewController : UIViewController

@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, strong) NSString *flightName;
@property (nonatomic, strong) NSString *flightDetails;
@property (nonatomic, strong) NSString *planeName;
@property (nonatomic, strong) NSString *planeFileName;

@end
