//
//  ASFlight.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 30.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASFlight.h"
#import "NSDate+DateCategories.h"

#define kStartTimeAttribute @"startTime"
#define kEndTimeAttribute @"endTime"
#define kDateFormat @"HH:mm"
#define kNameAttribute @"name"
#define kDescriptionAttribute @"description"

@implementation ASFlight

-(id)initWithStartTime:(NSDate *)startTime endTime:(NSDate *)endTime name:(NSString *)name
{
    if (self = [super init]) {
        self.startTime = startTime;
        self.endTime = endTime;
        self.name = name;
    }
    return self;
}

-(id)initWithJSON:(NSDictionary *)json withDay:(NSDate*)day
{
    if (self = [super init]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:kDateFormat];
        NSDate *time = [dateFormatter dateFromString:[json objectForKey:kStartTimeAttribute]];
        self.startTime = [day withTime:time];
        time = [dateFormatter dateFromString:[json objectForKey:kEndTimeAttribute]];
        self.endTime = [day withTime:time];
        self.name = [json objectForKey:kNameAttribute];
        self.descriptionText = [json objectForKey:kDescriptionAttribute];
    }
    return self;
}

@end
