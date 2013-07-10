//
//  ASPlanesSection.h
//  AirShow2013
//
//  Created by Sergey Nestertsev on 28.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASPlane;

@interface ASPlanesSection : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *index;
@property (nonatomic, strong) NSMutableArray *planes;

-(id)initWithJSON:(NSDictionary *)json;
-(ASPlane*)addPlaneWithName:(NSString*)name inRect:(CGRect)rect labelInCorner:(int)corner withImage:(NSString*)imageFile andDescription:(NSString*)descriptionFile;

@end
