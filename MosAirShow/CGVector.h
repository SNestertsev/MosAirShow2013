//
//  CGVector.h
//  MosAirShow
//
//  Created by Sergey on 25.07.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#ifndef MosAirShow_CGVector_h
#define MosAirShow_CGVector_h

// 2D vector
typedef CGPoint CGVector;

#define DEGREES_TO_RADIANS(x) ((x) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(x) ((x) / M_PI * 180.0)

static inline CGVector CGVectorMake(CGPoint start, CGPoint end)
{
    CGVector vector;
    vector.x = end.x - start.x;
    vector.y = end.y - start.y;
    return vector;
}

static inline CGFloat CGVectorDistanceBetweenPoints(CGPoint point1, CGPoint point2)
{
    CGFloat deltaX, deltaY;
    
    deltaX = point2.x - point1.x;
    deltaY = point2.y - point1.y;
    
    return sqrtf((deltaX * deltaX) + (deltaY * deltaY));
}

static inline BOOL CGPointsAreEqual(CGPoint point1, CGPoint point2)
{
    return (point1.x == point2.x) && (point1.y == point2.y);
}

static inline CGFloat CGVectorMagnitude(CGVector vector)
{
    return sqrtf((vector.x * vector.x) + (vector.y * vector.y));
}

static inline CGFloat CGVectorDotProduct(CGVector vector1, CGVector vector2)
{
    return (vector1.x * vector2.x) + (vector1.y * vector2.y);
}

static inline void CGVectorNormalize(CGVector *vector)
{
    CGFloat vecMag = CGVectorMagnitude(*vector);
    if (vecMag == 0.0)
    {
        vector->x = 1.0;
        vector->y = 0.0;
        return;
    }
    vector->x /= vecMag;
    vector->y /= vecMag;
}

static inline CGVector CGVectorMakeNormalized(CGPoint start, CGPoint end)
{
    CGVector ret = CGVectorMake(start, end);
    CGVectorNormalize(&ret);
    return ret;
}

static inline void CGVectorFlip (CGVector *vector)
{
    vector->x = -vector->x;
    vector->y = -vector->y;
}

// Angle between two normalized vectors
static inline CGFloat CGVectorAngleBetweenNormalized(CGVector vector1, CGVector vector2)
{
    return acosf(CGVectorDotProduct(vector1, vector2));
}

static inline CGFloat CGVectorAngleBetween(CGVector vector1, CGVector vector2)
{
    return acosf(CGVectorDotProduct(vector1, vector2) / (CGVectorMagnitude(vector1) * CGVectorMagnitude(vector2)));
}

static inline CGVector CGVectorRotate(CGVector vector, CGFloat radAngle)
{
    CGFloat cs = cosf(radAngle);
    CGFloat sn = sinf(radAngle);
    CGVector result;
    result.x = vector.x * cs - vector.y * sn;
    result.y = vector.x * sn + vector.y * cs;
    return result;
}

static inline CGPoint CGVectorDestinationPoint(CGVector vector, CGPoint origin)
{
    return CGPointMake(origin.x + vector.x, origin.y + vector.y);
}

static inline CGVector CGVectorMultiplyScalar(CGVector vector, CGFloat scalar)
{
    CGVector result;
    result.x = vector.x * scalar;
    result.y = vector.y * scalar;
    return result;
}

#endif
