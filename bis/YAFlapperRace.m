//
//  YAFlapperRace.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 03.09.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//
//#define async(cmds) dispatch_async(dispatch_get_main_queue(), ^{ cmds });
//#define sync(cmds) dispatch_sync(dispatch_get_main_queue(), ^{ cmds });

#define async(cmds) cmds
#define sync(cmds) cmds

#import "YARenderLoop.h"
#import "YAImpersonator+Physic.h"
#import "YAIngredient.h"
#import "YAMaterial.h"
#import "YAVector3f.h"
#import "YAFlapperMover.h"


#import "YAFlapperRace.h"

@implementation YAFlapperRace

- (id) initInWorld: (YARenderLoop*) world PlayerId: (int) id
{
    self = super.init;
    
    if(self) {
        playerId = id;
        _world = world;

        defaultSize = 0.17;
        
        NSString* model = @"Flapper";
        ingredient = [_world createIngredient:model];
        sync([ingredient setModelWithShader:model shader:@"ads_texture_bones"];)
        sync([_world addShapeShifter:model];)
        
        int raceId = [_world createImpersonatorWithShapeShifter: @"Flapper"];
        impersonator = [_world getImpersonator:raceId];
        [impersonator resize:0.17];
        [impersonator setVisible:true];
        [[impersonator rotation] setVector:[[YAVector3f alloc] initVals:-90 :0 :0] ];
        [[impersonator translation] setVector:[[YAVector3f alloc] initVals:-4  :0 :4] ];
        [[[impersonator material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
        [[[impersonator material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
        [[[impersonator material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
        [[impersonator material] setPhongShininess: 20];
        [impersonator setVisible:false];
        
        mover = [[YAFlapperMover alloc] initWithImp:impersonator inWorld:_world];
        [mover setActive:none];
        
        self.money = 1600;
        
        // Physics
        [impersonator setMass:@1.0];
        
        YAVector3f* cylinder = [[YAVector3f alloc]initVals:11.358 :13.903 :14.561];
        [cylinder mulScalar:0.5f];
        [impersonator setCylinderHalfExtents:cylinder];
        
        YAVector3f* offset = [[YAVector3f alloc]initVals:-0.14649 :7.28587 :0];
        [impersonator setCylinderOffset:offset];
 
    }
    
    return self;
}

@end
