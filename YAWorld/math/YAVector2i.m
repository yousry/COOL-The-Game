//
//  Vector2i.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 18.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import "YAVector2i.h"

@implementation YAVector2i

@synthesize x;
@synthesize y;

- (id)init
{
    self = [super init];
    if (self) {
        x = 0;
        y = 0;
    }
    
    return self;
}

- (id)initCopy: (YAVector2i*) orig
{
    self = [super init];
    if (self) {
        x = [orig x];
        y = [orig y];
    }
    
    return self;
    
}

- (id)initVals: (int)xVal : (int) yVal 
{
    self = [super init];
    if (self) {
        x = xVal;
        y = yVal;
    }
    return self;
}

- (NSString *)description 
{
    NSString* result = [NSString stringWithFormat: @"YAVector2i [%i, %i]", x, y];
    return result;
}

- (double) distanceTo: (YAVector2i*) other
{
    const double a =  pow(x - other.x,2);
    const double b =  pow(y - other.y,2);
    return sqrt(a + b);
}

- (void) setValues: (int) xVal : (int) yVal
{
    x = xVal;
    y = yVal;
}

@end
