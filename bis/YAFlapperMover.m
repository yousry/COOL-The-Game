//
//  YAFlapperMover.m
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
#import "YAFlapperMover.h"

@interface YAFlapperMover ()
- (void) setupKinematik;
@end

@implementation YAFlapperMover
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
    [boneAnim setInterval:1.0f];
    [boneAnim setAsyncProcessing:NO];
    [boneAnim addListener:^(float spanPos, NSNumber* event, int message) {
        if(active  == walk) {
            [kinematic reset];
            
            const float pseudoFly = 0.4;
            
            [kinematic setJointOrientation:@"UpperLeg.L" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:spanPos * 0.3  roll:  0 ]];
            [kinematic setJointOrientation:@"LowerLeg.L" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:spanPos * 0.05 + pseudoFly roll:  0 ]];
            [kinematic setJointOrientation:@"UpperLeg.R" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:spanPos * 0.3  roll:  0 ]];
            [kinematic setJointOrientation:@"LowerLeg.R" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:spanPos * 0.05 + pseudoFly  roll:  0 ]];
            
            [kinematic setJointOrientation:@"Body" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:spanPos * 0.2 + pseudoFly roll:  0 ]];
            [kinematic setJointOrientation:@"Head" quaternion:[[YAQuaternion alloc] initEuler:-spanPos * 0.2 pitch:0  roll:  -spanPos * 0.15 ]];


            
        }
    }];

    animators[1] = [_world createBlockAnimator];
    boneAnim = animators[1];
    
    [boneAnim setProgress:harmonic];
    [boneAnim setInterval:0.35f];
    [boneAnim setDelay:0.2f];
    [boneAnim setAsyncProcessing:NO];
    [boneAnim addListener:^(float spanPos, NSNumber* event, int message) {
        if(active == walk) {
            [kinematic setJointOrientation:@"Arm.L" quaternion:[[YAQuaternion alloc] initEuler:spanPos * 1.2 pitch:0  roll:  0 ]];
            [kinematic setJointOrientation:@"Arm.R" quaternion:[[YAQuaternion alloc] initEuler:-spanPos * 1.2 pitch:0  roll:  0 ]];
        }
    }];

    animators[2] = [_world createBlockAnimator];
    boneAnim = animators[2];
    
    [boneAnim setProgress:harmonic];
    [boneAnim setInterval:0.35f];
    [boneAnim setDelay:0.2f];
    [boneAnim setAsyncProcessing:NO];
    [boneAnim addListener:^(float spanPos, NSNumber* event, int message) {
        if(active == parade) {
            [kinematic reset];
            [kinematic setJointOrientation:@"Arm.L" quaternion:[[YAQuaternion alloc] initEuler:spanPos * 1.2 pitch:0  roll:  0 ]];
            [kinematic setJointOrientation:@"Arm.R" quaternion:[[YAQuaternion alloc] initEuler:-spanPos * 1.2 pitch:0  roll:  0 ]];
        }
    }];
   
}


@end
