//
//  ASPlane.h
//  AirShow2013
//
//  Created by Sergey Nestertsev on 28.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASPlanesSection;
@class ASPlane;

@interface ASPlanesModel : NSObject

@property (nonatomic) int version;
@property (nonatomic, strong) NSDate *expoDate;
@property (nonatomic) CGSize bounds;
@property (nonatomic, strong, readonly) NSMutableArray* sections;
@property (nonatomic, readonly) NSArray *sectionNames;
@property (nonatomic, strong, readonly) NSMutableArray* gpsBindings;

-(id)initWithJSON:(NSDictionary *)json;
-(ASPlanesSection*)addSectionWithName:(NSString*)name andIndex:(NSString*)index;
-(CGRect)getBounds;

@end
