//
//  CGTriangle.h
//  MosAirShow
//
//  Created by Sergey on 25.07.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#include "CGVector.h"

#ifndef MosAirShow_CGTriangle_h
#define MosAirShow_CGTriangle_h

typedef struct
{
    CGPoint point0;
    CGPoint point1;
    CGPoint point2;
} CGTriangle;

static inline CGTriangle CGTriangleMake(CGPoint point0, CGPoint point1, CGPoint point2)
{
    CGTriangle triangle;
    triangle.point0 = point0;
    triangle.point1 = point1;
    triangle.point2 = point2;
    return triangle;
}

static inline CGFloat CGTrianglePerimeter(CGTriangle triangle)
{
    CGFloat perimeter = 0.0f;
    perimeter += CGVectorDistanceBetweenPoints(triangle.point0, triangle.point1);
    perimeter += CGVectorDistanceBetweenPoints(triangle.point1, triangle.point2);
    perimeter += CGVectorDistanceBetweenPoints(triangle.point2, triangle.point0);
    return perimeter;
}

static inline CGPoint CGTriangleCenter(CGTriangle triangle)
{
    return CGPointMake((triangle.point0.x + triangle.point1.x + triangle.point2.x) / 3,
                       (triangle.point0.y + triangle.point1.y + triangle.point2.y) / 3);
}

#endif
