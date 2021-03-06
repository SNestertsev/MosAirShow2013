//
//  ASGpsBinding.h
//  AirShow2013
//
//  Created by Sergey Nestertsev on 08.07.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASPoint;

@interface ASGpsBinding : NSObject

@property (nonatomic) NSMutableArray *modelRegion;
@property (nonatomic) NSMutableArray *gpsRegion;

-(id)initWithJSON:(NSDictionary *)json;
-(BOOL)containsGpsPoint:(CLLocationCoordinate2D)coordinate;
-(ASPoint*)transformGpsToModel:(CLLocationCoordinate2D)coordinate;

@end
