//
//  YAVector4f.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 18.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import "YAVector4f.h"

@implementation YAVector4f

@synthesize x;
@synthesize y;
@synthesize z;
@synthesize w;


- (id)init
{
    self = [super init];
    if (self) {
        x = 0.0f;
        y = 0.0f;
        z = 0.0f;
        w = 0.0f;
    }
    
    return self;
}


- (id) initVals: (float)xVal : (float)yVal : (float)zVal : (float)wVal 
{
    self = [super init];
    if (self) {
        x = xVal;
        y = yVal;
        z = zVal;
        w = wVal;
    }
    
    return self;
}

- (id)initCopy: (YAVector4f*) orig
{
    self = [super init];
    if (self) {
        x = [orig x];
        y = [orig y];
        z = [orig z];
        w = [orig w];
    }
    
    return self;
    
}

- (YAVector4f*) normalize {
    const float length = sqrtf(x * x + y * y + z * z + w * w);
    
    x /= length;
    y /= length;
    z /= length;
    w /= length;
    
    return self;
}


- (NSString *)description 
{
    NSString* result = [NSString stringWithFormat: @"YAVector4f [%f, %f, %f, %f]", x, y, z, w];
    return result;
}


- (void) setVector: (const YAVector4f*) other 
{
    x = other.x;
    y = other.y;
    z = other.z;
    w = other.w;
}


@end
