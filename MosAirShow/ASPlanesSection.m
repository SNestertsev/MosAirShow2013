//
//  ASPlanesSection.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 28.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASPlanesSection.h"
#import "ASPlane.h"

#define kNameAttribute @"name"
#define kIndexAttribute @"index"
#define kPlanesArrayAttribute @"planes"

@implementation ASPlanesSection

@synthesize name = _name;
@synthesize index = _index;
@synthesize planes = _planes;

-(NSMutableArray *)planes
{
    if (!_planes) {
        _planes = [[NSMutableArray alloc] init];
    }
    return _planes;
}

-(id)initWithJSON:(NSDictionary *)json
{
    if (self = [super init]) {
        self.name = [json objectForKey:kNameAttribute];
        self.index = [json objectForKey:kIndexAttribute];
        NSArray* jsonPlanes = [json objectForKey:kPlanesArrayAttribute];
        for (NSDictionary* jsonPlane in jsonPlanes) {
            [self.planes addObject:[[ASPlane alloc] initWithJSON:jsonPlane]];
        }
    }
    return self;
}

-(ASPlane *)addPlaneWithName:(NSString *)name inRect:(CGRect)rect labelInCorner:(int)corner withImage:(NSString *)imageFile andDescription:(NSString *)descriptionFile
{
    ASPlane *plane = [[ASPlane alloc] initWithName:name inRect:rect labelInCorner:corner withImage:imageFile andDescription:descriptionFile];
    [self.planes addObject:plane];
    return plane;
}

@end
