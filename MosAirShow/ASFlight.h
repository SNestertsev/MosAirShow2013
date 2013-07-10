//
//  ASFlight.h
//  AirShow2013
//
//  Created by Sergey Nestertsev on 30.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASFlight : NSObject

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *descriptionText;

-(id)initWithStartTime:(NSDate*)startTime endTime:(NSDate*)endTime name:(NSString*)name;
-(id)initWithJSON:(NSDictionary *)json withDay:(NSDate*)day;

@end
