//
//  ASFlightsModel.h
//  AirShow2013
//
//  Created by Sergey Nestertsev on 30.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASFlightsModel : NSObject

@property (nonatomic) int version;
@property (nonatomic, strong) NSMutableArray *days;

-(id)initWithJSON:(NSDictionary *)json;

@end
