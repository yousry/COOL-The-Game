//
//  YAMainEvents.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 29.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YALog.h"
#import "YAEvent.h"
#import "YAAvatar.h"
#import "YAQuaternion.h"
#import "YAOpenAL.h"
#import "YASoundCollector.h"
#import "YAInterpolationAnimator.h"
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
#import "YAMainEvents.h"

@implementation YAMainEvents {
    YAImpersonator* textLandingInfo;
}


- (ListenerEvent) standByEvent
{

    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Stand By Event");

        YAImpCollector* ic = [info objectForKey:@"IMPCOLLECTOR"];
        YAEventChain* eventChain = [info objectForKey:@"EVENTCHAIN"];
        YASceneUtils* sceneUtils = [info objectForKey:@"SCENEUTILS"];
        YARenderLoop* world = [info objectForKey:@"WORLD"];
        YASoundCollector* sc = [info objectForKey:@"SOUNDCOLLECTOR"];
        
        [ic.terrainImp setVisible:true];
        [ic.cursorInnerImp setVisible:false];
        [ic.cursorOuterImp setVisible:false];
        [ic.moonImp setVisible:false];
        [ic.sunImp setVisible:false];
        [ic.sunCoverImp setVisible:false];
        [ic.deskImp setVisible:true];
        [ic.boardImp setVisible:true];
        [ic.boardTitleImp setVisible:false];
        [ic.spaceShipImp setVisible:false];
        [ic.barrackImp setVisible:false];
        [ic.planeImp setVisible:false];

        // Flat ground
        [ic.terrainImp setNormalMapFactor:0];

        YAInterpolationAnimator* ipo = [world createInterpolationAnimator];
        [ipo addIpo:[[YAVector3f alloc] initVals:127.0 / 102.0 :108.0 / 98.0 :59.0 / 36.0]  timeFrame:0.0f];
        [ipo addIpo:[[YAVector3f alloc] initVals:0.6 :0.6 :0.6]  timeFrame:0.5f];
        [ipo addListener:[[ic.terrainImp material] phongAmbientReflectivity]];

        NSString* landingInfo = [YALog decode:@"landingInfo"];
        textLandingInfo = [sceneUtils genTextBlocked:landingInfo];
        [textLandingInfo setVisible:false];

        [textLandingInfo resize:0.20];
        [[textLandingInfo translation] setVector:[[YAVector3f alloc] initVals:-0.8 :0.5 :5]];
        [[textLandingInfo material] setEta:0.31];

        [[[textLandingInfo material] phongAmbientReflectivity] setVector:sceneUtils.color_yellow];
        [sc.soundHandler setVolume:[sc getSoundId:@"Chirp"] gain:1.0];
        [sc playForImp:ic.terrainImp Sound:[sc getSoundId:@"Chirp"]];
        
        [sceneUtils alignToCam:textLandingInfo];
        [sceneUtils scrollText:textLandingInfo atTime:0];
        [sceneUtils showImp:textLandingInfo atTime:0.01];

        
        __block YABlockAnimator* landGrow;
        landGrow = [world createBlockAnimator];
        [landGrow setOnce:true];
        [landGrow setOnceReset:false];
        [landGrow setInterval:1.0];
        [landGrow setDelay:0.5];
        [landGrow setProgress:accelerate];
        [landGrow addListener:^(float sp, NSNumber *event, int message) {
            [ic.terrainImp setNormalMapFactor:sp];
        }];
        
       [eventChain startEvent:@"setupStore" At:1.5];

    };

    return listener;
}

- (ListenerEvent) setupStoreEvent
{
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Setup Store Event");
        
        YAImpCollector* ic = [info objectForKey:@"IMPCOLLECTOR"];
        YAEventChain* eventChain = [info objectForKey:@"EVENTCHAIN"];
        YAColonyMap* colMap = [info objectForKey:@"COLONYMAP"];
        YASoundCollector* sc = [info objectForKey:@"SOUNDCOLLECTOR"];
        YARenderLoop* world = [info objectForKey:@"WORLD"];

        
        [ic.boardTitleImp setVisible:NO];
        [ic.boardImp setVisible:YES];
        [ic.terrainImp setVisible:YES];
        
        if(![colMap getHouseGroupAtX:3 Z:3])
            [colMap buidlHouse:HOUSE_STORE forPlayer:PLAYER_STORE X:3 Z:3 At: 0];
       
        YABlockAnimator* delayedSound = [world createBlockAnimator];
        [delayedSound setOneExecution:YES];
        [delayedSound setDelay:0.4];
        [delayedSound addListener:^(float sp, NSNumber *event, int message) {
            [sc playForImp:ic.terrainImp Sound:[sc getSoundId:@"Pickup"]];
        }];
        

        int jingleId = [sc getJingleId:@"melodyG"];
        [sc playJingle: jingleId];
        
        [eventChain startEvent:@"spaceshipLands" At:0.8];
    };
    
    return listener;
}

- (ListenerEvent) spaceshipStartEvent
{
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Spaceship Start Event");
        
        YAImpCollector* ic = [info objectForKey:@"IMPCOLLECTOR"];
        YARenderLoop* world = [info objectForKey:@"WORLD"];
        YAColonyMap* colMap = [info objectForKey:@"COLONYMAP"];

        float myTime = 0;
        
        // start again
        YABlockAnimator* blockAnim = [world createBlockAnimator];
        [blockAnim setProgress:PROGRESS_SLOW_ACCELERATE_DECELERATE];
        [blockAnim setInterval:2];
        [blockAnim setOnce:true];
        [blockAnim setOnceReset:false];
        [blockAnim setDelay:myTime];
        [blockAnim addListener:^(float sp, NSNumber *event, int message) {
            
            float height = [colMap worldHeightX:3 Z:3];
            height += 0.25;
            
            [[ic.spaceShipImp translation] setY: height +  sp * (3 - height)];
            [[ic.spaceShipImp rotation] setY:-90 + ((1 - sp) * 90)];
            [ic.spaceShipImp resize: 0.1 + sp * (0.25 - 0.1) ];
        }];

        myTime += 2.1;
        
        YAInterpolationAnimator* ipo = [world createInterpolationAnimator];
        [ipo setDelay:myTime];
        [ipo addListener:ic.spaceShipImp.rotation];
        // Rotation_Euler
        [ipo addIpo:[[YAVector3f alloc] initVals:-90.0f :270 : 0.0f] timeFrame: 0 ];
        [ipo addIpo:[[YAVector3f alloc] initVals:-122.860909 :316.932678 : -50.330395] timeFrame: 1.0f ];
        [ipo addIpo:[[YAVector3f alloc] initVals:-90.0f :360 : 0.0f] timeFrame: 2.0f ];

        blockAnim = [world createBlockAnimator];
        [blockAnim setProgress:accelerate];
        [blockAnim setInterval:2];
        [blockAnim setOnce:true];
        [blockAnim setOnceReset:false];
        [blockAnim setDelay:myTime];
        [blockAnim addListener:^(float sp, NSNumber *event, int message) {
            float distX =  -sp;
            float distY = -1 + cos(distX * M_PI * 0.5);
            
            [[ic.spaceShipImp translation] setX:distX * 10];
            [[ic.spaceShipImp translation] setZ: distY * 10];
        }];
    };

    return listener;
    
}


- (ListenerEvent) spaceshipLandEvent
{
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Spaceship Land Event");
        
        YAImpCollector* ic = [info objectForKey:@"IMPCOLLECTOR"];
        YAEventChain* eventChain = [info objectForKey:@"EVENTCHAIN"];
        YASceneUtils* sceneUtils = [info objectForKey:@"SCENEUTILS"];
        YARenderLoop* world = [info objectForKey:@"WORLD"];
        YAColonyMap* colMap = [info objectForKey:@"COLONYMAP"];
        
        [ic.boardImp setVisible:YES];
        [ic.boardTitleImp setVisible:NO];
        [ic.terrainImp setVisible:YES];
        [ic.spaceShipImp setVisible:NO];

        
        float myTime = 0;
        
        if(![colMap getHouseGroupAtX:3 Z:3])
            [colMap buidlHouse:HOUSE_STORE forPlayer:PLAYER_STORE X:3 Z:3 At: (float) myTime];
        
        [sceneUtils removeImp:textLandingInfo atTime:myTime];
        
        [[ic.spaceShipImp translation] setY:3];
        [sceneUtils showImp:ic.spaceShipImp atTime:myTime + 0.1];

        YAInterpolationAnimator* ipo = [world createInterpolationAnimator];
        [ipo addListener:ic.spaceShipImp.rotation];
        // Rotation_Euler
        [ipo addIpo:[[YAVector3f alloc] initVals:-90.0f :180.00000500895632f : -0.0f] timeFrame: 0 ];
        [ipo addIpo:[[YAVector3f alloc] initVals:-67.086357 :206.257645 : 48.592098] timeFrame: 1.0f ];
        [ipo addIpo:[[YAVector3f alloc] initVals:-90.0f :270.00000068324533f : -0.0f] timeFrame: 2.0f ];
        
        YABlockAnimator* blockAnim = [world createBlockAnimator];
        [blockAnim setProgress:damp];
        [blockAnim setInterval:2];
        [blockAnim setOnce:true];
        [blockAnim setOnceReset:false];
        [blockAnim setDelay:myTime];
        [blockAnim setAsyncProcessing:NO];
        [blockAnim addListener:^(float sp, NSNumber *event, int message) {
            float distX =  1 - sp;
            float distY = -1 + cos(distX * M_PI * 0.5);
            [[ic.spaceShipImp translation] setX:distX * 10];
            [[ic.spaceShipImp translation] setZ: distY * 10];
        }];
        
        
        myTime += 2.1;
        
        blockAnim = [world createBlockAnimator];
        [blockAnim setProgress:PROGRESS_SLOW_ACCELERATE_DECELERATE];
        [blockAnim setInterval:1.3];
        [blockAnim setOnce:true];
        [blockAnim setOnceReset:false];
        [blockAnim setDelay:myTime];
        [blockAnim setAsyncProcessing:NO];
        [blockAnim addListener:^(float sp, NSNumber *event, int message) {
            float height = [colMap worldHeightX:3 Z:3];
            height += 0.25;
            
            [[ic.spaceShipImp translation] setY: height +  (1 - sp) * (3 - height)];
            [[ic.spaceShipImp rotation] setY:-90 + (sp * 90)];
            [ic.spaceShipImp resize: 0.1 +  (1 - sp) * (0.25 - 0.1) ];
        }];
        
        [eventChain startEvent:@"showScoreboard" At:1.7];
        [eventChain startEvent:@"spaceshipStarts" At:6.5];
    };
    
    return listener;
}


- (ListenerEvent) showScoreBoardEvent
{
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Show Score Board Event");
        float myTime = 0;
        YASceneUtils* sceneUtils = [info objectForKey:@"SCENEUTILS"];
        YAGameContext* gameContext = [info objectForKey:@"GAMECONTEXT"];
        YAEventChain* eventChain = [info objectForKey:@"EVENTCHAIN"];

        [sceneUtils showScoreBoard:gameContext At:myTime];
        myTime += 2;
        
        [sceneUtils updateFrustumTo:AVATAR_SCORE At:myTime];
        myTime = [sceneUtils moveAvatarPositionTo:AVATAR_SCORE At:myTime];
        
        myTime += 5.5;
        myTime = [sceneUtils moveAvatarPositionTo:AVATAR_PLANET At:myTime];
        
        [sceneUtils hideScoreBoard:gameContext At:myTime];
        
        if([[eventChain getEvent:@"moonClockSetup"] valid])
            [eventChain resetEvents:[NSArray arrayWithObject:@"moonClockSetup"]];
        else
            [eventChain startEvent:@"moonClockSetup" At:5.0];

        if([[eventChain getEvent:@"roundsLeftInfo"] valid])
            [eventChain resetEvents:[NSArray arrayWithObject:@"roundsLeftInfo"]];
        else
            [eventChain startEvent:@"roundsLeftInfo" At:10.0];
    };
    
    return listener;
}

@end
