//
//  YASpheroidMover.m
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

#import "YASpheroidMover.h"

@interface YASpheroidMover()
- (void) setupKinematik;
@end

@implementation YASpheroidMover

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
    [boneAnim setInterval:2.5f];
    [boneAnim setAsyncProcessing:NO];
    [boneAnim addListener:^(float spanPos, NSNumber* event, int message) {
        if(active == walk) {
            [kinematic reset];
            [kinematic setJointOrientation:@"Neck" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:-spanPos * 1  roll:  0 ]];

        }
    }];
    
    
    
}

@end
