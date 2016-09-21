//
//  YABonzoidMover.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 04.06.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAQuaternion.h"
#import "YABlockAnimator.h"
#import "YARenderLoop.h"
#import "YAImpersonator.h"
#import "YAKinematic.h"
#import "YABonzoidMover.h"

@interface YABonzoidMover ()
- (void) setupKinematik;
@end

@implementation YABonzoidMover

@synthesize active;


- (void) reset
{
    [kinematic reset];
}


- (id) initWithImp: (YAImpersonator*) impersonator inWorld: (YARenderLoop*) world
{
    self = [super init];
    if(self) {
        _impersonator = impersonator;
        _world = world;
        [self setupKinematik];
    }
    return self;
}

- (void) setupKinematik
{
    kinematic = [[YAKinematic alloc] initWithJoints:[_impersonator joints]];
    [kinematic createKinematic];
    
    YABlockAnimator* boneAnim;
    
    animators[0] = [_world createBlockAnimator];
    boneAnim = animators[0];
    
    [boneAnim setProgress:harmonic];
    [boneAnim setInterval:0.4f];
    [boneAnim setAsyncProcessing:NO];
    [boneAnim addListener:^(float spanPos, NSNumber* event, int message) {
        if(active == walk) {
            [kinematic reset];
            [kinematic setJointOrientation:@"UperLeg.L" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:-spanPos * 0.2  roll:  0 ]];
            [kinematic setJointOrientation:@"LowerLeg.L" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:-spanPos * 0.5  roll:  0 ]];
            [kinematic setJointOrientation:@"UperLeg.R" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:spanPos * 0.2  roll:  0 ]];
            [kinematic setJointOrientation:@"LowerLeg.R" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:spanPos * 0.5  roll:  0 ]];
        }
    }];
    
    animators[1] = [_world createBlockAnimator];
    boneAnim = animators[1];

    [boneAnim setProgress:harmonic];
    [boneAnim setInterval:0.8f];
    [boneAnim setDelay:0.2f];
    [boneAnim setAsyncProcessing:NO];
    [boneAnim addListener:^(float spanPos, NSNumber* event, int message) {
        if(active == walk) {
            [kinematic setJointOrientation:@"UpperArm.L" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:-spanPos * 0.1  roll:  0 ]];
            [kinematic setJointOrientation:@"LowerArm.L" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:-spanPos * 0.5  roll:  0 ]];
            [kinematic setJointOrientation:@"UpperArm.R" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:-spanPos * 0.1  roll:  0 ]];
            [kinematic setJointOrientation:@"LowerArm.R" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:-spanPos * 0.3  roll:  0 ]];
        }
    }];
    
    animators[2] = [_world createBlockAnimator];
    boneAnim = animators[2];

    [boneAnim setProgress:harmonic];
    [boneAnim setInterval:0.8f];
    [boneAnim setAsyncProcessing:NO];
    [boneAnim addListener:^(float spanPos, NSNumber* event, int message) {
        if(active == walk) {
            [kinematic setJointOrientation:@"Head" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:-spanPos * 0.1  roll:  fmod(spanPos * 2, 1) * 0.08 ]];
            [kinematic setJointOrientation:@"Torso" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:-spanPos * 0.2  roll:  fmod(spanPos * 2, 1) * 0.05 ]];
        }
    }];
    
    
}


@end
