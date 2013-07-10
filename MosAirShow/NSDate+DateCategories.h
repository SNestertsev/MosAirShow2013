//
//  NSDate+DateCategories.h
//  AirShow2013
//
//  Created by Sergey Nestertsev on 30.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DateCategories)

-(NSDate*)dateWithNoTime;
-(NSDate*)withHour:(NSInteger)hour minute:(NSInteger)minute;
-(NSDate*)withTime:(NSDate*)time;

@end
