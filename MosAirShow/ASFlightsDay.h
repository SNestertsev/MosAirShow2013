//
//  ASFlightsDay.h
//  AirShow2013
//
//  Created by Sergey Nestertsev on 30.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASFlight;

@interface ASFlightsDay : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSMutableArray *flights;

-(id)initWithDate:(NSDate*)date;
-(id)initWithJSON:(NSDictionary *)json;
-(BOOL)isFlight:(ASFlight*)flight within:(int)count nearTime:(NSDate*)time;

@end
