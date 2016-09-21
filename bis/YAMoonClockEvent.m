//
//  YAMoonClockEvent.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 30.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YALog.h"
#import "YAGameStateMachine.h"
#import "YAChronograph.h"
#import "YAEvent.h"
#import "YAAvatar.h"
#import "YAGameContext.h"
#import "YATerrain.h"
#import "YAColonyMap.h"
#import "YARenderLoop.h"
#import "YAMaterial.h"
#import "YAVector3f.h"
#import "YABlockAnimator.h"
#import "YABasicAnimator.h"
#import "YASceneUtils.h"
#import "YAEventChain.h"
#import "YAImpersonator.h"
#import "YAImpCollector.h"
#import "YAMoonClockEvent.h"

@implementation YAMoonClockEvent {
@private
    YABasicAnimator *rotCover, *rotSun, *rotMoon, *solarRot;
}

- (ListenerEvent) setupEvent
{
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Clock Setup Event");
        YARenderLoop* world = [info objectForKey:@"WORLD"];
        YAImpCollector* ic = [info objectForKey:@"IMPCOLLECTOR"];
        YAEventChain* eventChain = [info objectForKey:@"EVENTCHAIN"];
        
        float myTime = 0;
        
        YABlockAnimator *solarRotHelper;
        
        rotCover = [world createBasicAnimator];
        [rotCover setAsyncProcessing:NO];
        [rotCover setInfluence:Y_AXE];
        [rotCover setInterval:4];
        [rotCover setDelay:myTime];
        [rotCover addListener:[ic.sunCoverImp rotation] factor:360];
        [rotCover addListener:[ic.stickSunImp rotation] factor:360];

        
        rotSun = [world createBasicAnimator];
        [rotSun setAsyncProcessing:NO];
        [rotSun setInfluence:Y_AXE];
        [rotSun setInterval:20];
        [rotSun setDelay:myTime];
        [rotSun addListener:[ic.sunImp rotation] factor:360];

        
        rotMoon = [world createBasicAnimator];
        [rotMoon setAsyncProcessing:NO];
        [rotMoon setInfluence:Y_AXE];
        [rotMoon setInterval:20];
        [rotMoon setDelay:myTime];
        [rotMoon addListener:[ic.moonImp rotation] factor:360];
        [rotMoon addListener:[ic.stickMoonImp rotation] factor:360];

        solarRotHelper = [world createBlockAnimator];
        [solarRotHelper setInterval:25];
        [solarRotHelper setDelay:myTime];
        [solarRotHelper setAsyncProcessing:NO];
        [solarRotHelper addListener:^(float sp, NSNumber *event, int message) {
            YAVector3f* pos = [[YAVector3f alloc] initVals:-0.5f :4 : 0];
            [pos rotate: 360.0f * -sp axis:[[YAVector3f alloc] initYAxe]];
            [[ic.sunImp translation] setVector:pos];
            [[ic.sunCoverImp translation] setVector:pos];
            
            
            [[ic.stickSunImp translation] setVector:pos];
            ic.stickSunImp.translation.y += 1.105;
            
            
            pos = [[YAVector3f alloc] initVals:3 :4: 0];
            [pos rotate: 360.0f * -sp axis:[[YAVector3f alloc] initYAxe]];
            [[ic.moonImp translation] setVector:pos];
           
            [[ic.stickMoonImp translation] setVector:pos];
            ic.stickMoonImp.translation.y += 0.622;

        }];
        
        solarRot = solarRotHelper;
        
        if([[eventChain getEvent:@"moonClockShow"] valid])
            [eventChain resetEvents:[NSArray arrayWithObject:@"moonClockShow"]];
        else
            [eventChain startEvent:@"moonClockShow" At:0.2];


        
    };
    
    return listener;
}

- (ListenerEvent) shutdownEvent;
{
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Clock Shutdown Event");
        YARenderLoop* world = [info objectForKey:@"WORLD"];

        float myTime = 0;
        YABlockAnimator* anim = [world createBlockAnimator];
        
        [anim setOneExecution:true];
        [anim setDelay:myTime];
        [anim setAsyncProcessing:NO];
        [anim addListener:^(float sp, NSNumber *event, int message) {
            [rotCover setDeleteme:true];
            [rotSun setDeleteme:true];
            [rotMoon setDeleteme:true];
            [solarRot setDeleteme:true];
        }];

        
    };
    
    return listener;
}

- (ListenerEvent) showEvent;
{
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Clock Show Event");
        YAImpCollector* ic = [info objectForKey:@"IMPCOLLECTOR"];
        __block YARenderLoop* world = [info objectForKey:@"WORLD"];
        YAEventChain* eventChain = [info objectForKey:@"EVENTCHAIN"];
        __block YAGameContext* gameContext = [info objectForKey:@"GAMECONTEXT"];
        __block YASceneUtils* sceneUtils = [info objectForKey:@"SCENEUTILS"];

        float myTime = 0;
        float duration = 1;
        
        __block float yoffset = 5;
        __block float moonHeight = ic.moonImp.translation.y;
        __block float sunHeight = ic.sunImp.translation.y;
        __block float sunCoverHeight = ic.sunCoverImp.translation.y;
        
        __block float stickMoonHeight =  ic.stickMoonImp.translation.y;
        __block float stickSunHeight = ic.stickSunImp.translation.y;
        
        YABlockAnimator* anim = [world createBlockAnimator];
        [anim setDelay:myTime];
        [anim setProgress:damp];
        [anim setInterval:duration];
        [anim setOnce:true];
        [anim setOnceReset:false];
        [anim setAsyncProcessing:NO];
        [anim addListener:^(float sp, NSNumber *event, int message) {
            [ic.moonImp setVisible:true];
            [ic.sunImp setVisible:true];
            [ic.sunCoverImp setVisible:true];
            [ic.stickSunImp setVisible:true];
            [ic.stickMoonImp setVisible:true];

            [[ic.moonImp translation] setY: moonHeight + (yoffset * (1 - sp))];
            [[ic.stickMoonImp translation] setY: stickMoonHeight + (yoffset * (1 - sp))];

            
            [[ic.sunImp translation] setY: sunHeight + (yoffset * (1 - sp))];
            [[ic.sunCoverImp translation] setY: sunCoverHeight + (yoffset * (1 - sp))];
            [[ic.stickSunImp translation] setY: stickSunHeight + (yoffset * (1 - sp))];

        }];
 
        if([[eventChain getEvent:@"moonClockHide"] valid])
            [eventChain resetEvents:[NSArray arrayWithObject:@"moonClockHide"]];
        else
            [eventChain startEvent:@"moonClockHide" At:9.0];
        
        if([[eventChain getEvent:@"moonClockShutdown"] valid])
            [eventChain resetEvents:[NSArray arrayWithObject:@"moonClockShutdown"]];
        else
            [eventChain startEvent:@"moonClockShutdown" At:9.0f];

        anim = [world createBlockAnimator];
        anim.oneExecution = YES;
        anim.delay = 10.0;
        [anim addListener:^(float sp, NSNumber *event, int message) {

            if(!gameContext.gameOver) {
                if([[eventChain getEvent:@"removeRoundsLeftInfo"] valid])
                    [eventChain resetEvents:[NSArray arrayWithObject:@"removeRoundsLeftInfo"]];
                else
                    [eventChain startEvent:@"removeRoundsLeftInfo"];
                
                if([[eventChain getEvent:@"plotSelectionEvent"] valid])
                    [eventChain resetEvents:[NSArray arrayWithObject:@"plotSelectionEvent"]];
                else
                    [eventChain startEvent:@"plotSelectionEvent"];
            } else {
                [self waitForPlayers:world SceneUtils:sceneUtils GameContext:gameContext];
            }
        }];
        
    };
    
    return listener;
}

- (void) waitForPlayers: (YARenderLoop*) world SceneUtils: (YASceneUtils*) sceneUtils GameContext: (YAGameContext*) gameContext
{
    YAImpersonator* infoTextImp = [sceneUtils genText:[YALog decode:@"GoOn"]];
    [[[infoTextImp material] phongAmbientReflectivity] setVector:sceneUtils.color_red];
    [infoTextImp resize:0.15];
    [[infoTextImp translation] setVector:[[YAVector3f alloc] initVals:-1.29 :-0.98 :5.5]];
    [[infoTextImp material] setEta:0.5];
    [sceneUtils alignToCam:infoTextImp];

    if(gameContext.playerNumber == 0) {
        
        YABlockAnimator* waitForPlayers = [world createBlockAnimator];
        [waitForPlayers setDelay:5.0f];
        [waitForPlayers setOneExecution:YES];
        [waitForPlayers addListener:^(float sp, NSNumber *event, int message) {
            [sceneUtils removeImp:infoTextImp atTime:0];
            if(sceneUtils.gameState != nil)
               [[sceneUtils gameState] nextState];
        }];
    } else {
        
        __block int pA = 0;
        __block int pB = 0;
        __block int pC = 0;
        __block int pD = 0;

        YABlockAnimator* waitForPlayers = [world createBlockAnimator];
        __weak YABlockAnimator* waitForPlayersW = waitForPlayers;
        [waitForPlayers addListener:^(float sp, NSNumber *event, int message) {
            const int evInt = event.intValue;
            
            int player = -1;
            
            if(evInt == MOUSE_DOWN) {
                for(int i = 0; i < gameContext.playerNumber; i++) {
                    if([gameContext deviceIdforPlayer:i]  == 1000)
                        player = i;
                }
            } else if (evInt == GAMEPAD_BUTTON_OK) {
                const int device =(message >> 16);
                for(int i = 0; i < gameContext.playerNumber; i++) {
                    if([gameContext deviceIdforPlayer:i]  == device)
                        player = i;
                }
            }
            
            if(player == 0)
                pA =1;
            else if(player == 1)
                pB = 1;
            else if(player == 2)
                pC = 1;
            else if(player == 3)
                pD = 1;
            
            if(pA + pB + pC + pD >= gameContext.playerNumber)
                waitForPlayersW.deleteme = YES;
            
            if(waitForPlayersW.deleteme) {
                [sceneUtils removeImp:infoTextImp atTime:0];
                if(sceneUtils.gameState != nil)
                    [[sceneUtils gameState] nextState];
            }
        }];
    }
    
}

- (ListenerEvent) hideEvent;
{
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Clock hide Event");
        YAImpCollector* ic = [info objectForKey:@"IMPCOLLECTOR"];
        YARenderLoop* world = [info objectForKey:@"WORLD"];

        float myTime = 0;
        
        float duration = 1;
        __block float yoffset = 5;
        __block float moonHeight = ic.moonImp.translation.y;
        __block float sunHeight = ic.sunImp.translation.y;
        __block float sunCoverHeight = ic.sunCoverImp.translation.y;
        
        __block float stickMoonHeight =  ic.stickMoonImp.translation.y;
        __block float stickSunHeight = ic.stickSunImp.translation.y;

        
        YABlockAnimator* anim = [world createBlockAnimator];
        [anim setDelay:myTime];
        [anim setProgress:damp];
        [anim setInterval:duration];
        [anim setOnce:true];
        [anim setOnceReset:false];
        [anim setAsyncProcessing:NO];
        [anim addListener:^(float sp, NSNumber *event, int message) {
            [ic.moonImp setVisible:true];
            [ic.sunImp setVisible:true];
            [ic.sunCoverImp setVisible:true];
            [ic.stickSunImp setVisible:true];
            [ic.stickMoonImp setVisible:true];
            
            [[ic.moonImp translation] setY: moonHeight + (yoffset * sp)];
            [[ic.sunImp translation] setY: sunHeight + (yoffset * sp)];
            [[ic.sunCoverImp translation] setY: sunCoverHeight + (yoffset * sp)];
            
            [[ic.stickMoonImp translation] setY: stickMoonHeight + (yoffset * sp)];
            [[ic.stickSunImp translation] setY: stickSunHeight + (yoffset * sp)];

            
        }];
        
        
        anim = [world createBlockAnimator];
        [anim setDelay:myTime + duration];
        [anim setOneExecution:true];
        [anim setAsyncProcessing:NO];
        [anim addListener:^(float sp, NSNumber *event, int message) {
            [ic.moonImp setVisible:false];
            [ic.sunImp setVisible:false];
            [ic.sunCoverImp setVisible:false];

            [ic.stickSunImp setVisible:false];
            [ic.stickMoonImp setVisible:false];

            [[ic.moonImp translation] setY:sunHeight];
            [[ic.sunImp translation] setY: sunHeight];
            [[ic.sunCoverImp translation] setY: sunCoverHeight];
            [[ic.stickSunImp translation] setY: stickSunHeight];
            [[ic.stickMoonImp translation] setY: stickMoonHeight];
        }];
        
    };
    
    return listener;
}


@end
