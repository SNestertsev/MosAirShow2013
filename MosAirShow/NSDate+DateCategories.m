//
//  NSDate+DateCategories.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 30.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "NSDate+DateCategories.h"

@implementation NSDate (DateCategories)

-(NSDate *)dateWithNoTime
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    NSDate *dateOnly = [[NSCalendar currentCalendar] dateFromComponents:comps];
    return dateOnly;
}

-(NSDate*)withHour:(NSInteger)hour minute:(NSInteger)minute
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    [comps setHour:hour];
    [comps setMinute:minute];
    NSDate *result = [[NSCalendar currentCalendar] dateFromComponents:comps];
    return result;
}

- (NSDate*)withTime:(NSDate*)time
{
    NSDateComponents *compsDate = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    NSDateComponents *compsTime = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:time];
    [compsDate setHour:compsTime.hour];
    [compsDate setMinute:compsTime.minute];
    [compsDate setSecond:compsTime.second];
    NSDate *result = [[NSCalendar currentCalendar] dateFromComponents:compsDate];
    return result;
}

@end
