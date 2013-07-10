//
//  ASGpsBinding.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 08.07.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASGpsBinding.h"
#import "ASPoint.h"

#define kPointX @"pointX"
#define kPointY @"pointY"
#define kGpsRegion @"gpsRegion"
#define kModelRegion @"modelRegion"

@implementation ASGpsBinding

-(id)initWithJSON:(NSDictionary *)json
{
    if (self = [super init]) {
        NSArray *jsonGpsPoints = [json objectForKey:kGpsRegion];
        self.gpsRegion = [[NSMutableArray alloc] init];
        for (NSDictionary *jsonPoint in jsonGpsPoints) {
            NSNumber *x = [jsonPoint objectForKey:kPointX];
            NSNumber *y = [jsonPoint objectForKey:kPointY];
            [self.gpsRegion addObject:[[ASPoint alloc] initWithX:x.floatValue andY:y.floatValue]];
        }
        
        NSArray *jsonModelPoints = [json objectForKey:kModelRegion];
        self.modelRegion = [[NSMutableArray alloc] init];
        for (NSDictionary *jsonPoint in jsonModelPoints) {
            NSNumber *x = [jsonPoint objectForKey:kPointX];
            NSNumber *y = [jsonPoint objectForKey:kPointY];
            [self.modelRegion addObject:[[ASPoint alloc] initWithX:x.floatValue andY:y.floatValue]];
        }
    }
    return self;
}

@end
