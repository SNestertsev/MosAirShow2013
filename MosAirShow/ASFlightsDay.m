//
//  ASFlightsDay.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 30.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASFlightsDay.h"
#import "ASFlight.h"
#import "NSDate+DateCategories.h"

#define kDateAttribute @"date"
#define kDateFormat @"yyyy-MM-dd"
#define kFlightsArrayAttribute @"flights"

@implementation ASFlightsDay

@synthesize date = _date;
@synthesize flights = _flights;

-(NSMutableArray *)flights
{
    if (!_flights) {
        _flights = [[NSMutableArray alloc] init];
    }
    return _flights;
}

-(id)initWithDate:(NSDate *)date
{
    if (self = [super init]) {
        self.date = date;
    }
    return self;
}

-(id)initWithJSON:(NSDictionary *)json
{
    if (self = [super init]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:kDateFormat];
        self.date = [dateFormatter dateFromString:[json objectForKey:kDateAttribute]];
        NSArray* jsonFlights = [json objectForKey:kFlightsArrayAttribute];
        for (NSDictionary* jsonFlight in jsonFlights) {
            [self.flights addObject:[[ASFlight alloc] initWithJSON:jsonFlight withDay:self.date]];
        }
    }
    return self;
}

-(BOOL)isFlight:(ASFlight*)flight within:(int)count nearTime:(NSDate*)time
{
    if (![[time dateWithNoTime] isEqualToDate:self.date]) {
        return NO;  // different dates
    }
    
    int nearCount = 0;
    for (int i = 0; i < self.flights.count; i++) {
        ASFlight *item = [self.flights objectAtIndex:i];
        NSComparisonResult compResult = [item.startTime compare:time];
        if (compResult == NSOrderedAscending) {
            if (item == flight) {
                return NO;
            }
            else {
                continue;
            }
        }
        else {
            nearCount++;
            if (nearCount > count) {
                return NO;
            }
            if (item == flight) {
                return YES;
            }
        }
    }
    return NO;
}

@end
