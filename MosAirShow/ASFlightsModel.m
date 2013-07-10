//
//  ASFlightsModel.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 30.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASFlightsModel.h"
#import "ASFlightsDay.h"

#define kFlightsVersionAttribute @"version"
#define kDaysArrayAttribute @"days"

@implementation ASFlightsModel

@synthesize days = _days;

-(NSMutableArray *)days
{
    if (!_days) {
        _days = [[NSMutableArray alloc] init];
    }
    return _days;
}

-(id)initWithJSON:(NSDictionary *)json
{
    if (self = [super init]) {
        self.version = ((NSNumber*)[json objectForKey:kFlightsVersionAttribute]).intValue;
        NSArray* jsonDays = [json objectForKey:kDaysArrayAttribute];
        for (NSDictionary* jsonDay in jsonDays) {
            [self.days addObject:[[ASFlightsDay alloc] initWithJSON:jsonDay]];
        }
    }
    return self;
}

@end
