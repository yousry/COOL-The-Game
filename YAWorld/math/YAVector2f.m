//
//  YAVector2f.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 18.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import "YAVector2f.h"

@implementation YAVector2f

@synthesize x;
@synthesize y;

- (id)init
{
    self = [super init];
    if (self) {
        x = 0.0f;
        y = 0.0f;
    }
    
    return self;
}

- (id) initCopy: (YAVector2f*) orig
{
    self = [super init];
    if (self) {
        x = [orig x];
        y = [orig y];
    }
    
    return self;  
}

- (id) initVals: (float)xVal : (float)yVal
{
    self = [super init];
    if (self) {
        x = xVal;
        y = yVal;
    }
    
    return self;
}

- (YAVector2f*) normalize
{
    const float length = sqrtf(x * x + y * y);
    x /= length;
    y /= length;
    return self;
}

- (YAVector2f*) mulScalar: (const float) scalar
{
    x *= scalar;
    y *= scalar;
    return self;
}

- (double) length;
{
    const double a =  pow(x,2);
    const double b =  pow(y,2);
    return sqrt(a + b);
}


- (double) distanceTo: (YAVector2f*) other
{
    const double a =  pow(x - other.x,2);
    const double b =  pow(y - other.y,2);
    return sqrt(a + b);
}


- (YAVector2f*) addVector: (const YAVector2f*) other
{
    x += other.x;
    y += other.y;
    return self;
}

- (YAVector2f*) subVector: (const YAVector2f*) other
{
    x -= other.x;
    y -= other.y;
    return self;
}


- (NSString *)description 
{
    NSString* result = [NSString stringWithFormat: @"YAVector2f [%f, %f]", x, y];
    return result;
}


@end
