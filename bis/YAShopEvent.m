//
//  YAShopEvent.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 01.01.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import "YASpotLight.h"
#import "YABlockAnimator.h"
#import "YAStore.h"
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
#import "YASoundCollector.h"

#import "YAShopEvent.h"

@implementation YAShopEvent {
    YAImpGroup* eagleGroup;
}



- (id) init
{
    self = [super init];
    
    if (self) {
        eagleGroup = nil;
    }
    
    return self;
}

- (ListenerEvent) shopEvent
{
    ListenerEvent listener =  ^(NSDictionary *info) {
        // NSLog(@"Shopping Event");
        
        float myTime = 0;
        
        YASceneUtils* sceneUtils = [info objectForKey:@"SCENEUTILS"];
        YARenderLoop* world = [info objectForKey:@"WORLD"];
        YABulletEngineTranslator* be = [info objectForKey:@"PHYSICS"];
        YAImpCollector* ic = [info objectForKey:@"IMPCOLLECTOR"];
        YAColonyMap* colMap = [info objectForKey:@"COLONYMAP"];
        YAGameContext* gameContext = [info objectForKey:@"GAMECONTEXT"];
        __block YAStore* store = [info objectForKey:@"STORE"];
        YASoundCollector* soundCollector = [info objectForKey:@"SOUNDCOLLECTOR"];
        
        // preconditions
        [colMap resetFabs];
        [soundCollector stopAllSounds];
        
        if(![colMap getHouseGroupAtX:3 Z:3]) {
            [colMap buidlHouse:HOUSE_STORE forPlayer:PLAYER_STORE X:3 Z:3 At: (float) myTime];
            myTime += 0.5;
        }
       
        YABlockAnimator* triggerAtRuntime = [world createBlockAnimator];
        [triggerAtRuntime setDelay:myTime];
        [triggerAtRuntime setOneExecution:true];
        [triggerAtRuntime addListener:^(float sp, NSNumber *event, int message) {
            if(eagleGroup == nil) {
                if(ic.eagleGroup == nil) {
                    eagleGroup = [[YAImpGroup alloc] init];
                    [YAEagleAssembler buildEagle:world Group:eagleGroup];
                    [eagleGroup setCollisionName:@"eagle"];
                    ic.eagleGroup = eagleGroup;
                } else {
                    eagleGroup = ic.eagleGroup;
                }
            }
            
            NSAssert(eagleGroup, @"eagleGroup should not be null.");
            
            YAVector3f* fPos = [[YAVector3f alloc] initCopy:[[colMap getHouseGroupAtX:3 Z:3] translation]];
            fPos.x += 0.22978;
            fPos.y += 0.03042;
            
            [eagleGroup setTranslation:fPos];
            eagleGroup.state = @"withPod";
            
            ic.podImp.visible = false;
        }];


        NSMutableArray* physicImps = be.physicImps;
        
        // TODO: Get player from Info Dictionary
        __block int activePlayer = [gameContext activePlayer];
        if(activePlayer == -1)
            return;

        myTime = [store showShopAt:myTime + 0.8];
        myTime += 0.4;

        triggerAtRuntime = [world createBlockAnimator];
        [triggerAtRuntime setDelay:myTime];
        [triggerAtRuntime setOneExecution:true];
        [triggerAtRuntime addListener:^(float sp, NSNumber *event, int message) {

            
            YAVector3f* shopPos = [[colMap getHouseGroupAtX:3 Z:3] translation];
            [sceneUtils setPoi:shopPos];
            [sceneUtils setLightPosition:[sceneUtils spotLight] to:LIGHT_RELATIVE_POI];
            [[sceneUtils spotLight] spotAt:[colMap getHouseGroupAtX:3 Z:3].translation];

            sceneUtils.spotLight.cutoff = 25;
            sceneUtils.spotLight.exponent = 4;
            
            [sceneUtils updateFrustumTo:AVATAR_RELATIV_POI];
            [sceneUtils updateSpotLightFrustum];
        }];
        
        triggerAtRuntime = [world createBlockAnimator];
        [triggerAtRuntime setDelay:myTime];
        [triggerAtRuntime setOneExecution:true];
        [triggerAtRuntime addListener:^(float sp, NSNumber *event, int message) {
            
            if(eagleGroup == nil) {
                if(ic.eagleGroup == nil) {
                    eagleGroup = [[YAImpGroup alloc] init];
                    [YAEagleAssembler buildEagle:world Group:eagleGroup];
                    [eagleGroup setCollisionName:@"eagle"];
                    ic.eagleGroup = eagleGroup;
                } else {
                    eagleGroup = ic.eagleGroup;
                }
            }

            NSAssert(eagleGroup, @"eagleGroup should not be null.");
            
            [eagleGroup setVisible:YES];
            [eagleGroup setState:@"withoutPod"];
            [[colMap getHouseGroupAtX:3 Z:3] setState:@"withPod"];
            
            YAVector3f* fPos = [[YAVector3f alloc] initCopy:[[colMap getHouseGroupAtX:3 Z:3] translation]];
            fPos.x += 0.22978;
            fPos.y += 0.03042;
            
            [eagleGroup setTranslation:fPos];
            [eagleGroup setMass:0]; // in the shop scene the eagle is static
            [eagleGroup setGravity:[[YAVector3f alloc] initVals:0 :0 :0]];
            [eagleGroup setBoxHalfExtents:[[YAVector3f alloc] initVals:0.255 * 0.5 :0.113 * 0.5 :0.654 * 0.5]];
            [eagleGroup setBoxOffset: [[YAVector3f alloc] initVals:0 :0.05646 :0.001388]];
            
            if(eagleGroup.rotation.y > 90 && eagleGroup.rotation.y < 270) {
                eagleGroup.rotation.y = 180;
                [eagleGroup setRotationQuaternion:[[YAQuaternion alloc] initEulerDeg:180 pitch:0 roll:0]];
            }else {
                eagleGroup.rotation.y = 0;
                [eagleGroup setRotationQuaternion:[[YAQuaternion alloc] init]];
            }
            
            if(![physicImps containsObject:eagleGroup])
                [physicImps addObject:eagleGroup];
            
            float scale = 23.0;
            [world rescaleScene:scale];
            // NSLog(@"World Rescaled");
            
            
            // avoid observer notification by indirect access / imps already scaled
            [[eagleGroup size] mulScalar:scale];
            [[eagleGroup translation] mulScalar:scale];

            
            NSAssert(be, @"Bullet Physic Engine not initialized.");
            
            if(![store.contactImps containsObject:eagleGroup])
                [[store contactImps] addObject:eagleGroup];
            
            [store setEnvironment:be];
            [store activatePodDoor:0];
            [store goShoppingWith:activePlayer];
            
            if(!be.setupScene)
                [be restart];
            
            // add ropes to stars
            for(YAImpersonator* starImp in ic.starImps) {
                YAVector3f* from = [[YAVector3f alloc] initCopy:[starImp translation]];
                YAVector3f* to = [[YAVector3f alloc] initCopy:[starImp translation]];
                from.y = 8;
                to.y += 2;
                [be addRopeFor:starImp.identifier top:from anchor:to];
            }
        }];
    };
    
    return listener;
}


@end
