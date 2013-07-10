//
//  ASPoint.h
//  AirShow2013
//
//  Created by Sergey Nestertsev on 08.07.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASPoint : NSObject

@property (nonatomic) float x;
@property (nonatomic) float y;

-(id)initWithX:(float)x andY:(float)y;

@end
