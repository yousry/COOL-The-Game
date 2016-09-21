//
//  YAEagleFlightEvents.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 01.01.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import "YAGameContext.h"
#import "YAInterpolationAnimator.h"
#import "YAGouradLight.h"
#import "YASpotLight.h"
#import "YASoundCollector.h"
#import "YAOpenAL.h"
#import "YAEagleController.h"
#import "YABulletEngineTranslator.h"
#import "YAQuaternion.h"
#import "YAEagleAssembler.h"
#import "YAImpGroup.h"
#import "YAGameContext.h"
#import "YATerrain.h"
#import "YAColonyMap.h"
#import "YARenderLoop.h"
#import "YAMaterial.h"
#import "YAVector3f.h"
#import "YABlockAnimator.h"
#import "YASceneUtils.h"
#import "YAEventChain.h"
#import "YAImpersonator+Physic.h"
#import "YAImpCollector.h"

#import "YAEagleFlightEvents.h"

@implementation YAEagleFlightEvents 

- (ListenerEvent) flyEvent
{
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Eagle Fly Event");
        
        __block float myTime = 0;
        
        YASceneUtils* sceneUtils = [info objectForKey:@"SCENEUTILS"];
        YARenderLoop* world = [info objectForKey:@"WORLD"];
        YABulletEngineTranslator* be = [info objectForKey:@"PHYSICS"];
        YAImpCollector* ic = [info objectForKey:@"IMPCOLLECTOR"];
        YASoundCollector* sc = [info objectForKey:@"SOUNDCOLLECTOR"];
        YAColonyMap* colMap = [info objectForKey:@"COLONYMAP"];
        YATerrain* terrain = [info objectForKey:@"TERRAIN"];
        YAEventChain* eventChain = [info objectForKey:@"EVENTCHAIN"];
        YAGameContext* gameContext = [info objectForKey:@"GAMECONTEXT"];
        
        // preconditions
        [world setDrawScene:false];

        ic.terrainImp.visible = YES;
        ic.boardImp. visible = YES;
        ic.boardTitleImp.visible = NO;
        
        // TODO: Get player from Info Dictionary
        int activePlayer = [gameContext activePlayer];
        if(activePlayer == -1)
            return;
        
        NSMutableArray* physicImps = be.physicImps;
        
        if(![colMap getHouseGroupAtX:3 Z:3])
            [colMap buidlHouse:HOUSE_STORE forPlayer:PLAYER_STORE X:3 Z:3 At: (float) myTime];
        
        // reset lights
        // Set Light position and radiation
        [sceneUtils setLightPosition:sceneUtils.light to:LIGHT_NOON_RELAXED];
        
        [sceneUtils setRadiation:sceneUtils.light to:EMISSION_WHITE_FULL];
        [[sceneUtils light] setDirectional:true];
        
        // Set Spotlight position, cutoff and radiation
        [sceneUtils setLightPosition:sceneUtils.spotLight to:LIGHT_ROOM_SPOT];
        [sceneUtils.spotLight.direction setVector:[[YAVector3f alloc] initVals: -0.333625 : -0.940831 : 0.059562]];
        
        [sceneUtils.spotLight setCutoff:2.5];
        [sceneUtils.spotLight setExponent:3000];
        [sceneUtils setRadiation:sceneUtils.spotLight to:EMISSION_ARTIFICIAL_FULL];
        
        if(ic.eagleGroup == nil) {
            eagleGroup = [[YAImpGroup alloc] init];
            [YAEagleAssembler buildEagle:world Group:(YAImpGroup*)eagleGroup];
            [eagleGroup setCollisionName:@"eagle"];
            ic.eagleGroup = (YAImpGroup*)eagleGroup;
        } else {
            eagleGroup = ic.eagleGroup;
        }
        
        [eagleGroup setSize: [[YAVector3f alloc] initVals:1 :1 :1]];
        
        YAVector3f* fPos = [[YAVector3f alloc] initCopy:[[colMap getHouseGroupAtX:3 Z:3] translation]];
        fPos.x += 0.22978;
        fPos.y += 0.03042;
        [eagleGroup setTranslation:fPos];
        
        
        YABlockAnimator* moveToStart = [world createBlockAnimator];
        [moveToStart setDelay:myTime];
        [moveToStart setInterval:1.5];
        [moveToStart setOnce:YES];
        [moveToStart setOnceReset:NO];
        [moveToStart setProgress:damp];
        [moveToStart setAsyncProcessing:NO];
        
        __block YAQuaternion* startQuat = eagleGroup.rotationQuaternion;
        __block YAVector3f* endTranslation = [[YAVector3f alloc] initVals:0.2 :2 :-0.05];
        __block YAVector3f* startTranslation = eagleGroup.translation;
        
        const float startRotation = startQuat.y;
        const float endRotation = 0;
        
        [moveToStart addListener:^(float sp, NSNumber *event, int message) {
            
            float x = [startTranslation x] + (([endTranslation x] - [startTranslation x]) * sp);
            float y = [startTranslation y] + (([endTranslation y] - [startTranslation y]) * sp);
            float z = [startTranslation z] + (([endTranslation z] - [startTranslation z]) * sp);
            
            float rotation = startRotation + ((endRotation - startRotation) * sp);
            
            __block YAVector3f* tsl = [[YAVector3f alloc] initVals:x :y :z];
            [eagleGroup setTranslation:tsl];

            [[eagleGroup rotationQuaternion] setY:rotation];
        }];
        
        __block NSString* wp = @"withPod";
        [eagleGroup setState:wp];

        __block NSString* wo = @"withoutPod";
        [[colMap getHouseGroupAtX:3 Z:3] setState:wo];
        
        myTime = fmax([sceneUtils moveAvatarPositionTo:AVATAR_EAGLE At:myTime], myTime + 0.5);
        [sceneUtils updateFrustumTo:AVATAR_EAGLE At:myTime];
        [sceneUtils updateSpotLightFrustum];
        
        [eagleGroup setMass:@1.0f];
        [eagleGroup setGravity:[[YAVector3f alloc] initVals:0 :0 :0]];
        [eagleGroup setBoxHalfExtents:[[YAVector3f alloc] initVals:0.255 * 0.5 :0.113 * 0.5 :0.654 * 0.5]];
        [eagleGroup setBoxOffset: [[YAVector3f alloc] initVals:0 :0.05646 :0.001388]];
        
        
        if(![physicImps containsObject:eagleGroup])
            [physicImps addObject:eagleGroup];
        
        
        int i = 0;
        for(YAImpersonator* starImp in ic.starImps) {
        
            [starImp setUseQuaternionRotation:true];
            
            if(i == 0) {
                [[starImp translation] setValues:-5.543136 :4.250978 :-0.149020];
                [[starImp rotation] setZ: 30];
                [starImp setRotationQuaternion:[[YAQuaternion alloc] initEuler:0 pitch:0 roll:30]];
            } else if (i == 1) {
                [[starImp translation] setValues:-6.747066 :3.449020 :-0.807845];
                [[starImp rotation] setZ: 55];
                [starImp setRotationQuaternion:[[YAQuaternion alloc] initEuler:0 pitch:0 roll:55]];
            } else if (i == 2) {
                [[starImp translation] setValues:-4.462750 :3.245075 :1.149022];
                [[starImp rotation] setZ: 0];
                [starImp setRotationQuaternion:[[YAQuaternion alloc] initEuler:0 pitch:0 roll:0]];
            }
            i++;
            
            [starImp setMass:@0.5f];
            [starImp setHulls:[[NSArray alloc] initWithObjects:@"StarHull", @"StarHull.001", @"StarHull.002", @"StarHull.003", nil]];
            
            if(![physicImps containsObject:starImp])
                [physicImps addObject:starImp];
        }
        
        [be restart];
        
        // add ropes to stars
        for(YAImpersonator* starImp in ic.starImps) {
            YAVector3f* from = [[YAVector3f alloc] initCopy:[starImp translation]];
            YAVector3f* to = [[YAVector3f alloc] initCopy:[starImp translation]];
            from.y = 8;
            to.y += 2;
            [be addRopeFor:starImp.identifier top:from anchor:to];
        }
        
        [eagleGroup setState:@"withPod"];
        [[colMap getHouseGroupAtX:3 Z:3] setState:@"withoutPod"];
        
        
        if(!eac) {
            eac = [[YAEagleController alloc] initFor:(YAImpGroup*)eagleGroup
                                             inWorld:world
                                           colonyMap:colMap
                                            flyAbove:ic.terrainImp
                                           withUtils:sceneUtils
                                          forTerrain:terrain
                                          withPhysic:be
                                      soundCollector:sc
                                          eventChain:eventChain
                                        impCollector:ic
                                         gameContext:gameContext];
        }
        
        [sc.soundHandler setVolume:[sc getSoundId:@"EagleBackDrive"] gain:0.25];
        [sc.soundHandler setVolume:[sc getSoundId:@"EagleEngine"] gain:0.08];
        
        [world setDrawScene:YES];
        [eac fly:YES at: myTime withPlayer:activePlayer];
    };
    
    return listener;
}


@end
