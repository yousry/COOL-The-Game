//
//  YADromedarMover.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 14.06.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAQuaternion.h"
#import "YABlockAnimator.h"
#import "YARenderLoop.h"
#import "YAImpersonator.h"
#import "YAKinematic.h"

#import "YADromedarMover.h"

@interface YADromedarMover () 

- (void) setupKinematik;

@end

@implementation YADromedarMover

@synthesize active;

float progress (float a, float b, float p) {
    return   ((a + (b - a) * p) / 360) * M_PI ;
}


YAQuaternion* progressQuat(YAQuaternion* a, YAQuaternion* b, float p) {
    return [[YAQuaternion alloc] initVals:progress(a.x, b.x, p) :progress(a.y, b.y, p) :progress(a.z, b.z, p) :progress(a.w, b.w, p)];
}


- (void) reset
{
    [kinematic reset];
}

- (id) initWithImp: (YAImpersonator*) impersonator inWorld: (YARenderLoop*) world;
{
    self = [super init];
    if(self) {
        _impersonator = impersonator;
        _world = world;
        
        [self setupQuats];
        [self setupKinematik];
    }
    return self;
}

- (void) setupQuats
{
    upperArmL = [[NSMutableArray alloc] initWithCapacity:9];
    lowerArmL = [[NSMutableArray alloc] initWithCapacity:9];
    footL = [[NSMutableArray alloc] initWithCapacity:9];
    upperArmR = [[NSMutableArray alloc] initWithCapacity:9];
    lowerArmR = [[NSMutableArray alloc] initWithCapacity:9];
    footR = [[NSMutableArray alloc] initWithCapacity:9];
    upperLegL = [[NSMutableArray alloc] initWithCapacity:9];
    lowerLegL = [[NSMutableArray alloc] initWithCapacity:9];
    handL = [[NSMutableArray alloc] initWithCapacity:9];
    upperLegR = [[NSMutableArray alloc] initWithCapacity:9];
    lowerLegR = [[NSMutableArray alloc] initWithCapacity:9];
    handR = [[NSMutableArray alloc] initWithCapacity:9];
    
    // Pose.Bones["Upperarm.L"].Rotation_Quaternion
    // Frame: 0.0
    [upperArmL addObject: [[YAQuaternion alloc] initVals:0.434237 :0.018671 :-0.036868 :0.899850]];
    // Frame: 5.0
    [upperArmL addObject: [[YAQuaternion alloc] initVals:0.604469 :0.025990 :-0.051321 :0.794549]];
    // Frame: 10.0
    [upperArmL addObject: [[YAQuaternion alloc] initVals:0.305841 :0.013150 :-0.025967 :0.951638]];
    // Frame: 15.0
    [upperArmL addObject: [[YAQuaternion alloc] initVals:0.325387 :0.013991 :-0.027626 :0.945074]];
    // Frame: 20.0
    [upperArmL addObject: [[YAQuaternion alloc] initVals:0.287867 :0.012377 :-0.024441 :0.957279]];
    // Frame: 25.0
    [upperArmL addObject: [[YAQuaternion alloc] initVals:0.187339 :0.008055 :-0.015906 :0.982134]];
    // Frame: 30.0
    [upperArmL addObject: [[YAQuaternion alloc] initVals:0.069688 :0.002996 :-0.005917 :0.997548]];
    // Frame: 35.0
    [upperArmL addObject: [[YAQuaternion alloc] initVals:0.211251 :0.009083 :-0.017936 :0.977226]];
    // Frame: 40.0
    [upperArmL addObject: [[YAQuaternion alloc] initVals:0.434237 :0.018671 :-0.036868 :0.899850]];
    
    
    // Pose.Bones["Lowerarm.L"].Rotation_Quaternion
    // Frame: 0.0
    [lowerArmL addObject: [[YAQuaternion alloc] initVals:0.666984 :-0.002136 :0.006670 :0.745040]];
    // Frame: 5.0
    [lowerArmL addObject: [[YAQuaternion alloc] initVals:0.560804 :-0.001796 :0.005609 :0.827928]];
    // Frame: 10.0
    [lowerArmL addObject: [[YAQuaternion alloc] initVals:0.118573 :-0.000380 :0.001186 :0.992945]];
    // Frame: 15.0
    [lowerArmL addObject: [[YAQuaternion alloc] initVals:0.164503 :-0.000527 :0.001645 :0.986376]];
    // Frame: 20.0
    [lowerArmL addObject: [[YAQuaternion alloc] initVals:0.362319 :-0.001160 :0.003623 :0.932047]];
    // Frame: 25.0
    [lowerArmL addObject: [[YAQuaternion alloc] initVals:0.295781 :-0.000947 :0.002958 :0.955251]];
    // Frame: 30.0
    [lowerArmL addObject: [[YAQuaternion alloc] initVals:0.172926 :-0.000554 :0.001729 :0.984934]];
    // Frame: 35.0
    [lowerArmL addObject: [[YAQuaternion alloc] initVals:0.560859 :-0.001796 :0.005609 :0.827891]];
    // Frame: 40.0
    [lowerArmL addObject: [[YAQuaternion alloc] initVals:0.666984 :-0.002136 :0.006670 :0.745040]];
    
    [lowerArmL replaceObjectAtIndex:0 withObject:[[lowerArmL objectAtIndex:0] conjugate]];
    [lowerArmL replaceObjectAtIndex:1 withObject:[[lowerArmL objectAtIndex:1] conjugate]];
    [lowerArmL replaceObjectAtIndex:2 withObject:[[lowerArmL objectAtIndex:2] conjugate]];
    [lowerArmL replaceObjectAtIndex:3 withObject:[[lowerArmL objectAtIndex:3] conjugate]];
    [lowerArmL replaceObjectAtIndex:4 withObject:[[lowerArmL objectAtIndex:4] conjugate]];
    [lowerArmL replaceObjectAtIndex:5 withObject:[[lowerArmL objectAtIndex:5] conjugate]];
    [lowerArmL replaceObjectAtIndex:6 withObject:[[lowerArmL objectAtIndex:6] conjugate]];
    [lowerArmL replaceObjectAtIndex:7 withObject:[[lowerArmL objectAtIndex:7] conjugate]];
    [lowerArmL replaceObjectAtIndex:8 withObject:[[lowerArmL objectAtIndex:8] conjugate]];
    
    
    // Pose.Bones["Hand.L"].Rotation_Quaternion
    // Frame: 0.0
    [handL addObject: [[YAQuaternion alloc] initVals:0.741436 :0.003470 :-0.014472 :0.670859]];
    // Frame: 5.0
    [handL addObject: [[YAQuaternion alloc] initVals:0.741436 :0.003470 :-0.014472 :0.670859]];
    // Frame: 10.0
    [handL addObject: [[YAQuaternion alloc] initVals:0.189024 :0.000885 :-0.003690 :0.981965]];
    // Frame: 15.0
    [handL addObject: [[YAQuaternion alloc] initVals:0.159307 :0.000746 :-0.003110 :0.987224]];
    // Frame: 20.0
    [handL addObject: [[YAQuaternion alloc] initVals:-0.073376 :-0.000343 :0.001432 :0.997303]];
    // Frame: 25.0
    [handL addObject: [[YAQuaternion alloc] initVals:-0.110046 :-0.000515 :0.002148 :0.993924]];
    // Frame: 30.0
    [handL addObject: [[YAQuaternion alloc] initVals:-0.100914 :-0.000472 :0.001970 :0.994894]];
    // Frame: 35.0
    [handL addObject: [[YAQuaternion alloc] initVals:0.639970 :0.002995 :-0.012492 :0.768293]];
    // Frame: 40.0
    [handL addObject: [[YAQuaternion alloc] initVals:0.741436 :0.003470 :-0.014472 :0.670859]];
    
    
    [handL replaceObjectAtIndex:0 withObject:[[handL objectAtIndex:0] conjugate]];
    [handL replaceObjectAtIndex:1 withObject:[[handL objectAtIndex:1] conjugate]];
    [handL replaceObjectAtIndex:2 withObject:[[handL objectAtIndex:2] conjugate]];
    [handL replaceObjectAtIndex:3 withObject:[[handL objectAtIndex:3] conjugate]];
    [handL replaceObjectAtIndex:4 withObject:[[handL objectAtIndex:4] conjugate]];
    [handL replaceObjectAtIndex:5 withObject:[[handL objectAtIndex:5] conjugate]];
    [handL replaceObjectAtIndex:6 withObject:[[handL objectAtIndex:6] conjugate]];
    [handL replaceObjectAtIndex:7 withObject:[[handL objectAtIndex:7] conjugate]];
    [handL replaceObjectAtIndex:8 withObject:[[handL objectAtIndex:8] conjugate]];

    
    
    // Pose.Bones["Upperarm.R"].Rotation_Quaternion
    // Frame: 0.0
    [upperArmR addObject: [[YAQuaternion alloc] initVals:0.300153 :-0.025362 :0.007763 :0.953523]];
    // Frame: 5.0
    [upperArmR addObject: [[YAQuaternion alloc] initVals:0.243587 :-0.020583 :0.006300 :0.969640]];
    // Frame: 10.0
    [upperArmR addObject: [[YAQuaternion alloc] initVals:0.045716 :-0.003863 :0.001182 :0.998947]];
    // Frame: 15.0
    [upperArmR addObject: [[YAQuaternion alloc] initVals:0.209173 :-0.017675 :0.005410 :0.977705]];
    // Frame: 20.0
    [upperArmR addObject: [[YAQuaternion alloc] initVals:0.399002 :-0.033715 :0.010320 :0.916273]];
    // Frame: 25.0
    [upperArmR addObject: [[YAQuaternion alloc] initVals:0.597966 :-0.050527 :0.015466 :0.799778]];
    // Frame: 30.0
    [upperArmR addObject: [[YAQuaternion alloc] initVals:0.310018 :-0.026196 :0.008018 :0.950337]];
    // Frame: 35.0
    [upperArmR addObject: [[YAQuaternion alloc] initVals:0.324421 :-0.027413 :0.008391 :0.945479]];
    // Frame: 40.0
    [upperArmR addObject: [[YAQuaternion alloc] initVals:0.300153 :-0.025362 :0.007763 :0.953523]];
    
    // Pose.Bones["Lowerarm.R"].Rotation_Quaternion
    // Frame: 0.0
    [lowerArmR addObject: [[YAQuaternion alloc] initVals:0.094978 :0.000304 :-0.000950 :0.995479]];
    // Frame: 5.0
    [lowerArmR addObject: [[YAQuaternion alloc] initVals:0.353423 :0.001132 :-0.003535 :0.935457]];
    // Frame: 10.0
    [lowerArmR addObject: [[YAQuaternion alloc] initVals:0.123886 :0.000397 :-0.001239 :0.992296]];
    // Frame: 15.0
    [lowerArmR addObject: [[YAQuaternion alloc] initVals:0.531658 :0.001703 :-0.005317 :0.846941]];
    // Frame: 20.0
    [lowerArmR addObject: [[YAQuaternion alloc] initVals:0.665299 :0.002131 :-0.006654 :0.746545]];
    // Frame: 25.0
    [lowerArmR addObject: [[YAQuaternion alloc] initVals:0.555119 :0.001778 :-0.005552 :0.831752]];
    // Frame: 30.0
    [lowerArmR addObject: [[YAQuaternion alloc] initVals:0.113934 :0.000365 :-0.001139 :0.993489]];
    // Frame: 35.0
    [lowerArmR addObject: [[YAQuaternion alloc] initVals:0.134120 :0.000430 :-0.001341 :0.990965]];
    // Frame: 40.0
    [lowerArmR addObject: [[YAQuaternion alloc] initVals:0.094978 :0.000304 :-0.000950 :0.995479]];
    
    
    [lowerArmR replaceObjectAtIndex:0 withObject:[[lowerArmR objectAtIndex:0] conjugate]];
    [lowerArmR replaceObjectAtIndex:1 withObject:[[lowerArmR objectAtIndex:1] conjugate]];
    [lowerArmR replaceObjectAtIndex:2 withObject:[[lowerArmR objectAtIndex:2] conjugate]];
    [lowerArmR replaceObjectAtIndex:3 withObject:[[lowerArmR objectAtIndex:3] conjugate]];
    [lowerArmR replaceObjectAtIndex:4 withObject:[[lowerArmR objectAtIndex:4] conjugate]];
    [lowerArmR replaceObjectAtIndex:5 withObject:[[lowerArmR objectAtIndex:5] conjugate]];
    [lowerArmR replaceObjectAtIndex:6 withObject:[[lowerArmR objectAtIndex:6] conjugate]];
    [lowerArmR replaceObjectAtIndex:7 withObject:[[lowerArmR objectAtIndex:7] conjugate]];
    [lowerArmR replaceObjectAtIndex:8 withObject:[[lowerArmR objectAtIndex:8] conjugate]];

    
    
//    // Pose.Bones["Hand.R"].Rotation_Quaternion
//    // Frame: 0.0
//    [handR addObject: [[YAQuaternion alloc] initVals:0.181818 :0.137209 :-0.036589 :0.973025]];
//    // Frame: 5.0
//    [handR addObject: [[YAQuaternion alloc] initVals:-0.095669 :-0.072196 :0.019252 :0.992605]];
//    // Frame: 10.0
//    [handR addObject: [[YAQuaternion alloc] initVals:-0.064121 :-0.048389 :0.012904 :0.996685]];
//    // Frame: 15.0
//    [handR addObject: [[YAQuaternion alloc] initVals:0.599449 :0.452373 :-0.120631 :0.649206]];
//    // Frame: 20.0
//    [handR addObject: [[YAQuaternion alloc] initVals:0.553332 :0.417571 :-0.111351 :0.712082]];
//    // Frame: 25.0
//    [handR addObject: [[YAQuaternion alloc] initVals:0.433103 :0.326840 :-0.087156 :0.835466]];
//    // Frame: 30.0
//    [handR addObject: [[YAQuaternion alloc] initVals:0.183612 :0.138563 :-0.036949 :0.972483]];
//    // Frame: 35.0
//    [handR addObject: [[YAQuaternion alloc] initVals:0.172590 :0.130245 :-0.034731 :0.975728]];
//    // Frame: 40.0
//    [handR addObject: [[YAQuaternion alloc] initVals:0.181818 :0.137209 :-0.036589 :0.973025]];

    // Pose.Bones["Hand.R"].Rotation_Quaternion
    // Frame: 0.0
    [handR addObject: [[YAQuaternion alloc] initEuler:0 pitch:(M_PI / 360.0) * -20.0 roll:0]];
    // Frame: 5.0
    [handR addObject: [[YAQuaternion alloc] initEuler:0 pitch:(M_PI / 360.0) * 15 roll:0]];
    // Frame: 10.0
    [handR addObject: [[YAQuaternion alloc] initEuler:0 pitch:(M_PI / 360.0) * 15 roll:0]];
    // Frame: 15.0
    [handR addObject: [[YAQuaternion alloc] initEuler:0 pitch:(M_PI / 360.0) * -20.0 roll:0]];
    // Frame: 20.0
    [handR addObject: [[YAQuaternion alloc] initEuler:0 pitch:(M_PI / 360.0) * -90.0 roll:0]];
    // Frame: 25.0
    [handR addObject: [[YAQuaternion alloc] initEuler:0 pitch:(M_PI / 360.0) * -90.0 roll:0]];
    // Frame: 30.0
    [handR addObject: [[YAQuaternion alloc] initEuler:0 pitch:(M_PI / 360.0) * -20.0 roll:0]];
    // Frame: 35.0
    [handR addObject: [[YAQuaternion alloc] initEuler:0 pitch:(M_PI / 360.0) * -20.0 roll:0]];
    // Frame: 40.0
    [handR addObject: [[YAQuaternion alloc] initEuler:0 pitch:(M_PI / 360.0) * -20.0 roll:0]];

    
    
//    [handR replaceObjectAtIndex:0 withObject:[[handR objectAtIndex:0] conjugate]];
//    [handR replaceObjectAtIndex:1 withObject:[[handR objectAtIndex:1] conjugate]];
//    [handR replaceObjectAtIndex:2 withObject:[[handR objectAtIndex:2] conjugate]];
//    [handR replaceObjectAtIndex:3 withObject:[[handR objectAtIndex:3] conjugate]];
//    [handR replaceObjectAtIndex:4 withObject:[[handR objectAtIndex:4] conjugate]];
//    [handR replaceObjectAtIndex:5 withObject:[[handR objectAtIndex:5] conjugate]];
//    [handR replaceObjectAtIndex:6 withObject:[[handR objectAtIndex:6] conjugate]];
//    [handR replaceObjectAtIndex:7 withObject:[[handR objectAtIndex:7] conjugate]];
//    [handR replaceObjectAtIndex:8 withObject:[[handR objectAtIndex:8] conjugate]];

    
    // Pose.Bones["Upperleg.L"].Rotation_Quaternion
    // Frame: 0.0
    [upperLegL addObject: [[YAQuaternion alloc] initVals:0.155511 :-0.000035 :-0.005744 :0.987818]];
    // Frame: 5.0
    [upperLegL addObject: [[YAQuaternion alloc] initVals:-0.091138 :0.000020 :0.003366 :0.995833]];
    // Frame: 10.0
    [upperLegL addObject: [[YAQuaternion alloc] initVals:-0.135692 :0.000030 :0.005012 :0.990739]];
    // Frame: 15.0
    [upperLegL addObject: [[YAQuaternion alloc] initVals:-0.133998 :0.000030 :0.004950 :0.990970]];
    // Frame: 20.0
    [upperLegL addObject: [[YAQuaternion alloc] initVals:-0.102476 :0.000023 :0.003785 :0.994729]];
    // Frame: 25.0
    [upperLegL addObject: [[YAQuaternion alloc] initVals:-0.368847 :0.000082 :0.013624 :0.929391]];
    // Frame: 30.0
    [upperLegL addObject: [[YAQuaternion alloc] initVals:-0.420518 :0.000094 :0.015533 :0.907152]];
    // Frame: 35.0
    [upperLegL addObject: [[YAQuaternion alloc] initVals:0.092633 :-0.000021 :-0.003422 :0.995695]];
    // Frame: 40.0
    [upperLegL addObject: [[YAQuaternion alloc] initVals:0.155511 :-0.000035 :-0.005744 :0.987818]];
    
    // Pose.Bones["Lowerleg.L"].Rotation_Quaternion
    // Frame: 0.0
    [lowerLegL addObject: [[YAQuaternion alloc] initVals:0.157827 :-0.010164 :-0.002244 :0.987412]];
    // Frame: 5.0
    [lowerLegL addObject: [[YAQuaternion alloc] initVals:-0.015324 :0.000987 :0.000218 :0.999882]];
    // Frame: 10.0
    [lowerLegL addObject: [[YAQuaternion alloc] initVals:0.109422 :-0.007047 :-0.001556 :0.993970]];
    // Frame: 15.0
    [lowerLegL addObject: [[YAQuaternion alloc] initVals:0.101763 :-0.006554 :-0.001447 :0.994786]];
    // Frame: 20.0
    [lowerLegL addObject: [[YAQuaternion alloc] initVals:0.261734 :-0.016856 :-0.003722 :0.964986]];
    // Frame: 25.0
    [lowerLegL addObject: [[YAQuaternion alloc] initVals:-0.030719 :0.001978 :0.000437 :0.999527]];
    // Frame: 30.0
    [lowerLegL addObject: [[YAQuaternion alloc] initVals:-0.397481 :0.025599 :0.005652 :0.917237]];
    // Frame: 35.0
    [lowerLegL addObject: [[YAQuaternion alloc] initVals:-0.165394 :0.010652 :0.002352 :0.986168]];
    // Frame: 40.0
    [lowerLegL addObject: [[YAQuaternion alloc] initVals:0.157827 :-0.010164 :-0.002244 :0.987412]];
    
    [lowerLegL replaceObjectAtIndex:0 withObject:[[lowerLegL objectAtIndex:0] conjugate]];
    [lowerLegL replaceObjectAtIndex:1 withObject:[[lowerLegL objectAtIndex:1] conjugate]];
    [lowerLegL replaceObjectAtIndex:2 withObject:[[lowerLegL objectAtIndex:2] conjugate]];
    [lowerLegL replaceObjectAtIndex:3 withObject:[[lowerLegL objectAtIndex:3] conjugate]];
    [lowerLegL replaceObjectAtIndex:4 withObject:[[lowerLegL objectAtIndex:4] conjugate]];
    [lowerLegL replaceObjectAtIndex:5 withObject:[[lowerLegL objectAtIndex:5] conjugate]];
    [lowerLegL replaceObjectAtIndex:6 withObject:[[lowerLegL objectAtIndex:6] conjugate]];
    [lowerLegL replaceObjectAtIndex:7 withObject:[[lowerLegL objectAtIndex:7] conjugate]];
    [lowerLegL replaceObjectAtIndex:8 withObject:[[lowerLegL objectAtIndex:8] conjugate]];

    
    // Pose.Bones["Foot.L"].Rotation_Quaternion
    // Frame: 0.0
    [footL addObject: [[YAQuaternion alloc] initVals:0.000044 :0.000000 :0.000000 :1.000000]];
    // Frame: 5.0
    [footL addObject: [[YAQuaternion alloc] initVals:-0.084172 :-0.000006 :-0.000100 :0.996451]];
    // Frame: 10.0
    [footL addObject: [[YAQuaternion alloc] initVals:-0.272959 :-0.000019 :-0.000323 :0.962026]];
    // Frame: 15.0
    [footL addObject: [[YAQuaternion alloc] initVals:-0.253921 :-0.000018 :-0.000301 :0.967225]];
    // Frame: 20.0
    [footL addObject: [[YAQuaternion alloc] initVals:-0.394113 :-0.000028 :-0.000467 :0.919062]];
    // Frame: 25.0
    [footL addObject: [[YAQuaternion alloc] initVals:0.516126 :0.000036 :0.000612 :0.856513]];
    // Frame: 30.0
    [footL addObject: [[YAQuaternion alloc] initVals:0.497120 :0.000035 :0.000589 :0.867682]];
    // Frame: 35.0
    [footL addObject: [[YAQuaternion alloc] initVals:0.292492 :0.000020 :0.000347 :0.956268]];
    // Frame: 40.0
    [footL addObject: [[YAQuaternion alloc] initVals:0.000044 :0.000000 :0.000000 :1.000000]];
    
    
    [footL replaceObjectAtIndex:0 withObject:[[footL objectAtIndex:0] conjugate]];
    [footL replaceObjectAtIndex:1 withObject:[[footL objectAtIndex:1] conjugate]];
    [footL replaceObjectAtIndex:2 withObject:[[footL objectAtIndex:2] conjugate]];
    [footL replaceObjectAtIndex:3 withObject:[[footL objectAtIndex:3] conjugate]];
    [footL replaceObjectAtIndex:4 withObject:[[footL objectAtIndex:4] conjugate]];
    [footL replaceObjectAtIndex:5 withObject:[[footL objectAtIndex:5] conjugate]];
    [footL replaceObjectAtIndex:6 withObject:[[footL objectAtIndex:6] conjugate]];
    [footL replaceObjectAtIndex:7 withObject:[[footL objectAtIndex:7] conjugate]];
    [footL replaceObjectAtIndex:8 withObject:[[footL objectAtIndex:8] conjugate]];

    
    
    // Pose.Bones["Upperleg.R"].Rotation_Quaternion
    // Frame: 0.0
    [upperLegR addObject: [[YAQuaternion alloc] initVals:-0.077559 :0.000017 :-0.002865 :0.996984]];
    // Frame: 5.0
    [upperLegR addObject: [[YAQuaternion alloc] initVals:-0.393281 :0.000088 :-0.014527 :0.919304]];
    // Frame: 10.0
    [upperLegR addObject: [[YAQuaternion alloc] initVals:-0.201113 :0.000045 :-0.007429 :0.979540]];
    // Frame: 15.0
    [upperLegR addObject: [[YAQuaternion alloc] initVals:-0.053741 :0.000012 :-0.001985 :0.998553]];
    // Frame: 20.0
    [upperLegR addObject: [[YAQuaternion alloc] initVals:0.138533 :-0.000031 :0.005117 :0.990345]];
    // Frame: 25.0
    [upperLegR addObject: [[YAQuaternion alloc] initVals:-0.065149 :0.000015 :-0.002406 :0.997874]];
    // Frame: 30.0
    [upperLegR addObject: [[YAQuaternion alloc] initVals:-0.093339 :0.000021 :-0.003448 :0.995630]];
    // Frame: 35.0
    [upperLegR addObject: [[YAQuaternion alloc] initVals:-0.095628 :0.000021 :-0.003532 :0.995412]];
    // Frame: 40.0
    [upperLegR addObject: [[YAQuaternion alloc] initVals:-0.077559 :0.000017 :-0.002865 :0.996984]];
    
    // Pose.Bones["Lowerleg.R"].Rotation_Quaternion
    // Frame: 0.0
    [lowerLegR addObject: [[YAQuaternion alloc] initVals:0.318196 :-0.000704 :0.017108 :0.947870]];
    // Frame: 5.0
    [lowerLegR addObject: [[YAQuaternion alloc] initVals:-0.171833 :0.000380 :-0.009239 :0.985083]];
    // Frame: 10.0
    [lowerLegR addObject: [[YAQuaternion alloc] initVals:-0.364273 :0.000806 :-0.019585 :0.931086]];
    // Frame: 15.0
    [lowerLegR addObject: [[YAQuaternion alloc] initVals:-0.378015 :0.000836 :-0.020324 :0.925576]];
    // Frame: 20.0
    [lowerLegR addObject: [[YAQuaternion alloc] initVals:0.129134 :-0.000286 :0.006943 :0.991603]];
    // Frame: 25.0
    [lowerLegR addObject: [[YAQuaternion alloc] initVals:-0.002620 :0.000006 :-0.000141 :0.999997]];
    // Frame: 30.0
    [lowerLegR addObject: [[YAQuaternion alloc] initVals:-0.014769 :0.000033 :-0.000794 :0.999892]];
    // Frame: 35.0
    [lowerLegR addObject: [[YAQuaternion alloc] initVals:-0.008204 :0.000018 :-0.000441 :0.999968]];
    // Frame: 40.0
    [lowerLegR addObject: [[YAQuaternion alloc] initVals:0.318196 :-0.000704 :0.017108 :0.947870]];
    
    
    [lowerLegR replaceObjectAtIndex:0 withObject:[[lowerLegR objectAtIndex:0] conjugate]];
    [lowerLegR replaceObjectAtIndex:1 withObject:[[lowerLegR objectAtIndex:1] conjugate]];
    [lowerLegR replaceObjectAtIndex:2 withObject:[[lowerLegR objectAtIndex:2] conjugate]];
    [lowerLegR replaceObjectAtIndex:3 withObject:[[lowerLegR objectAtIndex:3] conjugate]];
    [lowerLegR replaceObjectAtIndex:4 withObject:[[lowerLegR objectAtIndex:4] conjugate]];
    [lowerLegR replaceObjectAtIndex:5 withObject:[[lowerLegR objectAtIndex:5] conjugate]];
    [lowerLegR replaceObjectAtIndex:6 withObject:[[lowerLegR objectAtIndex:6] conjugate]];
    [lowerLegR replaceObjectAtIndex:7 withObject:[[lowerLegR objectAtIndex:7] conjugate]];
    [lowerLegR replaceObjectAtIndex:8 withObject:[[lowerLegR objectAtIndex:8] conjugate]];

    
    
    // Pose.Bones["Foot.R"].Rotation_Quaternion
    // Frame: 0.0
    [footR addObject: [[YAQuaternion alloc] initVals:-0.428190 :0.000030 :0.000507 :0.903689]];
    // Frame: 5.0
    [footR addObject: [[YAQuaternion alloc] initVals:0.559987 :-0.000039 :-0.000664 :0.828501]];
    // Frame: 10.0
    [footR addObject: [[YAQuaternion alloc] initVals:0.548935 :-0.000038 :-0.000651 :0.835865]];
    // Frame: 15.0
    [footR addObject: [[YAQuaternion alloc] initVals:0.515975 :-0.000036 :-0.000611 :0.856603]];
    // Frame: 20.0
    [footR addObject: [[YAQuaternion alloc] initVals:0.012157 :-0.000001 :-0.000014 :0.999926]];
    // Frame: 25.0
    [footR addObject: [[YAQuaternion alloc] initVals:-0.065031 :0.000005 :0.000077 :0.997884]];
    // Frame: 30.0
    [footR addObject: [[YAQuaternion alloc] initVals:-0.087634 :0.000006 :0.000104 :0.996153]];
    // Frame: 35.0
    [footR addObject: [[YAQuaternion alloc] initVals:-0.087757 :0.000006 :0.000104 :0.996142]];
    // Frame: 40.0
    [footR addObject: [[YAQuaternion alloc] initVals:-0.428190 :0.000030 :0.000507 :0.903689]];
    
    [footR replaceObjectAtIndex:0 withObject:[[footR objectAtIndex:0] conjugate]];
    [footR replaceObjectAtIndex:1 withObject:[[footR objectAtIndex:1] conjugate]];
    [footR replaceObjectAtIndex:2 withObject:[[footR objectAtIndex:2] conjugate]];
    [footR replaceObjectAtIndex:3 withObject:[[footR objectAtIndex:3] conjugate]];
    [footR replaceObjectAtIndex:4 withObject:[[footR objectAtIndex:4] conjugate]];
    [footR replaceObjectAtIndex:5 withObject:[[footR objectAtIndex:5] conjugate]];
    [footR replaceObjectAtIndex:6 withObject:[[footR objectAtIndex:6] conjugate]];
    [footR replaceObjectAtIndex:7 withObject:[[footR objectAtIndex:7] conjugate]];
    [footR replaceObjectAtIndex:8 withObject:[[footR objectAtIndex:8] conjugate]];

    
    
}

- (void) setupKinematik
{
    kinematic = [[YAKinematic alloc] initWithJoints:[_impersonator joints]];
    [kinematic createKinematic];
    
    YABlockAnimator* boneAnim;
    
    animators[0] = [_world createBlockAnimator];
    boneAnim = animators[0];
    
    float ipoAnim = 0.80f; // was 1.6
    
    [boneAnim setInterval:ipoAnim];
    [boneAnim setDelay:0.00f]; 
    [boneAnim setProgress:cyclic];
    [boneAnim setAsyncProcessing:NO];
    [boneAnim addListener:^(float spanPos, NSNumber* event, int message) {
        if(active == walk) {
            [kinematic reset];
            
            float frames = spanPos * 40.0;
            float frameWindow = fmod(frames, 5.0f) / 5.0f;
            if(frames < 5) {
                
                [kinematic setJointOrientation:@"Hand.R" quaternion:progressQuat([handR         objectAtIndex:0], [handR     objectAtIndex:1], frameWindow)];
                [kinematic setJointOrientation:@"LowerArm.R" quaternion:progressQuat([lowerArmR objectAtIndex:0], [lowerArmR objectAtIndex:1], frameWindow)];
                [kinematic setJointOrientation:@"UpperArm.R" quaternion:progressQuat([upperArmR objectAtIndex:0], [upperArmR objectAtIndex:1], frameWindow)];
                
                [kinematic setJointOrientation:@"Hand.L" quaternion:progressQuat(    [handL     objectAtIndex:0], [handL    objectAtIndex:1], frameWindow)];
                [kinematic setJointOrientation:@"LowerArm.L" quaternion:progressQuat([lowerArmL objectAtIndex:0], [lowerArmL objectAtIndex:1], frameWindow)];
                [kinematic setJointOrientation:@"UpperArm.L" quaternion:progressQuat([upperArmL objectAtIndex:0], [upperArmL objectAtIndex:1], frameWindow)];
                
                [kinematic setJointOrientation:@"Foot.L" quaternion:progressQuat([footL         objectAtIndex:0], [footL     objectAtIndex:1], frameWindow)];
                [kinematic setJointOrientation:@"LowerLeg.L" quaternion:progressQuat([lowerLegL objectAtIndex:0], [lowerLegL objectAtIndex:1], frameWindow)];
                [kinematic setJointOrientation:@"UpperLeg.L" quaternion:progressQuat([upperLegL objectAtIndex:0], [upperLegL objectAtIndex:1], frameWindow)];
                
                [kinematic setJointOrientation:@"Foot.R" quaternion:progressQuat([footR         objectAtIndex:0], [footR     objectAtIndex:1], frameWindow)];
                [kinematic setJointOrientation:@"LowerLeg.R" quaternion:progressQuat([lowerLegR objectAtIndex:0], [lowerLegR objectAtIndex:1], frameWindow)];
                [kinematic setJointOrientation:@"UpperLeg.R" quaternion:progressQuat([upperLegR objectAtIndex:0], [upperLegR objectAtIndex:1], frameWindow)];

            } else if (frames < 10) {
                
                [kinematic setJointOrientation:@"Hand.R" quaternion:progressQuat([handR         objectAtIndex:1], [handR     objectAtIndex:2], frameWindow)];
                [kinematic setJointOrientation:@"LowerArm.R" quaternion:progressQuat([lowerArmR objectAtIndex:1], [lowerArmR objectAtIndex:2], frameWindow)];
                [kinematic setJointOrientation:@"UpperArm.R" quaternion:progressQuat([upperArmR objectAtIndex:1], [upperArmR objectAtIndex:2], frameWindow)];
                
                [kinematic setJointOrientation:@"Hand.L" quaternion:progressQuat([handL         objectAtIndex:1], [handL     objectAtIndex:2], frameWindow)];
                [kinematic setJointOrientation:@"LowerArm.L" quaternion:progressQuat([lowerArmL objectAtIndex:1], [lowerArmL objectAtIndex:2], frameWindow)];
                [kinematic setJointOrientation:@"UpperArm.L" quaternion:progressQuat([upperArmL objectAtIndex:1], [upperArmL objectAtIndex:2], frameWindow)];

                
                [kinematic setJointOrientation:@"Foot.L" quaternion:progressQuat([footL         objectAtIndex:1], [footL     objectAtIndex:2], frameWindow)];
                [kinematic setJointOrientation:@"LowerLeg.L" quaternion:progressQuat([lowerLegL objectAtIndex:1], [lowerLegL objectAtIndex:2], frameWindow)];
                [kinematic setJointOrientation:@"UpperLeg.L" quaternion:progressQuat([upperLegL objectAtIndex:1], [upperLegL objectAtIndex:2], frameWindow)];
                
                [kinematic setJointOrientation:@"Foot.R" quaternion:progressQuat([footR         objectAtIndex:1], [footR     objectAtIndex:2], frameWindow)];
                [kinematic setJointOrientation:@"LowerLeg.R" quaternion:progressQuat([lowerLegR objectAtIndex:1], [lowerLegR objectAtIndex:2], frameWindow)];
                [kinematic setJointOrientation:@"UpperLeg.R" quaternion:progressQuat([upperLegR objectAtIndex:1], [upperLegR objectAtIndex:2], frameWindow)];

            } else if (frames < 15) {
                
                [kinematic setJointOrientation:@"Hand.R" quaternion:progressQuat([handR         objectAtIndex:2], [handR     objectAtIndex:3], frameWindow)];
                [kinematic setJointOrientation:@"LowerArm.R" quaternion:progressQuat([lowerArmR objectAtIndex:2], [lowerArmR objectAtIndex:3], frameWindow)];
                [kinematic setJointOrientation:@"UpperArm.R" quaternion:progressQuat([upperArmR objectAtIndex:2], [upperArmR objectAtIndex:3], frameWindow)];
                
                [kinematic setJointOrientation:@"Hand.L" quaternion:progressQuat([handL         objectAtIndex:2], [handL     objectAtIndex:3], frameWindow)];
                [kinematic setJointOrientation:@"LowerArm.L" quaternion:progressQuat([lowerArmL objectAtIndex:2], [lowerArmL objectAtIndex:3], frameWindow)];
                [kinematic setJointOrientation:@"UpperArm.L" quaternion:progressQuat([upperArmL objectAtIndex:2], [upperArmL objectAtIndex:3], frameWindow)];
                
                [kinematic setJointOrientation:@"Foot.L" quaternion:progressQuat([footL         objectAtIndex:2], [footL     objectAtIndex:3], frameWindow)];
                [kinematic setJointOrientation:@"LowerLeg.L" quaternion:progressQuat([lowerLegL objectAtIndex:2], [lowerLegL objectAtIndex:3], frameWindow)];
                [kinematic setJointOrientation:@"UpperLeg.L" quaternion:progressQuat([upperLegL objectAtIndex:2], [upperLegL objectAtIndex:3], frameWindow)];
                
                [kinematic setJointOrientation:@"Foot.R" quaternion:progressQuat([footR         objectAtIndex:2], [footR     objectAtIndex:3], frameWindow)];
                [kinematic setJointOrientation:@"LowerLeg.R" quaternion:progressQuat([lowerLegR objectAtIndex:2], [lowerLegR objectAtIndex:3], frameWindow)];
                [kinematic setJointOrientation:@"UpperLeg.R" quaternion:progressQuat([upperLegR objectAtIndex:2], [upperLegR objectAtIndex:3], frameWindow)];

            } else if (frames < 20) {
                
                [kinematic setJointOrientation:@"Hand.R" quaternion:progressQuat([handR objectAtIndex:3], [handR objectAtIndex:4], frameWindow)];
                [kinematic setJointOrientation:@"LowerArm.R" quaternion:progressQuat([lowerArmR objectAtIndex:3], [lowerArmR objectAtIndex:4], frameWindow)];
                [kinematic setJointOrientation:@"UpperArm.R" quaternion:progressQuat([upperArmR objectAtIndex:3], [upperArmR objectAtIndex:4], frameWindow)];
                
                [kinematic setJointOrientation:@"Hand.L" quaternion:progressQuat([handL objectAtIndex:3], [handL objectAtIndex:4], frameWindow)];
                [kinematic setJointOrientation:@"LowerArm.L" quaternion:progressQuat([lowerArmL objectAtIndex:3], [lowerArmL objectAtIndex:4], frameWindow)];
                [kinematic setJointOrientation:@"UpperArm.L" quaternion:progressQuat([upperArmL objectAtIndex:3], [upperArmL objectAtIndex:4], frameWindow)];
                
                [kinematic setJointOrientation:@"Foot.L" quaternion:progressQuat([footL objectAtIndex:3], [footL objectAtIndex:4], frameWindow)];
                [kinematic setJointOrientation:@"LowerLeg.L" quaternion:progressQuat([lowerLegL objectAtIndex:3], [lowerLegL objectAtIndex:4], frameWindow)];
                [kinematic setJointOrientation:@"UpperLeg.L" quaternion:progressQuat([upperLegL objectAtIndex:3], [upperLegL objectAtIndex:4], frameWindow)];
                
                [kinematic setJointOrientation:@"Foot.R" quaternion:progressQuat([footR objectAtIndex:3], [footR objectAtIndex:4], frameWindow)];
                [kinematic setJointOrientation:@"LowerLeg.R" quaternion:progressQuat([lowerLegR objectAtIndex:3], [lowerLegR objectAtIndex:4], frameWindow)];
                [kinematic setJointOrientation:@"UpperLeg.R" quaternion:progressQuat([upperLegR objectAtIndex:3], [upperLegR objectAtIndex:4], frameWindow)];


            } else if (frames < 25) {

                [kinematic setJointOrientation:@"Hand.R" quaternion:progressQuat([handR objectAtIndex:4], [handR objectAtIndex:5], frameWindow)];
                [kinematic setJointOrientation:@"LowerArm.R" quaternion:progressQuat([lowerArmR objectAtIndex:4], [lowerArmR objectAtIndex:5], frameWindow)];
                [kinematic setJointOrientation:@"UpperArm.R" quaternion:progressQuat([upperArmR objectAtIndex:4], [upperArmR objectAtIndex:5], frameWindow)];

                [kinematic setJointOrientation:@"Hand.L" quaternion:progressQuat([handL objectAtIndex:4], [handL objectAtIndex:5], frameWindow)];
                [kinematic setJointOrientation:@"LowerArm.L" quaternion:progressQuat([lowerArmL objectAtIndex:4], [lowerArmL objectAtIndex:5], frameWindow)];
                [kinematic setJointOrientation:@"UpperArm.L" quaternion:progressQuat([upperArmL objectAtIndex:4], [upperArmL objectAtIndex:5], frameWindow)];

                [kinematic setJointOrientation:@"Foot.L" quaternion:progressQuat([footL objectAtIndex:4], [footL objectAtIndex:5], frameWindow)];
                [kinematic setJointOrientation:@"LowerLeg.L" quaternion:progressQuat([lowerLegL objectAtIndex:4], [lowerLegL objectAtIndex:5], frameWindow)];
                [kinematic setJointOrientation:@"UpperLeg.L" quaternion:progressQuat([upperLegL objectAtIndex:4], [upperLegL objectAtIndex:5], frameWindow)];
                
                [kinematic setJointOrientation:@"Foot.R" quaternion:progressQuat([footR objectAtIndex:4], [footR objectAtIndex:5], frameWindow)];
                [kinematic setJointOrientation:@"LowerLeg.R" quaternion:progressQuat([lowerLegR objectAtIndex:4], [lowerLegR objectAtIndex:5], frameWindow)];
                [kinematic setJointOrientation:@"UpperLeg.R" quaternion:progressQuat([upperLegR objectAtIndex:4], [upperLegR objectAtIndex:5], frameWindow)];

                
            } else if (frames < 30) {
                
                [kinematic setJointOrientation:@"Hand.R" quaternion:progressQuat([handR objectAtIndex:5], [handR objectAtIndex:6], frameWindow)];
                [kinematic setJointOrientation:@"LowerArm.R" quaternion:progressQuat([lowerArmR objectAtIndex:5], [lowerArmR objectAtIndex:6], frameWindow)];
                [kinematic setJointOrientation:@"UpperArm.R" quaternion:progressQuat([upperArmR objectAtIndex:5], [upperArmR objectAtIndex:6], frameWindow)];

                [kinematic setJointOrientation:@"Hand.L" quaternion:progressQuat([handL objectAtIndex:5], [handL objectAtIndex:6], frameWindow)];
                [kinematic setJointOrientation:@"LowerArm.L" quaternion:progressQuat([lowerArmL objectAtIndex:5], [lowerArmL objectAtIndex:6], frameWindow)];
                [kinematic setJointOrientation:@"UpperArm.L" quaternion:progressQuat([upperArmL objectAtIndex:5], [upperArmL objectAtIndex:6], frameWindow)];
                
                [kinematic setJointOrientation:@"Foot.L" quaternion:progressQuat([footL objectAtIndex:5], [footL objectAtIndex:6], frameWindow)];
                [kinematic setJointOrientation:@"LowerLeg.L" quaternion:progressQuat([lowerLegL objectAtIndex:5], [lowerLegL objectAtIndex:6], frameWindow)];
                [kinematic setJointOrientation:@"UpperLeg.L" quaternion:progressQuat([upperLegL objectAtIndex:5], [upperLegL objectAtIndex:6], frameWindow)];
                
                [kinematic setJointOrientation:@"Foot.R" quaternion:progressQuat([footR objectAtIndex:5], [footR objectAtIndex:6], frameWindow)];
                [kinematic setJointOrientation:@"LowerLeg.R" quaternion:progressQuat([lowerLegR objectAtIndex:5], [lowerLegR objectAtIndex:6], frameWindow)];
                [kinematic setJointOrientation:@"UpperLeg.R" quaternion:progressQuat([upperLegR objectAtIndex:5], [upperLegR objectAtIndex:6], frameWindow)];


            } else if (frames < 35) {
                
                [kinematic setJointOrientation:@"Hand.R" quaternion:progressQuat([handR objectAtIndex:6], [handR objectAtIndex:7], frameWindow)];
                [kinematic setJointOrientation:@"LowerArm.R" quaternion:progressQuat([lowerArmR objectAtIndex:6], [lowerArmR objectAtIndex:7], frameWindow)];
                [kinematic setJointOrientation:@"UpperArm.R" quaternion:progressQuat([upperArmR objectAtIndex:6], [upperArmR objectAtIndex:7], frameWindow)];

                [kinematic setJointOrientation:@"Hand.L" quaternion:progressQuat([handL objectAtIndex:6], [handL objectAtIndex:7], frameWindow)];
                [kinematic setJointOrientation:@"LowerArm.L" quaternion:progressQuat([lowerArmL objectAtIndex:6], [lowerArmL objectAtIndex:7], frameWindow)];
                [kinematic setJointOrientation:@"UpperArm.L" quaternion:progressQuat([upperArmL objectAtIndex:6], [upperArmL objectAtIndex:7], frameWindow)];
                
                [kinematic setJointOrientation:@"Foot.L" quaternion:progressQuat([footL objectAtIndex:6], [footL objectAtIndex:7], frameWindow)];
                [kinematic setJointOrientation:@"LowerLeg.L" quaternion:progressQuat([lowerLegL objectAtIndex:6], [lowerLegL objectAtIndex:7], frameWindow)];
                [kinematic setJointOrientation:@"UpperLeg.L" quaternion:progressQuat([upperLegL objectAtIndex:6], [upperLegL objectAtIndex:7], frameWindow)];
                
                [kinematic setJointOrientation:@"Foot.R" quaternion:progressQuat([footR objectAtIndex:6], [footR objectAtIndex:7], frameWindow)];
                [kinematic setJointOrientation:@"LowerLeg.R" quaternion:progressQuat([lowerLegR objectAtIndex:6], [lowerLegR objectAtIndex:7], frameWindow)];
                [kinematic setJointOrientation:@"UpperLeg.R" quaternion:progressQuat([upperLegR objectAtIndex:6], [upperLegR objectAtIndex:7], frameWindow)];

            } else {
                
                [kinematic setJointOrientation:@"Hand.R" quaternion:progressQuat([handR objectAtIndex:7], [handR objectAtIndex:8], frameWindow)];
                [kinematic setJointOrientation:@"LowerArm.R" quaternion:progressQuat([lowerArmR objectAtIndex:7], [lowerArmR objectAtIndex:8], frameWindow)];
                [kinematic setJointOrientation:@"UpperArm.R" quaternion:progressQuat([upperArmR objectAtIndex:7], [upperArmR objectAtIndex:8], frameWindow)];

                [kinematic setJointOrientation:@"Hand.L" quaternion:progressQuat([handL objectAtIndex:7], [handL objectAtIndex:8], frameWindow)];
                [kinematic setJointOrientation:@"LowerArm.L" quaternion:progressQuat([lowerArmL objectAtIndex:7], [lowerArmL objectAtIndex:8], frameWindow)];
                [kinematic setJointOrientation:@"UpperArm.L" quaternion:progressQuat([upperArmL objectAtIndex:7], [upperArmL objectAtIndex:8], frameWindow)];
                
                [kinematic setJointOrientation:@"Foot.L" quaternion:progressQuat([footL objectAtIndex:7], [footL objectAtIndex:8], frameWindow)];
                [kinematic setJointOrientation:@"LowerLeg.L" quaternion:progressQuat([lowerLegL objectAtIndex:7], [lowerLegL objectAtIndex:8], frameWindow)];
                [kinematic setJointOrientation:@"UpperLeg.L" quaternion:progressQuat([upperLegL objectAtIndex:7], [upperLegL objectAtIndex:8], frameWindow)];
                
                [kinematic setJointOrientation:@"Foot.R" quaternion:progressQuat([footR objectAtIndex:7], [footR objectAtIndex:8], frameWindow)];
                [kinematic setJointOrientation:@"LowerLeg.R" quaternion:progressQuat([lowerLegR objectAtIndex:7], [lowerLegR objectAtIndex:8], frameWindow)];
                [kinematic setJointOrientation:@"UpperLeg.R" quaternion:progressQuat([upperLegR objectAtIndex:7], [upperLegR objectAtIndex:8], frameWindow)];

            }
        }
    }];    

    
    animators[1] = [_world createBlockAnimator];
    boneAnim = animators[1];
    
    [boneAnim setInterval:ipoAnim / 2];
    [boneAnim setDelay:0.00f]; 
    [boneAnim setProgress:harmonic];
    [boneAnim setAsyncProcessing:NO];
    [boneAnim addListener:^(float spanPos, NSNumber* event, int message) {
        if(active == walk) {
            
            float sp = spanPos / 14;
            [kinematic setJointOrientation:@"Neck" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:sp roll:0 ]];
            [kinematic setJointOrientation:@"Head" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:-sp roll:0 ]];
            [kinematic setJointOrientation:@"UpperBody" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:sp / 2 roll:0  ]];

        }
    }];    


    animators[2] = [_world createBlockAnimator];
    boneAnim = animators[2];
    
    [boneAnim setInterval:1.6f];
    [boneAnim setDelay:0]; 
    [boneAnim setProgress:harmonic];
    [boneAnim setAsyncProcessing:NO];
    [boneAnim addListener:^(float spanPos, NSNumber* event, int message) {
        if(active == walk) {
            [kinematic setJointOrientation:@"UpperTail" quaternion:[[YAQuaternion alloc] initEuler: -spanPos * 0.2  pitch:0 roll:0 ]];
            [kinematic setJointOrientation:@"LowerTail" quaternion:[[YAQuaternion alloc] initEuler: -spanPos * 0.5  pitch:0 roll:0 ]];

        }
    }];    

    
    ////////////////////////////////////////////////////////////////////
    __block float bodyAdjust = 0;
    
    
    animators[3] = [_world createBlockAnimator];
    boneAnim = animators[3];
    
    [boneAnim setProgress:harmonic];
    [boneAnim setInterval:0.8f];
    [boneAnim setDelay:0.00f];
    [boneAnim setAsyncProcessing:NO];
    [boneAnim addListener:^(float spanPos, NSNumber* event, int message) {
        if(active == parade) {
            [kinematic reset];
            float basicStep = spanPos + 0.5; // 0 .. 1
            
            basicStep *= 1.25f;
            basicStep -= 0.25f / 2;
            
            if(basicStep > 1)  basicStep = 1;
            if(basicStep < 0) basicStep = 0;
            
            float armMult = 0.7;
            float handMult = 0.6f;
            
            
            [kinematic setJointOrientation:@"LowerArm.R" quaternion:[[YAQuaternion alloc] initEuler:bodyAdjust pitch:(basicStep - 1)  * handMult  roll:  0 ]];
            [kinematic setJointOrientation:@"LowerArm.L" quaternion:[[YAQuaternion alloc] initEuler:bodyAdjust pitch:(-basicStep) * handMult  roll:  0 ]];

            
            [kinematic setJointOrientation:@"UpperArm.R" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:(-basicStep + 1) * armMult  roll:  0 ]];
            [kinematic setJointOrientation:@"UpperArm.L" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:basicStep * armMult  roll:  0 ]];
            
            [kinematic setJointOrientation:@"Hand.L" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:basicStep * -armMult  roll:  0 ]];
            [kinematic setJointOrientation:@"Hand.R" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:(-basicStep + 1) * -armMult  roll:  0 ]];

        }
    }];
    
    
    animators[4] = [_world createBlockAnimator];
    boneAnim = animators[4];
    
    [boneAnim setProgress:harmonic];
    [boneAnim setInterval:0.8f];
    [boneAnim setDelay:0.00f];
    [boneAnim setAsyncProcessing:NO];
    [boneAnim addListener:^(float spanPos, NSNumber* event, int message) {
        if(active == parade) {
            float basicStep = spanPos + 0.5; // 0 .. 1
            
            basicStep *= 1.25f;
            basicStep -= 0.25f / 2;
            
            if(basicStep > 1) basicStep = 1;
            if(basicStep < 0) basicStep = 0;
            
            float legMult = -0.5;
            float feetMult = -0.5f;
            float toeMult = - 0.7f;
            
            [kinematic setJointOrientation:@"LowerLeg.L" quaternion:[[YAQuaternion alloc] initEuler:bodyAdjust pitch:(basicStep - 1)  * feetMult  roll:  0 ]];
            [kinematic setJointOrientation:@"LowerLeg.R" quaternion:[[YAQuaternion alloc] initEuler:bodyAdjust pitch:(-basicStep) * feetMult  roll:  0 ]];
            
            [kinematic setJointOrientation:@"UpperLeg.L" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:(-basicStep + 1) * legMult  roll:  0 ]];
            [kinematic setJointOrientation:@"UpperLeg.R" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:basicStep * legMult  roll:  0 ]];
            
            [kinematic setJointOrientation:@"Foot.L" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:(-basicStep + 1)  * toeMult  roll:  0 ]];
            [kinematic setJointOrientation:@"Foot.R" quaternion:[[YAQuaternion alloc] initEuler:0 pitch:basicStep * toeMult  roll:  0 ]];
            
            
            [kinematic setJointOrientation:@"UpperTail" quaternion:[[YAQuaternion alloc] initEuler: -spanPos * 0.2  pitch:0 roll:0 ]];
            [kinematic setJointOrientation:@"LowerTail" quaternion:[[YAQuaternion alloc] initEuler: -spanPos * 0.5  pitch:0 roll:0 ]];

        }
    }];
    
    animators[5] = [_world createBlockAnimator];
    boneAnim = animators[5];
    
    [boneAnim setProgress:harmonic];
    [boneAnim setInterval:1.7f];
    [boneAnim setDelay:0.0f];
    [boneAnim setAsyncProcessing:NO];
    [boneAnim addListener:^(float spanPos, NSNumber* event, int message) {
        if(active == parade) {
            bodyAdjust = -(spanPos * 0.06f);
            [kinematic setJointOrientation:@"Head" quaternion:[[YAQuaternion alloc] initEuler:bodyAdjust * 3.0f pitch: 0.15 roll:  spanPos * 0.4 ]];
            
            [kinematic setJointOrientation:@"UpperBody" quaternion:[[YAQuaternion alloc] initEuler:-bodyAdjust pitch:0   roll:  spanPos / 5 ]];
        }
    }];    
    
}

- (void) cleanup
{
    for(int i = 0; i < 6; i++) {
        YABlockAnimator* anim = animators[i];
        anim.deleteme = YES;
        animators[i] = nil;
    }
    _world = nil;
    kinematic = nil;
    _impersonator = nil;
    
    upperArmL = nil;
    lowerArmL = nil;
    footL = nil;
    upperArmR = nil;
    lowerArmR = nil;
    footR = nil;
    upperLegL = nil;
    lowerLegL = nil;
    handL = nil;
    upperLegR = nil;
    lowerLegR = nil;
    handR = nil;
}

- (void) dealloc
{
    
}

@end
