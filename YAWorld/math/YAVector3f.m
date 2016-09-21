//
//  YAVector3f.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 18.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <math.h>

#import "YAQuaternion.h"
#import "YAVector3f.h"


@implementation YAVector3f

#define ToRadian(x) ((x) * M_PI / 180.0f)
#define ToDegree(x) ((x) * 180.0f / M_PI)

@synthesize x;
@synthesize y;
@synthesize z;

- (id)init
{
    self = [super init];
    if (self) {
        x = 0.0f;
        y = 0.0f;
        z = 0.0f;
    }
    
    return self;
}

- (id) initVals: (float)xVal : (float)yVal : (float)zVal 
{
    self = [super init];
    if (self) {
        x = xVal;
        y = yVal;
        z = zVal;
    }
    
    return self;
  
}

- (id) initXAxe
{
    self = [super init];
    if (self) {
        x = 1.0f;
        y = 0.0f;
        z = 0.0f;
    }
    
    return self;
}

- (id) initYAxe
{
    self = [super init];
    if (self) {
        x = 0.0f;
        y = 1.0f;
        z = 0.0f;
    }
    
    return self;
}

- (id) initZAxe
{
    self = [super init];
    if (self) {
        x = 0.0f;
        y = 0.0f;
        z = 1.0f;
    }
    
    return self;
}



- (id)initCopy: (YAVector3f*) orig 
{
    self = [super init];
    if (self) {
        x = [orig x];
        y = [orig y];
        z = [orig z];
    }
    
    return self;
    
}

- (YAVector3f*) addVector: (const YAVector3f*) other
{
    x += other.x;
    y += other.y;
    z += other.z;
    return self;
}

- (YAVector3f*) subVector: (const YAVector3f*) other
{
    x -= other.x;
    y -= other.y;
    z -= other.z;
    return self;
}

- (YAVector3f*) mulScalar: (const float) scalar 
{
    x *= scalar;
    y *= scalar;
    z *= scalar;
    return self;     
}

- (YAVector3f*) crossVector: (const YAVector3f*) other {
    const float _x = y * other.z - z * other.y;
    const float _y = z * other.x - x * other.z;
    const float _z = x * other.y - y * other.x;
    
    x = _x;
    y = _y;
    z = _z;
    
    return self;
}

- (YAVector3f*) normalize {
    const float length = sqrtf(x * x + y * y + z * z);
    
    x /= length;
    y /= length;
    z /= length;
    
    return self;
}


- (NSString *)description 
{
    NSString* result = [NSString stringWithFormat: @"YAVector3f [%f, %f, %f]", x, y, z];
    return result;
}


- (YAVector3f*) rotate:(float)angle axis:(const YAVector3f*) axis 
{
    const float SinHalfAngle = sinf(ToRadian(angle/2));
    const float CosHalfAngle = cosf(ToRadian(angle/2));
    
    const float Rx = axis.x * SinHalfAngle;
    const float Ry = axis.y * SinHalfAngle;
    const float Rz = axis.z * SinHalfAngle;
    const float Rw = CosHalfAngle;
    
    YAQuaternion* rotationQ = [[YAQuaternion alloc] initVals:Rx :Ry :Rz :Rw];
    
    YAQuaternion* conjugateQ = [rotationQ conjugate];
    
    YAQuaternion* w = [[rotationQ mulVector3f:self] mulQuaternion:conjugateQ];
    
    x = w.x;
    y = w.y;
    z = w.z;
    
    return self;
}

- (void) setVector: (const YAVector3f*) other 
{
    x = other.x;
    y = other.y;
    z = other.z;
}

- (void) setValues: (float)xVal : (float)yVal : (float)zVal
{
    x = xVal;
    y = yVal;
    z = zVal;
}

- (double) distanceTo: (YAVector3f*) other
{
    const double a =  pow(x - other.x,2);
    const double b =  pow(y - other.y,2);
    const double c =  pow(z - other.z,2);
    return sqrt(a + b + c);
}

- (float) dotVector: (const YAVector3f*) other
{
    return (x * other.x + y * other.y + z * other.z);
}

- (id)copyWithZone:(NSZone *)zone {
    YAVector3f *s = [[[self class] allocWithZone:zone] init]; 
    s.x = self.x;
    s.y = self.y;
    s.z = self.z;
    return s;
}

@end
