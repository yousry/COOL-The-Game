//
//  YAMapEvents.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 31.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAQuaternion.h"
#import "YABulletEngineTranslator.h"
#import "YAChronograph.h"
#import "YAStore.h"
#import "YAChronograph.h"
#import "YADevelopmentAI.h"
#import "YAProbability.h"
#import "YAEvent.h"
#import "YAPerspectiveProjectionInfo.h"
#import "YATransformator.h"
#import "YASpotLight.h"
#import "YACommoditiesAuction.h"
#import "YAPlotAuction.h"
#import "YAMapManagement.h"
#import "YAGameContext.h"
#import "YATerrain.h"
#import "YAColonyMap.h"
#import "YARenderLoop.h"
#import "YAMaterial.h"
#import "YAVector3f.h"
#import "YABlockAnimator.h"
#import "YASceneUtils.h"
#import "YAEventChain.h"
#import "YAImpersonator.h"
#import "YAImpCollector.h"

#import "YAMapEvents.h"

#define PROBABILITY_AUCTION_ADVANCED_LEVEL 0.5f
#define ToDegree(x) ((x) * 180.0f / M_PI)

@implementation YAMapEvents {
    YAMapManagement* mapManagement;
    YAPlotAuction* plotAuction;
    YACommoditiesAuction* comodityAuction;
}


- (void) cleanUpBetweenStages: (YARenderLoop*) world
                  GameContext:(YAGameContext*) gameContext
                  Physics: (YABulletEngineTranslator*) be
                  ImpCollector: (YAImpCollector*) ic
{
    [world setActiveAnimation:NO];
    [world resetAnimators];
    [world removeAllAnimators];
    [world setActiveAnimation:YES];
    
    for (NSNumber* impId in [world getAllImpIds]) {
        YAImpersonator* imp = [world getImpersonator:impId.intValue];
        if([[imp ingredientName] hasPrefix:@"YAText2D"]) {
            [world removeImpersonator:impId.intValue];
        }
    }
    
    for(YAAlienRace* player in [gameContext playerGameData]) {
        [[player impersonator] setUseQuaternionRotation:NO];
        [player restartMover];
    }
    
    const float intervalTime = 5.0f;
    YABlockAnimator* nextStep = [world createBlockAnimator];
    [nextStep setInterval:intervalTime];
    [nextStep setAsyncProcessing:NO];
    [nextStep setDelay:0];
    __block float lastSP = -1;
    
    [nextStep addListener:^(float sp, NSNumber *event, int message) {
        if( lastSP >= 0) {
            float lastCall = lastSP < sp ? (sp - lastSP) : ((1.0 - lastSP) + sp);
            lastCall *= intervalTime;
            [be nextStep: lastCall];
        }
        lastSP = sp;
    }];
    
    YABlockAnimator* animRopes = [world createBlockAnimator];
    [animRopes setAsyncProcessing:NO];
    [animRopes addListener:^(float sp, NSNumber *event, int message) {
        NSArray* ropes = [be ropeDescriptions];
        
        YAVector3f* startSegment;
        int ropeSegmentIndex = 0;
        int starIndex = 0;
        
        for(NSArray* rope in ropes) {
            
            startSegment = [[ic.starImps objectAtIndex:starIndex++] translation];
            for(YAVector3f* nextSegment in [[rope reverseObjectEnumerator] allObjects]) {
                
                
                float stringLength = [startSegment distanceTo:nextSegment];
                YAImpersonator* starStringImp = [ic.ropeSegments objectAtIndex:ropeSegmentIndex++];
                
                starStringImp.visible = YES;
                [starStringImp resize:0.01];
                starStringImp.size.y = stringLength / 2;
                
                YAVector3f* pos = [[YAVector3f alloc] initCopy:nextSegment];
                [pos subVector:startSegment];
                
                [pos mulScalar:.5f];
                [pos addVector:startSegment];
                [[starStringImp translation] setVector:pos];
                
                
                YAVector3f* direction = [[YAVector3f alloc] initCopy:pos];
                [direction subVector:startSegment];
                [direction normalize];
                
                float rotZ = ToDegree(acosf([direction dotVector: [[YAVector3f alloc] initZAxe]]));
                float rotX = ToDegree(acosf([direction dotVector: [[YAVector3f alloc] initXAxe]]));
                YAQuaternion* quat = [[YAQuaternion alloc]initEulerDeg:0 pitch:90-rotZ roll: (90- rotX) * -1 ];
                [starStringImp setRotationQuaternion:quat];
                
                startSegment = nextSegment;
            }
        }
        
    }];
}

- (ListenerEvent) plotSelectionEvent
{
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Plot Selection Event");
        YASceneUtils* sceneUtils = [info objectForKey:@"SCENEUTILS"];
        YAImpCollector* ic = [info objectForKey:@"IMPCOLLECTOR"];
        YARenderLoop* world = [info objectForKey:@"WORLD"];
        YAColonyMap* colMap = [info objectForKey:@"COLONYMAP"];
        YAGameContext* gameContext = [info objectForKey:@"GAMECONTEXT"];
        YASoundCollector* sc = [info objectForKey:@"SOUNDCOLLECTOR"];
        YAEventChain* eventChain = [info objectForKey:@"EVENTCHAIN"];
        YABulletEngineTranslator* be = [info objectForKey:@"PHYSICS"];

        // Cleanup animations
        [self cleanUpBetweenStages:world GameContext:gameContext Physics:be ImpCollector:ic];
        
        float myTime = 0;
        
        if(![colMap getHouseGroupAtX:3 Z:3])
            [colMap buidlHouse:HOUSE_STORE forPlayer:PLAYER_STORE X:3 Z:3 At: (float) myTime];
        
        [sceneUtils hideImp:ic.boardTitleImp atTime:myTime];
        [sceneUtils showImp:ic.terrainImp atTime:myTime];
        [sceneUtils showImp:ic.cursorInnerImp atTime:myTime];
        [sceneUtils showImp:ic.cursorOuterImp atTime:myTime];
        [sceneUtils hideImp:ic.moonImp atTime:myTime];
        [sceneUtils hideImp:ic.sunImp atTime:myTime];
        [sceneUtils hideImp:ic.sunCoverImp atTime:myTime];
        [sceneUtils hideImp:ic.stickSunImp atTime:myTime];
        [sceneUtils hideImp:ic.stickMoonImp atTime:myTime];
        [sceneUtils showImp:ic.deskImp atTime:myTime];
        [sceneUtils showImp:ic.boardImp atTime:myTime];
        [sceneUtils hideImp:ic.spaceShipImp atTime:myTime];
        
        mapManagement = [[YAMapManagement alloc] init];
        
        assert(sceneUtils != nil);
        assert(world != nil);
        assert(ic.cursorInnerImp != nil);
        assert(ic.cursorOuterImp != nil);
        
        [mapManagement setSceneUtils:sceneUtils];
        [mapManagement setWorld:world];
        [mapManagement setCursorInnerImp:ic.cursorInnerImp];
        [mapManagement setCursorOuterImp:ic.cursorOuterImp];
        [mapManagement setColonyMap:colMap];
        [mapManagement setGameContext:gameContext];
        [mapManagement setSoundCollector:sc];
        
        [sceneUtils hideImp:ic.spaceShipImp atTime:myTime];
        [sceneUtils hideImp:ic.moonImp atTime:myTime];
        [sceneUtils hideImp:ic.sunImp atTime:myTime];
        [sceneUtils hideImp:ic.sunCoverImp atTime:myTime];

        myTime = [mapManagement selectPlots:myTime];
        
        [sceneUtils hideImp:ic.cursorInnerImp atTime:myTime];
        [sceneUtils hideImp:ic.cursorOuterImp atTime:myTime];
        
        YAChronograph* chronograph = [[YAChronograph alloc] init];
        [chronograph wait:myTime];
        
        if([[eventChain getEvent:@"plotAuction"] valid])
            [eventChain resetEvents:[NSArray arrayWithObject:@"plotAuction"]];
        else
            [eventChain startEvent:@"plotAuction"];
        
    };
    
    return listener;
    
}

- (ListenerEvent) comoditiesAuctionEvent
{
    
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Comodities Auction Event");
        
        YASceneUtils* sceneUtils = [info objectForKey:@"SCENEUTILS"];
        YAImpCollector* ic = [info objectForKey:@"IMPCOLLECTOR"];
        YAColonyMap* colMap = [info objectForKey:@"COLONYMAP"];
        YAEventChain* eventChain = [info objectForKey:@"EVENTCHAIN"];
        YAStore* store = [info objectForKey:@"STORE"];
        YARenderLoop* world = [info objectForKey:@"WORLD"];
        YAGameContext* gameContext = [info objectForKey:@"GAMECONTEXT"];
        YABulletEngineTranslator* be = [info objectForKey:@"PHYSICS"];
        
        // Cleanup animations
        [self cleanUpBetweenStages:world GameContext:gameContext Physics:be ImpCollector:ic];
        
        float myTime = 0;
        
        if(![colMap getHouseGroupAtX:3 Z:3]) {
            [colMap buidlHouse:HOUSE_STORE forPlayer:PLAYER_STORE X:3 Z:3 At:0];
            myTime += 0.4;
        }

        
        [sceneUtils setLightPosition:sceneUtils.spotLight to:LIGHT_ROOM_SPOT];
        [sceneUtils.spotLight spotAt:[[YAVector3f alloc] initVals:0 :0 :0]];
        
        [sceneUtils showImp:ic.terrainImp atTime:myTime];
        [sceneUtils showImp:ic.boardImp atTime:myTime];
        [sceneUtils hideImp:ic.tableImp atTime:myTime];
        
        [sceneUtils hideImp:ic.spaceShipImp atTime:myTime];
        [sceneUtils hideImp:ic.moonImp atTime:myTime];
        [sceneUtils hideImp:ic.sunImp atTime:myTime];
        [sceneUtils hideImp:ic.sunCoverImp atTime:myTime];
        [sceneUtils hideImp:ic.cursorInnerImp atTime:myTime];
        [sceneUtils hideImp:ic.cursorOuterImp atTime:myTime];
        [sceneUtils hideImp:ic.barrackImp atTime:myTime];
        [sceneUtils hideImp:ic.planeImp atTime:myTime];
        [sceneUtils hideImp:ic.boardTitleImp atTime:myTime];

        [sceneUtils updateFrustumTo:AVATAR_FRONT_GAMEBOARD At:myTime];
        myTime += 0.2;
        [sceneUtils updateSpotLightFrustum];
        myTime = [sceneUtils moveAvatarPositionTo:AVATAR_FRONT_GAMEBOARD At:myTime];
        myTime = [sceneUtils moveAvatarPositionTo:AVATAR_AUCTION At:myTime];

        comodityAuction =[[YACommoditiesAuction alloc] initInfo:info];
        YAChronograph *chronograph = [[YAChronograph alloc] init];
        [chronograph wait:myTime];
        
        
        // auction order
        // 1. Smithore
        // 2. Crystalite
        // 3. Food
        // 4. Energy
        
        myTime = [comodityAuction cleanBoard:YES];
        
//        YAGameContext* gameContext = [info objectForKey:@"GAMECONTEXT"];
//        YAAlienRace* player = [[gameContext playerGameData] objectAtIndex:2];
//        player.foodUnits += 5;
        
        [comodityAuction auctionFor: COMMODITY_SMITHORE];
        [comodityAuction auctionFor: COMMODITY_CRYSTALITE];
        [comodityAuction auctionFor: COMMODITY_FOOD];
        [comodityAuction auctionFor: COMMODITY_ENERGY];
        
        [chronograph wait: 1.0];
        myTime = [comodityAuction cleanBoard:NO];
        [sceneUtils updateFrustumTo:AVATAR_FRONT_GAMEBOARD At:myTime];
        [sceneUtils moveAvatarPositionTo:AVATAR_FRONT_GAMEBOARD At:myTime];
        
        [store produceCamels];
        
        // move to next state
        if([[eventChain getEvent:@"showScoreboard"] valid])
            [eventChain resetEvents:[NSArray arrayWithObject:@"showScoreboard"]];
        else
            [eventChain startEvent:@"showScoreboard"];

    };

    return listener;
}


- (ListenerEvent) plotAuctionEvent
{
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Plot Auction Event");
        
        
        
        YASceneUtils* sceneUtils = [info objectForKey:@"SCENEUTILS"];
        YAImpCollector* ic = [info objectForKey:@"IMPCOLLECTOR"];
        YARenderLoop* world = [info objectForKey:@"WORLD"];
        YAColonyMap* colMap = [info objectForKey:@"COLONYMAP"];
        YAGameContext* gameContext = [info objectForKey:@"GAMECONTEXT"];
        YAEventChain* eventChain = [info objectForKey:@"EVENTCHAIN"];
        YASoundCollector* soundCollector = [info objectForKey:@"SOUNDCOLLECTOR"];
        
        float doAuctionProbability = PROBABILITY_AUCTION_ADVANCED_LEVEL;
        bool doAuction = [YAProbability dice:doAuctionProbability];
        
        if(colMap.vacantPlots < 1 || gameContext.gameDifficulty == 0) {
            doAuction = 0;
        }
        
        if(! doAuction) { // directly move to next state
            if([[eventChain getEvent:@"developmentEvent"] valid]) {
                [eventChain resetEvents:[NSArray arrayWithObject: @"developmentEvent"]];
            } else {
                [eventChain startEvent:@"developmentEvent"];
            }
            return;
        }

        float myTime = 0;
        
        if(![colMap getHouseGroupAtX:3 Z:3]) {
            [colMap buidlHouse:HOUSE_STORE forPlayer:PLAYER_STORE X:3 Z:3 At:0];
            myTime += 0.4;
        }
        
        
        [sceneUtils setLightPosition:sceneUtils.spotLight to:LIGHT_ROOM_SPOT];
        [sceneUtils.spotLight spotAt:[[YAVector3f alloc] initVals:0 :0 :0]];
        
        [sceneUtils showImp:ic.terrainImp atTime:myTime];
        [sceneUtils showImp:ic.boardImp atTime:myTime];
        [sceneUtils hideImp:ic.tableImp atTime:myTime];
        
        [sceneUtils hideImp:ic.spaceShipImp atTime:myTime];
        [sceneUtils hideImp:ic.moonImp atTime:myTime];
        [sceneUtils hideImp:ic.sunImp atTime:myTime];
        [sceneUtils hideImp:ic.sunCoverImp atTime:myTime];
        [sceneUtils hideImp:ic.cursorInnerImp atTime:myTime];
        [sceneUtils hideImp:ic.cursorOuterImp atTime:myTime];
        [sceneUtils hideImp:ic.barrackImp atTime:myTime];
        [sceneUtils hideImp:ic.planeImp atTime:myTime];
        [sceneUtils hideImp:ic.boardTitleImp atTime:myTime];
        
        myTime = [sceneUtils moveAvatarPositionTo:AVATAR_FRONT_GAMEBOARD At:myTime];
        
        [sceneUtils updateFrustumTo:AVATAR_FRONT_GAMEBOARD At:myTime - 0.2];
        
        YADevelopmentAI* developmentAI = [[YADevelopmentAI alloc] initInfo:info];
        
        // TODO: reusage of plotAuction
        plotAuction = [[YAPlotAuction alloc] init];
        [plotAuction setSoundCollector:soundCollector];

        [plotAuction setSceneUtils:sceneUtils];
        [plotAuction setWorld:world];
        [plotAuction setColonyMap:colMap];
        [plotAuction setGameContext:gameContext];
        [plotAuction setTerrainImp:ic.terrainImp];
        [plotAuction setBarrackImp:ic.barrackImp];
        [plotAuction setPlaneImp:ic.planeImp];
        [plotAuction setStickSunImp:ic.stickSunImp];
        [plotAuction setDevelopmentAI:developmentAI];
        
        [plotAuction setSunImp:ic.sunImp];
        [plotAuction setSunCoverImp:ic.sunCoverImp];
        
        [plotAuction setBoardImp:ic.boardImp];
        [plotAuction setBoardTitleImp:ic.boardTitleImp];
        
        
        gameContext.lastAuction += 1;
        [plotAuction setAuctionNumber:gameContext.lastAuction];
        myTime = [plotAuction auction: myTime];
        [sceneUtils showImp:ic.tableImp atTime:myTime];
        myTime = [sceneUtils moveAvatarPositionTo:AVATAR_FRONT_GAMEBOARD At:myTime];
        
        
        NSNumber* eventDevelopProbability = @3.0;
        
        NSArray* const events = [NSArray arrayWithObjects:
                                 [NSMutableArray arrayWithObjects:@"developmentEvent", eventDevelopProbability, nil],
                                 [NSMutableArray arrayWithObjects:@"plotAuction", @1.0f, nil],
                                 nil];

        NSString* nextEvent = [YAProbability randomSelect:events];

        YABlockAnimator* realtimeTrigger = [world createBlockAnimator];
        realtimeTrigger.oneExecution = YES;
        realtimeTrigger.delay = myTime;
        [realtimeTrigger addListener:^(float sp, NSNumber *event, int message) {
            if([[eventChain getEvent:nextEvent] valid]) {
                [eventChain resetEvents:[NSArray arrayWithObject: nextEvent]];
            } else {
                [eventChain startEvent:nextEvent];
            }
        }];
        
    };
    
    return listener;
}


@end
