//
//  YAInertiaMovement.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 13.02.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import <math.h>
#import "YAAvatar.h"
#import "YATransformator.h"
#import "YAVector2f.h"
#import "YAVector3f.h"
#import "YAInertiaMovement.h"

#define ToDegree(x) ((x) * 180.0f / M_PI)

#define HEAD_ACCELERATION 0.005f
#define HEAD_MAX_SPEED 0.4f

@implementation YAInertiaMovement

static inline float rectangularTriAlpha(const float, const float);

- (id) init
{
    self = [super init];
    if(self) {
        _headRotateDirection[0] = [[YAVector2f alloc]init];
        _headRotateDirection[1] = [[YAVector2f alloc]init];
        _actRotId = 0;
        _speedFactor = 0;
        _memory = STORED_ENERGY;
    }
    return self;
}

static inline float rectangularTriAlpha(const float a, const float b)
{
    const float aq = powf(a, 2);
    const float bq = powf(b, 2);
    const float c = sqrtf(aq + bq);
    const float q = aq / c;
    const float p = c - q;
    const float h = sqrtf(p*q);
    return ToDegree(atanf(h/p));
}

- (void) lookAt:(YAVector3f *)target
{
    NSAssert(_avatar, @"Avatar is nil");
    NSAssert(_transformator, @"transformator is nil");

    _actRotId = !_actRotId;
    
    _position = [_avatar position];

    const float actualPitch = _avatar.headAtlas;
    const float actualRoll = _avatar.headAxis;

    const float xDist = target.x - _position.x;
    const float yDist = target.y - _position.y;
    const float zDist = target.z - _position.z;
    
    const float targetRoll = copysignf(rectangularTriAlpha(xDist, zDist), xDist);
    // error function: (targetRoll * targetRoll) / 180
    const float targetPitch = copysignf(rectangularTriAlpha(yDist, zDist), -yDist) - (targetRoll * targetRoll) / 180;

    _headRotateDirection[_actRotId].x = targetPitch - actualPitch;
    _headRotateDirection[_actRotId].y = targetRoll - actualRoll;

    const float dirLength = _headRotateDirection[_actRotId].length;
    
    if(dirLength != 0)
        [_headRotateDirection[_actRotId] normalize];
    
    
    if(_memory == STORED_ENERGY) {
        [_headRotateDirection[_actRotId] mulScalar:(_headRotateDirection[!_actRotId].length + HEAD_ACCELERATION)];
    } else { // vector
        [_headRotateDirection[_actRotId] mulScalar:HEAD_ACCELERATION * 5.9];
        [_headRotateDirection[_actRotId] addVector:_headRotateDirection[!_actRotId]];
    }
  

    if(_headRotateDirection[_actRotId].length > HEAD_MAX_SPEED) {
        [_headRotateDirection[_actRotId] normalize];
        [_headRotateDirection[_actRotId] mulScalar:HEAD_MAX_SPEED];
    }

    if(_headRotateDirection[_actRotId].length >= dirLength / 8) {
        [_headRotateDirection[_actRotId] normalize];
        [_headRotateDirection[_actRotId] mulScalar:dirLength / 8];
    }
    
    float nextPitch = actualPitch + _headRotateDirection[_actRotId].x;
    float nextRoll  = actualRoll + _headRotateDirection[_actRotId].y;

    
    
    [_avatar setAtlas:nextPitch axis:nextRoll];

    if(_memory == STORED_VECTOR) {
        if([_lastTarget distanceTo:target] == 0) {
            const float reducedLength = _headRotateDirection[_actRotId].length * 0.9f;
            [_headRotateDirection[_actRotId] normalize];
            [_headRotateDirection[_actRotId] mulScalar:reducedLength];
        }
        _lastTarget = [[YAVector3f alloc] initCopy:target];
    }
}

@end
