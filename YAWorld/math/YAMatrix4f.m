//
//  YAMatrix4f.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 18.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#include <math.h>
#import "YAQuaternion.h"
#import "YAVector3f.h"
#import "YAVector4f.h"
#import "YAPerspectiveProjectionInfo.h"
#import "YAMatrix4f.h"

#define ToRadian(x) ((x) * M_PI / 180.0f)
#define ToDegree(x) ((x) * 180.0f / M_PI)

@implementation YAMatrix4f

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}



- (id)initShadowBiasTransform
{
    self = [super init];
    if (self) {
        m[0][0] = 0.5f; m[0][1] = 0.0f; m[0][2] = 0.0f; m[0][3] = 0.5f;
        m[1][0] = 0.0f; m[1][1] = 0.5f; m[1][2] = 0.0f; m[1][3] = 0.5f;
        m[2][0] = 0.0f; m[2][1] = 0.0f; m[2][2] = 0.5f; m[2][3] = 0.5f;
        m[3][0] = 0.0f; m[3][1] = 0.0f; m[3][2] = 0.0f; m[3][3] = 1.0f;
    }
    
    return self;
}


- (id) initIdentity
{
    self = [super init];
    if (self) {
        m[0][0] = 1.0f; m[0][1] = 0.0f; m[0][2] = 0.0f; m[0][3] = 0.0f;
        m[1][0] = 0.0f; m[1][1] = 1.0f; m[1][2] = 0.0f; m[1][3] = 0.0f;
        m[2][0] = 0.0f; m[2][1] = 0.0f; m[2][2] = 1.0f; m[2][3] = 0.0f;
        m[3][0] = 0.0f; m[3][1] = 0.0f; m[3][2] = 0.0f; m[3][3] = 1.0f;
    }
    
    return self;
    
}

- (id)initScaleTransform: (float)scaleX : (float)scaleY : (float)scaleZ
{
    self = [super init];
    if (self) {
        m[0][0] = scaleX; m[0][1] = 0.0f;   m[0][2] = 0.0f;   m[0][3] = 0.0f;
        m[1][0] = 0.0f;   m[1][1] = scaleY; m[1][2] = 0.0f;   m[1][3] = 0.0f;
        m[2][0] = 0.0f;   m[2][1] = 0.0f;   m[2][2] = scaleZ; m[2][3] = 0.0f;
        m[3][0] = 0.0f;   m[3][1] = 0.0f;   m[3][2] = 0.0f;   m[3][3] = 1.0f;
        
    }
    
    return self;
}


- (id)initRotateTransform: (float)rotateX : (float)rotateY : (float)rotateZ
{
    self = [super init];
    if (self) {
        
        YAMatrix4f* rx = [[YAMatrix4f alloc]init];
        YAMatrix4f* ry = [[YAMatrix4f alloc]init];
        YAMatrix4f* rz = [[YAMatrix4f alloc]init];
        
        const float x = ToRadian(rotateX);
        const float y = ToRadian(rotateY);
        const float z = ToRadian(rotateZ);
        
        rx->m[0][0] = 1.0f; rx->m[0][1] = 0.0f   ; rx->m[0][2] = 0.0f    ; rx->m[0][3] = 0.0f;
        rx->m[1][0] = 0.0f; rx->m[1][1] = cosf(x); rx->m[1][2] = -sinf(x); rx->m[1][3] = 0.0f;
        rx->m[2][0] = 0.0f; rx->m[2][1] = sinf(x); rx->m[2][2] = cosf(x) ; rx->m[2][3] = 0.0f;
        rx->m[3][0] = 0.0f; rx->m[3][1] = 0.0f   ; rx->m[3][2] = 0.0f    ; rx->m[3][3] = 1.0f;
        
        ry->m[0][0] = cosf(y); ry->m[0][1] = 0.0f; ry->m[0][2] = -sinf(y); ry->m[0][3] = 0.0f;
        ry->m[1][0] = 0.0f   ; ry->m[1][1] = 1.0f; ry->m[1][2] = 0.0f    ; ry->m[1][3] = 0.0f;
        ry->m[2][0] = sinf(y); ry->m[2][1] = 0.0f; ry->m[2][2] = cosf(y) ; ry->m[2][3] = 0.0f;
        ry->m[3][0] = 0.0f   ; ry->m[3][1] = 0.0f; ry->m[3][2] = 0.0f    ; ry->m[3][3] = 1.0f;
        
        rz->m[0][0] = cosf(z); rz->m[0][1] = -sinf(z); rz->m[0][2] = 0.0f; rz->m[0][3] = 0.0f;
        rz->m[1][0] = sinf(z); rz->m[1][1] = cosf(z) ; rz->m[1][2] = 0.0f; rz->m[1][3] = 0.0f;
        rz->m[2][0] = 0.0f   ; rz->m[2][1] = 0.0f    ; rz->m[2][2] = 1.0f; rz->m[2][3] = 0.0f;
        rz->m[3][0] = 0.0f   ; rz->m[3][1] = 0.0f    ; rz->m[3][2] = 0.0f; rz->m[3][3] = 1.0f;
        
        self = [[rz mulMatrix4f: ry] mulMatrix4f: rx];
    }
    return self;
}

- (id)initTranslationTransform: (float)transX : (float)transY : (float)transZ
{
    self = [super init];
    if (self) {
        m[0][0] = 1.0f; m[0][1] = 0.0f; m[0][2] = 0.0f; m[0][3] = transX;
        m[1][0] = 0.0f; m[1][1] = 1.0f; m[1][2] = 0.0f; m[1][3] = transY;
        m[2][0] = 0.0f; m[2][1] = 0.0f; m[2][2] = 1.0f; m[2][3] = transZ;
        m[3][0] = 0.0f; m[3][1] = 0.0f; m[3][2] = 0.0f; m[3][3] = 1.0f;
    }
    
    return self;
}


- (id)initRotateQuatTransform: (YAQuaternion*) quatRotation
{
    
    
    self = [super init];
    if (self) {
        
        YAQuaternion* qR = quatRotation;
        
        float x2 = qR.x * qR.x;
        float y2 = qR.y * qR.y;
        float z2 = qR.z * qR.z;
        float xy = qR.x * qR.y;
        float xz = qR.x * qR.z;
        float yz = qR.y * qR.z;
        float wx = qR.w * qR.x;
        float wy = qR.w * qR.y;
        float wz = qR.w * qR.z;
        
        m[0][0] = 1.0f - 2.0f * (y2 + z2); m[0][1] = 2.0f * (xy - wz); m[0][2] = 2.0f * (xz + wy); m[0][3] = 0.0f;
        m[1][0] = 2.0f * (xy + wz); m[1][1] = 1.0f - 2.0f * (x2 + z2); m[1][2] = 2.0f * (yz - wx); m[1][3] = 0.0f;
        m[2][0] = 2.0f * (xz - wy); m[2][1] = 2.0f * (yz + wx); m[2][2] = 1.0f - 2.0f * (x2 + y2); m[2][3] = 0.0f;
        m[3][0] = 0.0f; m[3][1] = 0.0f; m[3][2] = 0.0f; m[3][3] = 1.0f;
        
        
    }
    
    return self;
}


// because of speed issues this is a copy of mulMatrix4f without object initialization
- (YAMatrix4f*) mulMatrix4f: (const YAMatrix4f*) other into: (YAMatrix4f*) result
{
    for (unsigned int i = 0 ; i < 4 ; i++) {
        for (unsigned int j = 0 ; j < 4 ; j++) {
            result->m[i][j] = m[i][0] * other->m[0][j] +
            m[i][1] * other->m[1][j] +
            m[i][2] * other->m[2][j] +
            m[i][3] * other->m[3][j];
        }
    }
    
    return result;
}


- (YAMatrix4f*) mulMatrix4f: (const YAMatrix4f*) other
{
    YAMatrix4f* result = [[YAMatrix4f alloc] init];
    
    
    for (unsigned int i = 0 ; i < 4 ; i++) {
        for (unsigned int j = 0 ; j < 4 ; j++) {
            result->m[i][j] = m[i][0] * other->m[0][j] +
            m[i][1] * other->m[1][j] +
            m[i][2] * other->m[2][j] +
            m[i][3] * other->m[3][j];
        }
    }
    
    return result;
}


- (YAVector4f*) mulVector3f: (const YAVector3f*) vector
{
    YAVector4f* result = [[YAVector4f alloc] init];
    
    result.x = m[0][0]* vector.x + m[0][1]* vector.y + m[0][2]* vector.z + m[0][3]* 1.0;
    result.y = m[1][0]* vector.x + m[1][1]* vector.y + m[1][2]* vector.z + m[1][3]* 1.0;
    result.z = m[2][0]* vector.x + m[2][1]* vector.y + m[2][2]* vector.z + m[2][3]* 1.0;
    result.w = m[3][0]* vector.x + m[3][1]* vector.y + m[3][2]* vector.z + m[3][3]* 1.0;
    
    return result;
}


- (YAVector4f*) mulVector4f: (const YAVector4f*) vector
{
    YAVector4f* result = [[YAVector4f alloc] init];
    
    result.x = m[0][0]* vector.x + m[0][1]* vector.y + m[0][2]* vector.z + m[0][3]* vector.w;
    result.y = m[1][0]* vector.x + m[1][1]* vector.y + m[1][2]* vector.z + m[1][3]* vector.w;
    result.z = m[2][0]* vector.x + m[2][1]* vector.y + m[2][2]* vector.z + m[2][3]* vector.w;
    result.w = m[3][0]* vector.x + m[3][1]* vector.y + m[3][2]* vector.z + m[3][3]* vector.w;
    
    return result;
}

- (NSString *)description
{
    
    NSMutableString* result = [NSMutableString string];
    [result appendString:@"Matrix4f:"];
    
    for (int i = 0 ; i < 4 ; i++) {
        [result appendFormat:@"\n%f %f %f %f", (m[i][0]), m[i][1], m[i][2], m[i][3]];
    }
    
    
    return result;
}


- (id)initCameraTransform: (const YAVector3f*)target up: (const YAVector3f*)up {
    self = [super init];
    if (self) {
        
        YAVector3f* N = [[(YAVector3f*)[YAVector3f alloc] initCopy:target] normalize];
        YAVector3f* U = [[(YAVector3f*)[YAVector3f alloc] initCopy:up] normalize];
        
        [U crossVector:target];
        
        YAVector3f* V = [[(YAVector3f*)[YAVector3f alloc] initCopy:target] crossVector:U];
        
        m[0][0] = U.x;   m[0][1] = U.y;   m[0][2] = U.z;   m[0][3] = 0.0f;
        m[1][0] = V.x;   m[1][1] = V.y;   m[1][2] = V.z;   m[1][3] = 0.0f;
        m[2][0] = N.x;   m[2][1] = N.y;   m[2][2] = N.z;   m[2][3] = 0.0f;
        m[3][0] = 0.0f;  m[3][1] = 0.0f;  m[3][2] = 0.0f;  m[3][3] = 1.0f;
    }
    
    return self;
}

- (id)initPerspectiveProjectionTransform: (const YAPerspectiveProjectionInfo*) ppInfo
{
    self = [super init];
    if (self) {
        const float ar         = [ppInfo width] / [ppInfo height];
        const float zRange     = [ppInfo zNear] - [ppInfo zFar];
        const float tanHalfFOV = tanf(ToRadian([ppInfo fieldOfView] / 2.0f));
        
        m[0][0] = 1.0f/(tanHalfFOV * ar); m[0][1] = 0.0f; m[0][2] = 0.0f; m[0][3] = 0.0;
        m[1][0] = 0.0f; m[1][1] = 1.0f/tanHalfFOV; m[1][2] = 0.0f; m[1][3] = 0.0;
        m[2][0] = 0.0f; m[2][1] = 0.0f; m[2][2] = (-[ppInfo zNear] - [ppInfo zFar])/zRange; m[2][3] = 2.0f*[ppInfo zFar]*[ppInfo zNear]/zRange;
        m[3][0] = 0.0f; m[3][1] = 0.0f; m[3][2] = 1.0f; m[3][3] = 0.0;
    }
    
    return self;
}


- (YAMatrix4f*) createTranspose
{
    YAMatrix4f* t  = [[YAMatrix4f alloc] init ];
    
    t->m[0][0] = m[0][0]; t->m[0][1] = m[1][0]; t->m[0][2] = m[2][0]; t->m[0][3] = m[3][0];
    t->m[1][0] = m[0][1]; t->m[1][1] = m[1][1]; t->m[1][2] = m[2][1]; t->m[1][3] = m[3][1];
    t->m[2][0] = m[0][2]; t->m[2][1] = m[1][2]; t->m[2][2] = m[2][2]; t->m[2][3] = m[3][2];
    t->m[3][0] = m[0][3]; t->m[3][1] = m[1][3]; t->m[3][2] = m[2][3]; t->m[3][3] = m[3][3];
    
    return t;
}


- (void) setMatrix: (const YAMatrix4f*) other
{
    const YAMatrix4f* o = other;
    m[0][0] = o->m[0][0]; m[0][1] = o->m[0][1]; m[0][2] = o->m[0][2]; m[0][3] = o->m[0][3];
    m[1][0] = o->m[1][0]; m[1][1] = o->m[1][1]; m[1][2] = o->m[1][2]; m[1][3] = o->m[1][3];
    m[2][0] = o->m[2][0]; m[2][1] = o->m[2][1]; m[2][2] = o->m[2][2]; m[2][3] = o->m[2][3];
    m[3][0] = o->m[3][0]; m[3][1] = o->m[3][1]; m[3][2] = o->m[3][2]; m[3][3] = o->m[3][3];
}


@end