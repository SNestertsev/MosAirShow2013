//
//  ASGpsBinding.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 08.07.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASGpsBinding.h"
#import "ASPoint.h"
#import "CGVector.h"
#import "CGTriangle.h"

#define kPointX @"pointX"
#define kPointY @"pointY"
#define kGpsRegion @"gpsRegion"
#define kModelRegion @"modelRegion"

@interface ASGpsBinding()

@property (nonatomic, readonly) NSArray* mapPoints;
@property (nonatomic, readonly) NSArray* modelPoints;

@end

@implementation ASGpsBinding

-(id)initWithJSON:(NSDictionary *)json
{
    if (self = [super init]) {
        NSArray *jsonGpsPoints = [json objectForKey:kGpsRegion];
        self.gpsRegion = [[NSMutableArray alloc] init];
        for (NSDictionary *jsonPoint in jsonGpsPoints) {
            NSNumber *x = [jsonPoint objectForKey:kPointX];
            NSNumber *y = [jsonPoint objectForKey:kPointY];
            [self.gpsRegion addObject:[[ASPoint alloc] initWithX:x.floatValue andY:y.floatValue]];
        }
        
        NSArray *jsonModelPoints = [json objectForKey:kModelRegion];
        self.modelRegion = [[NSMutableArray alloc] init];
        for (NSDictionary *jsonPoint in jsonModelPoints) {
            NSNumber *x = [jsonPoint objectForKey:kPointX];
            NSNumber *y = [jsonPoint objectForKey:kPointY];
            [self.modelRegion addObject:[[ASPoint alloc] initWithX:x.floatValue andY:y.floatValue]];
        }
        if (self.gpsRegion.count != self.modelRegion.count)
            NSLog(@"A GPS binding has different number of points!");
    }
    return self;
}

-(NSArray*)mapPoints
{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:self.gpsRegion.count + 1];
    for (ASPoint *point in self.gpsRegion) {
        MKMapPoint mapPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(point.y, point.x));
        [result addObject:[NSValue valueWithCGPoint:CGPointMake(mapPoint.x, mapPoint.y)]];
    }
    // Add firsmost point at the end of array
    if (self.gpsRegion.count > 2) {
        ASPoint *firstPoint = [self.gpsRegion objectAtIndex:0];
        MKMapPoint mapPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(firstPoint.y, firstPoint.x));
        [result addObject:[NSValue valueWithCGPoint:CGPointMake(mapPoint.x, mapPoint.y)]];
    }
    return result;
}

-(NSArray*)modelPoints
{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:self.modelRegion.count];
    for (ASPoint *point in self.modelRegion) {
        [result addObject:[NSValue valueWithCGPoint:CGPointMake(point.x, point.y)]];
    }
    // Add firsmost point at the end of array
    if (self.modelRegion.count > 2) {
        ASPoint *firstPoint = [self.modelRegion objectAtIndex:0];
        [result addObject:[NSValue valueWithCGPoint:CGPointMake(firstPoint.x, firstPoint.y)]];
    }
    return result;
}

-(BOOL)containsGpsPoint:(CLLocationCoordinate2D)coordinate
{
    if (self.gpsRegion.count < 3)
        return NO;
    
    UIBezierPath *region = [UIBezierPath bezierPath];
    ASPoint *curPoint = [self.gpsRegion objectAtIndex:0];
    [region moveToPoint:CGPointMake(curPoint.x, curPoint.y)];
    for (int i = 1; i < self.gpsRegion.count; i++) {
        curPoint = [self.gpsRegion objectAtIndex:i];
        [region addLineToPoint:CGPointMake(curPoint.x, curPoint.y)];
    }
    [region closePath];
    return [region containsPoint:CGPointMake(coordinate.longitude, coordinate.latitude)];
}

-(ASPoint *)transformGpsToModel:(CLLocationCoordinate2D)coordinate
{
    MKMapPoint mapCoordinate = MKMapPointForCoordinate(coordinate);
    CGPoint point = CGPointMake(mapCoordinate.x, mapCoordinate.y);
    CGTriangle mapTriangle;
    CGTriangle modelTriangle;
    if (![self findTriangleWithPoint:point mapPoints:&mapTriangle modelPoints:&modelTriangle])
        return nil;
    CGFloat mapTrianglePerimeter = CGTrianglePerimeter(mapTriangle);
    if (mapTrianglePerimeter == 0.0f)
        return nil;
    
    // Проверяем попадание точки в один из углов mapTriangle
    if (CGPointsAreEqual(point, mapTriangle.point0)) {
        return [[ASPoint alloc] initWithX:modelTriangle.point0.x andY:modelTriangle.point0.y];
    }
    if (CGPointsAreEqual(point, mapTriangle.point1)) {
        return [[ASPoint alloc] initWithX:modelTriangle.point1.x andY:modelTriangle.point1.y];
    }
    if (CGPointsAreEqual(point, mapTriangle.point2)) {
        return [[ASPoint alloc] initWithX:modelTriangle.point2.x andY:modelTriangle.point2.y];
    }
    
    CGFloat ratio = CGTrianglePerimeter(modelTriangle) / mapTrianglePerimeter;
    // расстояния от заданной точки до углов треугольника на карте
    CGFloat d0 = CGVectorDistanceBetweenPoints(mapTriangle.point0, point);
    CGFloat d1 = CGVectorDistanceBetweenPoints(mapTriangle.point1, point);
    CGFloat d2 = CGVectorDistanceBetweenPoints(mapTriangle.point2, point);
    // углы в треугольнике на карте
    CGFloat a0 = CGVectorAngleBetween(CGVectorMake(mapTriangle.point0, point),
                                      CGVectorMake(mapTriangle.point0, mapTriangle.point1));
    CGFloat b0 = CGVectorAngleBetween(CGVectorMake(mapTriangle.point0, mapTriangle.point2),
                                      CGVectorMake(mapTriangle.point0, mapTriangle.point1));
    CGFloat a1 = CGVectorAngleBetween(CGVectorMake(mapTriangle.point1, point),
                                      CGVectorMake(mapTriangle.point1, mapTriangle.point2));
    CGFloat b1 = CGVectorAngleBetween(CGVectorMake(mapTriangle.point1, mapTriangle.point0),
                                      CGVectorMake(mapTriangle.point1, mapTriangle.point2));
    CGFloat a2 = CGVectorAngleBetween(CGVectorMake(mapTriangle.point2, point),
                                      CGVectorMake(mapTriangle.point2, mapTriangle.point0));
    CGFloat b2 = CGVectorAngleBetween(CGVectorMake(mapTriangle.point2, mapTriangle.point1),
                                      CGVectorMake(mapTriangle.point2, mapTriangle.point0));
    // углы в треугольнике на модели
    CGFloat B0 = CGVectorAngleBetween(CGVectorMake(modelTriangle.point0, modelTriangle.point2),
                                      CGVectorMake(modelTriangle.point0, modelTriangle.point1));
    CGFloat B1 = CGVectorAngleBetween(CGVectorMake(modelTriangle.point1, modelTriangle.point0),
                                      CGVectorMake(modelTriangle.point1, modelTriangle.point2));
    CGFloat B2 = CGVectorAngleBetween(CGVectorMake(modelTriangle.point2, modelTriangle.point1),
                                      CGVectorMake(modelTriangle.point2, modelTriangle.point0));
    // векторы от углов к искомой точке в модели
    CGVector V0 = CGVectorRotate(CGVectorMake(modelTriangle.point0, modelTriangle.point1), -a0 * B0 / b0);
    CGVector V1 = CGVectorRotate(CGVectorMake(modelTriangle.point1, modelTriangle.point2), -a1 * B1 / b1);
    CGVector V2 = CGVectorRotate(CGVectorMake(modelTriangle.point2, modelTriangle.point0), -a2 * B2 / b2);
    CGVectorNormalize(&V0);
    CGVectorNormalize(&V1);
    CGVectorNormalize(&V2);
    V0 = CGVectorMultiplyScalar(V0, d0 * ratio);
    V1 = CGVectorMultiplyScalar(V1, d1 * ratio);
    V2 = CGVectorMultiplyScalar(V2, d2 * ratio);
    // центр треугольника - искомая точка
    CGTriangle targetTriangle = CGTriangleMake(CGVectorDestinationPoint(V0, modelTriangle.point0),
                                               CGVectorDestinationPoint(V1, modelTriangle.point1),
                                               CGVectorDestinationPoint(V2, modelTriangle.point2));
    CGPoint target = CGTriangleCenter(targetTriangle);
    if (isnan(target.x) || isnan(target.y))
        return nil;
    
    return [[ASPoint alloc] initWithX:target.x andY:target.y];
}

-(BOOL)findTriangleWithPoint:(CGPoint)point mapPoints:(CGTriangle*)mapTriangle modelPoints:(CGTriangle*)modelTriangle
{
    if (self.gpsRegion.count < 3)
        return NO;
    NSArray *mapPoints = self.mapPoints;    // Array of NSValue with CGPoint
    int firstPointIndex = 0;
    do {
        UIBezierPath *region = [UIBezierPath bezierPath];
        CGPoint mapPoint0 = ((NSValue*)[mapPoints objectAtIndex:firstPointIndex]).CGPointValue;
        [region moveToPoint:mapPoint0];
        CGPoint mapPoint1 = ((NSValue*)[mapPoints objectAtIndex:firstPointIndex + 1]).CGPointValue;
        [region addLineToPoint:mapPoint1];
        CGPoint mapPoint2 = ((NSValue*)[mapPoints objectAtIndex:firstPointIndex + 2]).CGPointValue;
        [region addLineToPoint:mapPoint2];
        [region closePath];
        if ([region containsPoint:point]) {
            *mapTriangle = CGTriangleMake(mapPoint0, mapPoint1, mapPoint2);

            NSArray *modelPoints = self.modelPoints;    // Array of NSValue with CGPoint
            *modelTriangle = CGTriangleMake(
                                           ((NSValue*)[modelPoints objectAtIndex:firstPointIndex]).CGPointValue,
                                           ((NSValue*)[modelPoints objectAtIndex:firstPointIndex + 1]).CGPointValue,
                                           ((NSValue*)[modelPoints objectAtIndex:firstPointIndex + 2]).CGPointValue);
            return YES;
        }
        firstPointIndex++;
    } while (firstPointIndex + 2 < mapPoints.count);
    return NO;
}

@end
