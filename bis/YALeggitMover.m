//
//  YALeggitMover.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 05.06.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAQuaternion.h"
#import "YABlockAnimator.h"
#import "YARenderLoop.h"
#import "YAImpersonator.h"
#import "YAKinematic.h"
#import "YALeggitMover.h"


@interface YALeggitMover ()
- (void) setupKinematik;
@end

@implementation YALeggitMover

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
    [boneAnim setInterval:0.8f];
    [boneAnim setDelay:0.2];
    [boneAnim setAsyncProcessing:NO];
    [boneAnim addListener:^(float spanPos, NSNumber* event, int message) {
        if(active == walk) {
            [kinematic reset];
            [kinematic setJointOrientation:@"UpperLeg.L" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:-spanPos * 1.2  roll:  0 ]];
            [kinematic setJointOrientation:@"LowerLeg.R" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:-spanPos * 0.5  roll:  0 ]];
            [kinematic setJointOrientation:@"UpperLeg.R" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:spanPos * 1.2  roll:  0 ]];
            [kinematic setJointOrientation:@"LowerLeg.L" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:spanPos * 0.5  roll:  0 ]];
            
            [kinematic setJointOrientation:@"Body" quaternion:[[YAQuaternion alloc] initEuler:-spanPos * 0.2 pitch:0.0 + spanPos * 0.02  roll:  0 ]];

         }
    }];
    
    animators[1] = [_world createBlockAnimator];
    boneAnim = animators[1];
    
    [boneAnim setProgress:harmonic];
    [boneAnim setInterval:0.4f];
    [boneAnim setDelay:0.2f];
    [boneAnim setAsyncProcessing:NO];
    [boneAnim addListener:^(float spanPos, NSNumber* event, int message) {
        if(active == walk) {
            [kinematic setJointOrientation:@"Head" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:0.0 + spanPos * 0.2  roll:  0 ]];
            

        }
    }];

    
    
}
@end
