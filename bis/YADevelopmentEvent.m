//
//  YADevelopmentEvent.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 04.03.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import "YALog.h"
#import "YAQuaternion.h"
#import "YABulletEngineTranslator.h"
#import "YASoundCollector.h"
#import "YAStore.h"
#import "YAEvent.h"
#import "YAEventChain.h"
#import "YAImpCollector.h"
#import "YAProbability.h"
#import "YADevelopmentPlayer.h"
#import "YADevelopmentAI.h"
#import "YADevelopmentController.h"
#import "YAFortune.h"
#import "YAChronograph.h"
#import "YABlockAnimator.h"
#import "YARenderLoop.h"
#import "YAAlienRace.h"
#import "YAMaterial.h"
#import "YASceneUtils.h"
#import "YAGameContext.h"
#import "YAStore.h"
#import "YAVector3f.h"
#import "YAImpersonator.h"
#import "YAImpCollector.h"
#import "YAEventChain.h"
#import "YAColonyMap.h"
#import "YASocketEvents.h"
#import "YADevelopmentEvent.h"

#define TIMESPAN_WAIT_COMPUTER_TURN_MESSAGE 2.0f
#define DEVICE_MOUSE 1000
#define ToDegree(x) ((x) * 180.0f / M_PI)

@implementation YADevelopmentEvent {
    YAEventChain* eventChain;
    YAGameContext* gameContext;
    YASceneUtils* sceneUtils;
    YAColonyMap* colonyMap;
    YAStore* store;
    YASoundCollector* soundCollector;
    
    YARenderLoop* world;
    NSArray* players;
    int activePlayerId;
    YAImpersonator *infoTextImp, *titleImp;
    YAImpCollector* impcollector;
    YAChronograph* chronograph;
    YAFortune* fortune;
    float delayTime;
    NSDictionary* _info;
}

- (id) init
{
    self = [super init];
    if(self) {
        chronograph = [[YAChronograph alloc] init];
        _info = nil;
        delayTime = 0;
        fortune = [[YAFortune alloc] init];
    }
    
    return self;
}

- (void) cleanUpBetweenStages
{
    YABulletEngineTranslator* be = [_info objectForKey:@"PHYSICS"];
    
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
            
            startSegment = [[impcollector.starImps objectAtIndex:starIndex++] translation];
            for(YAVector3f* nextSegment in [[rope reverseObjectEnumerator] allObjects]) {
                
                
                float stringLength = [startSegment distanceTo:nextSegment];
                YAImpersonator* starStringImp = [impcollector.ropeSegments objectAtIndex:ropeSegmentIndex++];
                
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



- (ListenerEvent) developmentEvent
{
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Development event started");
        
        _info = info;
        [self setupGlobals:info];
        
        [self cleanUpBetweenStages];
        
        [sceneUtils setAvatarPositionTo:AVATAR_DEVELOPMENT];
        titleImp = self.createTitle;
        
        players = self.getPlayersSortedByWealth;
        
        fortune.sceneUtils = sceneUtils;
        fortune.players = players;
        fortune.impCollector = impcollector;
        fortune.world = world;
        fortune.colonyMap = colonyMap;
        fortune.gameContext = gameContext;
        fortune.store = store;
        fortune.soundCollector = soundCollector;

        int luckyPlayer = [YAProbability selectOneOutOf:4];
        for(YAAlienRace* player in players) { // parallel for
            bool isFortune = player.playerId == luckyPlayer;
            [self startDevelopmentWithPlayer:player Fortune:isFortune];
        }

        activePlayerId = [[players objectAtIndex:0] playerId];
    };
    
    return listener;
}

- (void) cleanup
{
    [world removeImpersonator:titleImp.identifier];
    // NSLog(@"Cleanup");
    
    if([[eventChain getEvent:@"productionEvent"] valid])
        [eventChain resetEvents:[NSArray arrayWithObject:@"productionEvent"]];
    else
        [eventChain startEvent:@"productionEvent"];
}

- (void) activateNextPlayer
{
    int playerNextIndex = -1;
    for(int e = 0; e < players.count; e++) {
        YAAlienRace* ar =[players objectAtIndex:e];
        if (ar.playerId == activePlayerId)
            playerNextIndex = e+1;
    }

    if(playerNextIndex > 0 && playerNextIndex < 4)
        activePlayerId = [[players objectAtIndex:playerNextIndex] playerId];
    else
        [self cleanup];

}

#pragma mark -
#pragma mark Main player development loop
#pragma mark -
-(void) startDevelopmentWithPlayer: (YAAlienRace*) player Fortune: (bool) isFortune;
{
    YABlockAnimator* anim = [world  createBlockAnimator];
    __weak YABlockAnimator* animW = anim;
    __block YABlockAnimator* blinkAnim;
    __block bool blink = NO;
    __block bool playerReady = NO;
    
    // logic for development activity (ai or player)
    __block id<YADevelopmentPlayer> playerDeveloper = nil;
    __block YAChronograph* delayChronograph = nil;

    anim.asyncProcessing = YES; // waiting for game input
    [anim setDelay:0.1];
    [anim addListener:^(float sp, NSNumber *event, int message) {
       
        // if this is not players turn -> skip
        if(activePlayerId != player.playerId)
            return;

        // start socket blinking
        if(!blink) { // need an extra check because anim could be gcd/releases
            blink = YES;
            blinkAnim = [colonyMap blinkPlots:player.playerId];
            return;
        }
        
        if(!playerReady) { // wait for player
            playerReady =[self playerSignaledReady:player Event:event Message:message];
            return;
        } else if(blinkAnim != nil) {
            blinkAnim.deleteme = YES; // end Blinking
            blinkAnim = nil;
        }
        
        // get fortune
        if(delayChronograph == nil) {
            
            if(isFortune)
                delayTime = [fortune fortuneFor: activePlayerId];
            else
                delayTime = 0;
            delayChronograph = [[YAChronograph alloc] init];
            return;
        } else if(delayTime > delayChronograph.getTime) {
            return; // wait for fortune event finished
        }

        // start player activity
        if(playerDeveloper == nil) {
            if([gameContext deviceIdforPlayer:activePlayerId] == -1 ) { // AI plays
                playerDeveloper = [[YADevelopmentAI alloc] initInfo:_info];
                [((YADevelopmentAI*)playerDeveloper) setFortune:fortune];
            } else { // Player plays
                playerDeveloper = [[YADevelopmentController alloc] initInfo:_info];
                [((YADevelopmentController*)playerDeveloper) setFortune:fortune];
            }
            
            [playerDeveloper play: player.playerId];
            return;
        } else if(!playerDeveloper.finished) {
            return;
        }

        // everything done; delete myself and signal next player
        [colonyMap resetFabs];
        animW.deleteme = YES;
        [self activateNextPlayer];
    }];
}

- (bool) playerSignaledReady: (YAAlienRace*) player Event: (NSNumber*) event Message: (int) message
{
    bool result = false;
    
    const int deviceId = [gameContext deviceIdforPlayer:player.playerId];
    const int evInt = event.intValue;
    
    NSString* infoTextString = nil; // nil implies infoTextImp
    
    if(deviceId == -1) { // bot, wait 1.5 sec.
        if(!infoTextImp) {
            infoTextString = [YALog decode:@"computerturn"];
            [chronograph start];
            
        } else if (chronograph.getTime > TIMESPAN_WAIT_COMPUTER_TURN_MESSAGE)
            result = true;
    } else { // wait for signal
        if(!infoTextImp)
            infoTextString = [YALog decode:@"playerturn"];
        else {
            if(
               (deviceId == DEVICE_MOUSE && evInt == MOUSE_DOWN) ||
               (deviceId == (message >> 16) && evInt == GAMEPAD_BUTTON_OK) // REVIEW: check for button down message
               )
                result = true;
        }
    }
    
    if(infoTextString) {
        infoTextImp = [sceneUtils genText:infoTextString];
        [[[infoTextImp material] phongAmbientReflectivity] setVector:sceneUtils.color_red];
        [infoTextImp resize:0.15];
        [[infoTextImp translation] setVector:[[YAVector3f alloc] initVals:-1.2 :-1.0 :5]];
        [[infoTextImp material] setEta:0.5];
        [sceneUtils alignToCam:infoTextImp];
    }
    
    if(result) {
        [world removeImpersonator:infoTextImp.identifier];
        infoTextImp = nil;
    }
    
    return result;
}

-(void) setupGlobals: (NSDictionary*) info
{
    gameContext = [info objectForKey:@"GAMECONTEXT"];
    sceneUtils = [info objectForKey:@"SCENEUTILS"];
    world = [info objectForKey:@"WORLD"];
    colonyMap = [info objectForKey:@"COLONYMAP"];
    impcollector = [info objectForKey:@"IMPCOLLECTOR"];
    eventChain = [info objectForKey:@"EVENTCHAIN"];
    store = [info objectForKey:@"STORE"];
    soundCollector = [info objectForKey:@"SOUNDCOLLECTOR"];
    infoTextImp = nil;
}

- (YAImpersonator*) createTitle
{
    int round = gameContext.round == 0 ? 1 : gameContext.round; // 0 if uninitialized
    NSString* developmentText = [NSString stringWithFormat:@"%@ %d", [YALog decode:@"development"], round];
    YAImpersonator* imp = [sceneUtils genTextBlocked:developmentText];
    [[[imp material] phongAmbientReflectivity] setVector:sceneUtils.color_yellow];
    [imp resize:0.20];
    [[imp translation] setVector:[[YAVector3f alloc] initVals:-0.8 :0.9 :5]];
    [[imp material] setEta:0.5];
    [sceneUtils alignToCam:imp];
    return imp;
}

- (NSArray*) getPlayersSortedByWealth
{
    NSArray* result = [[gameContext playerGameData] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int v1 = [(YAAlienRace*)obj1 totalValue];
        int v2 = [(YAAlienRace*)obj2 totalValue];
        if (v1 > v2)
            return NSOrderedAscending;
        else if (v1 < v2)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    
    return result;
}

@end
