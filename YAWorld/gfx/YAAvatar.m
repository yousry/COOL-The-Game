//
//  YAAvatar.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 20.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//


#import "math.h"

#import "YAVector2f.h"
#import "YATransformator.h"
#import "YAVector3f.h"
#import "YAAvatar.h"

@implementation YAAvatar

@synthesize moveForward;
@synthesize moveBackward;
@synthesize moveLeft;
@synthesize moveRight;
@synthesize headAtlas, headAxis;
@synthesize stepSize;


- (id) initWithTransformator: (YATransformator*) transformator
{
    self = [super init];
    if (self) {
        _transformator = transformator;
        headAtlas = 0.0f;
        headAxis = 0.0f;
        stepSize = 0.1f;
    }
    return self;
}

- (void) nextStep
{
    YAVector3f* eyepos = [_transformator eyePos];
    YAVector3f* eyefoc = [(YAVector3f*)[YAVector3f alloc] initCopy:[_transformator eyeFocus]];
    YAVector3f* eyeUp  = [_transformator eyeUp];

    if(moveForward){
        [eyepos addVector: [eyefoc mulScalar: stepSize]];
        [_transformator recalcCam];
    } else if(moveBackward) {
        [eyepos subVector:[eyefoc mulScalar: stepSize] ];
        [_transformator recalcCam];
    }

    if(moveLeft) {
        YAVector3f* left = [eyefoc crossVector:eyeUp];
        [left normalize];
        [left mulScalar: stepSize];
        [eyepos addVector:left];
        [_transformator recalcCam];
    } else if(moveRight) {
        YAVector3f* right = [[(YAVector3f*)[YAVector3f alloc] initCopy:[_transformator eyeUp]] crossVector:eyefoc] ;
        [right normalize];
        [right mulScalar: stepSize];
        [eyepos addVector:right];
        [_transformator recalcCam];
    }
}

- (void) setFocus: (YAVector3f*) direction
{
    YAVector3f* dirNormal = [[YAVector3f alloc] init];
    [dirNormal setVector:direction];
    [dirNormal normalize];

    [[_transformator eyeFocus] setVector:dirNormal];
    [[_transformator eyeUp] setVector:[[YAVector3f alloc] initZAxe]];

    if(dirNormal.y != 0) {

        YAVector3f* left = [[YAVector3f alloc] initVals:dirNormal.x :0 :dirNormal.z];
        [left normalize];

        if(dirNormal.y < 0)
            [left mulScalar:-1];

        [left crossVector:dirNormal];
        [[_transformator eyeUp] setVector:[left crossVector:dirNormal] ];
    }

    [_transformator recalcCam];
}


- (YAVector3f*) position
{
    return [_transformator eyePos];
}


- (void) setPosition: (YAVector3f*) position
{
    [[_transformator eyePos] setVector:position];
    [_transformator recalcCam];
}


- (void) setAtlas: (float)atlas axis: (float)axis {

    headAtlas = atlas;
    headAxis = axis;

    YAVector3f* eyeFocus = [_transformator eyeFocus];
    YAVector3f* eyeUp = [_transformator eyeUp];

    YAVector3f* origFocus = [[YAVector3f alloc] initZAxe];

    const  YAVector3f* yAxe = [[YAVector3f alloc] initYAxe];

    [origFocus rotate:headAxis axis:yAxe];
    [origFocus normalize];

    YAVector3f* localUp = [yAxe crossVector:origFocus];
    [localUp normalize];

    [origFocus rotate:headAtlas axis:localUp];
    [origFocus normalize];

    [eyeFocus setVector:origFocus];
    [eyeUp setVector:[origFocus crossVector:localUp]];
    [_transformator recalcCam];
}


- (void) moveHead: (float)speedX : (float)speedY
{

    if(fabsf(speedX) > 25.0f || fabsf(speedY) > 25.0f )
        return;

    headAtlas -= speedY / 5.0f;
    headAxis += speedX / 5.0f;
    headAxis = fmod(headAxis, 360);
    headAtlas = headAtlas > 80.0f ? 80.0 : headAtlas;
    headAtlas = headAtlas < -80.0f ? -80.0 : headAtlas;

    YAVector3f* eyeFocus = [_transformator eyeFocus];
    YAVector3f* eyeUp = [_transformator eyeUp];

    YAVector3f* origFocus = [[YAVector3f alloc] initVals:0.0f :0.0f :1.0f];

    const  YAVector3f* yAxe = [[YAVector3f alloc] initYAxe];

    [origFocus rotate:headAxis axis:yAxe];
    [origFocus normalize];

    YAVector3f* localUp = [yAxe crossVector:origFocus];
    [localUp normalize];

    [origFocus rotate:headAtlas axis:localUp];
    [origFocus normalize];

    [eyeFocus setVector:origFocus];
    [eyeUp setVector:[origFocus crossVector:localUp]];
    [_transformator recalcCam];
}

- (void) lookAt: (YAVector3f*) target
{
    YAVector3f* position = [_transformator eyePos];
    YAVector3f* targetDirection = [[YAVector3f alloc] initCopy:target];
    [targetDirection subVector:position];
    [targetDirection normalize];
    [self setFocus:targetDirection];
}

- (void) recenter: (YAVector3f*) target MarginAtlas: (float) marginAtlas MarginAxis: (float) marginAxis;
{

    YAVector3f* position = [_transformator eyePos];
    YAVector3f* td = [[YAVector3f alloc] initVals:target.x - position.x :target.y - position.y :target.z - position.z];
    [td normalize];

    float pitch = atan2f(-td.y, td.x*td.x + td.z*td.z) * 180 / M_PI;
    pitch *= 0.9;
    const float roll = atan2f(td.x, td.z) *  180 / M_PI;

    const float atlasDivergence = pitch > headAtlas ? pitch - headAtlas : headAtlas - pitch;
    const float axisDivergence = roll > headAxis ? roll - headAxis : headAxis - roll;

    if(atlasDivergence > marginAtlas || axisDivergence > marginAxis)
        [self setAtlas:pitch axis: roll];
}




- (NSString *)description
{
    NSString* result = [NSString stringWithFormat: @"Position: %@ \n Atlas: %f, Axis: %f",
                        _transformator.eyePos,
                        headAtlas,
                        headAxis];

    return result;
}

@end
