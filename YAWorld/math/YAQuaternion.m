//
//  YAQuaternion.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 18.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import "YAVector3f.h"
#import "YAQuaternion.h"

#define ToRadian(x) ((x) * M_PI / 180.0f)
#define ToDegree(x) ((x) * 180.0f / M_PI)
#define ToGrad(x) ((x) * M_PI / 360.0f)


@implementation YAQuaternion

@synthesize x;
@synthesize y;
@synthesize z;
@synthesize w;


- (id)init
{
    self = [super init];
    if (self) {
        YAQuaternion* qHead = [[YAQuaternion alloc] initVals:0 :sin(0) :0 :cos(0)];
        YAQuaternion* qPitch = [[YAQuaternion alloc] initVals:sin(0) :0 :0 :cos(0)];
        YAQuaternion* qRoll = [[YAQuaternion alloc] initVals:0 :0 :sin(0) :cos(0)];
        YAQuaternion* q =[[qHead mulQuaternion: qPitch] mulQuaternion:qRoll];
        x = [q x];
        y = [q y];
        z = [q z];
        w = [q w];
    }
    
    return self;
}


- (id) initEulerDeg: (float) head pitch: (float) pitch roll: (float) roll
{
    // TODO: identify Magic multiplicand 2
    float h = ToGrad(head);
    float p = ToGrad(pitch);
    float r = ToGrad(roll);

    self = [super init];
    if (self) {
        YAQuaternion* qHead = [[YAQuaternion alloc] initVals:0 :sin(h) :0 :cos(h)];
        YAQuaternion* qPitch = [[YAQuaternion alloc] initVals:sin(p) :0 :0 :cos(p)];
        YAQuaternion* qRoll = [[YAQuaternion alloc] initVals:0 :0 :sin(r) :cos(r)];
        
        YAQuaternion* q =[[qHead mulQuaternion: qPitch] mulQuaternion:qRoll];
        
        x = [q x];
        y = [q y];
        z = [q z];
        w = [q w];
        
    }
    
    return self;
    
}


- (id)initEuler: (float) head pitch: (float) pitch roll: (float) roll 
{
    self = [super init];
    if (self) {
        YAQuaternion* qHead = [[YAQuaternion alloc] initVals:0 :sin(head) :0 :cos(head)];
        YAQuaternion* qPitch = [[YAQuaternion alloc] initVals:sin(pitch) :0 :0 :cos(pitch)];
        YAQuaternion* qRoll = [[YAQuaternion alloc] initVals:0 :0 :sin(roll) :cos(roll)];

        YAQuaternion* q =[[qHead mulQuaternion: qPitch] mulQuaternion:qRoll];
        
        x = [q x];
        y = [q y];
        z = [q z];
        w = [q w];

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

- (id)initCopy: (YAQuaternion*) orig
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

- (YAQuaternion*) normalize 
{
    float length = sqrtf(x * x + y * y + z * z + w * w);
    
    x /= length;
    y /= length;
    z /= length;
    w /= length;
    
    return self;
}

- (YAQuaternion*) conjugate
{
    return [[YAQuaternion alloc] initVals:-x :-y :-z :w];
}


- (YAQuaternion*) addQuaternion: (YAQuaternion*) other
{
    return [[YAQuaternion alloc] initVals:x + other.x :y + + other.y  :z +  other.z :w + other.w ];
}



- (YAQuaternion*) mulQuaternion: (YAQuaternion*) other 
{
    const float _w = (w * other.w) - (x * other.x) - (y * other.y) - (z * other.z);
    const float _x = (x * other.w) + (w * other.x) + (y * other.z) - (z * other.y);
    const float _y = (y * other.w) + (w * other.y) + (z * other.x) - (x * other.z);
    const float _z = (z * other.w) + (w * other.z) + (x * other.y) - (y * other.x);
    
    return [[YAQuaternion alloc] initVals:_x :_y :_z :_w];
}

- (void) setQuat: (YAQuaternion*) other
{
    x = [other x];
    y = [other y];
    z = [other z];
    w = [other w];
}



- (YAQuaternion*) mulVector3f: (YAVector3f*) other {
    const float _w = - (x * other.x) - (y * other.y) - (z * other.z);
    const float _x =   (w * other.x) + (y * other.z) - (z * other.y);
    const float _y =   (w * other.y) + (z * other.x) - (x * other.z);
    const float _z =   (w * other.z) + (x * other.y) - (y * other.x);
    
    return [[YAQuaternion alloc] initVals:_x :_y :_z :_w];
}


- (NSString *)description 
{
    NSString* result = [NSString stringWithFormat: @"YAQuaternion [%f, %f, %f, %f]", x, y, z, w];
    return result;
}

- (YAVector3f*) rotate: (YAVector3f*) vector
{
    
    // return v + 2.0 * cross(q.xyz, cross(q.xyz ,v) + q.w*v); 

    YAVector3f* d = [[(YAVector3f*)[YAVector3f alloc] initCopy: vector] mulScalar:w]; 
    YAVector3f* c = [[[[YAVector3f alloc] initVals:x :y :z] crossVector: [(YAVector3f*)[YAVector3f alloc] initCopy: vector]] addVector: d];
    YAVector3f* b = [[[YAVector3f alloc] initVals:x :y :z]  crossVector:c];
    YAVector3f* a = [b mulScalar: 2.0f]; 
    
    YAVector3f* result = [[(YAVector3f*)[YAVector3f alloc] initCopy: vector] addVector:a];
    
    return result;
}

-(YAVector3f*) euler
{
    double sqw = w * w;
    double sqx = x * x;
    double sqy = y * y;
    double sqz = z * z;
    double unit = sqx + sqy + sqz + sqw;
    double test = x * y + z * w;
    
    if (test > 0.499 * unit) {
        double heading = 2 * atan2(x,w);
        double attitude = M_PI/2;
        double bank = 0;
        return [[YAVector3f alloc] initVals:heading :attitude :bank];
    }
    if (test < -0.499*unit) { // singularity at south pole
        double heading = -2 * atan2(x,w);
        double attitude = -M_PI/2;
        double bank = 0;
        return [[YAVector3f alloc] initVals:heading :attitude :bank];
    }
    
    
    double heading = atan2(2*y*w-2*x*z , sqx - sqy - sqz + sqw);
    double attitude = asin(2*test/unit);
    double bank = atan2(2*x*w-2*y*z , -sqx + sqy - sqz + sqw);
    return [[YAVector3f alloc] initVals:heading :attitude :bank];
}

- (void) setValues: (float)xVal : (float)yVal : (float)zVal : (float)wVal
{
    x = xVal;
    y = yVal;
    z = zVal;
    w = wVal;
}


@end
