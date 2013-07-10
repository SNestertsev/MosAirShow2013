//
//  ASPoint.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 08.07.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASPoint.h"

@implementation ASPoint

-(id)initWithX:(float)x andY:(float)y
{
    if (self = [super init]) {
        self.x = x;
        self.y = y;
    }
    return self;
}

@end
